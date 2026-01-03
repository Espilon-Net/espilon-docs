# Installation Guide

This guide provides detailed step-by-step instructions for setting up Espilon on your ESP32 devices.

---

## Table of Contents

- [Prerequisites](#prerequisites)
- [System Requirements](#system-requirements)
- [ESP-IDF Setup](#esp-idf-setup)
- [Espilon Installation](#epsilon-installation)
- [Configuration](#configuration)
- [Building the Firmware](#building-the-firmware)
- [Flashing](#flashing)
- [C2 Server Setup](#c2-server-setup)
- [Verification](#verification)
- [Troubleshooting](#troubleshooting)

---

## Prerequisites

### Hardware

- ESP32 development board (any variant: ESP32, ESP32-S2, ESP32-S3, ESP32-C3)
- USB cable (data-capable, not just power)
- Computer running Linux, macOS, or Windows (WSL2)
- For GPRS: SIM800/SIM808 module
- For Camera: ESP32-CAM module (AI-Thinker or compatible)

### Software

- Python 3.8 or newer
- Git
- C compiler toolchain
- USB-to-Serial drivers (CP210x or CH340 depending on your board)

---

## System Requirements

### Minimum

- **OS**: Ubuntu 20.04+, macOS 10.15+, Windows 10 (WSL2)
- **RAM**: 4GB
- **Disk**: 10GB free space
- **CPU**: Any modern x64 processor

### Recommended

- **OS**: Ubuntu 22.04 LTS
- **RAM**: 8GB
- **Disk**: 20GB free space (for ESP-IDF and build artifacts)
- **CPU**: Multi-core processor (faster builds)

---

## ESP-IDF Setup

Espilon requires **ESP-IDF v5.3.2** or compatible.

### Option 1: Quick Install (Recommended)

#### Linux / macOS

```bash
# Install dependencies
sudo apt-get update
sudo apt-get install -y git wget flex bison gperf python3 python3-pip \
    python3-venv cmake ninja-build ccache libffi-dev libssl-dev \
    dfu-util libusb-1.0-0

# Clone ESP-IDF
mkdir -p ~/esp
cd ~/esp
git clone --recursive --branch v5.3.2 https://github.com/espressif/esp-idf.git

# Run installer
cd ~/esp/esp-idf
./install.sh esp32

# Set up environment (add this to ~/.bashrc or ~/.zshrc for persistence)
. ~/esp/esp-idf/export.sh
```

#### macOS Additional Steps

```bash
# Install Homebrew if not present
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install dependencies
brew install cmake ninja ccache dfu-util python3
```

### Option 2: Using ESP-IDF Installer

Download the official installer from:
- **Windows**: [ESP-IDF Windows Installer](https://dl.espressif.com/dl/esp-idf/)
- **macOS/Linux**: Use method above

### Verify ESP-IDF Installation

```bash
# Should output: ESP-IDF v5.3.2 or similar
idf.py --version

# Test build system
cd ~/esp/esp-idf/examples/get-started/hello_world
idf.py build
```

---

## Espilon Installation

### 1. Clone Repository

```bash
cd ~
git clone https://github.com/yourusername/epsilon.git
cd epsilon
```

### 2. Verify Structure

```bash
ls -la
# Should see:
# - espilon_bot/    (ESP32 firmware)
# - tools/          (C2 server and utilities)
# - base/           (Base configurations)
# - docs/           (Documentation)
# - README.md
```

### 3. Install Python Dependencies (for C2 server)

```bash
cd tools/c2
pip3 install -r requirements.txt

# Or use virtual environment (recommended)
python3 -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate
pip install -r requirements.txt
```

---

## Configuration

### 1. Configure Network Backend

```bash
cd ~/epsilon/espilon_bot
idf.py menuconfig
```

Navigate through the menu:

```
→ Espilon Configuration
  → Network Backend Selection
    → [*] WiFi  (or [ ] GPRS)
```

### 2. WiFi Configuration

If using WiFi:

```
→ Espilon Configuration
  → WiFi Configuration
    → WiFi SSID: "your-network-name"
    → WiFi Password: "your-password"
```

### 3. GPRS Configuration

If using GPRS:

```
→ Espilon Configuration
  → GPRS Configuration
    → APN: "your-operator-apn"  (e.g., "sl2sfr" for SFR, "orange" for Orange)
    → UART TXD GPIO: 27
    → UART RXD GPIO: 26
```

Common APNs:
- SFR (France): `sl2sfr`
- Orange (France): `orange`
- AT&T (USA): `phone`
- T-Mobile (USA): `fast.t-mobile.com`
- Vodafone (UK): `pp.vodafone.co.uk`

### 4. C2 Server Configuration

```
→ Espilon Configuration
  → C2 Server Configuration
    → Server IP Address: "192.168.1.100"  (your C2 server IP)
    → Server Port: 2626
```

**Important**: Use the IP address where your C2 server will run. This can be:
- Your computer's local IP (e.g., `192.168.1.100`)
- A cloud server IP (e.g., `51.178.42.123`)
- Use `ifconfig` (Linux/Mac) or `ipconfig` (Windows) to find your local IP

### 5. Cryptography Configuration CRITICAL

```
→ Espilon Configuration
  → Cryptography Configuration
    → ChaCha20 Key (32 bytes): "YOUR-32-BYTE-KEY-HERE-EXACTLY"
    → ChaCha20 Nonce (12 bytes): "12BYTENONCE!"
```

**Generate secure keys:**

```bash
# Generate 32-byte key (64 hex characters)
openssl rand -hex 32
# Example output: a1b2c3d4e5f6...

# Generate 12-byte nonce (24 hex characters)
openssl rand -hex 12
# Example output: 1a2b3c4d5e6f...

# Convert hex to ASCII for menuconfig
# Or use this Python script:
python3 -c "import os; print(os.urandom(32).hex())"
```

**WARNING**: Never use default test keys in production!

### 6. Device ID

```
→ Espilon Configuration
  → Device Configuration
    → Device ID: "auto"  (generates unique CRC32 ID)
    → Or enter custom ID: "12345678"
```

The device ID should be 8 hexadecimal characters.

### 7. Module Selection

Enable desired modules:

```
→ Espilon Configuration
  → Module Selection
    → [*] System Module (basic commands)
    → [*] Network Module (ping, arp, proxy)
    → [*] FakeAP Module (rogue AP, sniffer)
    → [ ] Recon Module
        → [ ] Camera Mode (requires ESP32-CAM)
        → [ ] BLE Trilateration
```

**Note**: Only enable modules you need to reduce binary size.

### 8. Advanced Settings (Optional)

#### LWIP Configuration for FakeAP

```
→ Component config
  → LWIP
    → [*] Enable IP forwarding
    → [*] Enable NAT (Network Address Translation)
      → [*] Enable NAPT (Network Address Port Translation)
```

#### Memory Optimization

```
→ Component config
  → ESP System Settings
    → Main task stack size: 4096 (increase if needed)
  → FreeRTOS
    → Task stack size: 3072
```

### 9. Save Configuration

Press:
- `S` to save
- `Q` to quit menuconfig

Configuration is saved to `sdkconfig`.

---

## Building the Firmware

### 1. Clean Previous Builds (Optional)

```bash
cd ~/epsilon/espilon_bot
idf.py fullclean
```

### 2. Build

```bash
idf.py build
```

**Expected output:**
```
Project build complete. To flash, run:
 idf.py -p (PORT) flash
or
 idf.py -p (PORT) flash monitor
```

**Build time**: 2-5 minutes on first build (subsequent builds are faster)

### 3. Check Binary Size

```bash
idf.py size

# Should show something like:
# Total sizes:
#  DRAM .data size:   xxxxx bytes
#  DRAM .bss  size:   xxxxx bytes
#  Flash code:        xxxxx bytes
#  Flash rodata:      xxxxx bytes
```

Ensure total size fits in your ESP32's flash (typically 4MB limit).

---

## Flashing

### 1. Connect ESP32

Connect your ESP32 to USB. The device should appear as:
- Linux: `/dev/ttyUSB0` or `/dev/ttyACM0`
- macOS: `/dev/cu.usbserial-*`
- Windows (WSL2): COM port (use `usbipd` to attach)

**Find the port:**

```bash
# Linux
ls /dev/tty*
dmesg | grep tty  # Check recent connections

# macOS
ls /dev/cu.*

# Test permissions
sudo usermod -a -G dialout $USER  # Add user to dialout group
# Then logout and login again
```

### 2. Flash Firmware

```bash
idf.py -p /dev/ttyUSB0 flash

# Or with automatic port detection (Linux only)
idf.py flash
```

**Flashing options:**

```bash
# Flash only app (faster for code changes)
idf.py -p /dev/ttyUSB0 app-flash

# Flash with monitoring
idf.py -p /dev/ttyUSB0 flash monitor

# Erase entire flash before flashing
idf.py -p /dev/ttyUSB0 erase-flash
idf.py -p /dev/ttyUSB0 flash
```

### 3. Monitor Output

```bash
idf.py -p /dev/ttyUSB0 monitor

# Exit monitor: Ctrl+]
```

**Expected boot output:**

```
I (123) boot: ESP-IDF v5.3.2
I (234) wifi: WiFi initialized
I (345) epsilon: Device ID: ce4f626b
I (456) epsilon: Connecting to WiFi SSID: your-network
I (567) epsilon: WiFi connected, IP: 192.168.1.42
I (678) epsilon: Connecting to C2: 192.168.1.100:2626
I (789) epsilon: C2 connected successfully
```

### 4. Troubleshooting Flash Issues

#### "Failed to connect to ESP32"

```bash
# Put ESP32 in download mode manually:
# 1. Hold BOOT button
# 2. Press RESET button
# 3. Release RESET
# 4. Release BOOT
# 5. Try flashing again

# Or use slow baud rate
idf.py -p /dev/ttyUSB0 -b 115200 flash
```

#### "Permission denied" on /dev/ttyUSB0

```bash
# Add user to dialout group (Linux)
sudo usermod -a -G dialout $USER
# Logout and login

# Or use sudo (not recommended)
sudo idf.py -p /dev/ttyUSB0 flash
```

#### "Port doesn't exist"

```bash
# Check USB connection
lsusb  # Should show Silicon Labs or CH340

# Install drivers if needed
sudo apt-get install brltty
sudo systemctl stop brltty
sudo systemctl disable brltty
```

---

## C2 Server Setup

### 1. Configure C2

The C2 server needs matching crypto keys.

**Edit C2 configuration** (if configuration file exists):

```bash
cd ~/epsilon/tools/c2
# Configuration is typically in code or command-line args
```

**Or set via environment variables:**

```bash
export EPSILON_CRYPTO_KEY="YOUR-32-BYTE-KEY-HERE-EXACTLY"
export EPSILON_CRYPTO_NONCE="12BYTENONCE!"
```

### 2. Start C2 Server

```bash
cd ~/epsilon/tools/c2
python3 c3po.py --port 2626

# Or with specific interface
python3 c3po.py --host 0.0.0.0 --port 2626

# With verbose logging
python3 c3po.py --port 2626 --verbose
```

**Expected output:**

```
[*] Espilon C2 Server starting...
[*] Listening on 0.0.0.0:2626
[*] Waiting for agents...
```

### 3. Verify Connection

When ESP32 connects, C2 should show:

```
[+] New device connected: ce4f626b (192.168.1.42)
```

**Test command:**

```
c3po> list
ID           IP              CONNECTED
----------------------------------------
ce4f626b     192.168.1.42    12s

c3po> send ce4f626b system_mem
[*] Command sent to ce4f626b
[<] Response from ce4f626b:
    Free heap: 245678 bytes
    Min free heap: 201234 bytes
```

---

## Verification

### 1. Check Network Connectivity

**On ESP32** (via serial monitor):

```bash
idf.py monitor

# Should see:
# - WiFi connection successful
# - IP address assigned
# - C2 connection established
```

**On C2 server**:

```
c3po> list
# Device should appear
```

### 2. Test Basic Commands

```
c3po> send <device-id> system_uptime
c3po> send <device-id> system_mem
c3po> send <device-id> system_reboot
```

### 3. Test Network Commands

```
c3po> send <device-id> ping 8.8.8.8 5
c3po> send <device-id> arp_scan 192.168.1.0/24
```

### 4. Check Encryption

**Monitor network traffic:**

```bash
sudo tcpdump -i any port 2626 -A

# You should see Base64-encoded data, NOT plaintext
# Example: YWJjZGVmZ2hpams...
```

---

## Multi-Device Flashing

For flashing multiple devices with different configurations, use the multi-flasher tool.

### 1. Configure Devices

```bash
cd ~/epsilon/tools/flasher
cp devices.json.example devices.json
nano devices.json
```

**Example configuration:**

```json
{
  "project": "/home/user/epsilon/espilon_bot",
  "devices": [
    {
      "id": "device01",
      "wifi_ssid": "network1",
      "wifi_pass": "password1",
      "srv_ip": "192.168.1.100",
      "srv_port": 2626,
      "port": "/dev/ttyUSB0"
    },
    {
      "id": "device02",
      "wifi_ssid": "network2",
      "wifi_pass": "password2",
      "srv_ip": "192.168.1.100",
      "srv_port": 2626,
      "port": "/dev/ttyUSB1"
    }
  ]
}
```

### 2. Run Multi-Flasher

```bash
python3 flash.py devices.json

# The tool will:
# 1. Modify sdkconfig for each device
# 2. Build firmware
# 3. Flash to specified port
# 4. Repeat for all devices
```

---

## Troubleshooting

### ESP32 Won't Connect to WiFi

**Check credentials:**
```bash
idf.py menuconfig
# Verify SSID and password are correct
```

**Check WiFi logs:**
```bash
idf.py monitor | grep wifi
```

**Common issues:**
- Wrong password
- 5GHz network (ESP32 only supports 2.4GHz)
- Hidden SSID (not supported by default)
- MAC filtering on router

### C2 Connection Fails

**Check C2 is running:**
```bash
netstat -tuln | grep 2626
```

**Check IP address:**
```bash
# On C2 server
ip addr show  # Linux
ifconfig      # macOS
ipconfig      # Windows

# ESP32 must be able to reach this IP
```

**Check firewall:**
```bash
# Allow C2 port (Linux)
sudo ufw allow 2626/tcp

# Check if port is blocked
sudo iptables -L | grep 2626
```

**Test connectivity:**
```bash
# From ESP32's network, test connection
nc -zv <c2-ip> 2626
telnet <c2-ip> 2626
```

### Decryption Errors

**Symptoms:**
- C2 shows "Failed to decrypt message"
- ESP32 shows "Invalid response from C2"

**Solution:**
```bash
# Ensure EXACT same keys in both:
# 1. ESP32 menuconfig
# 2. C2 configuration

# Keys must be EXACTLY 32 bytes (ChaCha20 key)
# Nonce must be EXACTLY 12 bytes
```

### Flash Size Issues

**Symptom:**
```
Error: Not enough space in flash
```

**Solution:**
```bash
# Disable unused modules
idf.py menuconfig
# → Espilon Configuration → Module Selection
# Uncheck modules you don't need

# Or use larger flash
# → Serial flasher config → Flash size → 4MB/8MB
```

### Serial Monitor Garbage Output

**Symptoms:** Unreadable characters in monitor

**Solution:**
```bash
# Check baud rate (should be 115200)
idf.py monitor -b 115200

# Or set in menuconfig
# → Component config → ESP System → UART console baud rate
```

### Build Errors

**Missing dependencies:**
```bash
cd ~/esp/esp-idf
./install.sh esp32
```

**CMake errors:**
```bash
# Clean and rebuild
cd ~/epsilon/espilon_bot
rm -rf build
idf.py fullclean
idf.py build
```

**Python errors:**
```bash
# Update pip
pip3 install --upgrade pip

# Reinstall ESP-IDF requirements
cd ~/esp/esp-idf
pip3 install -r requirements.txt
```

---

## Next Steps

Once installation is complete:

1. Read [HARDWARE.md](HARDWARE.md) for hardware-specific setups
2. Review [MODULES.md](MODULES.md) for module documentation
3. Check [SECURITY.md](SECURITY.md) for security best practices
4. Explore [docs/examples/](../examples/) for usage scenarios

---

## Getting Help

- **GitHub Issues**: [Report issues](https://github.com/yourusername/epsilon/issues)
- **Discussions**: [Community forum](https://github.com/yourusername/epsilon/discussions)
- **ESP-IDF Docs**: [Official documentation](https://docs.espressif.com/projects/esp-idf/)

---

**Last Updated**: 2025-12-26
