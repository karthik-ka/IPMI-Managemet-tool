#!/bin/bash

# IPMI Management Tool
# Usage: ./ipmi-tool.sh

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
GRAY='\033[0;90m'
BOLD='\033[1m'
NC='\033[0m'

# Variables
IPMI_IP=""
IPMI_USER=""
IPMI_PASS=""
IPMI_CMD=""

# Functions
print_header() {
    clear
    echo ""
    echo -e "  ${BLUE}╔══════════════════════════════════════════════════╗${NC}"
    echo -e "  ${BLUE}║${NC}         ${BOLD}${WHITE}IPMI MANAGEMENT TOOL${NC}                     ${BLUE}║${NC}"
    echo -e "  ${BLUE}╚══════════════════════════════════════════════════╝${NC}"
    echo ""
}

print_menu_header() {
    local title="$1"
    if [ -n "$IPMI_IP" ]; then
        echo -e "  ${CYAN}Target: ${BOLD}${WHITE}${IPMI_IP}${NC}"
        echo -e "  ${CYAN}──────────────────────────────────────────────────────${NC}"
    fi
    echo -e "  ${BOLD}${title}${NC}"
    echo -e "  ${CYAN}──────────────────────────────────────────────────────${NC}"
    echo ""
}

confirm_action() {
    local message="$1"
    echo ""
    echo -e "  ${YELLOW}⚠️  WARNING: ${message}${NC}"
    echo ""
    read -p "  Confirm (y/N): " confirm
    if [[ "$confirm" != "y" && "$confirm" != "Y" ]]; then
        echo -e "  ${RED}✗ Cancelled${NC}"
        sleep 1
        return 1
    fi
    return 0
}

run_ipmi() {
    local cmd="$1"
    local title="$2"

    echo ""
    echo -e "  ${GRAY}Executing: ipmitool ${cmd}${NC}"
    echo -e "  ${GRAY}──────────────────────────────────────────────────────${NC}"
    echo ""

    local output
    output=$(ipmitool $IPMI_CMD $cmd 2>&1) || true
    local exit_code=0
    ipmitool $IPMI_CMD $cmd > /dev/null 2>&1 || exit_code=$?

    echo -e "  ${GREEN}${BOLD}${title}${NC}"
    echo -e "  ${GREEN}──────────────────────────────────────────────────────${NC}"
    if [ -n "$output" ]; then
        while IFS= read -r line; do
            echo -e "  ${line}"
        done <<< "$output"
    else
        echo -e "  ${GRAY}(no output)${NC}"
    fi

    echo ""
    if [ $exit_code -eq 0 ]; then
        echo -e "  ${GREEN}✓ Success${NC}"
    else
        echo -e "  ${RED}✗ Failed (exit code: ${exit_code})${NC}"
    fi
    echo ""
    read -p "  Press Enter to continue..."
}

get_credentials() {
    print_header
    echo -e "  ${BOLD}${MAGENTA}🔌 Connect to BMC${NC}"
    echo -e "  ${MAGENTA}──────────────────────────────────────────────────────${NC}"
    echo ""
    echo -e "  ${GRAY}Enter your IPMI/BMC connection details:${NC}"
    echo ""
    read -p "  IP Address  : " IPMI_IP
    read -p "  Username    : " IPMI_USER
    read -sp "  Password    : " IPMI_PASS
    echo ""
    echo ""

    if [ -z "$IPMI_IP" ] || [ -z "$IPMI_USER" ] || [ -z "$IPMI_PASS" ]; then
        echo -e "\n  ${RED}✗ All fields are required!${NC}"
        read -p "  Press Enter to try again..."
        get_credentials
        return
    fi

    IPMI_CMD="-I lanplus -H ${IPMI_IP} -U ${IPMI_USER} -P ${IPMI_PASS}"
    echo -e "\n  ${YELLOW}⏳ Connecting to ${IPMI_IP}...${NC}"

    if ipmitool $IPMI_CMD mc info > /dev/null 2>&1; then
        echo -e "  ${GREEN}✓ Connected!${NC}"
    else
        echo -e "  ${RED}✗ Connection failed${NC}"
        read -p "  Press Enter to continue anyway..."
    fi
    sleep 1
}

# ═══════════════════════════════════════════════════════════
#                     SYSTEM INFORMATION
# ═══════════════════════════════════════════════════════════

menu_system_info() {
    while true; do
        print_header
        print_menu_header "📊 System Information"
        echo -e "  ${CYAN}${BOLD}[1]${NC} 🖥️   Chassis Status"
        echo -e "  ${CYAN}${BOLD}[2]${NC} 🔧  Management Controller (MC) Info"
        echo -e "  ${CYAN}${BOLD}[3]${NC} 📦  FRU Inventory"
        echo -e "  ${CYAN}${BOLD}[4]${NC} 📑  SDR Repository Info"
        echo -e "  ${CYAN}${BOLD}[5]${NC} 📋  SDR List"
        echo ""
        echo -e "  ${GRAY}──────────────────────────────────────────────────────${NC}"
        echo -e "  ${RED}${BOLD}[0]${NC} 🔙  Back to Main Menu"
        echo ""
        read -p "  Select > " choice

        case $choice in
            1) run_ipmi "chassis status" "Chassis Status" ;;
            2) run_ipmi "mc info" "MC Info" ;;
            3) run_ipmi "fru list" "FRU Inventory" ;;
            4) run_ipmi "sdr info" "SDR Info" ;;
            5) run_ipmi "sdr list" "SDR List" ;;
            0) break ;;
            *) echo -e "  ${RED}✗ Invalid${NC}"; sleep 1 ;;
        esac
    done
}

# ═══════════════════════════════════════════════════════════
#                     POWER MANAGEMENT
# ═══════════════════════════════════════════════════════════

menu_power() {
    while true; do
        print_header
        print_menu_header "⚡ Power Management"
        echo -e "  ${CYAN}${BOLD}[1]${NC} 📊  Power Status"
        echo -e "  ${CYAN}${BOLD}[2]${NC} 🟢  Power On"
        echo -e "  ${YELLOW}${BOLD}[3]${NC} 🟡  Power Off (Soft - ACPI)"
        echo -e "  ${RED}${BOLD}[4]${NC} 🔴  Power Off (Hard - Immediate)"
        echo -e "  ${YELLOW}${BOLD}[5]${NC} 🔄  Power Cycle"
        echo -e "  ${RED}${BOLD}[6]${NC} 🔃  Power Reset"
        echo -e "  ${YELLOW}${BOLD}[7]${NC} ⏻  ACPI Soft Shutdown"
        echo ""
        echo -e "  ${GRAY}──────────────────────────────────────────────────────${NC}"
        echo -e "  ${RED}${BOLD}[0]${NC} 🔙  Back to Main Menu"
        echo ""
        read -p "  Select > " choice

        case $choice in
            1) run_ipmi "power status" "Power Status" ;;
            2) run_ipmi "power on" "Power On" ;;
            3)
                if confirm_action "Soft power off (ACPI shutdown)?"; then
                    run_ipmi "power off" "Power Off"
                fi ;;
            4)
                if confirm_action "HARD power off? Data loss may occur!"; then
                    run_ipmi "power off hard" "Hard Power Off"
                fi ;;
            5)
                if confirm_action "Power cycle system?"; then
                    run_ipmi "power cycle" "Power Cycle"
                fi ;;
            6)
                if confirm_action "Hard reset system?"; then
                    run_ipmi "power reset" "Power Reset"
                fi ;;
            7)
                if confirm_action "ACPI soft shutdown?"; then
                    run_ipmi "power soft" "ACPI Shutdown"
                fi ;;
            0) break ;;
            *) echo -e "  ${RED}✗ Invalid${NC}"; sleep 1 ;;
        esac
    done
}

# ═══════════════════════════════════════════════════════════
#                     SENSORS
# ═══════════════════════════════════════════════════════════

menu_sensors() {
    while true; do
        print_header
        print_menu_header "🌡️  Sensors & Status"
        echo -e "  ${CYAN}${BOLD}[1]${NC} 📡  All Sensors"
        echo -e "  ${CYAN}${BOLD}[2]${NC} 📈  Sensor Readings"
        echo -e "  ${CYAN}${BOLD}[3]${NC} 📋  SDR List (Detailed)"
        echo -e "  ${CYAN}${BOLD}[4]${NC} 🌀  Fan Status"
        echo -e "  ${CYAN}${BOLD}[5]${NC} 🌡️   Temperature Readings"
        echo ""
        echo -e "  ${GRAY}──────────────────────────────────────────────────────${NC}"
        echo -e "  ${RED}${BOLD}[0]${NC} 🔙  Back to Main Menu"
        echo ""
        read -p "  Select > " choice

        case $choice in
            1) run_ipmi "sensor list" "All Sensors" ;;
            2) run_ipmi "sdr elist" "Sensor Readings" ;;
            3) run_ipmi "sdr list" "SDR List" ;;
            4) run_ipmi "sdr elist | grep -i fan" "Fan Status" ;;
            5) run_ipmi "sdr elist | grep -i temp" "Temperature" ;;
            0) break ;;
            *) echo -e "  ${RED}✗ Invalid${NC}"; sleep 1 ;;
        esac
    done
}

# ═══════════════════════════════════════════════════════════
#                     USER MANAGEMENT
# ═══════════════════════════════════════════════════════════

menu_users() {
    while true; do
        print_header
        print_menu_header "👤 User Management"
        echo -e "  ${CYAN}${BOLD}[1]${NC} 📋  List All Users"
        echo -e "  ${CYAN}${BOLD}[2]${NC} 🔢  User Count"
        echo -e "  ${CYAN}${BOLD}[3]${NC} 🔍  User Access Info (by ID)"
        echo ""
        echo -e "  ${GRAY}──────────────────────────────────────────────────────${NC}"
        echo -e "  ${RED}${BOLD}[0]${NC} 🔙  Back to Main Menu"
        echo ""
        read -p "  Select > " choice

        case $choice in
            1) run_ipmi "user list" "All Users" ;;
            2) run_ipmi "user summary" "User Count" ;;
            3)
                read -p "  User ID (1-16): " user_id
                if [[ "$user_id" =~ ^[0-9]+$ ]] && [ "$user_id" -ge 1 ] && [ "$user_id" -le 16 ]; then
                    run_ipmi "user access summary $user_id" "User $user_id Access"
                else
                    echo -e "  ${RED}✗ Invalid ID${NC}"; sleep 1
                fi ;;
            0) break ;;
            *) echo -e "  ${RED}✗ Invalid${NC}"; sleep 1 ;;
        esac
    done
}

# ═══════════════════════════════════════════════════════════
#                     LAN CONFIGURATION
# ═══════════════════════════════════════════════════════════

menu_lan() {
    while true; do
        print_header
        print_menu_header "🌐 LAN Configuration"
        echo -e "  ${CYAN}${BOLD}[1]${NC} 📡  LAN Info (Channel 1)"
        echo -e "  ${CYAN}${BOLD}[2]${NC} 📡  LAN Info (Channel 3)"
        echo -e "  ${CYAN}${BOLD}[3]${NC} 📍  BMC IP Address"
        echo -e "  ${CYAN}${BOLD}[4]${NC} 🔗  BMC MAC Address"
        echo -e "  ${CYAN}${BOLD}[5]${NC} 🏷️   BMC Subnet Mask"
        echo ""
        echo -e "  ${GRAY}──────────────────────────────────────────────────────${NC}"
        echo -e "  ${RED}${BOLD}[0]${NC} 🔙  Back to Main Menu"
        echo ""
        read -p "  Select > " choice

        case $choice in
            1) run_ipmi "lan print 1" "LAN Info (Ch 1)" ;;
            2) run_ipmi "lan print 3" "LAN Info (Ch 3)" ;;
            3) run_ipmi "lan print 1 | grep -i 'IP Address'" "BMC IP" ;;
            4) run_ipmi "lan print 1 | grep -i 'MAC Address'" "BMC MAC" ;;
            5) run_ipmi "lan print 1 | grep -i 'Subnet Mask'" "BMC Subnet" ;;
            0) break ;;
            *) echo -e "  ${RED}✗ Invalid${NC}"; sleep 1 ;;
        esac
    done
}

# ═══════════════════════════════════════════════════════════
#                     EVENT LOGS
# ═══════════════════════════════════════════════════════════

menu_events() {
    while true; do
        print_header
        print_menu_header "📜 Event Logs (SEL)"
        echo -e "  ${CYAN}${BOLD}[1]${NC} 📖  View System Event Log"
        echo -e "  ${CYAN}${BOLD}[2]${NC} ℹ️   SEL Information"
        echo -e "  ${RED}${BOLD}[3]${NC} 🗑️   Clear SEL"
        echo -e "  ${CYAN}${BOLD}[4]${NC} 🕐  SEL Time"
        echo ""
        echo -e "  ${GRAY}──────────────────────────────────────────────────────${NC}"
        echo -e "  ${RED}${BOLD}[0]${NC} 🔙  Back to Main Menu"
        echo ""
        read -p "  Select > " choice

        case $choice in
            1) run_ipmi "sel list" "System Event Log" ;;
            2) run_ipmi "sel info" "SEL Info" ;;
            3)
                if confirm_action "CLEAR all events? Cannot be undone!"; then
                    run_ipmi "sel clear" "SEL Cleared"
                fi ;;
            4) run_ipmi "sel time get" "SEL Time" ;;
            0) break ;;
            *) echo -e "  ${RED}✗ Invalid${NC}"; sleep 1 ;;
        esac
    done
}

# ═══════════════════════════════════════════════════════════
#                     ADVANCED
# ═══════════════════════════════════════════════════════════

menu_advanced() {
    while true; do
        print_header
        print_menu_header "🛠️  Advanced Tools"
        echo -e "  ${CYAN}${BOLD}[1]${NC} 🖥️   SOL Info"
        echo -e "  ${CYAN}${BOLD}[2]${NC} ⌨️   Raw Command"
        echo -e "  ${CYAN}${BOLD}[3]${NC} ⚡  DCMI Power Readings"
        echo -e "  ${CYAN}${BOLD}[4]${NC} 📊  DCMI Sensors"
        echo -e "  ${RED}${BOLD}[5]${NC} 🔄  BMC Reset (Cold)"
        echo -e "  ${YELLOW}${BOLD}[6]${NC} 🔃  BMC Reset (Warm)"
        echo -e "  ${CYAN}${BOLD}[7]${NC} 📡  Channel Info"
        echo ""
        echo -e "  ${GRAY}──────────────────────────────────────────────────────${NC}"
        echo -e "  ${RED}${BOLD}[0]${NC} 🔙  Back to Main Menu"
        echo ""
        read -p "  Select > " choice

        case $choice in
            1) run_ipmi "sol info" "SOL Info" ;;
            2)
                echo -e "  ${CYAN}Enter raw command (e.g., 0x06 0x01):${NC}"
                read raw_cmd
                if [ -n "$raw_cmd" ]; then
                    run_ipmi "raw $raw_cmd" "Raw Command"
                else
                    echo -e "  ${RED}✗ No command${NC}"; sleep 1
                fi ;;
            3) run_ipmi "dcmi power reading" "DCMI Power" ;;
            4) run_ipmi "dcmi sensors" "DCMI Sensors" ;;
            5)
                if confirm_action "COLD reset BMC? BMC will restart!"; then
                    run_ipmi "mc reset cold" "BMC Cold Reset"
                fi ;;
            6)
                if confirm_action "WARM reset BMC?"; then
                    run_ipmi "mc reset warm" "BMC Warm Reset"
                fi ;;
            7) run_ipmi "channel info" "Channel Info" ;;
            0) break ;;
            *) echo -e "  ${RED}✗ Invalid${NC}"; sleep 1 ;;
        esac
    done
}

# ═══════════════════════════════════════════════════════════
#                       MAIN MENU
# ═══════════════════════════════════════════════════════════

main_menu() {
    while true; do
        print_header
        echo -e "  ${BOLD}${BLUE}Main Menu${NC}"
        echo -e "  ${BLUE}──────────────────────────────────────────────────────${NC}"
        echo ""
        echo -e "  ${CYAN}${BOLD}[1]${NC} 📊  System Information"
        echo -e "  ${CYAN}${BOLD}[2]${NC} ⚡  Power Management"
        echo -e "  ${CYAN}${BOLD}[3]${NC} 🌡️   Sensors & Status"
        echo -e "  ${CYAN}${BOLD}[4]${NC} 👤  User Management"
        echo -e "  ${CYAN}${BOLD}[5]${NC} 🌐  LAN Configuration"
        echo -e "  ${CYAN}${BOLD}[6]${NC} 📜  Event Logs (SEL)"
        echo -e "  ${CYAN}${BOLD}[7]${NC} 🛠️   Advanced Tools"
        echo ""
        echo -e "  ${GRAY}──────────────────────────────────────────────────────${NC}"
        echo -e "  ${CYAN}${BOLD}[8]${NC} 🔄  Change Target"
        echo -e "  ${RED}${BOLD}[0]${NC} 🚪  Exit"
        echo ""
        read -p "  Select > " choice

        case $choice in
            1) menu_system_info ;;
            2) menu_power ;;
            3) menu_sensors ;;
            4) menu_users ;;
            5) menu_lan ;;
            6) menu_events ;;
            7) menu_advanced ;;
            8) get_credentials ;;
            0)
                echo ""
                echo -e "  ${GREEN}Goodbye! 👋${NC}"
                echo ""
                exit 0 ;;
            *) echo -e "  ${RED}✗ Invalid${NC}"; sleep 1 ;;
        esac
    done
}

# ═══════════════════════════════════════════════════════════
#                       DEPENDENCY CHECK
# ═══════════════════════════════════════════════════════════

check_dependencies() {
    local missing=()

    if ! command -v ipmitool &> /dev/null; then
        missing+=("ipmitool")
    fi

    if [ ${#missing[@]} -gt 0 ]; then
        echo ""
        echo -e "  ${YELLOW}⚠️  Missing dependencies: ${missing[*]}${NC}"
        echo ""

        if [ "$EUID" -ne 0 ]; then
            echo -e "  ${GRAY}Need sudo to install dependencies.${NC}"
            read -p "  Install now? (Y/n): " install_choice
            if [[ "$install_choice" != "n" && "$install_choice" != "N" ]]; then
                echo ""
                echo -e "  ${YELLOW}Installing ipmitool...${NC}"
                sudo apt-get update -qq && sudo apt-get install -y -qq ipmitool
                if [ $? -eq 0 ]; then
                    echo -e "  ${GREEN}✓ ipmitool installed successfully!${NC}"
                else
                    echo -e "  ${RED}✗ Failed to install ipmitool${NC}"
                    echo -e "  ${GRAY}Install manually: sudo apt install ipmitool${NC}"
                    exit 1
                fi
            else
                echo -e "  ${RED}Cannot continue without ipmitool.${NC}"
                exit 1
            fi
        else
            echo -e "  ${YELLOW}Installing ipmitool...${NC}"
            apt-get update -qq && apt-get install -y -qq ipmitool
            if [ $? -eq 0 ]; then
                echo -e "  ${GREEN}✓ ipmitool installed successfully!${NC}"
            else
                echo -e "  ${RED}✗ Failed to install ipmitool${NC}"
                exit 1
            fi
        fi
        echo ""
    fi
}

check_dependencies
get_credentials
main_menu
