from http.server import ThreadingHTTPServer, SimpleHTTPRequestHandler
from urllib.request import urlopen, Request
from pathlib import Path
import os

WEB=Path(__file__).resolve().parent.parent/"web"
os.chdir(WEB)

class Handler(SimpleHTTPRequestHandler):
    def end_headers(self):
        self.send_header("Cache-Control","no-store")
        super().end_headers()

    def do_GET(self):
        if self.path.startswith("/stream.ts"):
            try:
                req=Request("http://127.0.0.1:8091/stream.ts",headers={"User-Agent":"KameraLIVE/1009"})
                upstream=urlopen(req,timeout=10)
                self.send_response(200)
                self.send_header("Content-Type","video/mp2t")
                self.send_header("Cache-Control","no-store")
                self.send_header("Access-Control-Allow-Origin","*")
                self.end_headers()
                while True:
                    chunk=upstream.read(64*1024)
                    if not chunk: break
                    self.wfile.write(chunk)
                    self.wfile.flush()
            except (BrokenPipeError, ConnectionResetError):
                pass
            except Exception as e:
                self.send_error(502,f"VLC stream unavailable: {e}")
            return
        super().do_GET()

print("Kamera LIVE v1009")
print("Aplikacja: http://127.0.0.1:8090")
print("Telefon w tym samym Wi-Fi: http://192.168.0.2:8090")
ThreadingHTTPServer(("0.0.0.0",8090),Handler).serve_forever()
