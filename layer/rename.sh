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
