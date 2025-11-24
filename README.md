# arcos-build

## DOCUMENTATION

#### Pre-Requisites:
- [arcOS "Xanadu 1124" (or later)](https://sourceforge.net/projects/arcos-linux/files/), installed and running
- [Cubic installed](https://github.com/PJ-Singh-001/Cubic#install-cubic) (persistent installation optional)
- An `ext4` formatted device, labeled as "ARCOS-DEV", and mounted at `/media/user/ARCOS-DEV`
- A copy of the [Linux Mint 22.2 "Zara" ISO](https://linuxmint.com/edition.php?id=322) placed in `/media/user/ARCOS-DEV`

#### Build Process:
1. Clone this repo into `/media/user/ARCOS-DEV`
   - `git clone --branch xanadu https://github.com/kg4vdk/arcos-build /media/user/ARCOS-DEV/arcos-build`
2. Change into repo directory
   - `cd /media/user/ARCOS-DEV/arcos-build`
3. Run "pre-build" script
   - `./pre-build.sh`
4. Run "cubic-start" script
   - `./cubic-start.sh`
   - When prompted, enter an alpha designator for Xanadu builds
   - Once Cubic starts, select `Next` on the first 2 screens (make no changes)
   - Wait for the live environment (terminal session in Cubic)
5. Copy repo files into Cubic
   - Once the live environment is ready, drag-and-drop the `arcos-build` directory into the Cubic window, then select `Copy`
---
6. In the Cubic live environment terminal:
   - `cd arcos-build`
   - `time ./arcos-build.sh`
   - ***WAIT PATIENTLY*** for the script to run
   - Once the "arcos-build" script finishes, select `Next` to exit the live environment
7. Select `Next` on the remaining Cubic screens (make no changes)
   - ***WAIT PATIENTLY*** for the new ISO to be generated
   - When the ISO generation is complete, select the checkbox to cleanup project files (at the bottom of the final screen), then select `Close`
  
The generated ISO will be available in `/media/user/ARCOS-DEV/cubic-build`
