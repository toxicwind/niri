#!/usr/bin/env bash
set -euo pipefail

CFG="${HOME}/.config/niri/config.kdl"
APEX_DIR="${HOME}/.config/niri/apex"
ACTIVE="${APEX_DIR}/active.kdl"
OUT_ROOT="${HOME}/Downloads/niri-applemax-helper"
TS="$(date +%Y%m%d_%H%M%S)"
OUT_DIR="${OUT_ROOT}/${TS}"
REPORT="${OUT_DIR}/report.txt"
RELOAD=1
START_ISO="$(date -Is)"

usage() {
  cat <<USAGE
Usage: niri-applemax-helper.sh [--no-reload]

Options:
  --no-reload  Skip 'niri msg action load-config-file'
USAGE
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --no-reload) RELOAD=0; shift ;;
    -h|--help) usage; exit 0 ;;
    *) echo "unknown arg: $1" >&2; usage >&2; exit 2 ;;
  esac
done

mkdir -p "$OUT_DIR"

# Non-interrupting safety: force-close spotlight/launcher before audit.
if command -v dms >/dev/null 2>&1; then
  dms ipc spotlight close >/dev/null 2>&1 || true
  dms ipc launcher close >/dev/null 2>&1 || true
fi

echo "=== niri-applemax-helper ===" > "$REPORT"
echo "time: $(date -Is)" >> "$REPORT"
echo "host: $(hostname)" >> "$REPORT"
echo "out:  $OUT_DIR" >> "$REPORT"
echo >> "$REPORT"

append() {
  local title="$1"
  echo "--- ${title} ---" >> "$REPORT"
  shift
  "$@" >> "$REPORT" 2>&1 || true
  echo >> "$REPORT"
}

append "niri versions" bash -lc 'niri --version; echo; niri msg version'

echo "--- validate ---" >> "$REPORT"
if niri validate -c "$CFG" >> "$REPORT" 2>&1; then
  VALIDATE_STATUS="PASS"
else
  VALIDATE_STATUS="FAIL"
fi
echo >> "$REPORT"

if [[ "$RELOAD" -eq 1 ]]; then
  echo "--- reload ---" >> "$REPORT"
  if niri msg action load-config-file >> "$REPORT" 2>&1; then
    RELOAD_STATUS="PASS"
  else
    RELOAD_STATUS="FAIL"
  fi
  echo >> "$REPORT"
else
  RELOAD_STATUS="SKIPPED"
fi

append "focused output" niri msg -j focused-output
append "workspaces" niri msg -j workspaces
append "windows" niri msg -j windows
append "layers" niri msg -j layers
append "journal (since helper start)" journalctl --user -u niri.service --since "$START_ISO" --no-pager

# Save machine-readable dumps too.
niri msg -j workspaces > "$OUT_DIR/workspaces.json" 2>/dev/null || true
niri msg -j windows > "$OUT_DIR/windows.json" 2>/dev/null || true
niri msg -j layers > "$OUT_DIR/layers.json" 2>/dev/null || true
niri msg -j outputs > "$OUT_DIR/outputs.json" 2>/dev/null || true

# Include resolution checks for active includes and symlinks.
{
  echo "--- include + symlink integrity ---"
  if [[ -f "$ACTIVE" ]]; then
    mapfile -t includes < <(sed -n 's/^\s*include\s\+"\([^"]\+\)".*/\1/p' "$ACTIVE")
    for inc in "${includes[@]}"; do
      p="${APEX_DIR}/${inc}"
      if [[ -L "$p" ]]; then
        target="$(readlink "$p")"
        if [[ -e "$p" ]]; then
          echo "OK symlink  ${inc} -> ${target}"
        else
          echo "BROKEN LINK ${inc} -> ${target}"
        fi
      elif [[ -f "$p" ]]; then
        echo "OK file     ${inc}"
      else
        echo "MISSING     ${inc}"
      fi
    done
  else
    echo "MISSING active.kdl: $ACTIVE"
  fi
  echo
} >> "$REPORT"

# Compare layer-rule namespaces to live namespaces.
{
  echo "--- namespace audit (enabled layer-rule vs live layers) ---"
  live_ns="$(jq -r '.[].namespace' "$OUT_DIR/layers.json" 2>/dev/null | sort -u || true)"
  enabled_layer_files=$(ls "$APEX_DIR"/mods.enabled/*layer* 2>/dev/null || true)
  if [[ -n "${enabled_layer_files}" ]]; then
    while IFS= read -r f; do
      [[ -z "$f" ]] && continue
      echo "file: $f"
      rg -n 'match namespace=' "$f" || true
    done <<< "$enabled_layer_files"
  else
    echo "No enabled *layer* mod files found."
  fi
  echo
  echo "live namespaces:"
  echo "$live_ns"
  echo
} >> "$REPORT"

# Capture one screenshot per output if grim exists.
if command -v grim >/dev/null 2>&1; then
  mapfile -t outputs < <(niri msg -j outputs | jq -r 'keys[]' 2>/dev/null || true)
  for out in "${outputs[@]}"; do
    [[ -z "$out" ]] && continue
    grim -o "$out" "$OUT_DIR/${out}.png" >/dev/null 2>&1 || true
  done
  echo "screenshots: captured with grim" >> "$REPORT"
else
  echo "screenshots: skipped (grim not found)" >> "$REPORT"
fi

{
  echo
  echo "--- summary ---"
  echo "validate: ${VALIDATE_STATUS}"
  echo "reload:   ${RELOAD_STATUS}"
  recent_errors="$(journalctl --user -u niri.service --since "$START_ISO" --no-pager | rg -n 'error loading config|failed to parse|failed to read included config|error parsing KDL' || true)"
  if [[ -n "$recent_errors" ]]; then
    echo "recent-config-errors: YES"
    echo "$recent_errors"
  else
    echo "recent-config-errors: NO"
  fi
} >> "$REPORT"

echo >> "$REPORT"
echo "report: $REPORT" >> "$REPORT"

cat "$REPORT"
