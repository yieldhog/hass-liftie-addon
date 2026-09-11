# Home Assistant Add-ons

[![CI][ci-badge]][ci-workflow]
[![Home Assistant Add-on][addon-badge]][addon-docs]
![Supports aarch64][aarch64-badge]
![Supports amd64][amd64-badge]
[![License: MIT][license-badge]][license]

A Home Assistant add-on repository.

## Add this repository

[![Add repository to your Home Assistant instance][my-badge]][my-add]

…or add it manually: **Settings → Add-ons → Add-on Store → ⋮ → Repositories**,
then add:

```
https://github.com/yieldhog/hass-liftie-addon
```

> Add-ons require **Home Assistant OS** or **Supervised**. They are not available
> on a bare Home Assistant Container / Core install.

## Add-ons

### [Liftie](./liftie)

Self-hosted [Liftie](https://github.com/pirxpilot/liftie) — free, unlimited
ski-resort **lift status** with no API key. Pairs with the
[Ski Resort](https://github.com/yieldhog/ski-resort-ha) integration: set the
integration's **Liftie base URL** to `http://<your-home-assistant-host>:3000` and
lift status comes from your own instance instead of a metered RapidAPI plan.

See the [add-on docs](./liftie/DOCS.md) for full setup.

## Disclaimer

These add-ons **package third-party software** for convenience and are **not
affiliated with or endorsed by** the upstream projects, Home Assistant, or any
ski resort. Lift status is scraped from public resort sites and may be delayed
or inaccurate — don't rely on it for safety decisions. Everything is provided
**as-is, without warranty**.

## License

The packaging in this repository (add-on manifests, Dockerfiles, CI, icons, and
docs) is [MIT licensed](./LICENSE). The bundled **Liftie** software is a separate
project by [pirxpilot](https://github.com/pirxpilot/liftie), distributed under
the BSD-3-Clause license.

[ci-badge]: https://github.com/yieldhog/hass-liftie-addon/actions/workflows/ci.yaml/badge.svg
[ci-workflow]: https://github.com/yieldhog/hass-liftie-addon/actions/workflows/ci.yaml
[addon-badge]: https://img.shields.io/badge/Home%20Assistant-Add--on-41BDF5?logo=home-assistant&logoColor=white
[addon-docs]: https://www.home-assistant.io/addons/
[aarch64-badge]: https://img.shields.io/badge/aarch64-yes-brightgreen.svg
[amd64-badge]: https://img.shields.io/badge/amd64-yes-brightgreen.svg
[license-badge]: https://img.shields.io/badge/License-MIT-blue.svg
[license]: ./LICENSE
[my-badge]: https://my.home-assistant.io/badges/supervisor_add_addon_repository.svg
[my-add]: https://my.home-assistant.io/redirect/supervisor_add_addon_repository/?repository_url=https%3A%2F%2Fgithub.com%2Fyieldhog%2Fhass-liftie-addon
