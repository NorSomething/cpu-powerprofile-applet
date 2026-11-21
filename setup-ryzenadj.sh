#!/bin/sh
set -eu

repo_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
ryzenadj_bin=${RYZENADJ:-/usr/local/bin/ryzenadj}

if [ ! -x "$ryzenadj_bin" ]; then
  printf 'RyzenAdj executable not found: %s\nInstall it first or set RYZENADJ=/path/to/ryzenadj.\n' "$ryzenadj_bin" >&2
  exit 1
fi

sudo install -o root -g root -m 0755 "$repo_dir/scripts/cpu-mode-normal" /usr/local/sbin/cpu-mode-normal
sudo install -o root -g root -m 0755 "$repo_dir/scripts/cpu-mode-gaming" /usr/local/sbin/cpu-mode-gaming
sudo install -o root -g root -m 0755 "$repo_dir/scripts/cpu-mode-saving" /usr/local/sbin/cpu-mode-saving

tmp_rule=$(mktemp)
trap 'rm -f "$tmp_rule"' EXIT HUP INT TERM
printf '%s ALL=(root) NOPASSWD: /usr/local/sbin/cpu-mode-normal, /usr/local/sbin/cpu-mode-gaming, /usr/local/sbin/cpu-mode-saving\n' "$(id -un)" > "$tmp_rule"
sudo install -o root -g root -m 0440 "$tmp_rule" /etc/sudoers.d/zz-cpu-power-modes
sudo visudo -cf /etc/sudoers

printf 'Installed RyzenAdj mode scripts and sudo rule.\n'
printf 'Verify with: sudo -n /usr/local/sbin/cpu-mode-gaming\n'
