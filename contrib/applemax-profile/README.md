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

## Module Naming
AppleMax modules use semantic names (not numeric prefixes), for example:
- `layout-staging.kdl`
- `switcher-recent-windows.kdl`
- `layers-system-bar.kdl`
- `routing-apps.kdl` (opt-in)

Installer behavior:
- installs modules to `~/.config/niri/apex/mods.available`
- enables non-template modules in `~/.config/niri/apex/mods.enabled`
- writes profile entrypoint to `~/.config/niri/apex/active.kdl`
- ensures `include "apex/active.kdl"` in `~/.config/niri/config.kdl`

## Toxic + Default Config Files
- Personal local default (ignored): `config.toxic.applemax.kdl`
- Generic tracked example: `config.default.applemax.example.kdl`

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
- Routing is opt-in by default. `routing-apps.kdl` is shipped but disabled unless you pass `--enable-routing`.
- Backdrop template is shipped as `90-backdrop-wallpaper.template.kdl` for reference only.
