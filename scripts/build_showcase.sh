#!/usr/bin/env bash
# Builds the web showcase (example/) into dist/d3-ui-showcase-web.tar.gz plus its
# .sha256. The same script runs in CI and locally.
#
#   scripts/build_showcase.sh                 # build only
#   scripts/build_showcase.sh --publish showcase-v1.9.0   # build, then attach to that GitHub Release
#
# GitHub Actions is disabled on this repo, so publishing is done here with the
# `gh` CLI (the host fetches the release asset). The web-showcase workflow does
# the same on a tag if Actions is ever turned on.
#
# Output: dist/d3-ui-showcase-web.tar.gz   (files at the archive root, index.html first level)
#         dist/d3-ui-showcase-web.tar.gz.sha256
set -euo pipefail
cd "$(dirname "$0")/.."

OUT=dist
NAME=d3-ui-showcase-web.tar.gz

# What the page shows as its version: the release tag when publishing (the tag
# does not exist yet at build time, so it comes from the argument), else "dev".
VERSION=dev
if [ "${1:-}" = "--publish" ]; then
  TAG="${2:?usage: scripts/build_showcase.sh --publish showcase-vX.Y.Z}"
  VERSION="${TAG#showcase-v}"
fi
COMMIT="$(git rev-parse --short HEAD 2>/dev/null || true)"
LIB_VERSION="$(sed -n 's/^version: *\([0-9][^ ]*\).*/\1/p' pubspec.yaml | head -1)"

(cd example && flutter pub get && dart run tool/gen_example_sources.dart && flutter build web --release --no-web-resources-cdn --base-href / \
  --dart-define=SHOWCASE_VERSION="$VERSION" --dart-define=SHOWCASE_COMMIT="$COMMIT" --dart-define=D3_UI_VERSION="$LIB_VERSION")

BUILD=example/build/web
[ -f "$BUILD/index.html" ] || { echo "No index.html in $BUILD"; exit 1; }
ls "$BUILD"/main.dart.* >/dev/null 2>&1 || { echo "No main.dart.* in $BUILD"; exit 1; }

# --no-web-resources-cdn makes the engine load CanvasKit from the build itself,
# not from a Google host (fonts.gstatic.com only remains as Flutter's fallback for
# glyphs no bundled font has).
[ -d "$BUILD/canvaskit" ] || { echo "No canvaskit/ in $BUILD (was --no-web-resources-cdn dropped?)"; exit 1; }

# Put the engine under a name that changes with it (canvaskit-<hash>/), so a host
# can cache it for a year as immutable: the 2 MB canvaskit.wasm must match the
# engine inside main.dart.js, and a fixed path cannot be cached for long without
# serving an old wasm to a new app. The page and the loader point at the new name
# (the service worker lists no engine files).
python3 - "$BUILD" <<'PY'
import hashlib, pathlib, re, sys
build = pathlib.Path(sys.argv[1])
wasm = build / "canvaskit/chromium/canvaskit.wasm"
h = hashlib.sha256(wasm.read_bytes() + (build / "canvaskit/chromium/canvaskit.js").read_bytes()).hexdigest()[:10]
new = f"canvaskit-{h}"
for old in build.glob("canvaskit-*"):  # left by an earlier build into the same folder
    __import__("shutil").rmtree(old)
(build / "canvaskit").rename(build / new)
for name in ["index.html", "flutter_service_worker.js"]:  # the worker only if it lists any
    f = build / name
    t = f.read_text()
    f.write_text(t.replace("canvaskit/", new + "/"))
f = build / "flutter_bootstrap.js"
t = f.read_text()
patched, n = re.subn(r':"canvaskit"\}', f':"{new}"}}', t)
if n != 1:
    sys.exit("flutter_bootstrap.js: expected one default canvaskit base, found %d" % n)
f.write_text(patched)
for name in ["index.html", "flutter_bootstrap.js"]:
    if new not in (build / name).read_text():
        sys.exit(f"{name} does not point at {new}")
print(f"engine is now {new}/")
PY

# Poster screenshots for the portfolio, taken from this very build so they never
# go stale. Needs Playwright (see scripts/make_showcase_assets.py); skipped, with
# a warning, when it is not installed.
if python3 -c 'import playwright' 2>/dev/null; then
  python3 scripts/make_showcase_assets.py posters
else
  echo "WARNING: Playwright is not installed: building without posters"
fi

rm -rf "$OUT" && mkdir -p "$OUT"
tar -czf "$OUT/$NAME" -C "$BUILD" .
(cd "$OUT" && sha256sum "$NAME" > "$NAME.sha256")
echo "Built $OUT/$NAME ($(du -h "$OUT/$NAME" | cut -f1))"
cat "$OUT/$NAME.sha256"

if [ "${1:-}" = "--publish" ]; then
  TAG="${2:?usage: scripts/build_showcase.sh --publish vX.Y.Z}"
  command -v gh >/dev/null || { echo "gh CLI is required to publish"; exit 1; }
  gh release view "$TAG" >/dev/null 2>&1 || gh release create "$TAG" --title "$TAG" --generate-notes
  gh release upload "$TAG" "$OUT/$NAME" "$OUT/$NAME.sha256" --clobber
  echo "Attached to release $TAG"
fi
