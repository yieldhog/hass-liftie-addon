# Changelog

All notable changes to the Liftie add-on are documented here. Versions track
the bundled Liftie release with a `-N` packaging suffix (e.g. `4.4.0-1`).

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
