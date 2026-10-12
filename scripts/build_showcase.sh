#!/usr/bin/env bash
# Builds the web showcase (example/) into dist/d3-ui-showcase-web.tar.gz plus its
# .sha256. The same script runs in CI and locally.
#
#   scripts/build_showcase.sh
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

rm -rf "$OUT" && mkdir -p "$OUT"
tar -czf "$OUT/$NAME" -C "$BUILD" .
(cd "$OUT" && sha256sum "$NAME" > "$NAME.sha256")
echo "Built $OUT/$NAME ($(du -h "$OUT/$NAME" | cut -f1))"
cat "$OUT/$NAME.sha256"
