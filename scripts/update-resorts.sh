#!/usr/bin/env bash
# Sync the pinned Liftie commit, the embedded resort dropdown, the add-on
# version, AND the changelog — all from upstream, in one pass.
#
# Usage:
#   scripts/update-resorts.sh [<git-ref>]   # default: latest upstream main
#
# It clones Liftie at the chosen ref and, ONLY IF something actually changed
# (a new commit, or a different set of bundled resorts):
#   * repins liftie/Dockerfile's ARG LIFTIE_COMMIT,
#   * rewrites the schema.resorts list(...) in liftie/config.yaml,
#   * bumps the add-on version (<upstream package.json version>-<packaging N>),
#   * prepends a generated entry to liftie/CHANGELOG.md — old->new commit with a
#     compare link, the resort additions/removals, and the upstream commit log.
# If nothing changed it exits WITHOUT touching any file, so the weekly workflow
# doesn't open a no-op "update" PR.
set -euo pipefail

REF="${1:-}"
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
CONFIG="$ROOT/liftie/config.yaml"
DOCKERFILE="$ROOT/liftie/Dockerfile"
CHANGELOG="$ROOT/liftie/CHANGELOG.md"
UPSTREAM="https://github.com/pirxpilot/liftie"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

# --- Current (old) state, captured before we change anything ----------------
OLD_SHA="$(grep -oE 'LIFTIE_COMMIT=[0-9a-f]+' "$DOCKERFILE" | cut -d= -f2)"
OLD_SLUGS="$(python3 - "$CONFIG" <<'PY'
import re, sys
s = open(sys.argv[1]).read()
m = re.search(r'\n  resorts:\n    - "list\(([^)]*)\)"', s)
print(m.group(1) if m else "")
PY
)"

# --- Fetch upstream (full history so we can log OLD..NEW) --------------------
git clone --quiet ${REF:+--branch "$REF"} "$UPSTREAM" "$TMP/liftie"
NEW_SHA="$(git -C "$TMP/liftie" rev-parse HEAD)"
NEW_SLUGS="$(ls "$TMP/liftie/lib/resorts" | sort | paste -sd'|')"
COUNT="$(ls "$TMP/liftie/lib/resorts" | wc -l | tr -d ' ')"

# --- Gate: do nothing unless the commit or the resort set actually changed ---
if [ "$OLD_SHA" = "$NEW_SHA" ] && [ "$OLD_SLUGS" = "$NEW_SLUGS" ]; then
    echo "No upstream change (still ${OLD_SHA:0:7}, ${COUNT} resorts). Nothing to do."
    exit 0
fi

# --- Apply the pin + resort list --------------------------------------------
python3 - "$CONFIG" "$NEW_SLUGS" <<'PY'
import re, sys
path, slugs = sys.argv[1], sys.argv[2]
s = open(path).read()
s = re.sub(r'(\n  resorts:\n    - )"list\([^"]*\)"',
           r'\1"list(%s)"' % slugs.replace('\\', r'\\'), s, count=1)
open(path, 'w').write(s)
PY
sed -i -E "s/(ARG LIFTIE_COMMIT=)[0-9a-f]+/\1${NEW_SHA}/" "$DOCKERFILE"

# --- Bump the add-on version: <upstream package.json version>-<packaging N> --
OLD_VER="$(grep -E '^version:' "$CONFIG" | sed -E 's/.*"(.*)".*/\1/')"
UPSTREAM_VER="$(python3 -c "import json;print(json.load(open('$TMP/liftie/package.json'))['version'])")"
OLD_BASE="${OLD_VER%-*}"
OLD_SUFFIX="${OLD_VER##*-}"
if [ "$OLD_BASE" = "$UPSTREAM_VER" ]; then
    NEW_VER="${UPSTREAM_VER}-$((OLD_SUFFIX + 1))"
else
    NEW_VER="${UPSTREAM_VER}-1"
fi
sed -i -E "s/^(version: )\"[^\"]*\"/\1\"${NEW_VER}\"/" "$CONFIG"

# --- Build the changelog entry ----------------------------------------------
DATE="$(date +%F)"
COMPARE="${UPSTREAM}/compare/${OLD_SHA}...${NEW_SHA}"

# Resort additions/removals (set diff of the |-joined slug lists).
resort_line() {
    python3 - "$OLD_SLUGS" "$NEW_SLUGS" "$COUNT" <<'PY'
import sys
old = set(filter(None, sys.argv[1].split("|")))
new = set(filter(None, sys.argv[2].split("|")))
count = sys.argv[3]
added = sorted(new - old)
removed = sorted(old - new)
fmt = lambda xs: ", ".join("`%s`" % x for x in xs)
parts = []
if added:
    parts.append("added " + fmt(added))
if removed:
    parts.append("removed " + fmt(removed))
print(f"- Resorts: {count} bundled — {'; '.join(parts) if parts else 'no resort changes'}.")
PY
}

# Upstream commit subjects between OLD and NEW (capped), when OLD is reachable
# in the clone (it may not be after an upstream force-push — then skip the list).
commit_lines() {
    if ! git -C "$TMP/liftie" cat-file -e "${OLD_SHA}^{commit}" 2>/dev/null; then
        return 0
    fi
    local total
    total="$(git -C "$TMP/liftie" rev-list --count --no-merges "${OLD_SHA}..${NEW_SHA}")"
    if [ "$total" -eq 0 ]; then
        return 0
    fi
    echo "- Upstream commits:"
    git -C "$TMP/liftie" log -n 15 --no-merges --format='  - %s' "${OLD_SHA}..${NEW_SHA}"
    if [ "$total" -gt 15 ]; then
        echo "  - …and $((total - 15)) more (see the compare link above)."
    fi
}

BASE_NOTE=""
if [ "$OLD_BASE" != "$UPSTREAM_VER" ]; then
    BASE_NOTE="- Bundled Liftie version: **${OLD_BASE} → ${UPSTREAM_VER}**."$'\n'
fi

ENTRY="$(cat <<EOF
## ${NEW_VER} — ${DATE}

${BASE_NOTE}- **Updated bundled Liftie** \`${OLD_SHA:0:7}\` → \`${NEW_SHA:0:7}\` ([upstream changes](${COMPARE})).
$(resort_line)
$(commit_lines)
EOF
)"

# Prepend the entry above the most recent existing version entry.
python3 - "$CHANGELOG" "$ENTRY" <<'PY'
import sys
path, entry = sys.argv[1], sys.argv[2]
s = open(path).read()
i = s.find("\n## ")
entry = entry.strip() + "\n\n"
s = (s + "\n" + entry) if i == -1 else s[:i + 1] + entry + s[i + 1:]
open(path, "w").write(s)
PY

echo "Updated to Liftie ${NEW_SHA:0:7} (${COUNT} resorts), add-on version ${NEW_VER}."
echo "Changelog entry for ${NEW_VER} written to liftie/CHANGELOG.md — review before merging."
