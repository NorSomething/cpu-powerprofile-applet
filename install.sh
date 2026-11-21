#!/bin/sh
set -eu

repo_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)

if ! command -v ryzenadj >/dev/null 2>&1 && [ ! -x /usr/local/bin/ryzenadj ]; then
  printf 'RyzenAdj was not found. On Void Linux, install/build RyzenAdj first.\n' >&2
  exit 1
fi

"$repo_dir/setup-ryzenadj.sh"
"$repo_dir/setup-waybar.sh"

printf '\nSetup complete. Restart Waybar to load the applet.\n'
