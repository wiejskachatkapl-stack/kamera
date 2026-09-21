$ErrorActionPreference="Stop"

$web = Join-Path (Split-Path $PSScriptRoot -Parent) "web"
$listener = [System.Net.HttpListener]::new()

# v1011: localhost only - no http://+:8090/ and no URL ACL/admin requirement.
$listener.Prefixes.Add("http://127.0.0.1:8090/")

try {
    $listener.Start()
} catch {
    Write-Host "Nie moge uruchomic lokalnego serwera 127.0.0.1:8090." -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "Kamera LIVE v1011" -ForegroundColor Cyan
Write-Host "Serwer lokalny: DZIALA" -ForegroundColor Green
Write-Host "Otworz: http://127.0.0.1:8090" -ForegroundColor Green
Write-Host ""

$mime = @{
    ".html" = "text/html; charset=utf-8"
    ".js"   = "application/javascript; charset=utf-8"
    ".css"  = "text/css; charset=utf-8"
}

while ($listener.IsListening) {
    $ctx = $listener.GetContext()
    try {
        $path = $ctx.Request.Url.AbsolutePath

        if ($path -eq "/stream.ts") {
            $req = [System.Net.HttpWebRequest]::Create("http://127.0.0.1:8091/stream.ts")
            $req.Timeout = 10000
            $req.ReadWriteTimeout = 10000
            $up = $req.GetResponse()

            $ctx.Response.StatusCode = 200
            $ctx.Response.ContentType = "video/mp2t"
            $ctx.Response.SendChunked = $true
            $ctx.Response.Headers["Cache-Control"] = "no-store"

            $input = $up.GetResponseStream()
            $buf = New-Object byte[] 65536
            try {
                while (($n = $input.Read($buf,0,$buf.Length)) -gt 0) {
                    $ctx.Response.OutputStream.Write($buf,0,$n)
                    $ctx.Response.OutputStream.Flush()
                }
            } catch {
                # Browser closed/reconnected.
            } finally {
                $input.Dispose()
                $up.Dispose()
            }
        }
        else {
            if ($path -eq "/") { $path = "/index.html" }
            $relative = $path.TrimStart("/").Replace("/", [IO.Path]::DirectorySeparatorChar)
            $file = Join-Path $web $relative

            if ((Test-Path $file) -and -not (Get-Item $file).PSIsContainer) {
                $bytes = [IO.File]::ReadAllBytes($file)
                $ext = [IO.Path]::GetExtension($file).ToLower()
                if ($mime.ContainsKey($ext)) { $ctx.Response.ContentType = $mime[$ext] }
                $ctx.Response.Headers["Cache-Control"] = "no-store"
                $ctx.Response.ContentLength64 = $bytes.Length
                $ctx.Response.OutputStream.Write($bytes,0,$bytes.Length)
            }
            else {
                $ctx.Response.StatusCode = 404
            }
        }
    }
    catch {
        try { $ctx.Response.StatusCode = 502 } catch {}
    }
    finally {
        try { $ctx.Response.OutputStream.Close() } catch {}
    }
}
