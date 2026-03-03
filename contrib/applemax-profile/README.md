# AppleMax For Niri

AppleMax is a modular Niri profile pack built as separate KDL patches with a single entrypoint.

## Scope
- Upstream compositor: [YaLTeR/niri](https://github.com/YaLTeR/niri)
- This pack only configures Niri behavior and layer/window rules.
- It does not patch compositor source code.

## Install
```bash
git clone https://github.com/toxicwind/niri.git
cd niri/contrib/applemax-profile
./install.sh
niri validate -c ~/.config/niri/config.kdl
niri msg action load-config-file
```

Enable app routing only if you explicitly want app->workspace pinning:
```bash
./install.sh --enable-routing
```

## File Layout
- Entry include: `~/.config/niri/apex/active.kdl`
- Patch store: `~/.config/niri/apex/mods.available/*.kdl`
- Enabled set: `~/.config/niri/apex/mods.enabled/*.kdl` symlinks
- Generic example: `config.default.applemax.example.kdl`
- Personal local default (ignored): `config.toxic.applemax.kdl`

## Patch Inventory (Detailed)
1. `layout-staging.kdl`
Purpose: Core window stage composition and depth language.
Key settings: `gaps`, `always-center-single-column`, `center-focused-column`, `focus-ring`, `border { off }`, `shadow`.
Effect: Keeps focused stage visually centered and removes heavy borders in favor of ring+shadow.
Risk: With very small screens, fixed gaps can reduce usable area.

2. `animations-springs.kdl`
Purpose: Apple-like continuity via spring motion instead of abrupt transitions.
Key settings: `slowdown`, spring configs for view movement, window move/resize, workspace switch, overview open/close.
Effect: Motion feels damped and coherent during fast navigation.
Risk: Some users may prefer less motion; reduce by raising damping or disabling animation sections.

3. `overview-mission-control.kdl`
Purpose: Mission Control style overview state.
Key settings: `overview.zoom`, `overview.backdrop-color`.
Effect: Better spatial orientation when entering overview.
Risk: Dark backdrop can feel heavy in very bright themes.

4. `gestures-edge-navigation.kdl`
Purpose: Predictable drag-and-drop edge behavior across views/workspaces.
Key settings: `dnd-edge-view-scroll` and `dnd-edge-workspace-switch` trigger width/height, delay, speed.
Effect: Reduces accidental edge jumps while dragging.
Risk: If delays feel slow, lower `delay-ms`.

5. `gestures-hot-corners.kdl`
Purpose: Fast Mission Control entry without keyboard.
Key settings: `gestures.hot-corners { top-left }`.
Effect: Top-left corner opens overview flow.
Risk: Can trigger unintentionally with aggressive pointer movement.

6. `switcher-recent-windows.kdl`
Purpose: App/window switcher behavior aligned with output-local context.
Key settings: `debounce-ms`, `open-delay-ms`, `highlight`, `previews`, recent-window binds.
Effect: `Alt+Tab` cycles recent windows on current output; app-local cycling on grave binds.
Risk: Requires Niri features for recent-windows actions; verify Niri version compatibility.

7. `windows-surface.kdl`
Purpose: Global surface material coherence for regular windows.
Key settings: `geometry-corner-radius`, `clip-to-geometry`, `variable-refresh-rate`, `scroll-factor`.
Effect: Rounded/clipped edges and smoother rendering profile.
Risk: App-specific edge cases can appear with forced clipping on unusual surfaces.

8. `layers-launcher-glass.kdl`
Purpose: Glass material styling for launcher surfaces.
Key settings: launcher namespace matching, `opacity`, `geometry-corner-radius`, shadow profile.
Effect: Launcher appears as intentional card-like system surface.
Risk: Namespace mismatch means no visible effect; verify with `niri msg -j layers`.

9. `layers-system-bar.kdl`
Purpose: System bar polish across common namespaces.
Key settings: `match namespace="^waybar$"` and `match namespace="^dms:bar$"`, bar opacity.
Effect: Uniform bar translucency independent of bar implementation.
Risk: Multiple bars with same namespace patterns will all receive this opacity.

10. `layers-backdrop-wallpaper.kdl`
Purpose: Mission Control backdrop integration.
Key settings: `place-within-backdrop true` for `wallpaper` and `quickshell`, `layout.background-color "transparent"`.
Effect: Overview backdrop can reuse wallpaper/background layers instead of flat black only.
Risk: If no matching namespace exists, backdrop placement has no effect.

11. `layers-notifications-glass.kdl`
Purpose: Notification/toast card styling.
Key settings: `match namespace="^dms:toast$"`, opacity, corner radius, shadow.
Effect: Toasts blend with AppleMax material system.
Risk: Namespace-specific; other notification daemons may need additional rules.

12. `binds-apple-primitives.kdl`
Purpose: Core AppleMax control chords.
Key settings: `Mod+Space` launcher, `F3`/`Mod+O` overview, mouse back/forward workspace navigation.
Effect: Consistent primary control surface for launcher and Mission Control.
Risk: Conflicts with user-defined binds if already in use.

13. `workspaces-named.kdl`
Purpose: Stable workspace naming conventions.
Key settings: `workspace "work"`, `workspace "chat" { open-on-output "DP-2" }`, `workspace "media"`.
Effect: Predictable target workspaces and monitor affinity for the chat space.
Risk: Output names vary between systems; adjust output id accordingly.

14. `pip-video-floating.kdl`
Purpose: Stabilize Picture-in-Picture behavior and geometry.
Key settings: title/app-id matching, `open-floating`, size bounds, output target, default floating position.
Effect: PiP opens as constrained floating overlay instead of random tiling shape.
Risk: App-id/title patterns can differ by browser variant; tune regex if needed.

15. `routing-apps.kdl` (optional)
Purpose: Deterministic app routing to named workspaces.
Key settings: `match app-id` with `open-on-workspace` and app-specific open rules.
Effect: Telegram/Spotify (and optional browser policy) open in predefined spaces.
Risk: This is the most disruptive patch for users who expect apps to open “where I currently am”. Kept opt-in.

16. `90-backdrop-wallpaper.template.kdl` (template only)
Purpose: Reference snippet for custom backdrop mapping.
Key settings: commented example only.
Effect: Documentation scaffolding, not active behavior.
Risk: None unless manually enabled/edited incorrectly.

## Active Default Set
Default active profile enables patches 1-14 except `routing-apps.kdl`.
`routing-apps.kdl` is intentionally disabled by default and only enabled with `--enable-routing`.

## Diagnostics
Use fork helper for live state checks with reload-by-default:
```bash
cd ~/path/to/niri-fork
./helpers/niri-applemax-helper.sh
```

## Quick Tuning Rules
- If effects do not apply, check namespace mismatches first.
- If windows open “in wrong place,” disable routing patch first.
- If motion feels too floaty, tune spring damping/stiffness in `animations-springs.kdl`.
- If overview feels too dark, tune `backdrop-color` in `overview-mission-control.kdl`.
