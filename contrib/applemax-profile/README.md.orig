# AppleMax For Niri

> A single, modular, Niri-native profile pack.
> Upstream-first structure, downstream aesthetics.

## Design Intent
AppleMax is not a compositor fork.  
It is a clean Niri profile layout that keeps upstream semantics and gives you one opinionated profile to iterate on.

## Upstream First
- Compositor upstream: [YaLTeR/niri](https://github.com/YaLTeR/niri)
- Niri docs: [yalter.github.io/niri](https://yalter.github.io/niri/)
- Theme references used in this workflow:
  - [vinceliuice/WhiteSur-gtk-theme](https://github.com/vinceliuice/WhiteSur-gtk-theme)
  - [vinceliuice/WhiteSur-firefox-theme](https://github.com/vinceliuice/WhiteSur-firefox-theme)

## Profile Architecture
```text
~/.config/niri/config.kdl
  -> include "apex/active.kdl"
       -> include "mods.enabled/*.kdl"
            -> symlink to "mods.available/*.kdl"
```

## What This Pack Ships
| File | Role |
|---|---|
| `active.kdl` | The single include entrypoint for AppleMax |
| `mods.available/*.kdl` | Canonical module files |
| `config.kdl.example` | Example top-level wiring |
| `install.sh` | Non-destructive installer |

## Compatibility
- Recommended Niri: `25.11+`
- Required features in this pack:
  - `recent-windows` actions (`next-window`, `previous-window`)
  - `gestures { hot-corners { ... } }`
- Core commands:
  - `niri validate -c ~/.config/niri/config.kdl`
  - `niri msg action load-config-file`

## Install (From Fork Branch)
```bash
git clone --branch codex/applemax-profile-pack https://github.com/toxicwind/niri.git
cd niri/contrib/applemax-profile
./install.sh
```

Then ensure this exists in `~/.config/niri/config.kdl`:

```kdl
include "apex/active.kdl"
```

Apply safely:

```bash
niri validate -c ~/.config/niri/config.kdl
niri msg action load-config-file
```

## Niri-Forward Tuning Order
1. `72-window-routing-rules.kdl`: controls app routing across workspaces.
2. `73-pip-fix.kdl`: controls PiP float behavior, size, and output.
3. `40-recent-windows-switcher.kdl`: Alt-Tab UX and output scope.
4. `60-layer-fuzzel-polish.kdl`, `61-layer-waybar-polish.kdl`, `62-backdrop-wallpaper.kdl`: namespace-sensitive layer styling.

Check layer namespaces before tuning layer files:

```bash
niri msg -j layers
```

## Verification
```bash
niri validate -c ~/.config/niri/config.kdl
niri msg -j workspaces
niri msg -j windows
niri msg -j layers
```

Expected:
- validate exits `0`
- windows open on intended workspace
- layer namespaces in rules match your actual shell/bar/launcher namespaces
