// BUSQUE SERVIÇOS — função isolada, ainda NÃO implantada.
// Exige webhook transacional antes de habilitar pagamentos reais.
import {createClient} from "https://esm.sh/@supabase/supabase-js@2.57.0";
const env=(k:string)=>Deno.env.get(k)||"";
const db=createClient(env("SUPABASE_URL"),env("SUPABASE_SERVICE_ROLE_KEY"),{auth:{persistSession:false}});
const origins=["https://busquetorres.com.br","https://www.busquetorres.com.br"];
const reply=(data:unknown,status=200,origin="https://busquetorres.com.br")=>new Response(JSON.stringify(data),{status,headers:{"Content-Type":"application/json","Access-Control-Allow-Origin":origin,"Access-Control-Allow-Headers":"content-type,authorization,apikey","Access-Control-Allow-Methods":"POST,OPTIONS","Vary":"Origin"}});
const digits=(v:unknown)=>String(v||"").replace(/\D/g,"");
const uuid=/^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i;
Deno.serve(async req=>{
 const origin=req.headers.get("origin")||"https://busquetorres.com.br";
 if(!origins.includes(origin))return reply({error:"Origem não autorizada"},403);
 if(req.method==="OPTIONS")return reply({},200,origin);
 if(req.method!=="POST")return reply({error:"Método inválido"},405,origin);
 try{
  // Segurança: nunca criar cobrança até reserva transacional e webhook estarem prontos.
  if(env("BUSQUE_SERVICOS_PIX_HABILITADO")!=="true")return reply({error:"PIX em homologação; nenhuma cobrança foi criada."},503,origin);
  const body=await req.json();
  const id=String(body.pedido_id||""),tipo=String(body.tipo||"");
  if(!uuid.test(id)||!["premium","desbloqueio_contato"].includes(tipo))return reply({error:"Dados inválidos"},422,origin);
  const {data:pedido,error}=await db.from("busque_servicos_pedidos").select("id,status,expira_em,limite_orcamentos").eq("id",id).maybeSingle();
  if(error)throw error;
  if(!pedido||pedido.status!=="aprovado"||new Date(pedido.expira_em).getTime()<=Date.now())return reply({error:"Pedido indisponível"},409,origin);
  const nome=String(body.profissional_nome||"").trim().slice(0,100);
  if(!/^[^@\s]+@[^@\s]+\.[^@\s]+$/.test(String(body.email_pagador||"").trim()))return reply({error:"Informe e-mail válido"},422,origin);
  const telefone=digits(body.profissional_whatsapp);
  if(tipo==="desbloqueio_contato"&&(nome.length<2||telefone.length<10||telefone.length>13))return reply({error:"Informe nome e WhatsApp do profissional"},422,origin);
  // Reserva deve ser atômica; não chamar MP sem uma vaga garantida.
  // A compra exige uma prova de titularidade que ainda será implementada.
  // Sem isso, qualquer pessoa pode tentar reservar vagas com dados de terceiros.
  if(env("BUSQUE_SERVICOS_IDENTIDADE_VERIFICADA")!=="true")
   return reply({error:"Validação de titularidade em homologação"},503,origin);
  const {data:reserva,error:reservaError}=await db.rpc("busque_servicos_reservar_pagamento",{
   p_pedido_id:id,p_tipo:tipo,p_profissional_nome:tipo==="premium"?null:nome,
   p_profissional_whatsapp:tipo==="premium"?null:telefone
  });
  if(reservaError)return reply({error:"Não foi possível reservar uma vaga"},409,origin);
  const reservaId=String(reserva?.id||"");
  if(!uuid.test(reservaId))return reply({error:"Reserva indisponível"},503,origin);
  const accessToken=env("MERCADO_PAGO_ACCESS_TOKEN");
  if(!accessToken)return reply({error:"Provedor indisponível"},503,origin);
  // PIX direto: nunca receber valor do cliente; enviar sempre R$ 3,50.
  const mp=await fetch("https://api.mercadopago.com/v1/payments",{
   method:"POST",headers:{"Authorization":"Bearer "+accessToken,"Content-Type":"application/json","X-Idempotency-Key":reservaId},
   body:JSON.stringify({transaction_amount:3.5,description:tipo==="premium"?"Busque Serviços - Premium":"Busque Serviços - Contato",
    payment_method_id:"pix",external_reference:reservaId,
    payer:{email:String(body.email_pagador||"").trim().toLowerCase(),first_name:nome||"Solicitante"}})
  });
  const payment=await mp.json().catch(()=>null);
  if(!mp.ok||!payment?.id)return reply({error:"Não foi possível gerar o PIX. Tente novamente mais tarde."},502,origin);
  const {error:saveError}=await db.from("busque_servicos_pagamentos")
   .update({provedor_pagamento_id:String(payment.id)})
   .eq("id",reservaId).eq("status","pendente");
  if(saveError)return reply({error:"Pagamento criado, aguardando conciliação segura.",referencia:reservaId},503,origin);
  const tx=payment.point_of_interaction?.transaction_data||{};
  return reply({referencia:reservaId,status:"pendente",qr_code:String(tx.qr_code||""),
   qr_code_base64:String(tx.qr_code_base64||""),ticket_url:String(tx.ticket_url||"")},200,origin);
 }catch(e){console.error("busque-servicos-pix",e instanceof Error?e.message:"erro");return reply({error:"Erro interno"},500,origin)}
});
