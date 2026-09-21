const video=document.querySelector('#video');
const statusEl=document.querySelector('#status');
const msg=document.querySelector('#msg');
const diag=document.querySelector('#diag');
const viewer=document.querySelector('#viewer');
const streamUrl=location.origin+'/stream.ts';

document.querySelector('#appUrl').textContent=location.href;
document.querySelector('#streamUrl').textContent=streamUrl;

let player=null;
let started=false;

function state(text,color){
  statusEl.textContent='● '+text;
  statusEl.style.color=color;
}
function show(text){
  msg.textContent=text;
  msg.style.display='flex';
}
function cleanup(){
  if(player){
    try{player.pause()}catch(e){}
    try{player.unload()}catch(e){}
    try{player.detachMediaElement()}catch(e){}
    try{player.destroy()}catch(e){}
  }
  player=null;
}

function connect(){
  cleanup();
  started=false;
  show('Łączenie ze strumieniem LIVE…');
  state('ŁĄCZENIE','#ffcc58');
  diag.textContent='';

  // v1016: no fetch/probe of an endless LIVE response.
  if(!window.mpegts){
    show('Nie udało się załadować biblioteki odtwarzacza.');
    state('BRAK ODTWARZACZA','#ff6262');
    diag.textContent='mpegts.js: BRAK';
    return;
  }
  if(!mpegts.isSupported()){
    show('Ta przeglądarka nie obsługuje MPEG-TS/H.264 przez Media Source Extensions.');
    state('FORMAT NIEOBSŁUGIWANY','#ff6262');
    diag.textContent='MSE/mpegts: NIEOBSŁUGIWANE';
    return;
  }

  diag.textContent='MSE/mpegts: OBSŁUGIWANE';
  try{
    player=mpegts.createPlayer(
      {type:'mpegts',isLive:true,url:streamUrl,hasAudio:false,hasVideo:true},
      {enableStashBuffer:false,lazyLoad:false,autoCleanupSourceBuffer:true}
    );
    player.attachMediaElement(video);

    player.on(mpegts.Events.ERROR,(type,detail,info)=>{
      console.error(type,detail,info);
      if(!started){
        show('Odtwarzacz nie może rozpocząć obrazu LIVE.');
        state('BŁĄD STRUMIENIA','#ff6262');
        diag.textContent='MSE/mpegts: OBSŁUGIWANE • start obrazu: BŁĄD';
      }
    });

    video.onplaying=()=>{
      started=true;
      msg.style.display='none';
      state('ONLINE','#45e47a');
      diag.textContent='MSE/mpegts: OBSŁUGIWANE • obraz LIVE: OK';
    };

    player.load();
    const promise=player.play();
    if(promise && promise.catch) promise.catch(()=>{});
  }catch(e){
    console.error(e);
    show('Błąd uruchamiania odtwarzacza.');
    state('BŁĄD','#ff6262');
  }

  setTimeout(()=>{
    if(!started){
      show('Strumień jest podłączony, ale obraz nie wystartował. Kliknij „Połącz ponownie”.');
      state('BRAK OBRAZU','#ff6262');
      diag.textContent=(diag.textContent||'MSE/mpegts: OBSŁUGIWANE')+' • obraz LIVE: BRAK';
    }
  },7000);
}

document.querySelector('#retry').onclick=connect;
document.querySelector('#full').onclick=()=>viewer.requestFullscreen?.();
window.addEventListener('beforeunload',cleanup);
connect();
