#!/usr/bin/env python3
"""Serve and open a local, dynamic image gallery for a folder."""

import argparse
import html
import mimetypes
import sys
import webbrowser
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path
from urllib.parse import quote, unquote, urlsplit

IMAGE_EXTENSIONS = {".jpg", ".jpeg", ".png"}


def list_images(folder: Path) -> list[Path]:
    return sorted(
        (p for p in folder.iterdir() if p.is_file() and p.suffix.lower() in IMAGE_EXTENSIONS),
        key=lambda p: p.name.lower(),
    )


def make_handler(folder: Path):
    class GalleryHandler(BaseHTTPRequestHandler):
        def do_GET(self) -> None:
            path = urlsplit(self.path).path
            if path == "/" or path == "/index.html":
                self.serve_gallery()
            elif path.startswith("/image/"):
                self.serve_image(unquote(path[len("/image/"):]))
            else:
                self.send_error(404)

        def serve_gallery(self) -> None:
            images = list_images(folder)
            cards = "\n".join(
                f'<figure><img src="/image/{quote(image.name, safe="")}" '
                f'alt="{html.escape(image.name, quote=True)}" loading="lazy">'
                f'<figcaption>{html.escape(image.name)}</figcaption></figure>'
                for image in images
            )
            if not cards:
                cards = '<p class="empty">No JPG, JPEG, or PNG images found in this folder.</p>'

            document = f'''<!doctype html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Image gallery — {html.escape(folder.name)}</title>
<style>
  body {{ margin: 0; padding: 1.5rem; background: #171717; color: #eee; font: 16px system-ui, sans-serif; }}
  h1 {{ font-size: 1.4rem; overflow-wrap: anywhere; }}
  .gallery {{ display: grid; grid-template-columns: repeat(auto-fill, minmax(220px, 1fr)); gap: 1rem; }}
  figure {{ margin: 0; padding: .6rem; background: #252525; border-radius: 8px; }}
  img {{ display: block; width: 100%; height: 220px; object-fit: contain; }}
  figcaption {{ padding-top: .5rem; overflow-wrap: anywhere; color: #ccc; font-size: .9rem; }}
  .empty {{ color: #bbb; }}
</style>
</head>
<body>
<h1>{html.escape(str(folder))}</h1>
<p>{len(images)} image(s)</p>
<div class="gallery">{cards}</div>
</body>
</html>'''
            body = document.encode("utf-8")
            self.send_response(200)
            self.send_header("Content-Type", "text/html; charset=utf-8")
            self.send_header("Content-Length", str(len(body)))
            self.end_headers()
            self.wfile.write(body)

        def serve_image(self, name: str) -> None:
            # Only serve image names found directly in the selected folder.
            image = next((p for p in list_images(folder) if p.name == name), None)
            if image is None:
                self.send_error(404)
                return
            try:
                body = image.read_bytes()
            except OSError:
                self.send_error(404)
                return
            self.send_response(200)
            self.send_header("Content-Type", mimetypes.guess_type(image.name)[0] or "application/octet-stream")
            self.send_header("Content-Length", str(len(body)))
            self.send_header("X-Content-Type-Options", "nosniff")
            self.end_headers()
            self.wfile.write(body)

        def log_message(self, fmt: str, *args) -> None:
            print(f"[{self.log_date_time_string()}] {fmt % args}")

    return GalleryHandler


def main() -> int:
    parser = argparse.ArgumentParser(description="Serve an image gallery for a folder.")
    parser.add_argument("folder", nargs="?", default=".", help="folder to show (default: current directory)")
    args = parser.parse_args()
    folder = Path(args.folder).expanduser().resolve()
    if not folder.is_dir():
        print(f"Not a folder: {folder}", file=sys.stderr)
        return 2

    server = ThreadingHTTPServer(("127.0.0.1", 0), make_handler(folder))
    url = f"http://127.0.0.1:{server.server_port}/"
    print(f"Serving {folder} at {url} (press Ctrl+C to stop)", flush=True)
    webbrowser.open(url, new=2)
    try:
        server.serve_forever()
    except KeyboardInterrupt:
        print("\nStopping gallery server.")
    finally:
        server.server_close()
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
