# toxicwind/niri

Fork of [YaLTeR/niri](https://github.com/YaLTeR/niri) for experimental compositor tracks, profile packs, and UX tuning.

## Upstream
- Upstream repo: [YaLTeR/niri](https://github.com/YaLTeR/niri)
- Upstream docs: [niri-wm.github.io/niri](https://niri-wm.github.io/niri/)

## Fork Tracks
- `contrib/applemax-profile/`: AppleMax modular profile pack
  - Entry readme: [contrib/applemax-profile/README.md](./contrib/applemax-profile/README.md)
  - Original readme snapshot: [contrib/applemax-profile/README.md.orig](./contrib/applemax-profile/README.md.orig)

## Quick Start (AppleMax)
```bash
git clone https://github.com/toxicwind/niri.git
cd niri/contrib/applemax-profile
./install.sh
niri validate -c ~/.config/niri/config.kdl
niri msg action load-config-file
```

Routing is opt-in (safe default):
```bash
./install.sh --enable-routing
```

## Fork Policy
- Keep upstream Niri as compositor base.
- Keep each track under `contrib/` and independently installable.
- Keep defaults safe; optional behavior should be explicit opt-in.
