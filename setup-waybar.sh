#!/bin/sh
set -eu

repo_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
config=${WAYBAR_CONFIG:-"$HOME/.config/waybar/config.jsonc"}
style=${WAYBAR_STYLE:-"$HOME/.config/waybar/style.css"}
bin_dir=${XDG_BIN_HOME:-"$HOME/.local/bin"}
menu="$bin_dir/cpu-power-profile-menu"

if ! command -v jq >/dev/null 2>&1; then
  printf 'jq is required to safely merge Waybar configuration. Install jq and rerun.\n' >&2
  exit 1
fi
if ! command -v wofi >/dev/null 2>&1 || ! command -v notify-send >/dev/null 2>&1; then
  printf 'Install wofi and libnotify (notify-send), then rerun.\n' >&2
  exit 1
fi
if [ ! -f "$config" ]; then
  printf 'Waybar config not found: %s\n' "$config" >&2
  exit 1
fi

mkdir -p "$bin_dir" "$(dirname -- "$style")"
install -m 0755 "$repo_dir/scripts/cpu-power-profile-menu" "$menu"

tmp_config=$(mktemp "${config}.XXXXXX")
trap 'rm -f "$tmp_config"' EXIT HUP INT TERM
jq --comments --arg menu "$menu" '
  .["modules-left"] = ((.["modules-left"] // []) | map(select(. != "custom/cpu-power-profile")) + ["custom/cpu-power-profile"])
  | .["custom/cpu-power-profile"] = {
      "exec": ($menu + " --status"),
      "interval": "once",
      "signal": 8,
      "format": "{}",
      "tooltip": "Choose CPU power limit",
      "on-click": $menu
    }
' "$config" > "$tmp_config" || {
  printf 'Could not parse Waybar config as JSONC: %s\nNo config changes made.\n' "$config" >&2
  exit 1
}
cp -p "$config" "$config.backup.$(date +%Y%m%d-%H%M%S)"
cat "$tmp_config" > "$config"

if [ -f "$style" ]; then
  if ! grep -q '#custom-cpu-power-profile' "$style"; then
    printf '\n#custom-cpu-power-profile { padding: 0 10px; }\n' >> "$style"
  fi
else
  printf '#custom-cpu-power-profile { padding: 0 10px; }\n' > "$style"
fi

printf 'Installed Waybar module in %s and launcher at %s.\n' "$config" "$menu"
