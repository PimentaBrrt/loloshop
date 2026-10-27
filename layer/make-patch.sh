#!/usr/bin/env bash
# Save the code changes in a tree made by build-tree.sh as the new loloshop.patch, based on the
# PhotoCraft commit that tree came from. Use it after fixing a conflict or changing Loloshop's code.
#
#   layer/make-patch.sh <dir>
#
# The patch is everything that differs from "Loloshop: rename" (PhotoCraft + rename.sh), committed
# or not, except the files overlay.sh owns (the app icon and NOTICE).
set -euo pipefail
LAYER="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$1"

RENAME="$(git log --format=%H -1 --grep='^Loloshop: rename$')"
[ -n "$RENAME" ] || { echo "error: no \"Loloshop: rename\" commit in $1; run build-tree.sh first" >&2; exit 1; }
git diff "$RENAME" -- . ':(exclude)assets/app-icon' ':(exclude)NOTICE' > "$LAYER/loloshop.patch"
git rev-parse "$RENAME^" > "$LAYER/BASE"
echo "loloshop.patch: $(grep -c '^diff --git' "$LAYER/loloshop.patch") files, based on PhotoCraft $(cat "$LAYER/BASE")"
