#!/usr/bin/env bash
set -Eeuo pipefail
IFS=$'\n\t'

resolve_script_path() {
  local path="$1"

  if command -v realpath >/dev/null 2>&1; then
    realpath "$path" 2>/dev/null && return
  fi

  if command -v readlink >/dev/null 2>&1; then
    readlink -f "$path" 2>/dev/null && return
  fi

  local dir
  dir="$(cd -P "$(dirname "$path")" && pwd)"
  printf '%s/%s\n' "$dir" "$(basename "$path")"
}

SCRIPT_PATH="$(resolve_script_path "${BASH_SOURCE[0]}")"
MODULE_DIR="$(cd "$(dirname "$SCRIPT_PATH")" && pwd -P)"
ROOT_DIR="$(cd "$MODULE_DIR/.." && pwd -P)"
DEST="$HOME/.config/hypr"
SESSION_TARGET="${XDG_CONFIG_HOME:-$HOME/.config}/systemd/user/hyprland-session.target"

source "$ROOT_DIR/setup/lib.sh"

case "${1:-}" in
  enable)
    link_path "$MODULE_DIR" "$DEST"
    link_path "$MODULE_DIR/hyprland-session.target" "$SESSION_TARGET"
    ;;
  disable)
    unlink_path "$MODULE_DIR" "$DEST"
    unlink_path "$MODULE_DIR/hyprland-session.target" "$SESSION_TARGET"
    ;;
  *)
    error "Usage: bash $MODULE_DIR/setup.sh <enable|disable>"
    exit 1
    ;;
esac
