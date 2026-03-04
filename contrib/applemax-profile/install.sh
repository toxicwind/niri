#!/usr/bin/env bash
set -euo pipefail

SRC_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
INCLUDE_LINE='include "apex/active.kdl"'
ENABLE_ROUTING=0
TARGET_USER=""

resolve_home_for_user() {
  local user="$1"
  local home

  if command -v getent >/dev/null 2>&1; then
    home="$(getent passwd "$user" | cut -d: -f6)"
  fi
  if [[ -z "${home:-}" ]]; then
    home="/home/${user}"
  fi

  printf '%s\n' "$home"
}

usage() {
  cat <<USAGE
Usage: ./install.sh [--enable-routing] [--user <username>]

Options:
  --enable-routing Enable routing-apps.kdl by default (opt-in)
  --user           Install into /home/<username>/.config/niri
USAGE
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --enable-routing)
      ENABLE_ROUTING=1
      shift
      ;;
    --user)
      if [[ $# -lt 2 ]]; then
        echo "--user requires a value" >&2
        usage >&2
        exit 2
      fi
      TARGET_USER="$2"
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "unknown arg: $1" >&2
      usage >&2
      exit 2
      ;;
  esac
done

TARGET_HOME="${HOME}"
if [[ -n "${TARGET_USER}" ]]; then
  TARGET_HOME="$(resolve_home_for_user "$TARGET_USER")"
fi

NIRI_DIR="${TARGET_HOME}/.config/niri"
APEX_DIR="${NIRI_DIR}/apex"
CONFIG_FILE="${NIRI_DIR}/config.kdl"
APEX_CFG_DIR="${TARGET_HOME}/.config/apex"
APEX_SCRIPTS_DIR="${APEX_CFG_DIR}/scripts"
SYSTEMD_USER_DIR="${TARGET_HOME}/.config/systemd/user"
NIRI_WANTS_DIR="${SYSTEMD_USER_DIR}/niri.service.wants"

mkdir -p "${APEX_DIR}/mods.available" "${APEX_DIR}/mods.enabled" "${NIRI_DIR}"
mkdir -p "${APEX_SCRIPTS_DIR}" "${APEX_CFG_DIR}/flags" "${SYSTEMD_USER_DIR}" "${NIRI_WANTS_DIR}"
cp -f "${SRC_DIR}/active.kdl" "${APEX_DIR}/active.kdl"
cp -f "${SRC_DIR}/mods.available"/*.kdl "${APEX_DIR}/mods.available/"
cp -f "${SRC_DIR}/scripts/"* "${APEX_SCRIPTS_DIR}/"
chmod +x "${APEX_SCRIPTS_DIR}/"*
cp -f "${SRC_DIR}/systemd/"*.service "${SYSTEMD_USER_DIR}/"

# Default enabled services for AppleMax "max-level" UX.
for svc in \
  apex-session.service \
  niri-float-sticky.service \
  nirinit.service
do
  ln -sfn "../${svc}" "${NIRI_WANTS_DIR}/${svc}"
done

# Keep overlapping daemons installed but disabled in DMS-native baseline.
rm -f "${NIRI_WANTS_DIR}/niri-switch-daemon.service"
rm -f "${NIRI_WANTS_DIR}/niri-sidebar.service"

# Keep this alternative session manager available but disabled by default
# to avoid running two session-restore daemons simultaneously.
rm -f "${NIRI_WANTS_DIR}/niri-session-manager.service"

# Record default operating mode for helper scripts.
printf '%s\n' "dms-native" > "${APEX_CFG_DIR}/flags/mode"

# Enable only the active AppleMax baseline module set.
find "${APEX_DIR}/mods.enabled" -maxdepth 1 -name '*.kdl' -delete
for bn in \
  layout-staging.kdl \
  animations-springs.kdl \
  overview-mission-control.kdl \
  gestures-edge-navigation.kdl \
  gestures-hot-corners.kdl \
  windows-surface.kdl \
  layers-launcher-glass.kdl \
  layers-system-bar.kdl \
  layers-backdrop-wallpaper.kdl \
  layers-notifications-glass.kdl \
  binds-apple-primitives.kdl \
  workspaces-named.kdl \
  pip-video-floating.kdl
do
  if [[ -f "${APEX_DIR}/mods.available/${bn}" ]]; then
    ln -sfn "../mods.available/${bn}" "${APEX_DIR}/mods.enabled/${bn}"
  fi
done

# Keep optional "plus" include parse-safe by default.
cat > "${APEX_DIR}/mods.enabled/dms-native-plus.kdl" <<'EOF'
// Optional dms-native-plus module (disabled by default).
EOF
cat > "${APEX_DIR}/mods.enabled/ux-workspaces-experiment.kdl" <<'EOF'
// Optional workspace experiment slot.
EOF
cat > "${APEX_DIR}/mods.enabled/ux-routing-experiment.kdl" <<'EOF'
// Optional routing experiment slot.
EOF
cat > "${APEX_DIR}/mods.enabled/ux-gestures-experiment.kdl" <<'EOF'
// Optional gestures experiment slot.
EOF
cat > "${APEX_DIR}/mods.enabled/ux-binds-experiment.kdl" <<'EOF'
// Optional binds experiment slot.
EOF
cat > "${APEX_DIR}/mods.enabled/ux-overview-experiment.kdl" <<'EOF'
// Optional overview experiment slot.
EOF
cat > "${APEX_DIR}/mods.enabled/ux-throws-experiment.kdl" <<'EOF'
// Optional monitor throw experiment slot.
EOF
if [[ "$ENABLE_ROUTING" -eq 1 && -f "${APEX_DIR}/mods.available/routing-apps.kdl" ]]; then
  ln -sfn "../mods.available/routing-apps.kdl" "${APEX_DIR}/mods.enabled/routing-apps.kdl"
fi

if [[ -f "${CONFIG_FILE}" ]]; then
  if ! rg -q '^\s*include\s+"apex/active\.kdl"\s*$' "${CONFIG_FILE}"; then
    cp -f "${CONFIG_FILE}" "${CONFIG_FILE}.bak.$(date +%Y%m%d_%H%M%S)"
    printf "\n%s\n" "${INCLUDE_LINE}" >> "${CONFIG_FILE}"
  fi
else
  cp -f "${SRC_DIR}/config.default.applemax.example.kdl" "${CONFIG_FILE}"
fi

# Ensure DMS-managed config fragments are included when present.
for dms_line in \
  'include "dms/colors.kdl"' \
  'include "dms/layout.kdl"' \
  'include "dms/alttab.kdl"' \
  'include "dms/binds.kdl"' \
  'include "dms/outputs.kdl"' \
  'include "dms/cursor.kdl"' \
  'include "dms/windowrules.kdl"' \
  'include "dms/wpblur.kdl"'
do
  if ! grep -Fqx "${dms_line}" "${CONFIG_FILE}" 2>/dev/null; then
    printf "%s\n" "${dms_line}" >> "${CONFIG_FILE}"
  fi
done

# DMS is primary in AppleMax: disable stock waybar autostart line if present
# to avoid dual bars with DMS.
if rg -n '^\s*spawn-at-startup\s+"waybar"\s*$' "${CONFIG_FILE}" >/dev/null 2>&1; then
  cp -f "${CONFIG_FILE}" "${CONFIG_FILE}.bak.waybar.$(date +%Y%m%d_%H%M%S)"
  sed -i 's/^\(\s*\)spawn-at-startup\s\+"waybar"\s*$/\1\/\/ spawn-at-startup "waybar"  \/\/ managed by AppleMax session-up/' "${CONFIG_FILE}"
fi

echo "Installed AppleMax profile for user: ${TARGET_USER:-${USER:-unknown}}"
echo "Target niri dir: ${NIRI_DIR}"
echo "Profile file: ${APEX_DIR}/active.kdl"
echo "Config include ensured: ${INCLUDE_LINE}"
echo "Session bootstrap: ${APEX_SCRIPTS_DIR}/session-up"
echo "Systemd units installed in: ${SYSTEMD_USER_DIR}"
echo "Enabled by default (niri.service.wants):"
echo "  apex-session.service, niri-float-sticky.service, nirinit.service"
echo "Disabled by default: niri-switch-daemon.service, niri-sidebar.service,"
echo "  niri-session-manager.service"
echo "Validate: niri validate -c ${CONFIG_FILE}"
echo "Reload:   niri msg action load-config-file"
echo
if [[ "$ENABLE_ROUTING" -eq 1 ]]; then
  echo "Routing: enabled (routing-apps.kdl)"
else
  echo "Routing: disabled (opt-in)."
  echo "Enable with: ./install.sh --enable-routing"
fi
echo
echo "Shell mode: DMS primary, Waybar fallback."
echo "Force fallback anytime:"
echo "  touch ${APEX_CFG_DIR}/flags/force-waybar"
echo "  systemctl --user start apex-session.service"
