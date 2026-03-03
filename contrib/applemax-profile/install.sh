#!/usr/bin/env bash
set -euo pipefail

SRC_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
NIRI_DIR="${HOME}/.config/niri"
APEX_DIR="${NIRI_DIR}/apex"
CONFIG_FILE="${NIRI_DIR}/config.kdl"
INCLUDE_LINE='include "apex/active.kdl"'
ENABLE_ROUTING=0

usage() {
  cat <<USAGE
Usage: ./install.sh [--enable-routing]

Options:
  --enable-routing Enable routing-apps.kdl by default (opt-in)
USAGE
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --enable-routing)
      ENABLE_ROUTING=1
      shift
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

mkdir -p "${APEX_DIR}/mods.available" "${APEX_DIR}/mods.enabled" "${NIRI_DIR}"
cp -f "${SRC_DIR}/active.kdl" "${APEX_DIR}/active.kdl"
cp -f "${SRC_DIR}/mods.available"/*.kdl "${APEX_DIR}/mods.available/"

# Enable semantic module set; keep routing opt-in.
for f in "${APEX_DIR}/mods.available"/*.kdl; do
  bn="$(basename "$f")"
  [[ "$bn" == *.template.kdl ]] && continue
  if [[ "$bn" == "routing-apps.kdl" && "$ENABLE_ROUTING" -ne 1 ]]; then
    rm -f "${APEX_DIR}/mods.enabled/${bn}"
    continue
  fi
  ln -sfn "../mods.available/${bn}" "${APEX_DIR}/mods.enabled/${bn}"
done

if [[ -f "${CONFIG_FILE}" ]]; then
  if ! rg -q '^\s*include\s+"apex/active\.kdl"\s*$' "${CONFIG_FILE}"; then
    cp -f "${CONFIG_FILE}" "${CONFIG_FILE}.bak.$(date +%Y%m%d_%H%M%S)"
    printf "\n%s\n" "${INCLUDE_LINE}" >> "${CONFIG_FILE}"
  fi
else
  cp -f "${SRC_DIR}/config.default.applemax.example.kdl" "${CONFIG_FILE}"
fi

echo "Installed AppleMax profile for user: ${USER:-unknown}"
echo "Profile file: ${APEX_DIR}/active.kdl"
echo "Config include ensured: ${INCLUDE_LINE}"
echo "Validate: niri validate -c ${CONFIG_FILE}"
echo "Reload:   niri msg action load-config-file"
echo
if [[ "$ENABLE_ROUTING" -eq 1 ]]; then
  echo "Routing: enabled (routing-apps.kdl)"
else
  echo "Routing: disabled (opt-in)."
  echo "Enable with: ./install.sh --enable-routing"
fi
