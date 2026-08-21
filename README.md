# yieldhog Home Assistant Add-ons

A Home Assistant add-on repository.

## Add this repository

**Settings → Add-ons → Add-on Store → ⋮ → Repositories**, then add:

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
