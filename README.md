# IPMI Management Tool

A beautiful, interactive CLI tool for managing servers via IPMI/BMC.

```
  ╔══════════════════════════════════════════════════╗
  ║         IPMI MANAGEMENT TOOL                     ║
  ╚══════════════════════════════════════════════════╝
```

## Features

- **Auto-Install** - Installs `ipmitool` automatically if missing
- **Interactive Menu** - Easy-to-navigate colorful interface
- **Power Management** - On, off, cycle, reset, ACPI shutdown
- **Sensor Monitoring** - View all sensors, temps, fan speeds
- **User Management** - List and manage BMC users
- **LAN Configuration** - View BMC network settings
- **Event Logs** - Read and clear System Event Log (SEL)
- **Advanced Tools** - SOL, raw commands, DCMI, BMC reset

## Quick Start

```bash
# Clone the repo
git clone https://github.com/yourusername/ipmi-tool.git

# Enter the directory
cd ipmi-tool

# Make executable (if not already)
chmod +x ipmi-tool.sh

# Run the tool
./ipmi-tool.sh
```

## Requirements

- Linux (Debian/Ubuntu, RHEL/CentOS)
- `ipmitool` (auto-installed if missing)
- Network access to target BMC

## Usage

```bash
./ipmi-tool.sh
```

### Main Menu

```
  [1] 📊  System Information
  [2] ⚡  Power Management
  [3] 🌡️   Sensors & Status
  [4] 👤  User Management
  [5] 🌐  LAN Configuration
  [6] 📜  Event Logs (SEL)
  [7] 🛠️   Advanced Tools
  [8] 🔄  Change Target
  [0] 🚪  Exit
```

### Examples

**Check power status:**
```
Main Menu > [2] Power Management > [1] Power Status
```

**View temperature sensors:**
```
Main Menu > [3] Sensors & Status > [5] Temperature Readings
```

**Clear event logs:**
```
Main Menu > [6] Event Logs > [3] Clear SEL
```

## Script Location

```
~/Projects/ipmi-tool/
└── ipmi-tool.sh
```

## License

MIT

## Author

Created with ❤️ for server administrators
