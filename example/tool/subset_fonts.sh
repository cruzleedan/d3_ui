#!/usr/bin/env bash
# The bundled Roboto files are subset to Latin (plus the arrows, dashes and a few
# symbols the showcase uses) and unhinted: 170 KB each became about 32 KB. Hosts
# send .ttf uncompressed, so this is most of the font download on first load.
#
#   pip install fonttools brotli
#   tool/subset_fonts.sh <dir with the full Roboto-*.ttf and RobotoMono-Regular.ttf>
#
# A character outside this set falls back to a font fetched from a CDN, which the
# showcase avoids; add its range below and re-run if you need one.
set -euo pipefail
SRC="${1:?usage: tool/subset_fonts.sh <dir with the full fonts>}"
OUT="$(dirname "$0")/../assets/fonts"
U="U+0000-00FF,U+0131,U+0152-0153,U+02C6,U+02DA,U+02DC,U+2000-206F,U+20AC,U+20B1,U+2122,U+2190-21FF,U+2212,U+2215,U+2248,U+2264-2265,U+2605,U+2713,U+2715,U+FEFF"
for f in Roboto-Regular Roboto-Medium Roboto-Bold RobotoMono-Regular; do
  pyftsubset "$SRC/$f.ttf" --unicodes="$U" --layout-features='*' \
    --no-hinting --desubroutinize --output-file="$OUT/$f.ttf"
done
