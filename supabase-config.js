"use strict";
const BUSQUE_SUPABASE_URL = "https://xwkmsqawiimouilldwit.supabase.co";
const BUSQUE_SUPABASE_KEY = "sb_publishable_yDaiyt-jns7xIhSd5MHrrQ_jcSi_r_s";

const BusqueAPI = (() => {
  const headers = {
    apikey: BUSQUE_SUPABASE_KEY,
    Authorization: `Bearer ${BUSQUE_SUPABASE_KEY}`,
    "Content-Type": "application/json"
  };

  async function request(path, options={}) {
    const response = await fetch(`${BUSQUE_SUPABASE_URL}/rest/v1/${path}`, {
      ...options,
      headers: {...headers, ...(options.headers||{})}
    });
    const raw = await response.text();
    let data = null;
    if(raw) { try { data=JSON.parse(raw); } catch { data=raw; } }
    if(!response.ok) {
      const message = data?.message || data?.hint || `Erro ${response.status} ao acessar a Central de Dados.`;
      throw new Error(message);
    }
    return data;
  }

  function rpc(name, params={}) {
    return request(`rpc/${encodeURIComponent(name)}`, {method:"POST", body:JSON.stringify(params)});
  }

  function select(resource, query="") {
    return request(`${resource}${query ? `?${query}` : ""}`, {method:"GET"});
  }

  async function invokeFunction(name, payload={}) {
    const response = await fetch(`${BUSQUE_SUPABASE_URL}/functions/v1/${encodeURIComponent(name)}`, {
      method: "POST",
      headers: {
        apikey: BUSQUE_SUPABASE_KEY,
        Authorization: `Bearer ${BUSQUE_SUPABASE_KEY}`,
        "Content-Type": "application/json"
      },
      body: JSON.stringify(payload)
    });
    const raw = await response.text();
    let data = null;
    if(raw) { try { data=JSON.parse(raw); } catch { data=raw; } }
    if(!response.ok) {
      throw new Error(data?.erro || data?.detalhe || data?.message || `Erro ${response.status} na função ${name}.`);
    }
    return data;
  }

  return {rpc, select, invokeFunction};
})();
