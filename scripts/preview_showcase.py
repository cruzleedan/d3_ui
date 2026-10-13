#!/usr/bin/env python3
"""Serves the built web showcase for a private preview.

  python3 scripts/preview_showcase.py --bind <private-address> [--port 8090]

Like the real host, it answers any path that is not a file with index.html, so a
deep link such as /button works on a reload (python3 -m http.server answers 404
for it). Build first: scripts/build_showcase.sh (or flutter build web in
example/). Bind to a specific private address, not 0.0.0.0.
"""
import argparse
import functools
import http.server
import socketserver
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
BUILD = ROOT / "example/build/web"


class Handler(http.server.SimpleHTTPRequestHandler):
    def do_GET(self):
        if not Path(self.translate_path(self.path.split("?")[0])).exists():
            self.path = "/index.html"
        return super().do_GET()


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--bind", required=True, help="a private address, not 0.0.0.0")
    ap.add_argument("--port", type=int, default=8090)
    ap.add_argument("--directory", default=str(BUILD))
    a = ap.parse_args()
    if not (Path(a.directory) / "index.html").exists():
        sys.exit(f"No build in {a.directory}: run scripts/build_showcase.sh first")
    if a.bind in ("0.0.0.0", "::"):
        sys.exit("Bind to a specific private address, not every interface")
    handler = functools.partial(Handler, directory=a.directory)
    with socketserver.ThreadingTCPServer((a.bind, a.port), handler) as server:
        server.allow_reuse_address = True
        print(f"Serving {a.directory} at http://{a.bind}:{a.port}/")
        server.serve_forever()


if __name__ == "__main__":
    main()
