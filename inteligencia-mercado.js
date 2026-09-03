(()=>{
  "use strict";

  const CIDADE_ID="torres";
  let ultimaChave="";
  let ultimoRegistroEm=0;

  function termoAtual(){
    const input=document.getElementById("searchInput");
    return String(input?.value||"").trim().replace(/\s+/g," ").slice(0,80);
  }

  function quantidadeResultados(){
    const cards=document.querySelectorAll("#cards .card");
    if(cards.length)return cards.length;
    const text=String(document.getElementById("resultCount")?.textContent||"");
    const match=text.match(/\d+/);
    return match?Number(match[0]):0;
  }

  function registrarBuscaEfetiva(){
    const termo=termoAtual();
    if(termo.length<2)return;

    const chave=termo.toLocaleLowerCase("pt-BR");
    const agora=Date.now();
    if(chave===ultimaChave&&agora-ultimoRegistroEm<2000)return;
    ultimaChave=chave;
    ultimoRegistroEm=agora;

    // Espera a busca já existente renderizar os resultados antes de contar.
    setTimeout(async()=>{
      try{
        if(!window.BusqueAPI?.rpc)return;
        await window.BusqueAPI.rpc("registrar_busca_mercado",{
          p_cidade_id:CIDADE_ID,
          p_termo:termo,
          p_resultados:quantidadeResultados()
        });
      }catch(error){
        console.warn("Inteligência de Mercado: busca não registrada.",error?.message||error);
      }
    },40);
  }

  document.addEventListener("click",event=>{
    if(event.target.closest("#searchButton"))registrarBuscaEfetiva();
  });

  document.addEventListener("keydown",event=>{
    if(event.key==="Enter"&&event.target?.id==="searchInput")registrarBuscaEfetiva();
  });
})();
