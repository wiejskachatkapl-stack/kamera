const video=document.querySelector('#video');
const statusEl=document.querySelector('#status');
const message=document.querySelector('#message');
const streamUrlEl=document.querySelector('#streamUrl');
const viewer=document.querySelector('#viewer');
let player=null;

function getHost(){
  if(localStorage.camHost) return localStorage.camHost;
  const h=location.hostname;
  return (!h || h==='localhost' || h==='127.0.0.1') ? '127.0.0.1' : h;
}
function url(){ return `http://${getHost()}:8091/stream.ts`; }
function setStatus(ok,text){
 statusEl.textContent='● '+text;
 statusEl.className=ok?'online':'offline';
 message.style.display=ok?'none':'flex';
}
function stop(){
 try{ if(player){player.pause();player.unload();player.detachMediaElement();player.destroy();} }catch(e){}
 player=null;
}
async function connect(){
 stop();
 const u=url(); streamUrlEl.textContent=u;
 setStatus(false,'ŁĄCZENIE');
 if(!window.mpegts || !mpegts.isSupported()){
   message.textContent='Ta przeglądarka nie obsługuje odtwarzacza MPEG-TS/MSE.';
   setStatus(false,'BRAK MSE'); return;
 }
 try{
   player=mpegts.createPlayer(
     {type:'mpegts',isLive:true,url:u,hasAudio:false,hasVideo:true,cors:false},
     {enableStashBuffer:false,lazyLoad:false,liveBufferLatencyChasing:true,liveBufferLatencyMaxLatency:1.5,liveBufferLatencyMinRemain:.5}
   );
   player.attachMediaElement(video);
   player.on(mpegts.Events.ERROR,(type,detail,info)=>{
      console.error(type,detail,info);
      message.textContent='Brak obrazu. Sprawdź, czy VLC działa i port 8091 ma TRUE.';
      setStatus(false,'BŁĄD');
   });
   video.addEventListener('playing',()=>setStatus(true,'ONLINE'),{once:true});
   player.load();
   await player.play().catch(()=>{});
 }catch(e){
   console.error(e); message.textContent='Nie udało się uruchomić odtwarzacza.'; setStatus(false,'BŁĄD');
 }
}
document.querySelector('#connect').onclick=connect;
document.querySelector('#full').onclick=()=>viewer.requestFullscreen?.();
document.querySelector('#host').onclick=()=>{
 const h=prompt('IP komputera z VLC, np. 192.168.0.2',getHost());
 if(h){localStorage.camHost=h.trim();connect();}
};
window.addEventListener('beforeunload',stop);
connect();
