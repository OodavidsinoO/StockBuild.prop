# StockBuild.prop — Agent Guide

## Architecture

Two independent build flows, same module output format:

| Flow | Trigger | Download | Release tag |
|------|---------|----------|-------------|
| **Pixel** | Scheduled (7th monthly) + manual | Scrapes Google OTA pages (`download_latest_ota_build.sh`) | `YYYYMMDD` |
| **Stock** | Manual only (`workflow_dispatch`) | Arbitrary URL (`download_ota_from_url.sh`) | `codename-YYYYMMDD` | Codename auto-detected from OTA metadata (`pre-device`) if not provided |

Both flows converge at `extract_images.sh` which orchestrates: download → extract payload.bin → dump partitions → build props → build module ZIP.

## Commands

```bash
# Local: build from any OTA URL (one step, codename auto-detected)
./build_from_url.sh <URL> [codename] [device_name]

# Local: just download OTA (codename auto-detected if not given)
./download_ota_from_url.sh <URL> [codename]     # writes resolved codename to ./dl/.codename
./download_latest_ota_build.sh <device>          # e.g. husky felix_beta

# Extract + build everything in ./dl/
./extract_images.sh

# Install payload_dumper (required)
pip install git+https://github.com/5ec1cff/payload-dumper    # Python >= 3.9
```

## Critical constraints

- **`config.prop` keys MUST stay as `pixelprops.sensitive.*`** — renaming them breaks existing Pixel modules on user devices. The `service.sh` reads these keys at runtime.
- **payload_dumper is installed via pip git+https**, NOT a submodule. The old `.gitmodules` was deleted. Both workflows use `pip install git+https://github.com/5ec1cff/payload-dumper`.
- **OTA zips must contain `payload.bin`** (A/B OTA format). Factory images (no `payload.bin`) also work but only for Pixel. All three test devices (fuxi, kebab, pacman) use `payload.bin`.
- **Python >= 3.9** required (payload_dumper v0.4.0).
- **Local dev uses `uv`/`uvx`**; GitHub Actions uses regular `python3` + `pip`.

## Script dependency chain

```
*.sh  →  util_functions.sh  →  requirements.sh   (auto-installs deps via system pkg manager)
```
`requirements.sh` runs `install_packages "zip" "p7zip" "dos2unix" "aria2"` on every script invocation (idempotent). It also checks that `payload_dumper` is on PATH and will error-exit if missing.

## Module output

- **Module ID**: `${Codename}_Props` (e.g. `Fuxi_Props`, `Husky_Props`)
- **Author**: `OodavidsinoO, based on work by Tesla`
- **Description**: `Spoof your device props to ${CODENAME} [build_id] (month year)`
- `build_module.sh` writes GitHub Actions output variables to `$GITHUB_OUTPUT`: `module_base_name`, `module_hash`, `device_name`, `device_codename`, `device_build_id`, `device_build_description`, `device_build_android_version`, `device_build_security_patch`

## File ownership

| Path | Role |
|------|------|
| `extract_images.sh` | Master orchestrator — calls all build scripts |
| `build_props.sh` | Generates `system.prop` + `module.prop` from extracted partitions. **Generic** — works for any device. |
| `build_module.sh` | Assembles final Magisk/KernelSU module ZIP |
| `build_sysconfig.sh` | Copies Pixel-specific sysconfig XMLs (harmless no-op for non-Pixel) |
| `download_latest_ota_build.sh` | **Pixel only** — scrapes Google's OTA/beta pages |
| `download_ota_from_url.sh` | Generic aria2c download for any URL |
| `module_files/` | Shared module runtime files (installed on device) |
| `.github/workflows/build-on-schedule.yml` | Pixel monthly CI |
| `.github/workflows/build-from-url.yml` | Stock on-demand CI |

## CI gotchas

- Both workflows need `sudo apt install -y dos2unix android-sdk-libsparse-utils` explicitly; other deps are handled by `requirements.sh` at script runtime. `simg2img` (from `android-sdk-libsparse-utils`) is required to convert sparse ext4 partition images from non-Pixel OEM OTAs.
- The Pixel workflow uses **deprecated actions** (`actions/create-release@v1`, `actions/upload-release-asset@v1`) — do not copy this pattern to new workflows. Use `gh release create` instead.
- Telegram notifications require `secrets.BOT_TOKEN` and `secrets.CHANNEL_ID`.
