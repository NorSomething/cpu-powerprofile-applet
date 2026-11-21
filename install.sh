#!/bin/sh
set -eu

repo_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)

missing_packages=
for pair in 'jq:jq' 'wofi:wofi' 'notify-send:libnotify'; do
  command_name=${pair%%:*}
  package_name=${pair#*:}
  if ! command -v "$command_name" >/dev/null 2>&1; then
    missing_packages="$missing_packages $package_name"
  fi
done

if [ -n "$missing_packages" ]; then
  if [ -r /etc/os-release ]; then
    . /etc/os-release
  fi

  case "${ID:-}" in
    void) package_manager=xbps-install; package_args='-S'; package_prefix='sudo' ;;
    debian|ubuntu|linuxmint|pop|raspbian) package_manager=apt-get; package_args='install'; package_prefix='sudo' ;;
    arch|manjaro|endeavouros) package_manager=pacman; package_args='-S'; package_prefix='sudo' ;;
    *)
      printf 'Missing required packages:%s\n' "$missing_packages" >&2
      printf 'Could not identify a supported distro from /etc/os-release. Install them manually, then rerun.\n' >&2
      exit 1
      ;;
  esac

  if ! command -v "$package_manager" >/dev/null 2>&1; then
    printf 'Missing required packages:%s\n' "$missing_packages" >&2
    printf 'Package manager %s was not found. Install the packages manually, then rerun.\n' "$package_manager" >&2
    exit 1
  fi

  printf 'Missing required packages:%s\n' "$missing_packages"
  printf 'Install them using %s %s %s? [y/N] ' "$package_prefix" "$package_manager" "$package_args"
  if ! IFS= read -r answer || { [ "$answer" != y ] && [ "$answer" != Y ]; }; then
    printf 'Installation declined. Install the missing packages manually and rerun.\n' >&2
    exit 1
  fi

  # Intentional word splitting turns the package list into command arguments.
  # shellcheck disable=SC2086
  sudo "$package_manager" $package_args $missing_packages
fi

if ! command -v ryzenadj >/dev/null 2>&1 && [ ! -x /usr/local/bin/ryzenadj ]; then
  printf 'RyzenAdj was not found. Install or build RyzenAdj first, then rerun.\n' >&2
  exit 1
fi

"$repo_dir/setup-ryzenadj.sh"
"$repo_dir/setup-waybar.sh"

printf '\nSetup complete. Restart Waybar to load the applet.\n'
