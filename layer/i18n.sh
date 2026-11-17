#!/usr/bin/env bash
# Fetch the translations a Loloshop tree embeds, renamed to match it. Since PhotoCraft 957b10ccc
# the catalogs live in storytold/craft-i18n (at the commit in the tree's craft-i18n.rev), and
# crates/ui-egui/build.rs embeds them from CRAFT_I18N_DIR. rename.sh turned "PhotoCraft" into
# "Loloshop" in the English keys (`tl!("About Loloshop")`), so the catalogs get the same rename,
# or those strings show in English. Then the rows the layer adds.
#
#   layer/i18n.sh <dir> <loloshop tree>
#
# <dir> is replaced. Point CRAFT_I18N_DIR at it (an absolute Windows path on Windows).
set -euo pipefail
DIR="$1"
REV="$(tr -d '[:space:]' < "$2/craft-i18n.rev")"

rm -rf "$DIR"
git init -q "$DIR"
git -C "$DIR" config core.autocrlf false
git -C "$DIR" fetch -q --depth=1 https://github.com/storytold/craft-i18n.git "$REV"
git -C "$DIR" checkout -q FETCH_HEAD
cd "$DIR/locales"

# Only the catalogs Loloshop reads: each locale's photocraft.tsv and the shared common.tsv.
ls */photocraft.tsv */common.tsv | xargs grep -l "PhotoCraft" | xargs -r sed -i 's/PhotoCraft/Loloshop/g'

# What the start screen shows instead of PhotoCraft's links (loloshop.patch, links.rs).
PTBR=pt-br/photocraft.tsv
if ! grep -q $'^\tBased on Photoshop\t' "$PTBR"; then
  [ -z "$(tail -c1 "$PTBR")" ] || echo >> "$PTBR"
  printf '\tBased on Photoshop\tBaseado no Photoshop\n' >> "$PTBR"
fi
echo "craft-i18n $REV in $DIR"
