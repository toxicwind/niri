# AppleMax For Niri (Forked Readme)

This is the fork-facing entrypoint for the AppleMax profile pack.

Original readme preserved here:
- [README.md.orig](./README.md.orig)

## Quick Pull
```bash
git clone --branch codex/applemax-profile-pack https://github.com/toxicwind/niri.git
cd niri/contrib/applemax-profile
./install.sh
```

## Apply
```bash
niri validate -c ~/.config/niri/config.kdl
niri msg action load-config-file
```

## Notes
- This pack is downstream and Niri-native; upstream compositor remains [YaLTeR/niri](https://github.com/YaLTeR/niri).
- Edit routing first if apps open on unexpected workspaces: `mods.available/72-window-routing-rules.kdl`.
