
# StockBuild.prop: OTA to Build.prop Module Builder

Build KernelSU/Magisk modules from OTA images to spoof device properties. Supports both **Pixel devices** (scheduled automatic builds) and **any stock device** (on-demand builds from any OTA URL).

## Features

- **Pixel Scheduled Builds**: Automatically downloads the latest Pixel OTA images and builds spoofing modules on a monthly schedule.
- **Stock On-Demand Builds**: Provide any OTA ZIP URL and device codename to build a spoofing module for that device.
- **Play Integrity Fix (PIF)**: Automatic `pif.json` generation from OTA images.
- **TrickyStore**: Automatic target package list generation and broken TEE handling.
- **PIHooks (PropImitationHooks)**: Internal prop spoofing with automatic detection of Play Integrity Fix modules.
- **Safe Mode**: Prevents accidental modification of critical system settings.
- **Sensitive Props**: Advanced system property management for strong integrity.
- **GitHub Actions**: Automated CI/CD with release management and Telegram notifications.

## Quick Start

### Prerequisites

- **Unix-like environment**: Linux or macOS with Bash.
- **Core utilities**: `dos2unix`, `aria2`, `zip`, `p7zip`, `curl`
- **Python >= 3.9**:
  ```bash
  sudo apt-get update -y
  sudo apt-get install python3 python3-pip python3-venv -y
  ```

### Installation

1. **Clone the repository**:

   ```bash
   git clone https://github.com/OodavidsinoO/StockBuild.prop && cd StockBuild.prop
   ```

2. **Create and activate a virtual environment** (recommended):

   ```bash
   python3 -m venv .venv
   . .venv/bin/activate
   ```

3. **Install dependencies**:

   ```bash
   python3 -m pip install git+https://github.com/5ec1cff/payload-dumper
   ```

## Usage

### Building from a Stock OTA URL (any device)

Provide a direct OTA ZIP URL and device codename:

```bash
./build_from_url.sh <OTA_URL> <device_codename> [device_name]
```

Example:
```bash
./build_from_url.sh "https://example.com/fuxi-ota.zip" fuxi "Xiaomi 13"
```

This will:
1. Download the OTA ZIP
2. Extract `payload.bin` and dump partition images
3. Extract build properties
4. Build a KernelSU/Magisk module in `result/`

### Building from Pixel OTA Images (manual)

1. Download Pixel OTA images automatically:
   ```bash
   ./download_latest_ota_build.sh <device_name1> <device_name2> ...
   ```
   Examples: `husky`, `felix_beta`, `cheetah`, `akita_beta15`

2. Extract and build:
   ```bash
   ./extract_images.sh
   ```

3. Find the module in `result/`

### GitHub Actions

- **Pixel scheduled builds**: Runs automatically on the 7th of each month for 10 Pixel devices.
- **Stock on-demand builds**: Trigger manually via `Actions > Build from OTA URL`, providing the device codename and OTA URL.

Both workflows upload built modules to GitHub Releases with detailed firmware information.

## Module Features

### service.sh
- **Safe Mode**: Compares module properties with existing system values to prevent accidental modification.
- **Sensitive Props**: Advanced property management for strong integrity, with conflict detection for standalone modules.
- **PIHooks (PropImitationHooks)**: Dynamically sets device properties based on the spoofed module's configuration. Automatically disables when Play Integrity Fix is detected.

### action.sh
- **PlayIntegrityFix**: Automatically builds `pif.json` from OTA images. Supports downloading pre-built configs or crawling Google's OTA pages.
- **TrickyStore**: Automatically builds `target.txt` with installed packages and handles broken TEE status.

### post-fs-data.sh
- Checks module compatibility with Magisk >= 26302 or KernelSU >= 10818.
- Manages Play Services in Magisk DenyList.
- Cleans custom ROM properties and resets build fingerprints.

## Credits

Originally forked from [Pixel-Props/build.prop](https://github.com/Pixel-Props/build.prop) by @T3SL4 (Tesla). Extended by @OodavidsinoO with support for building modules from any stock OTA image.

## License

GPL v3 - See [LICENSE.md](LICENSE.md)
