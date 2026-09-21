$ErrorActionPreference="Stop"
$vlc="C:\Program Files\VideoLAN\VLC\vlc.exe"
. "$PSScriptRoot\camera.local.ps1"
$url="rtsp://${CameraUser}:${CameraPass}@192.168.0.3:554/live/ch00_0"
& $vlc --rtsp-tcp $url
