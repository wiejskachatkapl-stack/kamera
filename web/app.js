const cam=document.querySelector('#cam'),msg=document.querySelector('#msg'),st=document.querySelector('#status'),viewer=document.querySelector('#viewer');
function host(){return localStorage.camHost||location.hostname||'127.0.0.1'}
function connect(){
  st.textContent='● ŁĄCZENIE'; cam.style.display='none'; msg.style.display='flex';
  cam.onload=()=>{st.textContent='● ONLINE';cam.style.display='block';msg.style.display='none'};
  cam.onerror=()=>{st.textContent='● OFFLINE';cam.style.display='none';msg.style.display='flex'};
  cam.src='http://'+host()+':8091/camera.mjpg?t='+Date.now();
}
document.querySelector('#retry').onclick=connect;
document.querySelector('#full').onclick=()=>viewer.requestFullscreen?.();
document.querySelector('#cfg').onclick=()=>{const x=prompt('IP komputera z VLC, np. 192.168.0.2',host());if(x){localStorage.camHost=x.trim();connect()}};
connect();