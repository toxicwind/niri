# AppleMax For Niri

Fork-facing entrypoint for the AppleMax profile pack.

## Pull
```bash
git clone https://github.com/toxicwind/niri.git
cd niri/contrib/applemax-profile
```

## Install (Single Profile: AppleMax)
```bash
./install.sh
```

Installer behavior:
- installs modules to `~/.config/niri/apex/mods.available`
- enables non-template modules in `~/.config/niri/apex/mods.enabled`
- writes profile entrypoint to `~/.config/niri/apex/active.kdl`
- ensures `include "apex/active.kdl"` in `~/.config/niri/config.kdl`

## Apply
```bash
niri validate -c ~/.config/niri/config.kdl
niri msg action load-config-file
```

## Diagnose (Fork Helper)
```bash
cd ~/path/to/niri-fork
./helpers/niri-applemax-helper.sh
```

## Safety Defaults
- Routing is opt-in by default. `72-window-routing-rules.kdl` is shipped but disabled unless you pass `--enable-routing`.
- Backdrop template is shipped as `90-backdrop-wallpaper.template.kdl` for reference only.

## Notes
- This pack is downstream and Niri-native; upstream compositor remains [YaLTeR/niri](https://github.com/YaLTeR/niri).
- If windows appear on unexpected workspaces, audit `mods.enabled/72-window-routing-rules.kdl` first.
