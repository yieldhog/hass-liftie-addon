#!/usr/bin/env bash
# Regenerate the pinned Liftie commit and the embedded resort dropdown so they
# stay in sync. Run this when bumping the Liftie version.
#
# Usage:
#   scripts/update-resorts.sh [<git-ref>]   # default: origin/HEAD (latest main)
#
# It clones Liftie at the chosen ref, then rewrites in liftie/config.yaml:
#   * (you) the ARG LIFTIE_COMMIT in liftie/Dockerfile — printed at the end
#   * the schema.resorts list(...) with every bundled resort slug
set -euo pipefail

REF="${1:-}"
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

git clone --quiet --depth 1 ${REF:+--branch "$REF"} \
    https://github.com/pirxpilot/liftie "$TMP/liftie"
SHA="$(git -C "$TMP/liftie" rev-parse HEAD)"
SLUGS="$(ls "$TMP/liftie/lib/resorts" | sort | paste -sd'|')"
COUNT="$(ls "$TMP/liftie/lib/resorts" | wc -l | tr -d ' ')"

python3 - "$ROOT/liftie/config.yaml" "$SLUGS" <<'PY'
import re, sys
path, slugs = sys.argv[1], sys.argv[2]
s = open(path).read()
s = re.sub(r'(\n  resorts:\n    - )"list\([^"]*\)"',
           r'\1"list(%s)"' % slugs.replace('\\', r'\\'), s, count=1)
open(path, 'w').write(s)
PY

# Pin the Dockerfile to the same commit.
sed -i -E "s/(ARG LIFTIE_COMMIT=)[0-9a-f]+/\1${SHA}/" "$ROOT/liftie/Dockerfile"

echo "Updated to Liftie ${SHA} with ${COUNT} resorts."
echo "Remember to bump liftie/config.yaml version and update the CHANGELOG."
