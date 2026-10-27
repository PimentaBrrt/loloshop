#!/usr/bin/env bash
# Copy Loloshop's own files over a PhotoCraft checkout (the app icon) and note the fork in NOTICE.
#
#   layer/overlay.sh <photocraft checkout>
set -euo pipefail
LAYER="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$1"

cp -R "$LAYER/overlay/." .

if ! head -1 NOTICE | grep -qx 'Loloshop'; then
  {
    printf 'Loloshop\n'
    printf 'Loloshop is a modified fork of PhotoCraft (https://github.com/storytold/photocraft):\n'
    printf "the product name, app icon, Help links and update check were changed. PhotoCraft's notice follows.\n\n"
    cat NOTICE
  } > NOTICE.loloshop
  mv NOTICE.loloshop NOTICE
fi
