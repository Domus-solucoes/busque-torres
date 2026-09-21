"use strict";
const CARDAPIO_SESSION_KEY="busque_cardapio_empresa_session_v1";
const CardapioCore=(()=>{
  const base=BUSQUE_SUPABASE_URL;
  const key=BUSQUE_SUPABASE_KEY;
  const money=v=>Number(v||0).toLocaleString("pt-BR",{style:"currency",currency:"BRL"});
  const esc=v=>String(v??"").replace(/[&<>"']/g,m=>({"&":"&amp;","<":"&lt;",">":"&gt;",'"':"&quot;","'":"&#039;"}[m]));
  const fmt=v=>v?new Date(v).toLocaleString("pt-BR",{day:"2-digit",month:"2-digit",hour:"2-digit",minute:"2-digit"}):"—";
  const read=()=>{try{return JSON.parse(localStorage.getItem(CARDAPIO_SESSION_KEY)||"null")}catch{return null}};
  const save=s=>{if(!s?.access_token||!s?.refresh_token)return;const p={access_token:s.access_token,refresh_token:s.refresh_token,expires_at:s.expires_at||null,expires_in:s.expires_in||null,token_type:s.token_type||"bearer",user:s.user||null};localStorage.setItem(CARDAPIO_SESSION_KEY,JSON.stringify(p));return p};
  const clear=()=>localStorage.removeItem(CARDAPIO_SESSION_KEY);
  async function authRequest(path,body){
    const r=await fetch(base+path,{method:"POST",headers:{apikey:key,"Content-Type":"application/json"},body:JSON.stringify(body)});
    const d=await r.json().catch(()=>({}));
    if(!r.ok)throw Object.assign(new Error(d.msg||d.message||d.error_description||"Falha de autenticação."),{status:r.status,data:d});
    return d;
  }
  async function signIn(email,password){const d=await authRequest("/auth/v1/token?grant_type=password",{email,password});save(d);return d}
  async function signUp(email,password,data){const d=await authRequest("/auth/v1/signup",{email,password,data});if(d.access_token)save(d);return d}
  async function refresh(){const s=read();if(!s?.refresh_token)throw new Error("Sessão encerrada.");const d=await authRequest("/auth/v1/token?grant_type=refresh_token",{refresh_token:s.refresh_token});save(d);return d}
  async function session(){let s=read();if(!s?.access_token)return null;if(s.expires_at&&Number(s.expires_at)*1000<Date.now()+60000){try{await refresh();s=read()}catch{clear();return null}}return s}
  async function fn(name,{method="POST",body=null,auth=false,form=null,query=""}={}){
    let s=auth?await session():null;const headers={apikey:key};if(auth&&s?.access_token)headers.Authorization="Bearer "+s.access_token;
    let payload;if(form)payload=form;else if(body!==null){headers["Content-Type"]="application/json";payload=JSON.stringify(body)}
    const doReq=()=>fetch(base+"/functions/v1/"+name+query,{method,headers,body:payload});let r=await doReq();
    if(r.status===401&&auth&&s?.refresh_token){await refresh();s=read();headers.Authorization="Bearer "+s.access_token;r=await doReq()}
    const d=await r.json().catch(()=>({}));if(!r.ok||d?.ok===false)throw Object.assign(new Error(d?.detalhe||d?.error||d?.erro||"Erro na operação."),{status:r.status,data:d});return d;
  }
  async function toWebp(file,maxBytes=262144){
    if(file.type==="image/webp"&&file.size<=maxBytes)return file;const bmp=await createImageBitmap(file);let scale=Math.min(1,1600/Math.max(bmp.width,bmp.height)),quality=.86,blob=null;
    for(let attempt=0;attempt<8;attempt++){const w=Math.max(1,Math.round(bmp.width*scale)),h=Math.max(1,Math.round(bmp.height*scale));const canvas=document.createElement("canvas");canvas.width=w;canvas.height=h;canvas.getContext("2d").drawImage(bmp,0,0,w,h);blob=await new Promise(res=>canvas.toBlob(res,"image/webp",quality));if(blob&&blob.size<=maxBytes)break;quality=Math.max(.5,quality-.08);scale*=.88}
    bmp.close();if(!blob||blob.size>maxBytes)throw new Error("Não foi possível reduzir a imagem para 256 KB.");return new File([blob],(file.name||"imagem").replace(/\.[^.]+$/,"" )+".webp",{type:"image/webp"});
  }
  return {money,esc,fmt,read,save,clear,session,signIn,signUp,refresh,fn,toWebp};
})();
