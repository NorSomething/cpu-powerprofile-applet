# CPU Power Profile Waybar applet

Installs a small Wofi menu in Waybar for three RyzenAdj power limit presets:

| Menu item | STAPM | PPT fast | PPT slow |
| --- | ---: | ---: | ---: |
| Saving | 7 W | 7 W | 7 W |
| Gaming | 20 W | 20 W | 20 W |
| Normal | 40 W | 40 W | 40 W |

## Requirements

- Void Linux, Debian-based Linux, or Arch-based Linux with Sway/Waybar.
- `ryzenadj` installed at `/usr/local/bin/ryzenadj`.
- `wofi`, `libnotify` (`notify-send`), `pkill`, and `sudo`.
- A Ryzen laptop supported by RyzenAdj. These limits are ceilings and firmware may overwrite them, including when changing Lenovo Fn+Q modes.

The installer checks for the helper dependencies and asks before installing any that are missing. If you decline, it exits so you can install them manually. The matching package names are:

| Distro family | Packages |
| --- | --- |
| Void | `jq wofi libnotify sudo waybar` (`sudo xbps-install -S ...`) |
| Debian/Ubuntu | `jq wofi libnotify-bin sudo waybar` (`sudo apt install ...`) |
| Arch | `jq wofi libnotify sudo waybar` (`sudo pacman -S ...`) |

`ryzenadj` is not consistently packaged across these distributions; install or build it separately and make sure it is available at `/usr/local/bin/ryzenadj` (or provide `RYZENADJ=/path/to/ryzenadj` when running `setup-ryzenadj.sh`).

## Install

From this repository, run:

```sh
./install.sh
```

The installer adds Waybar configuration, installs root-owned mode scripts, and writes a narrowly scoped sudoers rule for those scripts. It asks for sudo when needed. It will not overwrite your Waybar configuration: it creates a timestamped backup and merges the module using `jq`, or stops with instructions if your config cannot be safely parsed.

Restart Waybar after installation:

```sh
pkill waybar
waybar >/dev/null 2>&1 &
```

Click `CPU-Power-Profile`, then choose a mode. The label updates after a successful selection. The label shows the last preset selected during this login, not a live reading of firmware power limits.

To install only part of the setup, run `./setup-ryzenadj.sh` or `./setup-waybar.sh` directly. The RyzenAdj setup script accepts `RYZENADJ=/path/to/ryzenadj` if the executable is elsewhere.
