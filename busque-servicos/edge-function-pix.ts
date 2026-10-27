// BUSQUE SERVIÇOS — função isolada, ainda NÃO implantada.
// Exige webhook transacional antes de habilitar pagamentos reais.
import {createClient} from "https://esm.sh/@supabase/supabase-js@2.57.0";
const env=(k:string)=>Deno.env.get(k)||"";
const db=createClient(env("SUPABASE_URL"),env("SUPABASE_SERVICE_ROLE_KEY"),{auth:{persistSession:false}});
const origins=["https://busquetorres.com.br","https://www.busquetorres.com.br","https://raw.githack.com"];
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
  // TODO: executar RPC transacional de reserva com limite de 3 Premium / 3 ou 5 contatos.
  // TODO: validar pagador e criar pagamento Mercado Pago PIX com valor fixo 3.50 BRL.
  // TODO: gravar referência única e identificador MP para webhook.
  // Nunca substituir os TODOs por chamadas isoladas de contagem + insert (race condition).
  return reply({error:"Reserva transacional ainda não habilitada"},503,origin);
 }catch(e){console.error("busque-servicos-pix",e instanceof Error?e.message:"erro");return reply({error:"Erro interno"},500,origin)}
});
