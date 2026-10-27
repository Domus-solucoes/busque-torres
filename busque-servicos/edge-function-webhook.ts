// Webhook isolado BUSQUE SERVIÇOS. Implantação pendente de homologação.
// Mercado Pago notifica um ID; nunca confiar em status ou valor enviados no POST.
import {createClient} from "https://esm.sh/@supabase/supabase-js@2.57.0";
const env=(k:string)=>Deno.env.get(k)||"";
const db=createClient(env("SUPABASE_URL"),env("SUPABASE_SERVICE_ROLE_KEY"),{auth:{persistSession:false}});
const out=(v:unknown,status=200)=>new Response(JSON.stringify(v),{status,headers:{"Content-Type":"application/json"}});
Deno.serve(async req=>{
 if(req.method!=="POST")return out({error:"Método inválido"},405);
 if(env("BUSQUE_SERVICOS_PIX_HABILITADO")!=="true")return out({status:"desabilitado"},503);
 try{
  // Defesa adicional: endpoint exclusivo, sem reutilizar webhook das assinaturas.
  // O Mercado Pago assina webhooks com x-signature e x-request-id.
  // Não aceitar um header privado arbitrário: o provedor não o envia.
  const secret=env("BUSQUE_SERVICOS_MP_WEBHOOK_SECRET");
  const signature=req.headers.get("x-signature")||"";
  const requestId=req.headers.get("x-request-id")||"";
  const parts=Object.fromEntries(signature.split(",").map(x=>x.trim().split("=",2)));
  const ts=String(parts.ts||""),hash=String(parts.v1||"");
  if(!secret||!/^\\d{10,16}$/.test(ts)||!/^[0-9a-f]{64}$/i.test(hash)||!requestId)
   return out({error:"Assinatura ausente"},401);
  const body=await req.json().catch(()=>({}));
  const id=String(body?.data?.id||"");
  if(!/^[0-9]{1,30}$/.test(id))return out({status:"ignorado"},200);
  const urlId=new URL(req.url).searchParams.get("data.id")||id;
  if(urlId!==id)return out({error:"Identificador divergente"},401);
  // Rejeita notificações antigas ou com relógio muito distante (anti-replay).
  const epoch=Number(ts), seconds=ts.length>10?epoch/1000:epoch;
  if(!Number.isFinite(seconds)||Math.abs(Date.now()/1000-seconds)>300)
   return out({error:"Notificação fora da janela de validade"},401);
  const manifest="id:"+id.toLowerCase()+";request-id:"+requestId+";ts:"+ts+";";
  const key=await crypto.subtle.importKey("raw",new TextEncoder().encode(secret),{name:"HMAC",hash:"SHA-256"},false,["sign"]);
  const signed=new Uint8Array(await crypto.subtle.sign("HMAC",key,new TextEncoder().encode(manifest)));
  const expected=Array.from(signed).map(b=>b.toString(16).padStart(2,"0")).join("");
  let diff=0;for(let i=0;i<64;i++)diff|=expected.charCodeAt(i)^hash.toLowerCase().charCodeAt(i);
  if(diff!==0)return out({error:"Assinatura inválida"},401);
  const token=env("MERCADO_PAGO_ACCESS_TOKEN");
  if(!token)return out({error:"Provedor indisponível"},503);
  const response=await fetch("https://api.mercadopago.com/v1/payments/"+id,{headers:{"Authorization":"Bearer "+token}});
  if(!response.ok)return out({error:"Consulta ao provedor falhou"},502);
  const mp=await response.json();
  if(String(mp.id)!==id||mp.currency_id!=="BRL"||mp.payment_method_id!=="pix")return out({error:"Pagamento incompatível"},409);
  const ref=String(mp.external_reference||"");
  if(!/^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i.test(ref))return out({status:"ignorado"},200);
  const map:Record<string,string>={approved:"aprovado",pending:"pendente",in_process:"pendente",rejected:"rejeitado",cancelled:"cancelado",refunded:"reembolsado",charged_back:"reembolsado"};
  const status=map[String(mp.status||"")];
  if(!status)return out({status:"ignorado"},200);
  const cents=Math.round(Number(mp.transaction_amount)*100);
  const {data,error}=await db.rpc("busque_servicos_confirmar_pagamento",{p_referencia:ref,p_provedor_id:id,p_status:status,p_valor_centavos:cents});
  if(error){console.error("Erro conciliação",error.message);return out({error:"Falha de conciliação"},503)}
  return out(data);
 }catch(e){console.error("Webhook Serviços",e instanceof Error?e.message:"erro");return out({error:"Erro interno"},500)}
});