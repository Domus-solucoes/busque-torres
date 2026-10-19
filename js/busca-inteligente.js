// BUSQUE TORRES — módulo isolado de sugestões de busca.
// Não escreve no Supabase nem altera cadastros. Integração com a home após testes.
(function(global){
  'use strict';
  const normalize = value => String(value ?? '').normalize('NFD').replace(/[\u0300-\u036f]/g,'').toLowerCase().replace(/[^a-z0-9]+/g,' ').trim();
  const catalog = [
    {category:'construcao',sub:'Energia solar fotovoltaica',terms:['painel solar','placa solar','energia solar','fotovoltaica','inversor solar','instalacao solar']},
    {category:'casa',sub:'Limpeza residencial',terms:['diarista','faxina','faxineira','limpeza de casa','limpeza residencial']},
    {category:'climatização',sub:'Ar-condicionado',terms:['ar condicionado','split','climatizacao','instalacao de ar','conserto de ar condicionado']},
    {category:'casa',sub:'Manutenção de piscinas',terms:['piscina','piscineiro','limpeza de piscina','manutencao de piscina']},
    {category:'saude',sub:'Odontologia',terms:['dentista','odontologia','tratamento dentario','clinica odontologica']},
    {category:'servicos',sub:'Serviços elétricos',terms:['eletricista','instalacao eletrica','manutencao eletrica']}
  ];
  function suggestions(query,limit=3){
    const q=normalize(query);
    if(!q)return [];
    return catalog.map(item=>{
      const terms=[...item.terms,item.category,item.sub].map(normalize);
      const score=Math.max(...terms.map(term=>term===q?100:term.includes(q)&&q.length>=3?65:q.includes(term)&&term.length>=4?55:q.split(' ').filter(word=>word.length>2&&term.includes(word)).length*12));
      return {...item,score};
    }).filter(x=>x.score>0).sort((a,b)=>b.score-a.score).slice(0,limit);
  }
  function expandTerms(query){
    const q=normalize(query),result=new Set([q]);
    suggestions(q,2).filter(x=>x.score>=55).forEach(x=>x.terms.forEach(t=>result.add(normalize(t))));
    return [...result].filter(Boolean);
  }
  function rankBusiness(business,query){
    const q=normalize(query);if(!q)return 0;
    const fields=[['nome',8],['palavras_chave',6],['subcategoria',5],['categoria',4],['descricao',2]];
    const variants=expandTerms(q);
    return fields.reduce((score,[key,weight])=>{
      const value=normalize(business?.[key]);
      if(!value)return score;
      if(value.includes(q))return score+weight*10;
      return score+Math.min(variants.filter(term=>term!==q&&term.length>3&&value.includes(term)).length,3)*weight;
    },0);
  }
  global.BusqueBuscaInteligente=Object.freeze({normalize,suggestions,expandTerms,rankBusiness});
})(typeof window!=='undefined'?window:globalThis);
