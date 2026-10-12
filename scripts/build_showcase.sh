#!/usr/bin/env bash
# Builds the web showcase (example/) into dist/d3-ui-showcase-web.tar.gz plus its
# .sha256. The same script runs in CI and locally.
#
#   scripts/build_showcase.sh                 # build only
#   scripts/build_showcase.sh --publish v0.3.0   # build, then attach to that GitHub Release
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

(cd example && flutter pub get && flutter build web --release --no-web-resources-cdn --base-href /)

BUILD=example/build/web
[ -f "$BUILD/index.html" ] || { echo "No index.html in $BUILD"; exit 1; }
ls "$BUILD"/main.dart.* >/dev/null 2>&1 || { echo "No main.dart.* in $BUILD"; exit 1; }

# --no-web-resources-cdn makes the engine load CanvasKit from the build itself,
# not from a Google host (fonts.gstatic.com only remains as Flutter's fallback for
# glyphs no bundled font has).
[ -d "$BUILD/canvaskit" ] || { echo "No canvaskit/ in $BUILD (was --no-web-resources-cdn dropped?)"; exit 1; }

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
