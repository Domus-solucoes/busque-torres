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
  const secret=env("BUSQUE_SERVICOS_WEBHOOK_TOKEN");
  if(!secret||req.headers.get("x-busque-servicos-token")!==secret)return out({error:"Não autorizado"},401);
  const body=await req.json().catch(()=>({}));
  const id=String(body?.data?.id||"");
  if(!/^[0-9]{1,30}$/.test(id))return out({status:"ignorado"},200);
  const token=env("MERCADO_PAGO_ACCESS_TOKEN");
  if(!token)return out({error:"Provedor indisponível"},503);
  const response=await fetch("https://api.mercadopago.com/v1/payments/"+id,{headers:{"Authorization":"Bearer "+token}});
  if(!response.ok)return out({error:"Consulta ao provedor falhou"},502);
  const mp=await response.json();
  if(String(mp.id)!==id||mp.currency_id!=="BRL")return out({error:"Pagamento incompatível"},409);
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