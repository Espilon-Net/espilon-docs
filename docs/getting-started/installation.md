# Installation Guide

Complete setup instructions for Espilon firmware development and C2 server deployment.

## Prerequisites

### System Requirements

=== "Linux (Recommended)"
    - Ubuntu 20.04+ / Debian 11+
    - 4GB RAM minimum
    - 5GB free disk space
    - USB port for ESP32

=== "macOS"
    - macOS 10.15+
    - 4GB RAM minimum
    - 5GB free disk space
    - USB port for ESP32

=== "Windows"
    - Windows 10/11
    - WSL2 (Ubuntu recommended)
    - 4GB RAM minimum
    - 5GB free disk space

### Required Software

- Git
- Python 3.8 or later
- USB-to-UART drivers (CH340, CP2102, or CH9102)

## Part 1: ESP-IDF Installation

ESP-IDF (Espressif IoT Development Framework) is required to build Espilon firmware.

### Step 1: Install Dependencies

=== "Ubuntu/Debian"
    ```bash
    sudo apt-get update
    sudo apt-get install -y git wget flex bison gperf python3 python3-pip \
        python3-venv cmake ninja-build ccache libffi-dev libssl-dev dfu-util \
        libusb-1.0-0
    ```

=== "macOS"
    ```bash
    brew install cmake ninja dfu-util python3
    ```

=== "Windows (WSL2)"
    ```bash
    sudo apt-get update
    sudo apt-get install -y git wget flex bison gperf python3 python3-pip \
        python3-venv cmake ninja-build ccache libffi-dev libssl-dev dfu-util \
        libusb-1.0-0
    ```

### Step 2: Download ESP-IDF v5.3.2

```bash
mkdir -p ~/esp
cd ~/esp
git clone -b v5.3.2 --recursive https://github.com/espressif/esp-idf.git
```

### Step 3: Install ESP-IDF

```bash
cd ~/esp/esp-idf
./install.sh esp32
```

This will download the ESP32 toolchain (~1GB).

### Step 4: Set Up Environment

Add to your `~/.bashrc` or `~/.zshrc`:

```bash
alias get_idf='. $HOME/esp/esp-idf/export.sh'
```

Then reload:

```bash
source ~/.bashrc  # or source ~/.zshrc
```

### Step 5: Verify Installation

```bash
get_idf
idf.py --version
```

Expected output:
```
ESP-IDF v5.3.2
```

## Part 2: Clone Espilon Repository

```bash
cd ~
git clone https://github.com/yourusername/epsilon.git
cd epsilon
```

## Part 3: Build Espilon Firmware

### Step 1: Configure Project

```bash
cd espilon_bot
get_idf
idf.py menuconfig
```

### Step 2: Configure Basic Settings

Navigate through the menu:

```
Espilon Bot Configuration
  ├─ Device ID: "ce4f626b" (change to unique ID)
  ├─ Network
  │   ├─ Connection Mode: [X] WiFi (or GPRS for T-Call)
  │   ├─ WiFi SSID: "YourWiFiName"
  │   └─ WiFi Password: "YourPassword"
  ├─ Server
  │   ├─ Server IP: "192.168.1.100" (your C2 server IP)
  │   └─ Server Port: 2626
  └─ Modules
      ├─ [X] Network Commands
      ├─ [ ] Recon Commands
      └─ [ ] Fake Access Point Commands
```

Press `S` to save, then `Q` to quit.

### Step 3: Build Firmware

```bash
idf.py build
```

First build takes 5-10 minutes. Subsequent builds are faster.

### Step 4: Flash to ESP32

Connect your ESP32 via USB, then:

```bash
# Auto-detect port and flash
idf.py flash

# Or specify port manually
idf.py -p /dev/ttyUSB0 flash
```

### Step 5: Monitor Output

```bash
idf.py monitor
```

Press `Ctrl+]` to exit monitor.

Expected output:
```
I (123) boot: ESP-IDF v5.3.2
I (456) epsilon: Device ce4f626b starting...
I (789) WiFi: Connecting to YourWiFiName
I (1234) WiFi: Connected, IP: 192.168.1.50
I (1567) epsilon: Connecting to C2: 192.168.1.100:2626
I (2345) epsilon: Connected to C2
I (2456) epsilon: Device ready
```

## Part 4: C2 Server Setup

### Step 1: Install C2 Dependencies

```bash
cd ~/epsilon/tools/c2
pip3 install -r requirements.txt
```

### Step 2: Configure C2

Edit `config.json`:

```json
{
  "server": {
    "host": "0.0.0.0",
    "port": 2626
  },
  "crypto": {
    "key": "testde32chars00000000000000000000",
    "nonce": "noncenonceno"
  }
}
```

!!! warning "Change Crypto Keys"
    The default keys are for testing only. Generate new keys for production:
    ```bash
    openssl rand -hex 32  # 32-byte key
    openssl rand -hex 12  # 12-byte nonce
    ```

### Step 3: Run C2 Server

```bash
python3 c3po.py --port 2626
```

Expected output:
```
[*] C3PO C2 Server v1.0
[*] Listening on 0.0.0.0:2626
[*] Waiting for agents...
```

### Step 4: Verify Connection

When an ESP32 connects, you'll see:

```
[+] New device: ce4f626b (192.168.1.50)
```

Type `help` in the C2 CLI to see available commands.

## Part 5: Multi-Device Flasher (Optional)

For flashing multiple devices with different configs:

```bash
cd ~/epsilon/tools/flasher
```

Edit `devices.json` with your device configurations, then:

```bash
python3 flash.py --config devices.json
```

See [Flasher Documentation](../tools/flasher.md) for details.

## Troubleshooting

### ESP-IDF Installation Failed

**Error**: `fatal error: Python.h: No such file or directory`

**Solution**:
```bash
sudo apt-get install python3-dev
```

### Cannot Flash ESP32

**Error**: `A serial exception error occurred: could not open port`

**Solution**: Add user to dialout group:
```bash
sudo usermod -a -G dialout $USER
# Log out and log back in
```

### Build Failed

**Error**: `fatal error: sdkconfig.h: No such file or directory`

**Solution**: Run menuconfig first:
```bash
idf.py menuconfig
# Save and quit
idf.py build
```

### Agent Won't Connect to C2

**Checks**:
1. Is C2 server running?
2. Correct server IP in menuconfig?
3. Firewall blocking port 2626?
4. Agent and C2 on same network (WiFi mode)?

**Solution**:
```bash
# Check C2 is listening
netstat -tln | grep 2626

# Check firewall (Linux)
sudo ufw allow 2626/tcp
```

## Next Steps

Now that Espilon is installed:

1. [Hardware Guide](../hardware/index.md) - Choose the right ESP32 board
2. [Configuration Guide](../configuration/menuconfig.md) - Advanced settings
3. [Module Reference](../modules/index.md) - Available commands

---

**Previous**: [Overview](overview.md) | **Next**: [Hardware](../hardware/index.md)
