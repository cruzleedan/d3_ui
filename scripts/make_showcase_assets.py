#!/usr/bin/env python3
"""Pictures for the web showcase, drawn in Chromium (WORK-0073).

  icons    app icons and favicon  -> example/web/icons, example/web/favicon.png
  og       the social preview     -> example/web/og.png   (needs a build)
  posters  screenshots for the portfolio -> <build>/posters/  (needs a build)

Needs `pip install playwright && playwright install chromium`. `og` and
`posters` open the built site (example/build/web) and take screenshots of it,
so run scripts/build_showcase.sh first. Commit the icons and og.png; posters are
made fresh on every build, so they never go stale.
"""
import argparse
import base64
import functools
import http.server
import socketserver
import sys
import threading
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
WEB = ROOT / "example/web"
BUILD = ROOT / "example/build/web"
ARGS = ["--use-gl=swiftshader", "--enable-unsafe-swiftshader"]

ICON_HTML = """<html><body style="margin:0;background:transparent">
<div style="width:{s}px;height:{s}px;background:#4D62C5;border-radius:{r}px;display:flex;align-items:center;justify-content:center;
font:700 {f}px Roboto,Helvetica,Arial,sans-serif;color:#fff;letter-spacing:-0.04em">d3</div></body></html>"""


class _Quiet(http.server.SimpleHTTPRequestHandler):
    def log_message(self, *a):
        pass


def serve(directory):
    server = socketserver.TCPServer(("127.0.0.1", 0), functools.partial(_Quiet, directory=str(directory)))
    threading.Thread(target=server.serve_forever, daemon=True).start()
    return server, server.server_address[1]


def make_icons(p):
    browser = p.chromium.launch()
    # (file, size, corner radius, font size): maskable icons are full bleed with
    # the mark inside the safe zone; the others are rounded squares.
    specs = [
        ("icons/Icon-192.png", 192, 40, 96),
        ("icons/Icon-512.png", 512, 108, 256),
        ("icons/Icon-maskable-192.png", 192, 0, 72),
        ("icons/Icon-maskable-512.png", 512, 0, 192),
        ("favicon.png", 32, 7, 17),
    ]
    for name, size, radius, font in specs:
        page = browser.new_page(viewport={"width": size, "height": size})
        page.set_content(ICON_HTML.format(s=size, r=radius, f=font))
        page.screenshot(path=str(WEB / name), omit_background=True)
        page.close()
    browser.close()
    print("icons written to", WEB)


def open_site(browser, port, query, width, height):
    page = browser.new_page(viewport={"width": width, "height": height})
    page.goto(f"http://127.0.0.1:{port}/?{query}")
    page.wait_for_selector("flt-glass-pane", state="attached", timeout=45000)
    page.wait_for_timeout(5000)
    return page


def make_og(p):
    server, port = serve(BUILD)
    browser = p.chromium.launch(args=ARGS)
    phone = open_site(browser, port, "page=patterns&embed=1&theme=light&brand=blue", 390, 760)
    shot = base64.b64encode(phone.screenshot()).decode()
    card = browser.new_page(viewport={"width": 1200, "height": 630})
    card.set_content(f"""<html><body style="margin:0;width:1200px;height:630px;background:#F3F5FB;display:flex;align-items:center;
font-family:Roboto,Helvetica,Arial,sans-serif;color:#1B1E2B">
<div style="padding:0 70px;flex:1"><div style="font:700 96px Roboto;letter-spacing:-3px;color:#4D62C5">d3_ui</div>
<div style="font-size:40px;line-height:1.25;margin-top:8px">A Flutter design system</div>
<div style="font-size:26px;color:#5B6178;margin-top:22px">Try every component. Switch light and dark.<br>Restyle the whole app from a token file.</div></div>
<div style="width:300px;height:590px;margin-right:90px;border-radius:34px;overflow:hidden;border:3px solid #C9CEE0;background:#fff;box-shadow:0 20px 50px rgba(40,50,100,.25)">
<img src="data:image/png;base64,{shot}" style="width:300px;height:585px;object-fit:cover;object-position:top"></div></body></html>""")
    card.wait_for_timeout(500)
    card.screenshot(path=str(WEB / "og.png"))
    browser.close()
    server.shutdown()
    print("wrote", WEB / "og.png")


# (name, query, width, height): what the portfolio shows before "Try it live".
POSTERS = [
    ("patterns-phone-light", "page=patterns&embed=1&theme=light&brand=blue", 390, 760),
    ("patterns-phone-dark", "page=patterns&embed=1&theme=dark&brand=blue", 390, 760),
    ("patterns-phone-terracotta", "page=patterns&embed=1&theme=light&brand=terracotta", 390, 760),
    ("overview-light", "page=overview&theme=light&brand=blue", 1280, 800),
    ("overview-dark", "page=overview&theme=dark&brand=blue", 1280, 800),
    ("theme-terracotta-light", "page=theme&theme=light&brand=terracotta", 1280, 800),
    ("theme-terracotta-dark", "page=theme&theme=dark&brand=terracotta", 1280, 800),
    ("buttons-green-light", "page=button&theme=light&brand=green", 1280, 800),
]


def make_posters(p, out):
    out.mkdir(parents=True, exist_ok=True)
    server, port = serve(BUILD)
    browser = p.chromium.launch(args=ARGS)
    for name, query, w, h in POSTERS:
        page = open_site(browser, port, query, w, h)
        page.screenshot(path=str(out / f"{name}.png"))
        page.close()
    browser.close()
    server.shutdown()
    print(f"{len(POSTERS)} posters in {out}")


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("what", choices=["icons", "og", "posters"])
    ap.add_argument("--out", help="posters folder (default: <build>/posters)")
    a = ap.parse_args()
    if a.what != "icons" and not (BUILD / "index.html").exists():
        sys.exit(f"No build at {BUILD}: run scripts/build_showcase.sh first")
    from playwright.sync_api import sync_playwright

    with sync_playwright() as p:
        if a.what == "icons":
            make_icons(p)
        elif a.what == "og":
            make_og(p)
        else:
            make_posters(p, Path(a.out) if a.out else BUILD / "posters")


if __name__ == "__main__":
    main()
