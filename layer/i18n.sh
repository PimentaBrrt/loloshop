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

# The texts loloshop.patch adds: the start screen's credit (links.rs), where PhotoCraft had its
# links, and Preferences › AI Integrations (agents.rs), where PhotoCraft names its launcher.
PTBR=pt-br/photocraft.tsv
[ -z "$(tail -c1 "$PTBR")" ] || echo >> "$PTBR"
row() {
  grep -qF $'\t'"$1"$'\t' "$PTBR" || printf '\t%s\t%s\n' "$1" "$2" >> "$PTBR"
}
row "Based on Photoshop" "Baseado no Photoshop"
row "AI apps such as Claude work with Loloshop through its MCP server. Only programs on this computer can connect." \
    "Apps de IA como o Claude trabalham com o Loloshop pelo servidor MCP dele. Só programas deste computador podem se conectar."
row "AI apps use their own copy of Loloshop, not this window." \
    "Os apps de IA usam uma cópia própria do Loloshop, não esta janela."
row "Illostrator" "Illostrator"
echo "craft-i18n $REV in $DIR"
