# Mod bios.zip

This package contains the necessary files to update the BIOS of your Asrock BC-250 system. The update enables you to configure the amount of memory allocated to your GPU/APU.

## Features

- **BIOS Version After Update:** P3.0.0
- **New Option Available:** Configure GPU/APU memory allocation via BIOS settings.

## How to Use

1. **Extract** the contents of `Mod bios.zip`.
2. **Follow the included instructions** (if any) for applying the BIOS update to your Asrock BC-250.
3. **After flashing** the BIOS, reboot your system and enter the BIOS setup.

## Memory Configuration

To set the amount of memory for your GPU/APU:

- Navigate to:  
  `<CHIPSET>`  
    `<GXF Configuration>`  
      `<GXF Configuration>`  
      `<Integrated Graphics Controler> =  [Forces]`  
      `<UMA MODE>                      =  [UMA_SPECIFIED]`  
      `<UMA Frame buffer Size>         =  [512MB]` **recommended**  

Here, you can adjust the memory settings as desired.

## Warnings & Notes

- **Backup your current BIOS** before applying any update.
- **Use caution:** Incorrect BIOS updates can render your system unusable.
- Only use this update with the Asrock BC-250 platform.
- Ensure your system is stable and avoid interrupting the update process.

## Repository

This repository helps set up the Asrock BC-250 as a game/desktop PC, including BIOS modifications, Arch Linux setup scripts, and other tools.
