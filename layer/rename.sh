#!/usr/bin/env bash
# Rename PhotoCraft to Loloshop in a PhotoCraft checkout: every case-sensitive "PhotoCraft" in the
# Rust sources and the translation catalogs, so the English keys (`tl!("…")`) and the .tsv rows stay
# in step. Lowercase `photocraft` (crate names, the exe, env vars, `.pcraft`, the app id) is kept.
#
#   layer/rename.sh <photocraft checkout>
#
# Left alone, because the text is data rather than the product name on screen:
#   crates/cms/                       ICC profile descriptions, baked into committed .icc files
#   files that mention `xmptk`        the XMP toolkit name that marks a sidecar as one we wrote
#   crates/codecs/tests/it/orientation.rs   a byte-level EXIF test sized to "PhotoCraft"
# and a few lines that pair the name with its lowercase are adjusted after the rename (below).
set -euo pipefail
cd "$1"

grep -rlI "PhotoCraft" crates apps --include='*.rs' --include='*.tsv' \
  | grep -v '^crates/cms/' \
  | grep -v '^crates/codecs/tests/it/orientation.rs$' \
  | while read -r f; do grep -q 'xmptk' "$f" || echo "$f"; done \
  | xargs -r sed -i 's/PhotoCraft/Loloshop/g'

# A UI test compares against a crates/cms profile name, which keeps "PhotoCraft".
CHROME=crates/ui-egui/src/panels/chrome_ui.rs
if [ -f "$CHROME" ]; then
  sed -i 's/"Dot Gain 20%-compatible (gamma 1.732, Loloshop)"/"Dot Gain 20%-compatible (gamma 1.732, PhotoCraft)"/' "$CHROME"
fi

# A UI test finds the app name in a window title by its first letter: Loloshop's is "L".
LIVE=crates/ui-egui/src/i18n/live_tests.rs
if [ -f "$LIVE" ]; then
  sed -i "/Loloshop stays at the right/s/x_in(&galley, 'P')/x_in(\&galley, 'L')/" "$LIVE"
fi

# The volume case probe makes a ".PhotoCraftCaseProbe-…" file and looks for it by the same name in
# lowercase: Loloshop's lowercase is "loloshop", or the probe never finds its file and every
# volume reads as case-sensitive (Windows' batch output "same file" checks).
PATHS=crates/engine/src/cmd/file_cmds/paths.rs
if [ -f "$PATHS" ]; then
  sed -i 's/replacen("Loloshop", "photocraft", 1)/replacen("Loloshop", "loloshop", 1)/' "$PATHS"
fi
