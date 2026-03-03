# toxicwind/niri

[![Fork](https://img.shields.io/badge/repo-fork-1f6feb)](https://github.com/toxicwind/niri)
[![Upstream](https://img.shields.io/badge/upstream-YaLTeR%2Fniri-30363d)](https://github.com/YaLTeR/niri)
[![Language](https://img.shields.io/badge/language-Rust-b7410e)](https://www.rust-lang.org/)
[![Wayland](https://img.shields.io/badge/target-Wayland-2ea043)](https://wayland.app/)

Fork of [YaLTeR/niri](https://github.com/YaLTeR/niri) focused on downstream profile packs, interaction tuning, and compositor-level experiments while keeping upstream compatibility as the default posture.

## Upstream
- Upstream repository: [YaLTeR/niri](https://github.com/YaLTeR/niri)
- Upstream documentation: [niri-wm.github.io/niri](https://niri-wm.github.io/niri/)
- Snapshot of upstream README at fork-time: [README.md.orig](./README.md.orig)

## Tracks
| Track | Status | Path | Notes |
|---|---|---|---|
| AppleMax Profile Pack | Active | [`contrib/applemax-profile`](./contrib/applemax-profile) | Single-profile modular config, safe defaults, opt-in routing |

## Fork Helpers
- Live diagnostics helper: [`helpers/niri-applemax-helper.sh`](./helpers/niri-applemax-helper.sh)

Run helper directly from repo:
```bash
./helpers/niri-applemax-helper.sh
```

## Quick Start
```bash
git clone https://github.com/toxicwind/niri.git
cd niri/contrib/applemax-profile
./install.sh
niri validate -c ~/.config/niri/config.kdl
niri msg action load-config-file
```

Enable routing rules only if needed:
```bash
./install.sh --enable-routing
```

## Design Rules
- Keep upstream niri behavior as baseline.
- Keep track-specific logic under `contrib/`.
- Prefer opt-in behavior for actions that can move windows unexpectedly.
- Validate config before every live reload.

## Roadmap
- Add additional profile packs as separate tracks under `contrib/`.
- Keep each track independently installable with explicit docs.
- Maintain a minimal diff against upstream for easier rebasing.
