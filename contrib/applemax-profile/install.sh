#!/usr/bin/env bash
set -euo pipefail
SRC_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
NIRI_DIR="${HOME}/.config/niri"
APEX_DIR="${NIRI_DIR}/apex"
mkdir -p "${APEX_DIR}/mods.available" "${APEX_DIR}/mods.enabled"

cp -f "${SRC_DIR}/active.kdl" "${APEX_DIR}/active.kdl"
cp -f "${SRC_DIR}/mods.available"/*.kdl "${APEX_DIR}/mods.available/"

# Enable all shipped mods.
for f in "${APEX_DIR}/mods.available"/*.kdl; do
  bn="$(basename "$f")"
  ln -sfn "../mods.available/${bn}" "${APEX_DIR}/mods.enabled/${bn}"
done

# Do not overwrite user config.kdl; print expected include.
echo "Add this line to ${NIRI_DIR}/config.kdl if missing:"
echo "include \"apex/active.kdl\""

echo "Validate: niri validate -c ${NIRI_DIR}/config.kdl"
echo "Reload:   niri msg action load-config-file"
