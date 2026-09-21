const v=document.querySelector('#video'),s=document.querySelector('#status'),m=document.querySelector('#msg');let h;
function base(){return localStorage.gateway||'http://127.0.0.1:8888'}
function connect(){if(h)h.destroy(); const u=base()+'/kamera/index.m3u8'; s.textContent='● ŁĄCZENIE';m.style.display='flex';
 if(Hls.isSupported()){h=new Hls({lowLatencyMode:true});h.loadSource(u);h.attachMedia(v);h.on(Hls.Events.MANIFEST_PARSED,()=>v.play().catch(()=>{}));h.on(Hls.Events.ERROR,(_,d)=>{if(d.fatal)s.textContent='● OFFLINE'})}else v.src=u;
 v.onplaying=()=>{s.textContent='● ONLINE';m.style.display='none'};v.onerror=()=>s.textContent='● OFFLINE'}
retry.onclick=connect;full.onclick=()=>document.querySelector('.viewer').requestFullscreen?.();sound.onclick=e=>{v.muted=!v.muted;e.currentTarget.firstChild.textContent=v.muted?'🔇':'🔊'};
cfg.onclick=()=>{let x=prompt('Adres komputera z MediaMTX, np. http://192.168.0.2:8888',base());if(x){localStorage.gateway=x.replace(/\/$/,'');connect()}};connect();