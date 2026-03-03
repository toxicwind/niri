# toxicwind/niri

Fork of [YaLTeR/niri](https://github.com/YaLTeR/niri) for experimental profiles, UX polish, and downstream customization.

## Upstream
- Upstream project: [YaLTeR/niri](https://github.com/YaLTeR/niri)
- Upstream docs: [niri-wm.github.io/niri](https://niri-wm.github.io/niri/)

## Fork Tracks
- `contrib/applemax-profile/`: AppleMax modular profile pack
  - Entry readme: [contrib/applemax-profile/README.md](./contrib/applemax-profile/README.md)
  - Original profile readme snapshot: [contrib/applemax-profile/README.md.orig](./contrib/applemax-profile/README.md.orig)

More tracks can be added under `contrib/` without redefining this root README.

## Quick Start (AppleMax Track)
```bash
git clone https://github.com/toxicwind/niri.git
cd niri/contrib/applemax-profile
./install.sh
niri validate -c ~/.config/niri/config.kdl
niri msg action load-config-file
```

## Fork Policy
- Keep upstream Niri as the compositor base.
- Keep profile packs modular and isolated under `contrib/`.
- Prefer additive patches over invasive rewrites.
