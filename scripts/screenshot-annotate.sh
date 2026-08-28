#!/usr/bin/env bash
set -Eeuo pipefail

for command_name in grim slurp satty wl-copy; do
  if ! command -v "$command_name" >/dev/null 2>&1; then
    notify-send "Annotated screenshot failed" "Missing command: $command_name"
    exit 1
  fi
done

pictures_dir="$(xdg-user-dir PICTURES 2>/dev/null || true)"
if [[ -z "$pictures_dir" ]]; then
  pictures_dir="$HOME/Pictures"
fi

screenshots_dir="$pictures_dir/Screenshots"
timestamp="$(date +'%Y-%m-%d_%H-%M-%S-%N')"
raw_screenshot="$screenshots_dir/screenshot-$timestamp-raw.png"
annotated_screenshot="$screenshots_dir/screenshot-$timestamp.png"

geometry="$(slurp)" || exit 0
mkdir -p "$screenshots_dir"
grim -g "$geometry" "$raw_screenshot"

satty \
  --filename "$raw_screenshot" \
  --floating-hack \
  --output-filename "$annotated_screenshot" \
  --copy-command wl-copy \
  --save-after-copy \
  --early-exit
