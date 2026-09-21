const video=document.querySelector('#video'), img=document.querySelector('#mjpeg'), empty=document.querySelector('#empty'), statusEl=document.querySelector('#status');
const dlg=document.querySelector('#settingsDialog'), urlEl=document.querySelector('#streamUrl'), typeEl=document.querySelector('#streamType');
let hls;
function status(ok){statusEl.classList.toggle('online',ok);statusEl.querySelector('span').textContent=ok?'ONLINE':'OFFLINE'}
function clear(){if(hls){hls.destroy();hls=null} video.pause();video.removeAttribute('src');video.load();img.removeAttribute('src');video.style.display=img.style.display='none';empty.style.display='flex';status(false)}
function connect(){
 clear(); const url=localStorage.camUrl, type=localStorage.camType||'hls'; if(!url)return;
 if(type==='mjpeg'){img.style.display='block';empty.style.display='none';img.onload=()=>status(true);img.onerror=()=>status(false);img.src=url+(url.includes('?')?'&':'?')+'_='+Date.now();return}
 video.style.display='block';empty.style.display='none';
 if(type==='hls' && window.Hls && Hls.isSupported()){hls=new Hls();hls.loadSource(url);hls.attachMedia(video);hls.on(Hls.Events.MANIFEST_PARSED,()=>video.play().catch(()=>{}));hls.on(Hls.Events.ERROR,(_,d)=>{if(d.fatal)status(false)})}
 else video.src=url;
 video.onplaying=()=>status(true);video.onerror=()=>status(false);video.play().catch(()=>{});
}
document.querySelector('#settings').onclick=()=>{urlEl.value=localStorage.camUrl||'';typeEl.value=localStorage.camType||'hls';dlg.showModal()}
document.querySelector('#save').onclick=e=>{e.preventDefault();localStorage.camUrl=urlEl.value.trim();localStorage.camType=typeEl.value;dlg.close();connect()}
document.querySelector('#reconnect').onclick=connect;
document.querySelector('#fullscreen').onclick=()=>document.querySelector('#viewer').requestFullscreen?.();
document.querySelector('#sound').onclick=e=>{video.muted=!video.muted;e.currentTarget.firstChild.textContent=video.muted?'🔇':'🔊'};
if('serviceWorker' in navigator) navigator.serviceWorker.register('./sw.js');
connect();