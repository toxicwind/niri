# toxicwind/niri

Fork of [YaLTeR/niri](https://github.com/YaLTeR/niri) for downstream profile packs and compositor experiments.

## Upstream Reference
- Original upstream README snapshot: [README.md.orig](./README.md.orig)
- Upstream repository: [YaLTeR/niri](https://github.com/YaLTeR/niri)
- Upstream docs: [niri-wm.github.io/niri](https://niri-wm.github.io/niri/)

## Fork Tracks
- AppleMax profile pack: [contrib/applemax-profile](./contrib/applemax-profile)
  - Usage: [contrib/applemax-profile/README.md](./contrib/applemax-profile/README.md)

## Quick Start (AppleMax)
```bash
git clone https://github.com/toxicwind/niri.git
cd niri/contrib/applemax-profile
./install.sh
niri validate -c ~/.config/niri/config.kdl
niri msg action load-config-file
```

Routing is opt-in:
```bash
./install.sh --enable-routing
```
