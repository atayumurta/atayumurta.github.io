#!/usr/bin/env bash
# Exports business cards as 1004×650 px PNGs (300 dpi, 85×55 mm)
set -e

CHROME="/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
DIR="$(cd "$(dirname "$0")" && pwd)"

# Chrome headless reserves ~87px for browser chrome, so use taller window
# and crop the screenshot to the card's 1004×650 area.
ARGS=(--headless=new --disable-gpu --hide-scrollbars
      --window-size=1004,800 --virtual-time-budget=3000)

echo "Exporting front..."
"$CHROME" "${ARGS[@]}" --screenshot="$DIR/_f.png" "file://$DIR/card-front-print.html"

echo "Exporting back..."
"$CHROME" "${ARGS[@]}" --screenshot="$DIR/_b.png"  "file://$DIR/card-back-print.html"

python3 - "$DIR" <<'PYEOF'
import sys
from PIL import Image

d = sys.argv[1]
W, H = 1004, 650

for src, dst in (('_f', 'front'), ('_b', 'back')):
    img = Image.open(f'{d}/{src}.png')
    out = img.crop((0, 0, W, H))
    out.save(f'{d}/{dst}.png', dpi=(300, 300))
    import os; os.remove(f'{d}/{src}.png')
    print(f'  {dst}.png: {out.size}')
PYEOF

echo "Done — front.png & back.png, 1004×650 px @ 300 dpi"
echo "Tell the copyshop: print at 85 × 55 mm"
