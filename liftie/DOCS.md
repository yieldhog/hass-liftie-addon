# Liftie

Self-hosted [Liftie](https://github.com/pirxpilot/liftie) — a small, free,
open-source (BSD-3-Clause) service that reports **ski-resort lift status**. It
exposes the same data that some paid RapidAPI products resell, but with **no API
key and no request quota**.

This add-on is meant to pair with the
[Ski Resort](https://github.com/yieldhog/ski-resort-ha) Home Assistant
integration: point the integration's **Liftie base URL** at this add-on and live
lift status comes from your own instance instead of a metered API.

## Installation

1. In Home Assistant go to **Settings → Add-ons → Add-on Store**.
2. Click the **⋮** menu (top right) → **Repositories**.
3. Add: `https://github.com/yieldhog/hass-liftie-addon`
4. Find **Liftie** in the store, open it, and click **Install**.
5. Click **Start**. (First start builds the image and may take a few minutes.)

## Configuration

```yaml
resorts: []
active_interval: 1
inactive_interval: 30
```

- **`resorts`** — an optional allowlist of resorts.
  - In the **Configuration** tab, each entry is a **searchable dropdown** of
    every resort this add-on bundles (start typing to filter, e.g. `vail`) — so
    you pick valid slugs instead of guessing spellings.
  - **Empty (default):** Liftie tracks *every* bundled resort and re-scrapes
    them all roughly every 30 minutes. This produces harmless `403/404` log
    noise for resorts that block scrapers, and a lot of outbound requests.
  - **Set:** on start, the add-on removes every other resort so Liftie only
    knows about — and only scrapes — the ones you picked. The chosen slug is
    also what you use in the integration and at `/api/resort/<slug>`.

- **`active_interval`** (minutes, default `1`) — how often Liftie refreshes a
  resort that was **requested recently** (e.g. right after the integration polls
  it).
- **`inactive_interval`** (minutes, default `30`) — how often Liftie refreshes
  **every** resort it tracks, even if nothing requested it. This is the main
  "how often does it scrape" knob — raise it to scrape less often.
- **`user_agent`** — sets Liftie's `LIFTIE_USER_AGENT`. **Defaults to a
  browser-like string** (Chrome on Linux), because some resorts return `403` to
  Liftie's built-in scraper UA. Clear the field to use Liftie's own default
  instead, or set your own.

Example (Configuration tab) — only Vail, refreshed at most every 15 minutes:

```yaml
resorts:
  - vail
active_interval: 5
inactive_interval: 15
```

> Changes take effect on the next add-on **restart**. Since the Ski Resort
> integration polls on its own interval (default every 3 hours), you rarely need
> the intervals very short — the integration reads whatever Liftie last scraped.

## Using it with the Ski Resort integration

In the Ski Resort integration's options, set:

- **Liftie base URL** → `http://<your-home-assistant-host>:3000`
  - e.g. `http://homeassistant.local:3000` or `http://192.168.1.x:3000`

The integration prefers a Liftie base URL over any RapidAPI key, so once this is
set your lift status no longer touches RapidAPI (and its quota).

### Finding your resort's slug

Liftie identifies resorts by a slug (e.g. `vail`, `winter-park`). The Ski Resort
integration auto-fills the slug from its bundled crosswalk for most areas; if
yours is blank or wrong, browse [liftie.info](https://liftie.info) — the slug is
the last part of the resort URL — and set it in the integration's **Lift slug**
option.

You can sanity-check the add-on directly in a browser:
`http://<your-home-assistant-host>:3000/api/resort/vail`

## Notes

- Liftie fetches lift status by scraping each resort's site on a schedule, so the
  add-on needs outbound internet access (normal for a Home Assistant host).
- Ports: the add-on maps container port **3000** to host port **3000**. If 3000
  is already in use on your host, change the mapping on the add-on's
  **Configuration → Network** tab and update the integration's base URL to match.

## Keeping the backend up to date

Liftie has no release tags; it's updated with new commits — mostly **new
resorts** and **parser fixes** when a resort changes its website. A stale
backend can cause a resort's lift status to silently stop updating, so it's
worth refreshing periodically **during ski season**.

This repo checks for you: a weekly GitHub Action
([`update-check.yml`](../.github/workflows/update-check.yml)) compares the pinned
Liftie commit against upstream and, when it has moved, opens a **pull request**
that repins the commit, regenerates the resort dropdown, and bumps the version.
So "when should I update?" = "when a *Update Liftie backend* PR appears." Review
and merge it, then update the add-on in Home Assistant.

To update manually instead, run `scripts/update-resorts.sh` (optionally with a
git ref), add a CHANGELOG entry, and push.

## Disclaimer

- This add-on only **packages and runs** [Liftie](https://github.com/pirxpilot/liftie);
  it is **not affiliated with or endorsed by** Liftie/pirxpilot, Home Assistant,
  OpenSnow, or any ski resort.
- Lift status is scraped from public resort sites on a best-effort basis and may
  be **delayed, incomplete, or wrong**. Do not rely on it for safety decisions;
  always confirm conditions with the resort.
- Provided **as-is, without warranty** (see [LICENSE](../LICENSE)). The packaging
  here is MIT-licensed; Liftie itself is BSD-3-Clause by its own authors.
- Please use responsibly — keep the integration's poll interval reasonable so you
  don't hammer resort websites.
