# Changelog

All notable changes to the Liftie add-on are documented here. Versions track
the bundled Liftie release with a `-N` packaging suffix (e.g. `4.4.0-1`).

## 4.4.0-5

- **Watchdog:** Supervisor now restarts the add-on automatically if Liftie's API
  port stops responding.
- **`user_agent` option:** set a browser-like `LIFTIE_USER_AGENT` to reduce the
  `403` responses some resorts return to the default scraper UA.
- **Automatic update checks:** a weekly workflow opens a PR when upstream Liftie
  moves (repins the commit, regenerates the dropdown, bumps the version) — so
  you get a clear signal when the backend is worth updating. The regen script
  now bumps the version too.

## 4.4.0-4

- The **`resorts`** option is now a **searchable dropdown** of every bundled
  resort (201), so you pick valid slugs instead of typing them — no more
  guessing spellings.
- **Pin Liftie to an exact commit** (`2d0608d`) instead of a non-existent
  `v4.4.0` tag, so builds are reproducible and the dropdown always matches what
  ships. Added `scripts/update-resorts.sh` to regenerate the pin + list together.

## 4.4.0-3

- Add **`active_interval`** and **`inactive_interval`** options (minutes) to
  control how often Liftie re-scrapes. Liftie hard-codes these (1 min / 30 min)
  with no config, so the add-on patches them at startup. Raise
  `inactive_interval` to scrape less often.

## 4.4.0-2

- Add an optional **`resorts`** allowlist. Empty keeps the default behavior
  (Liftie tracks all bundled resorts, re-scraping them every ~30 min); listing
  slugs (e.g. `vail`) trims Liftie at startup so it only knows about — and only
  scrapes — those resorts, cutting the outbound requests and `403/404` log noise.

## 4.4.0-1

- Initial release. Packages [Liftie](https://github.com/pirxpilot/liftie)
  **4.4.0** as a Home Assistant add-on on the official Alpine base images
  (aarch64 / amd64 / armv7).
- Exposes Liftie's HTTP API on port **3000** for the
  [Ski Resort](https://github.com/yieldhog/ski-resort-ha) integration's
  **Liftie base URL** option.
