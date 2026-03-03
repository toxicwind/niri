# AppleMax Profile Pack (Apex)

This folder snapshots a live modular Niri profile from `/home/toxic/.config/niri`.

## Contents
- `active.kdl`: include list for enabled profile mods
- `mods.available/*.kdl`: individual profile modules
- `config.kdl.example`: top-level example that includes `apex/active.kdl`

## Usage
1. Copy `mods.available/` files to `~/.config/niri/apex/mods.available/`.
2. Ensure enabled symlinks exist in `~/.config/niri/apex/mods.enabled/`.
3. Copy `active.kdl` to `~/.config/niri/apex/active.kdl`.
4. Merge `config.kdl.example` with your own `~/.config/niri/config.kdl`.
5. Validate and live reload:
   - `niri validate -c ~/.config/niri/config.kdl`
   - `niri msg action load-config-file`

## Notes
- Routing rules in `72-window-routing-rules.kdl` can move app windows to named workspaces.
- PiP behavior is controlled by `73-pip-fix.kdl`.
- Layer namespaces in this pack may need adapting to your shell/bar namespace names.
