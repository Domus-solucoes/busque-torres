"use strict";
(function(){
  const SITES={
    torres:{id:"torres",name:"Busque Torres",brandCity:"TORRES",brandLabel:"Torres",city:"Torres",cityUf:"Torres/RS",uf:"RS",defaultHero:"assets/torres-hero.webp"},
    caxias:{id:"caxias",name:"Busque Caxias",brandCity:"CAXIAS",brandLabel:"Caxias",city:"Caxias do Sul",cityUf:"Caxias do Sul/RS",uf:"RS",defaultHero:""}
  };

  function normalize(v){
    v=String(v||"").toLowerCase().trim();
    return Object.prototype.hasOwnProperty.call(SITES,v)?v:"";
  }

  function detect(){
    const qs=normalize(new URLSearchParams(location.search).get("cidade"));
    if(qs)return qs;
    const host=String(location.hostname||"").toLowerCase();
    if(host.includes("caxias"))return "caxias";
    return "torres";
  }

  const activeId=detect();
  const current=()=>SITES[activeId];

  function shouldCarryCityParam(){
    return location.protocol==="file:" || location.hostname.endsWith("workers.dev") || new URLSearchParams(location.search).has("cidade");
  }

  function cityUrl(path,id=activeId){
    const u=new URL(path||location.pathname,location.href);
    if(shouldCarryCityParam())u.searchParams.set("cidade",id);
    return u.href;
  }

  function replaceText(value){
    const s=current();
    let text=String(value??"");
    text=text.replace(/BUSQUE TORRES/g,`BUSQUE ${s.brandCity}`);
    text=text.replace(/Busque Torres/g,s.name);
    text=text.replace(/Torres\/RS/g,s.cityUf);
    text=text.replace(/\bTorres\b/g,s.city);
    return text;
  }

  function rewriteInternalLinks(){
    if(!shouldCarryCityParam())return;
    document.querySelectorAll('a[href]').forEach(a=>{
      const raw=a.getAttribute('href')||"";
      if(!raw || raw.startsWith('#') || /^(mailto:|tel:|javascript:)/i.test(raw))return;
      try{
        const u=new URL(raw,location.href);
        if(u.origin!==location.origin)return;
        if(!/\.html(?:$|[?#])/.test(u.pathname+u.search+u.hash) && !u.pathname.endsWith('/'))return;
        u.searchParams.set("cidade",activeId);
        a.href=u.href;
      }catch{}
    });
  }

  function applyBranding(){
    const s=current();
    document.documentElement.dataset.busqueCity=activeId;

    if(document.title)document.title=replaceText(document.title);
    document.querySelectorAll('meta[name="description"],meta[property="og:title"],meta[property="og:description"]').forEach(meta=>{
      if(meta.hasAttribute('content'))meta.setAttribute('content',replaceText(meta.getAttribute('content')||""));
    });

    // O painel possui duas cidades no mesmo seletor e cuida da própria identidade.
    // Não fazemos substituição global nele para não transformar as duas opções em uma só.
    const isAdmin=Boolean(document.getElementById("adminCity"));
    if(!isAdmin && document.body){
      const walker=document.createTreeWalker(document.body,NodeFilter.SHOW_TEXT);
      const nodes=[];
      while(walker.nextNode())nodes.push(walker.currentNode);
      for(const node of nodes)node.nodeValue=replaceText(node.nodeValue);

      document.querySelectorAll("[title],[aria-label],[placeholder],[content]").forEach(el=>{
        for(const attr of ["title","aria-label","placeholder","content"]){
          if(el.hasAttribute(attr))el.setAttribute(attr,replaceText(el.getAttribute(attr)||""));
        }
      });

      // Corrige marcas que têm 'Busque' e o nome da cidade em nós HTML separados.
      document.querySelectorAll(".brand-name b").forEach(el=>el.textContent=s.brandCity);
      document.querySelectorAll(".brand-mark").forEach(el=>el.textContent=activeId==="caxias"?"BC":"BT");
      document.querySelectorAll("a.brand > b").forEach(el=>el.textContent=s.brandLabel);
      document.querySelectorAll(".mobile-brand-strip strong").forEach(el=>el.textContent=`BUSQUE ${s.brandCity}`);
      document.querySelectorAll(".marca-texto").forEach(el=>el.textContent=s.name);
    }

    rewriteInternalLinks();
  }

  window.BusqueSite={sites:SITES,current,activeId,cityUrl,applyBranding,replaceText};

  if(document.readyState==="loading"){
    document.addEventListener("DOMContentLoaded",applyBranding,{once:true});
  }else{
    applyBranding();
  }
})();
