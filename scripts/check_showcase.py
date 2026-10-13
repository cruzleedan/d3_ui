#!/usr/bin/env python3
"""Browser checks for the web showcase (WORK-0072).

Loads every showcase page in Chromium and fails on a console or page error, on
a request to any host but the local one, on sideways scrolling, or when the
accessibility (semantics) tree is empty. Then drives the overlays (dialog,
sheets, the Patterns app) the way a visitor would. Screenshots of every load
are saved for the portfolio posters.

Setup, once:   pip install playwright && playwright install chromium
Build first:   scripts/build_showcase.sh          (or flutter build web in example/)
Run:           python3 scripts/check_showcase.py            # quick: 2 combinations
               python3 scripts/check_showcase.py --full     # 2 widths x 2 themes x every brand
               python3 scripts/check_showcase.py --pages button,dialog --workers 2

Not covered (a Flutter canvas hides the DOM): keyboard navigation and an axe
scan; text overflow that only shows in a debug build. The widget tests catch
the overflow at several text scales.
"""
import argparse
import functools
import hashlib
import http.server
import itertools
import re
import socketserver
import sys
import threading
from concurrent.futures import ProcessPoolExecutor
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
REGISTRY = ROOT / "example/lib/showcase/registry.dart"
BRANDS = ROOT / "example/lib/showcase/brands.dart"
QUICK = [(390, "light", "blue"), (1280, "dark", "terracotta")]


def page_ids():
    return re.findall(r"id: '([a-z-]+)'", REGISTRY.read_text())


def brand_ids():
    return re.findall(r"id: '([a-z-]+)'", BRANDS.read_text())


class _Quiet(http.server.SimpleHTTPRequestHandler):
    """Static files, with index.html for any path that is not a file (pages
    have paths such as /button, as on the real host)."""

    def log_message(self, *a):
        pass

    def do_GET(self):
        path = self.translate_path(self.path.split("?")[0])
        if not Path(path).exists():
            self.path = "/index.html"
        return super().do_GET()


def serve(build):
    server = socketserver.TCPServer(
        ("127.0.0.1", 0), functools.partial(_Quiet, directory=str(build))
    )
    threading.Thread(target=server.serve_forever, daemon=True).start()
    return server, server.server_address[1]


def open_page(browser, port, query, width, height=900):
    """Loads a showcase URL; returns (page, problems) once the app has drawn."""
    page = browser.new_page(viewport={"width": width, "height": height})
    problems = []
    hosts = set()
    page.on("console", lambda m: problems.append("console: " + m.text[:160]) if m.type == "error" else None)
    page.on("pageerror", lambda e: problems.append("page error: " + str(e)[:160]))
    page.on("request", lambda r: hosts.add(r.url.split("/")[2]) if r.url.startswith("http") else None)
    page.goto(f"http://127.0.0.1:{port}/?{query}")
    page.wait_for_selector("flt-glass-pane", state="attached", timeout=45000)
    page.wait_for_timeout(3500)
    page.hosts = hosts
    return page, problems


def enable_semantics(page):
    page.evaluate("document.querySelector('flt-semantics-placeholder')?.click()")
    page.wait_for_timeout(800)


def check_load(args):
    build, out, page_id, width, theme, brand = args
    from playwright.sync_api import sync_playwright

    server, port = serve(build)
    problems = []
    digest = ""
    with sync_playwright() as p:
        browser = p.chromium.launch(args=["--use-gl=swiftshader", "--enable-unsafe-swiftshader"])
        try:
            page, problems = open_page(browser, port, f"page={page_id}&theme={theme}&brand={brand}", width)
            enable_semantics(page)
            if page.locator("flt-semantics").count() < 3:
                problems.append("accessibility tree is empty")
            outside = [h for h in page.hosts if not h.startswith("127.0.0.1")]
            if outside:
                problems.append(f"requests to other hosts: {sorted(outside)}")
            if page.evaluate("document.documentElement.scrollWidth > window.innerWidth + 1"):
                problems.append("sideways scroll")
            shot = Path(out) / f"{page_id}_{width}_{theme}_{brand}.png"
            page.screenshot(path=str(shot))
            digest = hashlib.sha1(shot.read_bytes()).hexdigest()
        except Exception as e:  # a timeout or crash is a failure, not a skip
            problems.append(f"{type(e).__name__}: {str(e)[:160]}")
        finally:
            browser.close()
    server.shutdown()
    return (page_id, width, theme, brand), problems, digest


# What a visitor does on pages whose point is an overlay or a flow. Each step is
# (action, name, open): click a button by its accessible name, then check whether
# an overlay is open. A modal hides the page behind it from the accessibility
# tree, so "open" means the navigation (the Overview button, or the menu button on a
# phone) is gone.
FLOWS = {
    "dialog": [
        ("click", "Confirm delete", 1),
        ("click", "Cancel", 0),
    ],
    "bottom-sheet": [
        ("click", "Sort by", 1),
        ("click", "Name", 0),
    ],
    "patterns": [
        ("click", "Casa Verde", 1),
        ("click", "Cancel", 0),
    ],
}


def run_flow(browser, port, page_id, steps, width):
    """One attempt at a flow; returns a list of problems (empty means passed)."""
    page = None
    try:
        page, problems = open_page(browser, port, f"page={page_id}&theme=light&brand=blue", width)
        enable_semantics(page)
        for action, name, wants_open in steps:
            if action == "click":
                target = page.get_by_role("button", name=name)
                if target.count() == 0:
                    return problems + [f"no button named {name!r}"]
                target.first.click()
            else:
                page.keyboard.press(name)
            page.wait_for_timeout(1200)
            behind = page.get_by_role("button", name=re.compile("^(Overview|Open navigation menu)$"))
            # A modal hides the page behind it, or (inside the Places frame) shows
            # its own Cancel button while the showcase navigation stays visible.
            is_open = behind.count() == 0 or page.get_by_role("button", name=re.compile("^Cancel")).count() > 0
            if is_open != bool(wants_open):
                return problems + [f"after {action} {name!r}: expected {'an overlay' if wants_open else 'no overlay'}"]
        return problems
    except Exception as e:
        return [f"{type(e).__name__}: {str(e)[:160]}"]
    finally:
        if page:
            page.close()


def check_flows(args):
    build, width = args
    from playwright.sync_api import sync_playwright

    server, port = serve(build)
    results = []
    with sync_playwright() as p:
        browser = p.chromium.launch(args=["--use-gl=swiftshader", "--enable-unsafe-swiftshader"])
        for page_id, steps in FLOWS.items():
            # The software renderer is slow: allow one retry before failing.
            problems = run_flow(browser, port, page_id, steps, width)
            if problems:
                problems = run_flow(browser, port, page_id, steps, width)
            results.append(((f"flow {page_id}", width), problems))
        browser.close()
    server.shutdown()
    return results


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--build", default=str(ROOT / "example/build/web"))
    ap.add_argument("--out", default=str(ROOT / "example/build/showcase-check"))
    ap.add_argument("--full", action="store_true", help="every width, theme and brand")
    ap.add_argument("--pages", help="comma-separated page ids (default: all)")
    ap.add_argument("--workers", type=int, default=4)
    ap.add_argument("--no-flows", action="store_true")
    a = ap.parse_args()

    build = Path(a.build)
    if not (build / "index.html").exists():
        sys.exit(f"No build at {build}: run scripts/build_showcase.sh first")
    Path(a.out).mkdir(parents=True, exist_ok=True)
    pages = a.pages.split(",") if a.pages else page_ids()
    unknown = set(pages) - set(page_ids())
    if unknown:
        sys.exit(f"Unknown page ids: {sorted(unknown)}")
    combos = (
        list(itertools.product([390, 1280], ["light", "dark"], brand_ids()))
        if a.full
        else QUICK
    )
    jobs = [(str(build), a.out, pid, w, t, b) for pid in pages for (w, t, b) in combos]
    print(f"{len(pages)} pages x {len(combos)} combinations = {len(jobs)} loads, {a.workers} workers")

    failures = []
    digests = {}
    with ProcessPoolExecutor(max_workers=a.workers) as pool:
        for key, problems, digest in pool.map(check_load, jobs):
            digests[key] = digest
            if problems:
                failures.append((key, problems))
                print("FAIL", key, *problems, sep="\n   ")
        if not a.no_flows:
            for results in pool.map(check_flows, [(str(build), 1280), (str(build), 390)]):
                for key, problems in results:
                    if problems:
                        failures.append((key, problems))
                        print("FAIL", key, *problems, sep="\n   ")

    # Each brand must really change how a page looks.
    if a.full:
        for pid in pages:
            for w, t in itertools.product([390, 1280], ["light", "dark"]):
                shots = {digests.get((pid, w, t, b)) for b in brand_ids()}
                if len(shots) < len(brand_ids()):
                    failures.append(((pid, w, t), ["two brands render identically"]))
                    print("FAIL", (pid, w, t), "two brands render identically")

    print(f"\n{len(jobs)} loads checked, screenshots in {a.out}")
    if failures:
        print(f"{len(failures)} failure(s)")
        sys.exit(1)
    print("all passed")


if __name__ == "__main__":
    main()
