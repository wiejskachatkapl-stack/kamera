const video=document.querySelector('#video'),statusEl=document.querySelector('#status'),msg=document.querySelector('#msg'),diag=document.querySelector('#diag'),viewer=document.querySelector('#viewer');
const streamUrl=location.origin+'/stream.ts';
document.querySelector('#appUrl').textContent=location.href;
document.querySelector('#streamUrl').textContent=streamUrl;
let player=null;
function state(text,color){statusEl.textContent='● '+text;statusEl.style.color=color}
async function probe(){
 try{const r=await fetch('/stream.ts',{method:'GET',cache:'no-store'}); return r.ok;}catch(e){return false;}
}
async function connect(){
 if(player){try{player.destroy()}catch(e){} player=null}
 msg.style.display='flex';msg.textContent='Sprawdzam strumień…';state('ŁĄCZENIE','#ffcc58');diag.textContent='';
 const ok=await probe();
 if(!ok){msg.textContent='Telefon widzi aplikację, ale serwer nie przekazuje strumienia z VLC.';state('BRAK STRUMIENIA','#ff6262');diag.textContent='Test /stream.ts: BŁĄD';return}
 diag.textContent='Test /stream.ts: OK';
 if(window.mpegts && mpegts.isSupported()){
  try{
   player=mpegts.createPlayer({type:'mpegts',isLive:true,url:streamUrl,hasAudio:false,hasVideo:true},{enableStashBuffer:false,lazyLoad:false});
   player.attachMediaElement(video);
   player.on(mpegts.Events.ERROR,(t,d,i)=>{console.error(t,d,i);msg.style.display='flex';msg.textContent='Strumień dochodzi do telefonu, ale ta przeglądarka nie odtwarza MPEG-TS/H.264 przez MSE.';state('NIEOBSŁUGIWANY FORMAT','#ff6262')});
   video.onplaying=()=>{msg.style.display='none';state('ONLINE','#45e47a')};
   player.load();await player.play().catch(()=>{});
   return;
  }catch(e){console.error(e)}
 }
 msg.textContent='Strumień dochodzi do telefonu, ale przeglądarka nie obsługuje obecnego odtwarzacza MPEG-TS/MSE.';
 state('NIEOBSŁUGIWANY FORMAT','#ff6262');
}
document.querySelector('#retry').onclick=connect;
document.querySelector('#full').onclick=()=>viewer.requestFullscreen?.();
connect();
