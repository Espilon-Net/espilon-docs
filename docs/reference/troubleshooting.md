# Troubleshooting Guide

Common issues and solutions for Espilon.

## Installation Issues

### ESP-IDF Installation

??? question "Command not found: idf.py"
    **Cause:** ESP-IDF environment not sourced.

    **Solution:**
    ```bash
    # Source ESP-IDF environment
    . ~/esp/esp-idf/export.sh

    # Or add to .bashrc for permanent setup
    echo '. ~/esp/esp-idf/export.sh' >> ~/.bashrc
    ```

??? question "Python version error"
    **Cause:** ESP-IDF requires Python 3.8+

    **Solution:**
    ```bash
    # Check Python version
    python3 --version

    # Install Python 3.8+ if needed
    sudo apt install python3.8 python3.8-venv
    ```

??? question "Missing dependencies"
    **Cause:** Build tools not installed.

    **Solution:**
    ```bash
    # Ubuntu/Debian
    sudo apt-get install git wget flex bison gperf python3 \
        python3-pip python3-venv cmake ninja-build ccache \
        libffi-dev libssl-dev dfu-util libusb-1.0-0

    # macOS
    brew install cmake ninja ccache dfu-util python3
    ```

### Compilation Errors

??? question "Component not found"
    **Cause:** Submodules not initialized.

    **Solution:**
    ```bash
    cd espilon
    git submodule update --init --recursive
    ```

??? question "PSRAM not available"
    **Cause:** Board doesn't have PSRAM or not enabled.

    **Solution:**
    ```bash
    idf.py menuconfig
    # Navigate to: Component config -> ESP32-specific
    # Enable: Support for external, SPI-connected RAM
    ```

??? question "Linker error: region 'iram0_0_seg' overflowed"
    **Cause:** Code too large for IRAM.

    **Solution:**
    ```bash
    idf.py menuconfig
    # Component config -> ESP32-specific -> Instruction cache
    # Try: "32KB instruction cache, 32KB line size"

    # Or disable unused modules
    # Espilon Configuration -> Module Selection
    ```

## Flashing Issues

### Device Not Detected

??? question "Permission denied on /dev/ttyUSB0"
    **Cause:** User not in dialout group.

    **Solution:**
    ```bash
    # Add user to dialout group
    sudo usermod -a -G dialout $USER

    # Logout and login again
    # Or use sudo (not recommended)
    sudo idf.py -p /dev/ttyUSB0 flash
    ```

??? question "Device not found"
    **Cause:** Wrong port or driver issue.

    **Solution:**
    ```bash
    # List available ports
    ls /dev/ttyUSB* /dev/ttyACM*

    # Check dmesg for device
    dmesg | grep -i usb | tail -20

    # Install drivers if needed (CH340)
    sudo apt install ch341
    ```

??? question "No serial data received"
    **Cause:** USB cable is charge-only (no data).

    **Solution:**

    - Use a data-capable USB cable
    - Try a different USB port
    - Test with another device

### Flash Failed

??? question "Failed to connect to ESP32: Timed out"
    **Cause:** ESP32 not in download mode.

    **Solution:**

    1. Hold **BOOT** button
    2. Press and release **RESET** button
    3. Release **BOOT** button
    4. Try flashing again

    For ESP32-CAM:

    1. Connect GPIO 0 to GND
    2. Power cycle
    3. Flash
    4. Disconnect GPIO 0
    5. Power cycle again

??? question "A fatal error occurred: Packet content transfer stopped"
    **Cause:** Power issue during flash.

    **Solution:**

    - Use external 5V power supply
    - Reduce baud rate: `idf.py -p /dev/ttyUSB0 -b 115200 flash`
    - Try shorter USB cable

??? question "Flash encryption check failed"
    **Cause:** Device has flash encryption enabled.

    **Solution:**

    - Flash encryption cannot be disabled once enabled
    - Use a new ESP32 module
    - Or use encrypted firmware

## Network Issues

### WiFi Connection

??? question "WiFi won't connect"
    **Checks:**

    1. SSID and password correct?
    2. 2.4GHz network? (ESP32 doesn't support 5GHz)
    3. Router allows new connections?

    **Debug:**
    ```bash
    idf.py monitor
    # Look for WiFi connection logs
    ```

??? question "WiFi keeps disconnecting"
    **Cause:** Weak signal or power issues.

    **Solution:**

    - Move closer to access point
    - Use external antenna (if available)
    - Check power supply stability
    - Reduce TX power in menuconfig

??? question "Can't find hidden SSID"
    **Cause:** Hidden SSIDs require specific handling.

    **Solution:**
    ```bash
    idf.py menuconfig
    # Espilon Configuration -> WiFi Settings
    # Enable: Scan for hidden APs
    ```

### GPRS Connection

??? question "SIM800 not responding"
    **Checks:**

    1. Antenna connected?
    2. SIM card inserted correctly?
    3. SIM PIN disabled?
    4. Power supply adequate?

    **Debug:**
    ```bash
    idf.py monitor
    # Look for "AT -> OK" responses
    ```

??? question "Network registration failed"
    **Cause:** No signal or SIM issue.

    **Solution:**

    1. Check SIM is active (has credit/data)
    2. Verify APN settings
    3. Try better antenna placement
    4. Check signal strength in logs

??? question "GPRS activation failed"
    **Cause:** Wrong APN settings.

    **Solution:**
    ```bash
    idf.py menuconfig
    # Espilon Configuration -> GPRS Settings
    # Set correct APN for your carrier
    ```

    Common APNs:

    | Carrier | APN |
    |---------|-----|
    | SFR (FR) | sl2sfr |
    | Orange (FR) | orange.fr |
    | AT&T (US) | phone |
    | T-Mobile (US) | fast.t-mobile.com |

### C2 Connection

??? question "Can't connect to C2 server"
    **Checks:**

    1. C2 server running?
    2. Correct IP address in firmware?
    3. Correct port?
    4. Firewall allows connection?

    **Debug:**
    ```bash
    # On C2 server
    nc -l 2626

    # Check firewall
    sudo ufw status
    sudo ufw allow 2626
    ```

??? question "Connection established but no commands work"
    **Cause:** Encryption key mismatch.

    **Solution:**

    1. Verify keys are identical in C2 and firmware
    2. Keys must be exact hex strings
    3. Key = 32 bytes (64 hex chars)
    4. Nonce = 12 bytes (24 hex chars)

??? question "Connection drops after a few seconds"
    **Cause:** Timeout or keepalive issue.

    **Solution:**
    ```json
    // C2 config.json
    {
      "server": {
        "timeout": 60,
        "keepalive_interval": 30
      }
    }
    ```

## Command Issues

### Commands Not Working

??? question "Command not recognized"
    **Cause:** Module not enabled or command misspelled.

    **Solution:**
    ```bash
    # Check enabled modules
    c3po> send device_id help

    # Verify module is enabled in firmware
    idf.py menuconfig
    # Espilon Configuration -> Module Selection
    ```

??? question "Command timeout"
    **Cause:** Command takes too long or failed.

    **Solution:**

    - Increase timeout for long operations
    - Check device logs for errors
    - Verify network stability

??? question "Permission denied for command"
    **Cause:** Command requires elevated privileges.

    **Solution:**

    - Some commands are restricted by design
    - Check command documentation
    - Verify firmware configuration

### Specific Commands

??? question "ARP scan returns no results"
    **Checks:**

    1. Correct network range?
    2. Device on same network?
    3. Network allows ARP?

    **Debug:**
    ```bash
    # Try smaller range first
    c3po> send device_id arp_scan 192.168.1.1/28
    ```

??? question "Ping always fails"
    **Checks:**

    1. Target IP reachable from device's network?
    2. Target allows ICMP?
    3. Network firewall blocks ICMP?

    **Debug:**
    ```bash
    # Try pinging gateway first
    c3po> send device_id ping 192.168.1.1 3
    ```

??? question "FakeAP not visible"
    **Checks:**

    1. FakeAP module enabled?
    2. Not on same channel as connected AP?
    3. Device supports AP mode?

    **Solution:**
    ```bash
    # Start with default settings
    c3po> send device_id fakeap_start "TestAP"

    # Check logs for errors
    idf.py monitor
    ```

## Camera Issues (ESP32-CAM)

??? question "Camera init failed"
    **Checks:**

    1. PSRAM enabled in menuconfig?
    2. Camera ribbon cable secure?
    3. Correct camera model selected?

    **Solution:**
    ```bash
    idf.py menuconfig
    # Component config -> ESP32-specific
    # [X] Support for external, SPI-connected RAM

    # Espilon Configuration -> Recon Module
    # Camera Model: AI-Thinker ESP32-CAM
    ```

??? question "Images are too dark"
    **Solution:**
    ```bash
    # Enable flash LED
    c3po> send cam_agent capture_settings flash on

    # Adjust brightness
    c3po> send cam_agent capture_settings brightness 2
    ```

??? question "Capture causes reboot"
    **Cause:** Power supply insufficient.

    **Solution:**

    - Use external 5V 1A+ power supply
    - Add 100uF capacitor across power pins
    - Reduce resolution: `capture_settings resolution QVGA`

## Performance Issues

??? question "Device runs slowly"
    **Cause:** Memory pressure or CPU overload.

    **Debug:**
    ```bash
    c3po> send device_id system_mem
    # Check free heap memory
    ```

    **Solution:**

    - Disable unused modules
    - Reduce concurrent operations
    - Use smaller buffers in menuconfig

??? question "Frequent disconnects"
    **Cause:** WiFi interference or power issues.

    **Solution:**

    - Use stable power supply
    - Reduce WiFi TX power
    - Use external antenna
    - Move away from interference sources

??? question "Commands take too long"
    **Cause:** Network latency or command complexity.

    **Solution:**

    - Check network latency with ping
    - Break complex commands into smaller ones
    - Increase C2 timeout settings

## Recovery

### Factory Reset

If device is in unknown state:

```bash
# Erase flash completely
idf.py -p /dev/ttyUSB0 erase_flash

# Reflash firmware
idf.py -p /dev/ttyUSB0 flash
```

### Safe Mode

Boot with minimal configuration:

1. Hold BOOT button during power-up
2. Device starts with default settings
3. Reconfigure via serial console

### Serial Console Debug

Connect and monitor serial output:

```bash
# Start monitor
idf.py monitor

# Or use screen
screen /dev/ttyUSB0 115200

# Or use minicom
minicom -D /dev/ttyUSB0 -b 115200
```

## Getting Help

If you can't resolve the issue:

1. **Check logs**: Use `idf.py monitor` for detailed output
2. **Search issues**: [GitHub Issues](https://github.com/Espilon-Net/espilon/issues)
3. **Ask community**: [GitHub Discussions](https://github.com/Espilon-Net/espilon/discussions)
4. **Report bug**: Create a new issue with:
   - ESP-IDF version
   - Board type
   - Error messages
   - Steps to reproduce

---

**See also**: [FAQ](faq.md) | [Quick Start](../getting-started/quickstart.md)
