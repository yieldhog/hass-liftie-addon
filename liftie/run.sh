#!/usr/bin/with-contenv bashio
# Optionally trim Liftie's bundled resorts to a configured allowlist, then start
# it. Liftie re-scrapes every resort it knows about (~every 30 min); removing the
# folders it loads from is the only way to limit that, since Liftie has no
# resort-filter option of its own.
set -euo pipefail

RESORTS_DIR=/opt/liftie/lib/resorts
OPTIONS=/data/options.json

# Read the list option straight from options.json — one slug per line, empty if
# unset. (jq handles the array cleanly; bashio's list support is fiddly.)
mapfile -t KEEP < <(jq -r '.resorts[]? | select(. != "")' "$OPTIONS" 2>/dev/null || true)

if [ "${#KEEP[@]}" -eq 0 ]; then
    bashio::log.info "No 'resorts' allowlist set — Liftie will track all resorts."
else
    bashio::log.info "Limiting Liftie to: ${KEEP[*]}"
    declare -A wanted=()
    for slug in "${KEEP[@]}"; do
        wanted["$slug"]=1
    done

    kept=0
    for dir in "$RESORTS_DIR"/*/; do
        [ -d "$dir" ] || continue
        id="$(basename "$dir")"
        if [ -z "${wanted[$id]:-}" ]; then
            rm -rf "$dir"
        else
            kept=$((kept + 1))
        fi
    done

    if [ "$kept" -eq 0 ]; then
        bashio::log.warning \
            "None of the configured slugs matched a bundled resort; check spelling. Liftie may have no resorts to serve."
    else
        bashio::log.info "Kept ${kept} resort(s)."
    fi
fi

# --- Scrape frequency -------------------------------------------------------
# Liftie hard-codes its refresh intervals in lib/lifts/index.js and offers no
# config for them, so patch the two constants from the add-on options (minutes).
LIFTS_FILE=/opt/liftie/lib/lifts/index.js
ACTIVE_MIN="$(jq -r '.active_interval // 1' "$OPTIONS")"
INACTIVE_MIN="$(jq -r '.inactive_interval // 30' "$OPTIONS")"
active_ms=$((ACTIVE_MIN * 60 * 1000))
inactive_ms=$((INACTIVE_MIN * 60 * 1000))

if [ -f "$LIFTS_FILE" ]; then
    sed -i \
        -e "s/const shortInterval = 60 \* 1000;/const shortInterval = ${active_ms};/" \
        -e "s/const longInterval = 30 \* shortInterval;/const longInterval = ${inactive_ms};/" \
        "$LIFTS_FILE"
    if grep -q "const shortInterval = ${active_ms};" "$LIFTS_FILE" \
        && grep -q "const longInterval = ${inactive_ms};" "$LIFTS_FILE"; then
        bashio::log.info \
            "Scrape intervals set: active ${ACTIVE_MIN} min, inactive ${INACTIVE_MIN} min."
    else
        bashio::log.warning \
            "Could not patch Liftie's scrape intervals (upstream may have changed); using its defaults."
    fi
fi

cd /opt/liftie
exec node app.js
