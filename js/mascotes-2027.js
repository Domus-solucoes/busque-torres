/* Busque Torres · Mascotes 2027 · cenas vetoriais sob demanda.
   Natal existente preservado ate 25/12/2026.
   Nao carrega a biblioteca inteira; constroi apenas 1 SVG a cada acesso. */
(()=>{"use strict";
const TODAY=(()=>{const d=new Intl.DateTimeFormat("en-US",{timeZone:"America/Sao_Paulo",year:"numeric",month:"2-digit",day:"2-digit"}).formatToParts(new Date());const part=k=>d.find(x=>x.type===k).value;return part("year")+"-"+part("month")+"-"+part("day")})();
let PREVIEW=window.BT_MASCOTES_PREVIEW||null;
if(!PREVIEW&&TODAY<"2026-12-26")return;
const stage=document.getElementById("bt-natal");if(!stage)return;
const THEMES=["café","chimarrão","sorvete","melancia","bola","presente","livro","violão","flores","coração","estrela","guarda-chuva","pipa","balão","câmera","bicicleta","skate","prancha","coco","pizza","pipoca","chapéu","óculos","medalha","folha","concha","barco","tambor","lua","peixe","farol","castelo de areia","caiaque","pesca","mergulho","piquenique","borboletas","jardinagem","balonismo","corrida","patins","basquete","tênis","cinema","pintura","música","chocolate quente","tricô","fotografia","aventura","mar","pôr do sol","arco-íris","amigos","passeio","praça","sanfona","festa","cachoeira","livraria","conchas na praia","bodyboard","caranguejo","frisbee","girassóis","joaninhas","estrelas do céu","robô","carrinhos","origami","quebra-cabeça","futebol","boliche","musculação","peteca","maracas","flauta","chá","panquecas","cupcakes","patinete","jogo de tabuleiro","desenho","acampamento","dança","coração de flores","skate na praia","aventura na lagoa","artesanato","passeio ao farol"];
const ICONS=["☕","🧉","🍦","🍉","⚽","🎁","📖","🎸","🌷","♥","★","☂","🪁","🎈","📷","🚲","🛹","🏄","🥥","🍕","🍿","👒","🕶","🏅","🍃","🐚","⛵","🥁","☾","🐟","⚓","🏖","🛶","🐟","🐬","🧺","🦋","🌱","🎈","🏃","⛸","🏀","🎾","🎬","🎨","♫","☕","🧶","📸","✦","🌊","☀","🌈","♥","🚶","🌳","♫","🎉","💧","📚","🐚","🏄","🦀","🥏","🌻","🐞","★","🤖","🚗","✧","🧩","⚽","🎳","🏋","🏸","♫","♫","🍵","🥞","🧁","🛴","🎲","✎","⛺","♫","♥","🛹","⛵","✂","⚓"];
const EVENTS={
reveillon:["Feliz 2027!","celebration","✦"],"navegantes":["Homenagem ao mar","sea","⛵"],"carnaval":["Viva o Carnaval!","celebration","✦"],"mulher":["Dia Internacional da Mulher","flowers","✿"],"pascoa":["Feliz Páscoa!","flowers","●"],"povos-indigenas":["Respeito aos povos originários","nature","❧"],"balonismo":["Torres nas alturas!","sea","◉"],"trabalhador":["Feliz Dia do Trabalhador!","city","★"],"maes":["Feliz Dia das Mães!","flowers","♥"],"torres":["Parabéns, Torres!","sea","★"],"meio-ambiente":["Cuidar é preservar","nature","❧"],"namorados":["Feliz Dia dos Namorados!","flowers","♥"],"sao-joao":["Viva São João!","celebration","✦"],"amigo":["Feliz Dia do Amigo!","nature","♥"],"pais":["Feliz Dia dos Pais!","city","★"],"folclore":["Viva o folclore brasileiro!","nature","♫"],"independencia":["7 de Setembro","nature","★"],"farroupilha":["Viva a tradição gaúcha!","nature","❧"],"primavera":["Bem-vinda, primavera!","flowers","✿"],"criancas":["Feliz Dia das Crianças!","celebration","★"],"halloween":["Diversão de arrepiar!","celebration","☾"],"consciencia-negra":["Respeito, história e igualdade","city","✦"],"black-friday":["Confira as novidades!","city","★"],"natal-2027":["Feliz Natal!","celebration","★"],"reveillon-2028":["Feliz 2028!","celebration","✦"]
};
const SEASONS=["sea","sea","flowers","nature","flowers","city","city","nature","nature","flowers","city","celebration"];
const escape=s=>String(s).replace(/[&<>"']/g,c=>({"&":"&amp;","<":"&lt;",">":"&gt;",'"':"&quot;", "'":"&apos;"}[c]));
const svgNS="http://www.w3.org/2000/svg";
function bg(kind){
 const colors={sea:["#b4e0f2","#4d9cbd","#eed6a2"],nature:["#c9e8c3","#589c84","#9fc986"],flowers:["#f7dbe4","#b8d9bc","#d9e8b4"],city:["#d8e9f2","#87afc1","#c7ced0"],celebration:["#263a68","#546aa3","#7e8db5"]}[kind]||["#c7e0f2","#7ab6cb","#e9d6b0"];
 const night=kind==="celebration";
 let scene='<defs><linearGradient id="btSky" x1="0" y1="0" x2="0" y2="1"><stop stop-color="'+colors[0]+'"/><stop offset="1" stop-color="'+(night?"#7d8fc3":"#fff7e6")+'"/></linearGradient></defs><rect width="600" height="350" fill="url(#btSky)"/>';
 if(!night)scene+='<circle cx="502" cy="59" r="33" fill="#ffe8ac"/><path d="M50 82q17-23 43 0q28-31 56 0zM403 91q17-23 43 0q28-31 56 0z" fill="#fff" opacity=".8"/>';
 else scene+='<circle cx="510" cy="55" r="29" fill="#f9e4ac"/>';
 if(kind==="sea")scene+='<path d="M0 196Q85 172 170 196T340 193T600 190V350H0Z" fill="#68b6ca"/><path d="M0 235Q115 213 230 235T450 228T600 233V350H0Z" fill="#c5edf0" opacity=".65"/><path d="M0 285Q150 250 300 288T600 276V350H0Z" fill="#efd9a8"/><path d="M50 194l36-78 39 77z" fill="#6e9985" opacity=".7"/><path d="M65 193L103 84l55 107z" fill="#6b908a" opacity=".7"/>';
 else if(kind==="nature"||kind==="flowers")scene+='<path d="M0 238Q160 193 340 232T600 216V350H0Z" fill="'+colors[1]+'"/><path d="M0 295Q150 249 300 300T600 270V350H0Z" fill="'+colors[2]+'"/><g fill="#548b6c"><circle cx="60" cy="205" r="43"/><circle cx="505" cy="200" r="50"/></g><g fill="#82664f"><rect x="54" y="195" width="12" height="90" rx="4"/><rect x="500" y="197" width="12" height="86" rx="4"/></g>';
 else if(kind==="city")scene+='<path d="M0 226V150h75v-33h77v110h65v-77h83v76h52v-95h90v95h78v-80h80v204H0Z" fill="#8daeba"/><g fill="#e8f7ff"><rect x="28" y="169" width="18" height="24"/><rect x="100" y="147" width="19" height="23"/><rect x="260" y="168" width="17" height="21"/><rect x="396" y="157" width="17" height="22"/><rect x="549" y="165" width="21" height="23"/></g><path d="M0 282h600v68H0Z" fill="#c9dadb"/>';
 else scene+='<path d="M0 284Q150 253 300 284T600 275V350H0Z" fill="#c5b9d5" opacity=".6"/><g fill="#ffdf96"><path d="M70 58l7 16 16 7-16 6-7 16-6-16-17-6 17-7zM495 123l5 12 12 5-12 5-5 12-5-12-12-5 12-5z"/></g>';
 return scene;
}
function body(animal){
 const cap=animal==="capi",outline=cap?"#805a3c":"#647f88",main=cap?"#bb895b":"#95acb6",head=cap?"#d6a675":"#c4d3d5",belly=cap?"#e3bd8c":"#e5eae6";
 let content='<g fill="'+main+'" stroke="'+outline+'" stroke-width="2.2"><ellipse cy="59" rx="55" ry="60"/><ellipse cx="-35" cy="109" rx="22" ry="10"/><ellipse cx="35" cy="109" rx="22" ry="10"/></g><ellipse cy="72" rx="37" ry="40" fill="'+belly+'"/>';
 if(cap)content+='<ellipse cx="-43" cy="-53" rx="13" ry="15" fill="#a37146"/><ellipse cx="43" cy="-53" rx="13" ry="15" fill="#a37146"/>';
 content+='<ellipse cy="-20" rx="59" ry="53" fill="'+head+'" stroke="'+outline+'" stroke-width="2.5"/><ellipse cy="13" rx="33" ry="23" fill="'+(cap?"#bb895b":"#f5ecdf")+'"/><g fill="#392d29"><ellipse cx="-31" cy="-27" rx="8" ry="10"/><ellipse cx="31" cy="-27" rx="8" ry="10"/></g><g fill="#fff"><circle cx="-28" cy="-30" r="3"/><circle cx="34" cy="-30" r="3"/></g><g fill="#eda99e"><ellipse cx="-43" cy="-7" rx="9" ry="5"/><ellipse cx="43" cy="-7" rx="9" ry="5"/></g><path d="M-13 20Q0 33 13 20" stroke="'+outline+'" stroke-width="3" fill="none" stroke-linecap="round"/>';
 if(!cap)content+='<path d="M-1 7l-8-6 18 0z" fill="#48606b"/><g stroke="#71838b" stroke-width="2" fill="none"><path d="M-31 17l-25-6m25 12l-25 4m87-10l25-6m-25 12l25 4"/></g>';
 content+='<g fill="#372a28"><ellipse cx="-31" cy="-27" rx="9" ry="1.5"><animate attributeName="ry" values="1.5;1.5;10;1.5;1.5;10;1.5" keyTimes="0;.35;.38;.41;.78;.81;1" dur="5.6s" fill="freeze"/></ellipse><ellipse cx="31" cy="-27" rx="9" ry="1.5"><animate attributeName="ry" values="1.5;1.5;10;1.5;1.5;10;1.5" keyTimes="0;.35;.38;.41;.78;.81;1" dur="5.6s" fill="freeze"/></ellipse></g>';
 const arm=(x,dir)=>'<g transform="translate('+x+' 43)"><g><path d="M0 0Q'+(dir*24)+' 12 '+(dir*21)+' 50Q'+(dir*4)+' 58 '+(-dir*9)+' 22Z" fill="'+main+'" stroke="'+outline+'" stroke-width="2"/><animateTransform attributeName="transform" type="rotate" values="0;'+(dir*28)+';'+(-dir*18)+';'+(dir*23)+';0" begin="1.8s" dur="3.2s" fill="freeze"/></g></g>';
 return content+arm(-52,-1)+arm(52,1);
}
function mainSVG(kind,caption,animal,index,accent,symbol,variant,year){
 const v=variant%5,offset=v%2?250:-250,accentColor=accent||"#efb958";
 const poses=[
 '0;0;-7;8;-4;0',
 '0;-10;7;-8;10;0',
 '0;7;-6;9;-8;0',
 '0;-14;11;-11;8;0',
 '0;15;-13;17;-15;0'
 ];
 const energy='<g opacity=".85">'+Array.from({length:7},(_,i)=>'<circle cx="'+(65+i*74)+'" cy="'+(113+(i%3)*24)+'" r="'+(3+i%3)+'" fill="'+(i%2?"#fff0bb":"#ffe6f2")+'"><animate attributeName="opacity" values="0;1;0" begin="'+(2+i*.22)+'s" dur="1.4s" fill="freeze"/><animateTransform attributeName="transform" type="translate" values="0 22;0 -24;0 -50" begin="'+(2+i*.22)+'s" dur="2s" fill="freeze"/></circle>').join("")+'</g>';
 const label=caption.length>35?20:caption.length>25?24:29;
 const text='<text x="300" y="49" text-anchor="middle" fill="'+(kind==="celebration"?"#fff6d8":"#19425a")+'" font-family="Arial,sans-serif" font-weight="900" font-size="'+label+'">'+escape(caption)+'</text>';
 const support='<g transform="translate(390 206)"><circle r="42" fill="#fff7e7" stroke="'+accentColor+'" stroke-width="4"/><text y="13" text-anchor="middle" font-family="Arial,sans-serif" font-size="42" fill="'+accentColor+'">'+escape(symbol)+'</text><animateTransform attributeName="transform" type="translate" additive="sum" values="0 35;0 35;0 -20;0 -10;0 0" keyTimes="0;.33;.55;.7;1" dur="5.8s" fill="freeze"/></g>';
 const move='<g transform="translate(266 193)"><g><animateTransform attributeName="transform" type="translate" values="'+offset+' 0;0 0;0 -16;0 0;0 0" keyTimes="0;.28;.52;.73;1" dur="5.8s" fill="freeze"/><g><animateTransform attributeName="transform" type="rotate" values="'+poses[v]+'" dur="5.8s" fill="freeze"/>'+body(animal)+'</g></g></g>';
 return '<svg xmlns="'+svgNS+'" viewBox="0 0 600 350" role="img" aria-label="'+escape(animal+" · "+caption)+'">'+bg(kind)+energy+text+support+move+'<text x="300" y="340" text-anchor="middle" fill="'+(kind==="celebration"?"#fff":"#315878")+'" font-family="Arial,sans-serif" font-size="13" font-weight="bold">BUSQUE TORRES</text></svg>';
}
function localCalendar(date){
 const a=[["2026-12-26","2027-01-01","reveillon"],["2027-01-30","2027-02-02","navegantes"],["2027-02-03","2027-02-09","carnaval"],["2027-03-05","2027-03-08","mulher"],["2027-03-21","2027-03-28","pascoa"],["2027-04-17","2027-04-19","povos-indigenas"],["2027-04-21","2027-04-25","balonismo"],["2027-05-01","2027-05-01","trabalhador"],["2027-05-03","2027-05-09","maes"],["2027-05-17","2027-05-21","torres"],["2027-06-05","2027-06-05","meio-ambiente"],["2027-06-06","2027-06-12","namorados"],["2027-06-18","2027-06-24","sao-joao"],["2027-07-20","2027-07-20","amigo"],["2027-08-02","2027-08-08","pais"],["2027-08-22","2027-08-22","folclore"],["2027-09-07","2027-09-07","independencia"],["2027-09-13","2027-09-20","farroupilha"],["2027-09-21","2027-09-23","primavera"],["2027-10-05","2027-10-12","criancas"],["2027-10-29","2027-10-31","halloween"],["2027-11-20","2027-11-20","consciencia-negra"],["2027-11-26","2027-11-26","black-friday"],["2027-12-01","2027-12-25","natal-2027"],["2027-12-26","2028-01-01","reveillon-2028"]];
 const matching=a.filter(x=>date>=x[0]&&date<=x[1]);return matching.length?matching[matching.length-1][2]:null;
}
function choose(list,key){
 let queue=[];try{queue=JSON.parse(localStorage.getItem(key)||"[]")}catch{}
 if(!Array.isArray(queue)||!queue.length||queue.some(x=>!Number.isInteger(x)||x<0||x>=list.length)){
 queue=Array.from({length:list.length},(_,i)=>i);
 for(let i=queue.length-1;i>0;i--){let j=Math.floor(Math.random()*(i+1));[queue[i],queue[j]]=[queue[j],queue[i]]}
 }
 const pos=queue.shift();try{localStorage.setItem(key,JSON.stringify(queue))}catch{}
 return list[pos];
}
function normalSet(day){
 const year=Number(day.slice(0,4)),month=Number(day.slice(5,7)),date=Number(day.slice(8,10));
 const ordinal=Math.floor((Date.UTC(year,month-1,date)-Date.UTC(year,0,1))/86400000);
 const m=month-1,block=Math.floor(ordinal/30),within=ordinal%30;
 // Oito cenas por acesso: quatro de cada animal, renovacao mensal.
 const result=[];
 for(const animal of ["capi","lobo"])for(let i=0;i<4;i++){
   const id=(m*37+within*4+i*9+block*7)%450;
   result.push({animal,id,variant:id%5,theme:Math.floor(id/5)%90});
 }
 return result;
}
function render(campaign){
 const event=campaign&&EVENTS[campaign]||null;
 const pool=event?Array.from({length:8},(_,i)=>({animal:i<4?"capi":"lobo",variant:i%4,theme:i})):normalSet(TODAY);
 const choice=PREVIEW?((campaign&&EVENTS[campaign])?{animal:PREVIEW.animal==="lobo"?"lobo":"capi",variant:Math.max(0,Math.min(3,Number(PREVIEW.variant)||0)),theme:0}:{animal:PREVIEW.animal==="lobo"?"lobo":"capi",id:Math.max(0,Math.min(449,Number(PREVIEW.id)||0)),variant:Math.max(0,Math.min(449,Number(PREVIEW.id)||0))%5,theme:Math.floor(Math.max(0,Math.min(449,Number(PREVIEW.id)||0))/5)}):choose(pool,"bt-mascotes-ciclo:"+TODAY+":"+(campaign||"normal"));
 let kind,caption,symbol;
 if(event){[caption,kind,symbol]=event}
 else {const month=PREVIEW?Math.max(1,Math.min(12,Number(PREVIEW.month)||1)):Number(TODAY.slice(5,7));kind=SEASONS[month-1];caption=THEMES[choice.theme];symbol=ICONS[choice.theme]}
 const art=mainSVG(kind,caption,choice.animal,choice.theme,null,symbol,choice.variant);
 stage.hidden=false;
 document.body.classList.add("bt-natal");
 stage.setAttribute("aria-label",choice.animal==="capi"?"Animação da capivara do Busque Torres":"Animação do lobo-marinho do Busque Torres");
 stage.innerHTML='<div class="bt-dynamic-mascot" style="position:absolute;inset:0;width:100%;height:100%">'+art+'</div><button type="button" class="bt-replay" aria-label="Reproduzir animação">↻ Animar</button>';
 stage.style.cssText="position:absolute;inset:0;overflow:hidden;background:#b6dce9;";
 const svg=stage.querySelector("svg");
 svg.style.cssText="position:absolute;inset:0;width:100%;height:100%;object-fit:cover;";
 stage.querySelector(".bt-replay").addEventListener("click",()=>{try{svg.setCurrentTime(0);svg.unpauseAnimations()}catch{}});
 const reduce=window.matchMedia?.("(prefers-reduced-motion: reduce)")?.matches;
 if(reduce){/* movimento nao infinito; permite reproduzir manualmente */}
}
async function findCampaign(){
 // Calendario em cache curto: a agenda pode ser alterada pelo administrador.
 let items=null;const key="bt-mascotes-campanhas-cache-v2";
 try{const c=JSON.parse(sessionStorage.getItem(key)||"null");if(c&&c.day===TODAY&&Date.now()-c.at<3600000)items=c.rows}catch{}
 if(!items&&typeof BusqueAPI!=="undefined"){
   try{items=await Promise.race([BusqueAPI.select("mascotes_campanhas","select=inicio,fim,ativa,prioridade,diretorio&ativa=eq.true&inicio=lte."+TODAY+"&fim=gte."+TODAY),new Promise((_,reject)=>setTimeout(()=>reject(Error("calendar timeout")),1800))]);try{sessionStorage.setItem(key,JSON.stringify({at:Date.now(),day:TODAY,rows:items}))}catch{}}catch{items=null}
 }
 if(Array.isArray(items)){
 const valid=items.filter(x=>x.ativa&&x.inicio<=TODAY&&x.fim>=TODAY&&EVENTS[x.diretorio]);valid.sort((a,b)=>Number(b.prioridade)-Number(a.prioridade));if(valid.length)return valid[0].diretorio;
 }
 if(Array.isArray(items))return null;
 return localCalendar(TODAY);
}
if(PREVIEW){window.BT_MASCOTES_RENDER=config=>{PREVIEW=config||{};render(PREVIEW.campaign||null)};render(PREVIEW.campaign||null)}else findCampaign().then(render).catch(()=>render(localCalendar(TODAY)));
})();