const PROJECT = "https://wqfkysoodjyweanhsquk.supabase.co";
const ORIGIN = "https://busque-caxias-rs.martoandre-a-j2.workers.dev";
const PUBLISHABLE = "sb_publishable_lpHHnebV1KE0Gj8ojfLBiw_N7wfUjIf";
const limits: Record<string,[number,number]> = {
  nome:[3,100],categoria:[2,60],subcategoria:[2,100],descricao:[10,600],whatsapp:[10,15],
  email:[0,200],instagram:[0,200],site:[0,500],bairro:[0,120],endereco:[0,300],
  horario:[0,300],produtos:[0,1000],servicos:[0,1000],palavras_chave:[0,500]
};

Deno.serve(async (req: Request) => {
  const origin = req.headers.get("origin");
  const headers: Record<string,string> = { "Content-Type":"application/json", "Cache-Control":"no-store", "Vary":"Origin" };
  if (origin === ORIGIN) {
    headers["Access-Control-Allow-Origin"] = ORIGIN;
    headers["Access-Control-Allow-Methods"] = "POST, OPTIONS";
    headers["Access-Control-Allow-Headers"] = "apikey, content-type";
  }
  const reply = (data: unknown,status=200) => new Response(JSON.stringify(data),{status,headers});
  if (origin !== ORIGIN) return reply({erro:"Origem não autorizada."},403);
  if (req.method === "OPTIONS") return new Response(null,{status:204,headers});
  if (req.method !== "POST") return reply({erro:"Método não permitido."},405);
  // Endpoint público: a chave identifica o aplicativo, não atribui privilégios ao visitante.
  // Toda a autorização de escrita fica no fluxo limitado de cadastro pendente.
  if (req.headers.get("apikey") !== PUBLISHABLE) return reply({erro:"Aplicativo não autorizado."},401);
  if (!req.headers.get("content-type")?.toLowerCase().startsWith("application/json")) return reply({erro:"Formato inválido."},415);
  try {
    const reader = req.body?.getReader();
    if (!reader) return reply({erro:"Dados obrigatórios."},400);
    const chunks: Uint8Array[] = []; let size=0;
    while (true) {
      const {done,value}=await reader.read(); if(done) break;
      size+=value.byteLength;
      if(size>16384) { await reader.cancel(); return reply({erro:"Dados acima do limite."},413); }
      chunks.push(value);
    }
    const bytes=new Uint8Array(size);let offset=0;
    for(const chunk of chunks) {bytes.set(chunk,offset);offset+=chunk.length;}
    let body: Record<string,unknown>;
    try { body=JSON.parse(new TextDecoder().decode(bytes)); } catch { return reply({erro:"Dados inválidos."},400); }
    if (!body || Array.isArray(body) || typeof body !== "object") return reply({erro:"Dados inválidos."},400);
    const allowed = new Set([...Object.keys(limits),"aceite","tentativa","website"]);
    if(Object.keys(body).some(key=>!allowed.has(key))) return reply({erro:"Campos não permitidos."},400);
    if(typeof body.website!=="string" || body.website.length>200) return reply({erro:"Dados inválidos."},400);
    if(body.website) return reply({ok:true});
    if(body.aceite!==true || typeof body.tentativa!=="string" || !/^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/.test(body.tentativa)) return reply({erro:"Confirme a autorização para enviar o cadastro."},400);
    const data: Record<string,string|boolean> = {aceite:true};
    for(const [field,[min,max]] of Object.entries(limits)) {
      const value=body[field]??"";
      if(typeof value!=="string") return reply({erro:"Confira os campos do cadastro."},400);
      const clean=value.trim();
      if(clean.length<min || clean.length>max) return reply({erro:"Confira o tamanho dos campos do cadastro."},400);
      data[field]=clean;
    }
    if(!/^[0-9]{10,15}$/.test(data.whatsapp as string)) return reply({erro:"Informe WhatsApp com DDD, usando somente números."},400);
    if(data.email && !/^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}$/i.test(data.email as string)) return reply({erro:"Confira o e-mail."},400);
    if(data.site && !/^https?:\/\/[^\s]+$/i.test(data.site as string)) return reply({erro:"Informe o site com https://."},400);
    if(data.instagram && !/^(@?[a-z\d._]+|https?:\/\/[^\s]+)$/i.test(data.instagram as string)) return reply({erro:"Confira o Instagram."},400);
    if(Deno.env.get("SUPABASE_URL")!==PROJECT) return reply({erro:"Configuração indisponível."},503);
    let key: string|undefined;
    try { key=JSON.parse(Deno.env.get("SUPABASE_SECRET_KEYS")||"{}").default; } catch {}
    key ||= Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");
    if(!key) return reply({erro:"Configuração indisponível."},503);
    const ip=req.headers.get("cf-connecting-ip")||req.headers.get("x-forwarded-for")?.split(",").pop()?.trim()||"unknown";
    const digest=await crypto.subtle.digest("SHA-256",new TextEncoder().encode(key+"|caxias|"+ip));
    const ipHash=Array.from(new Uint8Array(digest),byte=>byte.toString(16).padStart(2,"0")).join("");
    const backendHeaders: Record<string,string> = {apikey:key,"Content-Type":"application/json"};
    if(key.startsWith("eyJ")) backendHeaders.Authorization="Bearer "+key;
    const response=await fetch(PROJECT+"/rest/v1/rpc/caxias_receber_cadastro",{method:"POST",headers:backendHeaders,
      body:JSON.stringify({p_dados:data,p_ip_hash:ipHash,p_tentativa:body.tentativa})});
    if(!response.ok) return reply({erro:"Não foi possível concluir o cadastro. Confira os dados e tente novamente."},400);
    const result=await response.json();
    if(result.limite) {headers["Retry-After"]="3600";return reply({erro:"Limite temporário de cadastros. Tente novamente mais tarde."},429);}
    if(result.ok!==true) return reply({erro:"Não foi possível confirmar o envio."},503);
    return reply({ok:true});
  } catch { return reply({erro:"Não foi possível enviar agora. Tente novamente."},503); }
});
