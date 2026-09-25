# FapOS

**FapOS** is a Linux-based operating system designed with a macOS / PearOS-like interface, featuring idle-time notifications and a collection of R34 wallpapers.

It is built on Ubuntu 24.04 LTS and is intended to run well under:
- QEMU / KVM
- Limbo PC Emulator (Android)
- UTM (iOS / iPadOS / macOS)

> **Disclaimer**: This is a community / personal project for fun. Use responsibly. Adult content (R34 wallpapers) is included by design.

## Features

- **UI**: macOS-inspired look (WhiteSur theme, Plank dock, top panel)
- **Idle Monitor**: Detects prolonged keyboard/mouse inactivity and shows playful notifications
- **Wallpapers**: Pre-configured folder for R34 wallpapers (`/usr/share/backgrounds/fapos/`)
- **Branding**: Custom os-release, hostname, Plymouth and LightDM themes
- **Live ISO**: Can be built via GitHub Actions (see below)

## Quick Start (already installed system)

```bash
# Clone the repo
git clone https://github.com/jesusxal777-boop/FapOS.git
cd FapOS

# Run the installer script (requires sudo)
sudo bash install.sh
```

The installer will:
1. Install required packages (plank, whitesur theme dependencies, xprintidle, etc.)
2. Install the idle monitor service
3. Set up branding
4. Configure autostart

## Idle Monitor

The daemon lives in `scripts/fapos-idle-monitor.sh`.

Default idle timeout: **5 minutes**.

You can change it by editing the script or the systemd user service.

## Building the Live ISO

A GitHub Actions workflow is provided in `.github/workflows/build-iso.yml`.

It uses `live-build` on an Ubuntu runner to produce a bootable ISO.

**Note**: Full ISO builds are heavy. The workflow is configured to run on `workflow_dispatch` (manual trigger) and may need adjustments for disk space / time limits.

To trigger a build:
1. Go to the Actions tab
2. Select "Build FapOS Live ISO"
3. Click "Run workflow"

Artifacts (the ISO) will be uploaded if the build succeeds.

## Running in Emulators

### QEMU
```bash
qemu-system-x86_64 -m 4096 -smp 4 -cdrom FapOS-*.iso -boot d -enable-kvm
```

### Limbo PC Emulator
Use the ISO as boot media (x86 image recommended).

### UTM
Create a new virtual machine → Linux → load the ISO.

## Project Structure

```
FapOS/
├── README.md
├── install.sh                  # Main installer for existing Ubuntu systems
├── scripts/
│   └── fapos-idle-monitor.sh   # Idle detection + notifications
├── configs/
│   ├── plank/                  # Dock configuration
│   ├── autostart/
│   └── theme/
├── branding/
│   ├── os-release
│   └── lsb-release
├── wallpapers/                 # Place R34 wallpapers here (not included in repo for size/legal reasons)
└── .github/workflows/
    └── build-iso.yml           # Live ISO builder
```

## License

MIT License – do whatever you want, just don't be a dick.

---
Made for fun. Stay safe.
