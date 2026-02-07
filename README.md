# sovol-sv08-macros

This repository contains improved macros for the Sovol SV08 3D printer running Klipper firmware. These macros enhance the printing workflow with better automation, safety features, and calibration routines.

## Overview

This collection includes macros for print management, filament handling, calibration, and utility functions specifically tailored for the Sovol SV08 printer. The macros are designed to work seamlessly with Klipper and provide an improved user experience.

## Features

### Print Management
- **START_PRINT**: Comprehensive print start routine with automatic bed leveling, mesh calibration, and filament detection
- **END_PRINT**: Safe print completion with proper cleanup and parking
- **PAUSE/RESUME**: Enhanced pause and resume functionality with smart filament handling
- **CANCEL_PRINT**: Safe print cancellation with proper cleanup

### Filament Management
- **LOAD_FILAMENT**: Automated filament loading with temperature control and purging
- **UNLOAD_FILAMENT**: Safe filament unloading with proper cooling procedures
- **M600**: Color change macro that combines pause and unload operations

> **Note**: The load and unload filament macros are based on the RatOS community implementations. For more information and community support, visit the [RatOS community](https://github.com/Rat-OS/RatOS).

### Calibration Macros
- **QUAD_GANTRY_LEVEL**: Enhanced quad gantry leveling with temperature management
- **BED_MESH_CALIBRATE**: Improved bed mesh calibration with adaptive meshing
- **PROBE_CALIBRATE**: Probe calibration with temperature control
- **G34**: Complete calibration routine (QGL + Z-homing)
- **CLEAN_NOZZLE**: Automated nozzle cleaning routine

### Homing
- **MAYBE_HOME**: Smart homing that only homes unhomed axes (located in `homing.cfg`)
- Enhanced homing routines integrated into print start sequences

> **Note**: The homing macros are inspired by the RatOS community implementations. Check out the [RatOS documentation](https://os.ratrig.com/) for more details.

### Utility Macros
- **BEEP**: Simple beep notification
- **MAINLED_ON/OFF**: Control main LED lighting
- **PARK_FRONT**: Park the printhead at the front of the bed
- **PRIME_BLOB/PRIME_LINE**: Filament priming routines

### Shell Scripts

The repository includes several shell scripts for advanced calibration and system management:

- **generate-shaper-graph-x.sh**: Generates input shaper resonance graphs for the X-axis
- **generate-shaper-graph-y.sh**: Generates input shaper resonance graphs for the Y-axis
- **generate-belt-tension-graph.sh**: Creates belt tension resonance graphs
- **change-hostname.sh**: Helper script to change the printer hostname
- **change-hostname-as-root.sh**: Root-level hostname change script

> **Note**: The shell scripts for shaper calibration and belt tension testing follow RatOS community best practices. For more information on input shaper calibration and resonance testing, refer to the [RatOS community resources](https://github.com/Rat-OS/RatOS).

## Configuration

### Required Includes

The `printer.cfg` file should include the following configuration files (in order):

```ini
[include mainsail.cfg]
[include timelapse.cfg]
[include get_ip.cfg]
[include plr.cfg]
[include homing.cfg]
[include shell_command.cfg]
[include Macro.cfg]
```

**Note**: Some of these files (like `mainsail.cfg`, `timelapse.cfg`, `get_ip.cfg`, `plr.cfg`) may be specific to your setup. Adjust or remove includes as needed for your configuration.

### Critical Configuration Steps

#### 1. MCU Serial IDs

**⚠️ IMPORTANT**: You must configure the MCU serial IDs before the printer will work:

```ini
[mcu]
serial: /dev/serial/by-id/<your_mcu_serial_id>

[mcu extra_mcu]
serial: /dev/serial/by-id/<your_extra_mcu_serial_id>
```

To find your serial IDs, run:
```bash
ls -l /dev/serial/by-id/
```

Replace the placeholders with your actual serial device paths.

#### 2. Shell Commands Configuration

The `shell_command.cfg` file configures shell commands for:
- Input shaper graph generation (X and Y axes)
- Belt tension graph generation
- Hostname changes

Make sure the script paths in `shell_command.cfg` match your installation:
- Default path: `/home/sovol/printer_data/config/scripts/`

#### 3. Hardware-Specific Settings

**ADXL345 Accelerometer** (for input shaper calibration):
- Connected to `extra_mcu:PB12`
- Axes mapping: `x,z,y`

**Probe Configuration**:
- Pin: `extra_mcu:PB6`
- X offset: `-17`
- Y offset: `10`
- Adjust `z_offset` during probe calibration

**Filament Sensor**:
- Pin: `PE9`
- Automatically triggers `M600` on runout
- Automatically calls `LOAD_FILAMENT` on insert

#### 4. Printer Kinematics

The printer uses **CoreXY** kinematics with the following limits:
- Max velocity: 700 mm/s
- Max acceleration: 40000 mm/s²
- Max Z velocity: 20 mm/s
- Max Z acceleration: 500 mm/s²

#### 5. Bed Mesh Configuration

- Mesh size: 9x9 points
- Mesh area: 10,10 to 333,340
- Algorithm: bicubic
- Adaptive meshing enabled

#### 6. Quad Gantry Leveling

- 4-point calibration
- Speed: 350 mm/s
- Retry tolerance: 0.02 mm
- Max adjust: 10 mm

#### 7. Input Shaper

Input shaper settings are commented out by default. After running resonance tests with `GENERATE_SHAPER_GRAPHS`, uncomment and configure:
```ini
shaper_type_x = mzv
shaper_freq_x = 35
shaper_type_y = mzv
shaper_freq_y = 35
```

### Macro Variables

The macros use global variables defined in `_global_var` that can be customized:

- `pause_park`: Parking position during pause (default: X0, Y0, Z10)
- `cancel_park`: Parking position on cancel (default: X0, Y350, Z10)
- `z_maximum_lifting_distance`: Maximum Z lift distance (default: 345)
- `bed_mesh_calibrate_target_temp`: Bed temperature for calibration (default: 60°C)
- `load_filament_extruder_temp`: Extruder temp for loading (default: 250°C)
- `filament_unload_length`: Filament unload length in mm (default: 130)
- `filament_unload_speed`: Filament unload speed in mm/s (default: 5)
- `filament_load_length`: Filament load length in mm (default: 100)
- `filament_load_speed`: Filament load speed in mm/s (default: 10)
- `mesh_extruder_temp`: Extruder temperature for mesh calibration (default: 150°C)
- `preheat_probe_time`: Probe preheat time in milliseconds (default: 240000)

### Stepper Motor Configuration

The printer uses TMC2209 drivers with the following setup:
- **X/Y steppers**: 1.061A run current, 64 microsteps
- **Z steppers** (4 total): 0.566A run current, 64 microsteps, 80:12 gear ratio
- **Extruder**: 0.8A run current, 64 microsteps

**Important**: Adjust motor currents based on your specific hardware and requirements. Start with lower values and increase if needed.

### Temperature Settings

- **Extruder**: Generic 3950 thermistor, max temp 305°C
- **Bed**: Custom thermistor (`my_thermistor`), max temp 105°C
- **Hotend fan**: Turns on at 45°C
- **CPU fan**: PID controlled, target 60°C

> **Note**: For information about the low-profile mainboard fan mount used in this configuration, see the [Printables article](https://www.printables.com/model/1048947-low-profile-mainboard-fan-mount-for-sovol-sv08).

### File Paths

Ensure these paths exist and are correct:
- Virtual SD card: `/home/sovol/printer_data/gcodes/`
- Saved variables: `/home/sovol/printer_data/config/saved_variables.cfg`
- Shell scripts: `/home/sovol/printer_data/config/scripts/`

## Installation

### Step 1: Copy Configuration Files

Copy the following configuration files to your Klipper config directory (typically `/home/sovol/printer_data/config/`):

- `Macro.cfg` - Main macros file
- `homing.cfg` - Homing macros
- `shell_command.cfg` - Shell command definitions for graph generation and hostname changes

### Step 2: Include Files in printer.cfg

Add the following includes to your `printer.cfg` file (in the order shown):

```ini
[include homing.cfg]
[include shell_command.cfg]
[include Macro.cfg]
```

**Note**: If you're using the provided `printer.cfg` as a reference, you may also need other includes like `mainsail.cfg`, `timelapse.cfg`, etc., depending on your setup.

### Step 3: Configure MCU Serial IDs

**⚠️ CRITICAL**: Edit your `printer.cfg` and replace the MCU serial ID placeholders:

```ini
[mcu]
serial: /dev/serial/by-id/<your_mcu_serial_id>

[mcu extra_mcu]
serial: /dev/serial/by-id/<your_extra_mcu_serial_id>
```

Find your serial IDs with:
```bash
ls -l /dev/serial/by-id/
```

### Step 4: Install Shell Scripts

Copy shell scripts to your scripts directory and make them executable:

```bash
# Create scripts directory if it doesn't exist
mkdir -p /home/sovol/printer_data/config/scripts/

# Copy scripts
cp scripts/*.sh /home/sovol/printer_data/config/scripts/

# Make them executable
chmod +x /home/sovol/printer_data/config/scripts/*.sh
```

**Important**: Verify the script paths in `shell_command.cfg` match your installation location.

### Step 5: Verify Configuration

After installation, restart Klipper and verify:
1. All macros are recognized (check in your web interface)
2. Shell commands are available (test with `GENERATE_SHAPER_GRAPHS`)
3. No configuration errors in Klipper logs

## Usage

### Basic Print Operations
- Start a print: The `START_PRINT` macro is typically called automatically by your slicer's start G-code
- Pause: `PAUSE` or `M600` (for color change)
- Resume: `RESUME`
- Cancel: `CANCEL_PRINT`

### Filament Operations
- Load filament: `LOAD_FILAMENT [TEMP=220]`
- Unload filament: `UNLOAD_FILAMENT [TEMP=220]`
- Color change: `M600`

### Calibration
- Full calibration: `G34`
- Quad gantry level: `QUAD_GANTRY_LEVEL`
- Bed mesh: `BED_MESH_CALIBRATE`
- Probe calibration: `PROBE_CALIBRATE`
- Input shaper graphs: `GENERATE_SHAPER_GRAPHS` or `GENERATE_SHAPER_GRAPHS AXIS=X` (or `Y`)
- Belt tension measurement: `MEASURE_COREXY_BELT_TENSION`

### System Management
- Change hostname: `CHANGE_HOSTNAME HOSTNAME="new_hostname"`

## Acknowledgments

This macro collection draws inspiration and best practices from:
- **RatOS Community**: Load/unload filament macros, homing routines, and shell script implementations
- Klipper documentation and community contributions

### Hardware References

- **Low-Profile Mainboard Fan Mount**: [Printables - Low Profile Mainboard Fan Mount for Sovol SV08](https://www.printables.com/model/1048947-low-profile-mainboard-fan-mount-for-sovol-sv08)

For more information about RatOS and its community resources:
- [RatOS GitHub](https://github.com/Rat-OS/RatOS)
- [RatOS Documentation](https://os.ratrig.com/)

## License

See [LICENSE](LICENSE) file for details.
