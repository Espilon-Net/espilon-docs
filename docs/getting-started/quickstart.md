# Quick Start Guide

Get Espilon up and running in minutes with this quick start guide.

## Prerequisites

Before you begin, ensure you have:

- [x] ESP32 development board (DevKit, LilyGO T-Call, or ESP32-CAM)
- [x] USB cable (data-capable)
- [x] Computer running Linux, macOS, or Windows (WSL2)
- [x] Python 3.8 or newer
- [x] Git

## Installation Steps

### 1. Install ESP-IDF

=== "Linux"
    ```bash
    # Install dependencies
    sudo apt-get update
    sudo apt-get install git wget flex bison gperf python3 \
        python3-pip python3-venv cmake ninja-build ccache \
        libffi-dev libssl-dev dfu-util libusb-1.0-0

    # Clone ESP-IDF
    mkdir -p ~/esp
    cd ~/esp
    git clone --recursive -b v5.3.2 \
        https://github.com/espressif/esp-idf.git

    # Install toolchain
    cd esp-idf
    ./install.sh esp32

    # Set up environment
    . ./export.sh
    ```

=== "macOS"
    ```bash
    # Install Homebrew
    /bin/bash -c "$(curl -fsSL \
        https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    # Install dependencies
    brew install cmake ninja ccache dfu-util python3

    # Clone and install ESP-IDF
    mkdir -p ~/esp
    cd ~/esp
    git clone --recursive -b v5.3.2 \
        https://github.com/espressif/esp-idf.git
    cd esp-idf
    ./install.sh esp32
    . ./export.sh
    ```

=== "Windows (WSL2)"
    ```bash
    # Open WSL2 terminal, then follow Linux instructions
    # Ensure WSL2 is installed:
    wsl --install

    # Then follow Linux tab instructions
    ```

### 2. Clone Espilon

```bash
cd ~
git clone https://github.com/yourusername/epsilon.git
cd epsilon
```

### 3. Configure Firmware

```bash
cd espilon_bot
idf.py menuconfig
```

#### Essential Configuration

Navigate through the menu and configure:

=== "WiFi Mode"
    ```
    Espilon Configuration
      ├─ Network Backend → [X] WiFi
      ├─ WiFi SSID: "YourNetwork"
      ├─ WiFi Password: "YourPassword"
      ├─ C2 Server IP: "192.168.1.100"
      ├─ C2 Server Port: 2626
      └─ Cryptography
          ├─ Key: [Generate new key]
          └─ Nonce: [Generate new nonce]
    ```

=== "GPRS Mode (T-Call)"
    ```
    Espilon Configuration
      ├─ Network Backend → [X] GPRS
      ├─ GPRS APN: "your-apn"
      ├─ C2 Server IP: "your.server.ip"
      ├─ C2 Server Port: 2626
      └─ Cryptography
          ├─ Key: [Generate new key]
          └─ Nonce: [Generate new nonce]
    ```

!!! warning "Change Default Keys"
    Generate secure keys before deployment:
    ```bash
    # 32-byte key
    openssl rand -hex 32

    # 12-byte nonce
    openssl rand -hex 12
    ```

### 4. Build and Flash

```bash
# Build firmware
idf.py build

# Flash to device (replace port if needed)
idf.py -p /dev/ttyUSB0 flash

# Monitor serial output
idf.py monitor
```

!!! tip "Find Your Port"
    === "Linux"
        ```bash
        ls /dev/ttyUSB* /dev/ttyACM*
        ```

    === "macOS"
        ```bash
        ls /dev/cu.*
        ```

    === "Windows"
        Use Device Manager to find COM port

### 5. Start C2 Server

In a new terminal:

```bash
cd ~/epsilon/tools/c2

# Install dependencies
pip3 install -r requirements.txt

# Start server
python3 c3po.py --port 2626
```

Expected output:

```
[*] Espilon C2 Server starting...
[*] Listening on 0.0.0.0:2626
[*] Waiting for agents...
```

### 6. Verify Connection

Once the ESP32 boots, you should see in the C2 server:

```
[+] New device connected: ce4f626b (192.168.1.42)
```

List connected devices:

```
c3po> list

ID           IP              CONNECTED
----------------------------------------
ce4f626b     192.168.1.42    12s
```

## First Commands

Try these basic commands:

```bash
# Check device uptime
c3po> send ce4f626b system_uptime

# Check memory
c3po> send ce4f626b system_mem

# Ping test
c3po> send ce4f626b ping 8.8.8.8 5

# Scan network
c3po> send ce4f626b arp_scan 192.168.1.0/24
```

## Common Issues

### Device Won't Flash

??? question "Permission denied on /dev/ttyUSB0"
    ```bash
    # Add user to dialout group
    sudo usermod -a -G dialout $USER

    # Logout and login again
    ```

??? question "Failed to connect to ESP32"
    Put device in download mode:

    1. Hold BOOT button
    2. Press RESET button
    3. Release RESET
    4. Release BOOT
    5. Try flashing again

### WiFi Won't Connect

??? question "Wrong credentials"
    - Verify SSID and password in menuconfig
    - Ensure 2.4GHz network (ESP32 doesn't support 5GHz)

??? question "Hidden SSID"
    Hidden SSIDs require additional configuration not enabled by default

### C2 Won't Connect

??? question "Can't reach C2 server"
    - Check firewall allows port 2626
    - Verify C2 IP address is reachable from ESP32
    - Ensure C2 server is running

??? question "Decryption errors"
    - Verify encryption keys match between firmware and C2
    - Keys must be EXACTLY 32 bytes (key) and 12 bytes (nonce)

## Next Steps

Now that Espilon is running:

<div class="grid cards" markdown>

-   :material-text-box-multiple:{ .lg .middle } __Explore Modules__

    ---

    Learn about available commands and modules

    [:octicons-arrow-right-24: Module Reference](../modules/index.md)

-   :material-chip:{ .lg .middle } __Hardware Setup__

    ---

    Configure additional hardware (GPRS, Camera)

    [:octicons-arrow-right-24: Hardware Guide](../hardware/index.md)

-   :material-school:{ .lg .middle } __Try Examples__

    ---

    Follow practical examples and use cases

    [:octicons-arrow-right-24: Examples](../examples/index.md)

-   :material-shield-lock:{ .lg .middle } __Security Review__

    ---

    Understand security best practices

    [:octicons-arrow-right-24: Security](../security/index.md)

</div>

## Getting Help

Need assistance?

- Check the [Troubleshooting Guide](../reference/troubleshooting.md)
- Read the [FAQ](../reference/faq.md)
- Ask in [GitHub Discussions](https://github.com/yourusername/epsilon/discussions)
- Report bugs in [GitHub Issues](https://github.com/yourusername/epsilon/issues)

---

**Congratulations!** You now have a working Espilon installation.
