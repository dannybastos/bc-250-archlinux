# BC-250 Arch Linux Setup

This repository contains scripts and instructions to configure an Asrock BC-250 system as a gaming/desktop PC on Arch Linux.

## Features

- Verifies required kernel (>= 6.x) and Mesa driver (>= 25.1.x) versions.
- Installs required build tools (`git`, `cmake`, `base-devel`).
- Sets environment variable for RADV Vulkan driver.
- Configures AMDGPU and NCT6683 kernel modules for optimal hardware support.
- Rebuilds initramfs to apply boot-time module options.
- Builds, installs, and enables the Oberon governor for improved CPU power management.

## Usage

1. **Backup your system** before running any setup script.
2. Ensure you are running Arch Linux.
3. Download the script:

    ```bash
    wget https://github.com/dannybastos/bc-250-archlinux/raw/main/bc-250-archlinux-setup.sh
    chmod +x bc-250-archlinux-setup.sh
    ```

4. Run the script as a regular user (it will request sudo for privileged steps):

    ```bash
    ./bc-250-archlinux-setup.sh
    ```

5. After a successful run, reboot your system to apply all changes.

## What the Script Does

- Checks your Linux kernel and Mesa versions.
- Installs missing build tools.
- Creates `/etc/environment.d/99-radv-bc250.conf` with `RADV_DEBUG=nocompute`.
- Configures AMDGPU and NCT6683 modules via `/etc/modprobe.d/` and `/etc/modules-load.d/`.
- Rebuilds initramfs with `mkinitcpio`.
- Clones, builds, and installs the Oberon governor, enabling its systemd service.

## Troubleshooting

- The script will stop and provide error messages if prerequisites are not met.
- Make sure your system meets the kernel and Mesa requirements before running.

## Credits

- Oberon governor by [mothenjoyer69](https://gitlab.com/mothenjoyer69/oberon-governor).

## License

MIT (see LICENSE file)
