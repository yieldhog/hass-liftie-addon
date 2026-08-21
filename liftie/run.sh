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

cd /opt/liftie
exec node app.js
