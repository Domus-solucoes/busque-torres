// BUSQUE SERVIÇOS: leitura privada do contato exclusivamente pelo comprador autenticado.
import {createClient} from "https://esm.sh/@supabase/supabase-js@2.57.0";
const env=(k:string)=>Deno.env.get(k)||"";
const db=createClient(env("SUPABASE_URL"),env("SUPABASE_SERVICE_ROLE_KEY"),{auth:{persistSession:false}});
const origins=["https://busquetorres.com.br","https://www.busquetorres.com.br"];
const out=(v:unknown,status=200,origin="https://busquetorres.com.br")=>new Response(JSON.stringify(v),{status,headers:{"Content-Type":"application/json","Access-Control-Allow-Origin":origin,"Access-Control-Allow-Headers":"authorization,content-type,apikey","Access-Control-Allow-Methods":"POST,OPTIONS","Cache-Control":"no-store","Vary":"Origin"}});
const uuid=/^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i;
Deno.serve(async req=>{
 const origin=req.headers.get("origin")||"https://busquetorres.com.br";
 if(!origins.includes(origin))return out({error:"Origem inválida"},403);
 if(req.method==="OPTIONS")return out({},200,origin);
 if(req.method!=="POST")return out({error:"Método inválido"},405,origin);
 if(env("BUSQUE_SERVICOS_PIX_HABILITADO")!=="true")return out({error:"Em homologação"},503,origin);
 try{
  const token=(req.headers.get("authorization")||"").replace(/^Bearer\s+/i,"");
  if(!token)return out({error:"Login obrigatório"},401,origin);
  const {data:auth,error:authError}=await db.auth.getUser(token);
  if(authError||!auth?.user?.id)return out({error:"Sessão inválida"},401,origin);
  const body=await req.json().catch(()=>({}));
  const paymentId=String(body.pagamento_id||"");
  if(!uuid.test(paymentId))return out({error:"Identificador inválido"},422,origin);
  const {data:pay,error:payError}=await db.from("busque_servicos_pagamentos")
   .select("pedido_id,tipo,status,comprador_user_id").eq("id",paymentId).maybeSingle();
  if(payError)throw payError;
  if(!pay||pay.comprador_user_id!==auth.user.id||pay.tipo!=="desbloqueio_contato"||pay.status!=="aprovado")
   return out({error:"Contato não autorizado"},403,origin);
  const {data:pedido,error:pedidoError}=await db.from("busque_servicos_pedidos")
   .select("nome_solicitante,whatsapp,status,expira_em").eq("id",pay.pedido_id).maybeSingle();
  if(pedidoError)throw pedidoError;
  if(!pedido||pedido.status!=="aprovado"||new Date(pedido.expira_em).getTime()<=Date.now())
   return out({error:"Pedido indisponível"},410,origin);
  return out({nome:pedido.nome_solicitante,whatsapp:pedido.whatsapp},200,origin);
 }catch(e){console.error("Contato serviços",e instanceof Error?e.message:"erro");return out({error:"Erro interno"},500,origin)}
});