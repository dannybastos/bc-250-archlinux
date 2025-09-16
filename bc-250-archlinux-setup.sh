#!/bin/bash
set -euo pipefail

# =======================================================
# Arch Linux Setup Script for BC-250 (Revised)
# - English documentation/comments
# - Clear outputs for each step
# - Kernel version check: requires >= 6.x
# - Mesa driver version check: requires >= 25.1.x
# - Restores original behavior:
#     * Adds RADV_DEBUG to /etc/environment.d/99-radv-bc250.conf
#     * Adds AMDGPU and NCT6683 module options
#     * Rebuilds initramfs
#     * Builds and enables Oberon governor
# =======================================================

log() { printf "%s\n" "$*"; }
ok()  { printf "✅ %s\n" "$*"; }
warn(){ printf "⚠️  %s\n" "$*"; }
err() { printf "❌ %s\n" "$*"; }

trap 'err "An unexpected error occurred. Check the messages above."' ERR

# --- Pre-flight: ensure we are on Arch & have sudo ---
log "Checking operating system and sudo availability..."
if ! command -v pacman >/dev/null 2>&1; then
  err "This script is intended for Arch Linux (pacman not found)."
  exit 1
fi
if ! command -v sudo >/dev/null 2>&1; then
  err "sudo is required to run privileged steps."
  exit 1
fi
ok "Environment looks good"

# --- Check kernel version >= 6.x ---
log "Checking Linux kernel version..."
KERNEL_MAJOR="$(uname -r | cut -d. -f1)"
if [[ "${KERNEL_MAJOR}" =~ ^[0-9]+$ ]] && (( KERNEL_MAJOR >= 6 )); then
  ok "Kernel version OK: $(uname -r)"
else
  err "Kernel version 6.x or higher is required. Found: $(uname -r)"
  exit 1
fi

# --- Check Mesa version >= 25.1.x ---
log "Checking Mesa driver version..."
if ! command -v glxinfo >/dev/null 2>&1; then
  log "mesa-utils not found; installing to query Mesa version..."
  sudo pacman -Sy --noconfirm --needed mesa-utils >/dev/null
fi

# Extract version like 25.1.2 from glxinfo output, robust to suffixes
MESA_VERSION="$(glxinfo -B 2>/dev/null | grep -Eo 'Mesa [0-9]+(\.[0-9]+)+' | awk '{print $2}' | head -n1)"
if [[ -z "${MESA_VERSION}" ]]; then
  # Fallback parsing
  MESA_VERSION="$(glxinfo 2>/dev/null | grep -m1 -Eo 'Mesa [0-9]+(\.[0-9]+)+' | awk '{print $2}')"
fi
if [[ -z "${MESA_VERSION}" ]]; then
  err "Unable to detect Mesa version via glxinfo."
  exit 1
fi
MESA_MAJOR="${MESA_VERSION%%.*}"
MESA_MINOR="$(printf "%s" "${MESA_VERSION#*.}" | cut -d. -f1)"
if (( MESA_MAJOR > 25 )) || (( MESA_MAJOR == 25 && MESA_MINOR >= 1 )); then
  ok "Mesa version OK: ${MESA_VERSION}"
else
  err "Mesa 25.1.x or higher is required. Found: ${MESA_VERSION}"
  exit 1
fi

# --- Ensure required build tools (for Oberon governor) ---
log "Ensuring build tools are available (git, cmake, base-devel)..."
sudo pacman -Sy --noconfirm --needed git cmake base-devel >/dev/null
ok "Build toolchain ready"

# --- Create /etc/environment.d entries (correct content) ---
log "Configuring /etc/environment.d entries..."
sudo mkdir -p /etc/environment.d/
# Restore original variable: RADV_DEBUG=nocompute in 99-radv-bc250.conf
echo "RADV_DEBUG=nocompute" | sudo tee /etc/environment.d/99-radv-bc250.conf >/dev/null
ok "Wrote /etc/environment.d/99-radv-bc250.conf (RADV_DEBUG=nocompute)"

# --- AMDGPU and NCT6683 module options ---
log "Writing modprobe/module-load configuration..."
# AMD GPU quirk as per original script
echo "options amdgpu sg_display=0" | sudo tee /etc/modprobe.d/amdgpu-bc250.conf >/dev/null
# NCT6683: load at boot and force detection
echo "nct6683" | sudo tee /etc/modules-load.d/nct6683-bc250.conf >/dev/null
echo "options nct6683 force=true" | sudo tee /etc/modprobe.d/nct6683-bc250.conf >/dev/null
ok "Module configuration files created"

# --- Rebuild initramfs so early-boot options are applied ---
log "Rebuilding initramfs with mkinitcpio -P..."
sudo mkinitcpio -P
ok "Initramfs rebuilt"

# --- Build and install Oberon governor ---
WORKDIR="/tmp/oberon-governor"
REPO_URL="https://gitlab.com/mothenjoyer69/oberon-governor.git"
log "Preparing Oberon governor build in ${WORKDIR} ..."
sudo rm -rf "${WORKDIR}"
git clone "${REPO_URL}" "${WORKDIR}"
cd "${WORKDIR}"

log "Running cmake/make..."
if cmake . && make; then
  ok "Build completed"
  log "Installing Oberon governor..."
  sudo make install
  ok "Installed Oberon governor"
  log "Enabling oberon-governor.service..."
  sudo systemctl enable --now oberon-governor.service
  ok "Oberon governor service enabled and started"
else
  err "Failed to build Oberon governor"
  exit 1
fi

log "🎉 Setup completed successfully. Please restart to make the changes effective"
