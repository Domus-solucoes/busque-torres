import { createClient } from "https://esm.sh/@supabase/supabase-js@2.57.0";
const url=Deno.env.get("SUPABASE_URL")!, key=Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
const db=createClient(url,key,{auth:{persistSession:false}});
const allowed=["https://busquetorres.com.br","https://www.busquetorres.com.br","https://raw.githack.com"];
const cors=(origin:string|null)=>({"Access-Control-Allow-Origin":origin&&allowed.includes(origin)?origin:"https://busquetorres.com.br","Access-Control-Allow-Headers":"authorization,apikey,content-type","Access-Control-Allow-Methods":"POST,OPTIONS","Vary":"Origin"});
const out=(body:unknown,status=200,origin:string|null=null)=>new Response(JSON.stringify(body),{status,headers:{"Content-Type":"application/json",...cors(origin)}});
const str=(v:unknown,max:number)=>typeof v==="string"?v.trim().slice(0,max+1):"";
Deno.serve(async(req)=>{
 const origin=req.headers.get("origin");if(req.method==="OPTIONS")return new Response(null,{status:204,headers:cors(origin)});
 if(req.method!=="POST")return out({error:"Método inválido"},405,origin);
 if(origin&&!allowed.includes(origin))return out({error:"Origem não autorizada"},403,origin);
 try{
 const body=await req.json();const action=body?.action;
 if(action==="submit"){
  const turnstileSecret=Deno.env.get("BUSQUE_SERVICOS_TURNSTILE_SECRET");
  if(!turnstileSecret)return out({error:"Envio temporariamente indisponível: proteção anti-spam não configurada."},503,origin);
  const captcha=str(body.captcha,4096);
  if(!captcha)return out({error:"Confirme a verificação anti-spam."},400,origin);
  const cfIp=req.headers.get("cf-connecting-ip")||"";
  const captchaResp=await fetch("https://challenges.cloudflare.com/turnstile/v0/siteverify",{method:"POST",headers:{"Content-Type":"application/json"},body:JSON.stringify({secret:turnstileSecret,response:captcha,remoteip:cfIp})});
  const captchaResult=await captchaResp.json().catch(()=>({success:false}));
  if(!captchaResult.success)return out({error:"Verificação anti-spam não aprovada."},403,origin);
  // Fase 1: fotos são enviadas por esta função ao bucket privado.
  if(str(body.website,200))return out({error:"Não foi possível enviar"},400,origin);
  const title=str(body.titulo,120),desc=str(body.descricao,2000),bairro=str(body.bairro,100),nome=str(body.nome,100),whatsapp=str(body.whatsapp,20).replace(/\D/g,""),endereco=str(body.endereco,180);
  const limite=Number(body.limite),dias=Number(body.dias);
  if(title.length<5||title.length>120||desc.length<10||desc.length>2000||bairro.length<2||bairro.length>100||nome.length<2||nome.length>100||whatsapp.length<10||whatsapp.length>13||![3,5].includes(limite)||![3,5].includes(dias)||body.aceite!==true)return out({error:"Confira os campos e o aceite dos termos."},400,origin);
  if(!Array.isArray(body.fotos)||body.fotos.length>3)return out({error:"Máximo de três fotos."},400,origin);
  const pics: {bytes:Uint8Array,mime:string,ext:string}[]=[];
  for(const f of body.fotos){if(!f||typeof f.data!=="string"||f.data.length>7_000_000||!["image/jpeg","image/png","image/webp"].includes(f.mime))return out({error:"Foto inválida (máximo 5 MB)."},400,origin);
   const bytes=Uint8Array.from(atob(f.data),c=>c.charCodeAt(0));if(bytes.length>5_242_880)return out({error:"Foto excede 5 MB."},400,origin);
   const signatures={"image/jpeg":[255,216,255],"image/png":[137,80,78,71],"image/webp":[82,73,70,70]} as Record<string,number[]>;if(!signatures[f.mime].every((n,i)=>bytes[i]===n))return out({error:"Formato de imagem inválido."},400,origin);
   pics.push({bytes,mime:f.mime,ext:f.mime==="image/jpeg"?"jpg":f.mime==="image/png"?"png":"webp"});}
  const id=crypto.randomUUID();const paths:string[]=[];
  for(let i=0;i<pics.length;i++){const p=pics[i],path=`${id}/${i}.${p.ext}`;const {error}=await db.storage.from("busque-servicos-fotos").upload(path,p.bytes,{contentType:p.mime,upsert:false});if(error){for(const prev of paths)await db.storage.from("busque-servicos-fotos").remove([prev]);return out({error:"Falha ao enviar fotos."},500,origin)}paths.push(path)}
  const {error}=await db.from("busque_servicos_pedidos").insert({id,titulo:title,descricao:desc,bairro,nome_solicitante:nome,whatsapp,endereco_privado:endereco||null,fotos_paths:paths,limite_orcamentos:limite,duracao_dias:dias,aceite_termos_versao:"2026-10-27",aceite_privacidade_versao:"2026-10-27",aceite_em:new Date().toISOString()});
  if(error){if(paths.length)await db.storage.from("busque-servicos-fotos").remove(paths);return out({error:"Falha ao salvar pedido."},500,origin)}
  return out({ok:true,id,status:"pendente"},200,origin);
 }
 const bearer=req.headers.get("authorization")?.replace(/^Bearer\s+/i,"");if(!bearer)return out({error:"Login necessário"},401,origin);
 const {data:{user},error:authError}=await db.auth.getUser(bearer);if(authError||!user)return out({error:"Sessão inválida"},401,origin);
 const {data:admin}=await db.from("administradores").select("user_id,ativo").eq("user_id",user.id).eq("ativo",true).maybeSingle();
 if(!admin)return out({error:"Acesso administrativo negado"},403,origin);
 if(action==="list"){const {data,error}=await db.from("busque_servicos_pedidos").select("*").order("criado_em",{ascending:false}).limit(200);if(error)throw error;return out({pedidos:data},200,origin)}
 if(action==="review"){if(!["aprovado","rejeitado"].includes(body.status)||typeof body.id!=="string")return out({error:"Dados inválidos"},400,origin);
  const {data:current}=await db.from("busque_servicos_pedidos").select("id,status,duracao_dias").eq("id",body.id).maybeSingle();if(!current||current.status!=="pendente")return out({error:"Pedido não está pendente"},409,origin);
  const now=new Date(),update=body.status==="aprovado"?{status:"aprovado",aprovado_em:now.toISOString(),expira_em:new Date(now.getTime()+current.duracao_dias*86400000).toISOString(),revisado_em:now.toISOString(),revisado_por:user.id}:{status:"rejeitado",revisado_em:now.toISOString(),revisado_por:user.id,motivo_rejeicao:str(body.motivo,500)||null};
  const {data,error}=await db.from("busque_servicos_pedidos").update(update).eq("id",body.id).eq("status","pendente").select("id,status").maybeSingle();if(error)throw error;if(!data)return out({error:"Pedido já foi revisado"},409,origin);return out({ok:true,pedido:data},200,origin);
 }
 return out({error:"Ação desconhecida"},400,origin);
 }catch(e){console.error("busque-servicos-etapa1",e);return out({error:"Erro interno"},500,origin)}
});