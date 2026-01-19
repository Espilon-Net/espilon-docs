# Frequently Asked Questions

Common questions about Espilon.

## General

??? question "What is Espilon?"
    Espilon is an ESP32-based embedded agent framework for security research. It allows ESP32 microcontrollers to act as networked agents controlled via a C2 (Command & Control) server.

??? question "Is Espilon legal to use?"
    Espilon is a security research tool. It is legal to use for:

    - Authorized penetration testing
    - Security research in controlled environments
    - CTF competitions
    - Educational purposes

    **Unauthorized use is illegal.** Always obtain written permission before deployment.

??? question "What can I do with Espilon?"
    Espilon agents can:

    - Scan networks (ARP, ICMP)
    - Create fake access points
    - Capture images (ESP32-CAM)
    - Proxy network traffic
    - Monitor wireless activity
    - And more with custom modules

??? question "Which ESP32 boards are supported?"
    Supported boards include:

    - ESP32 DevKit (any variant)
    - LilyGO T-Call (for GPRS)
    - ESP32-CAM (for camera features)
    - NodeMCU-32S
    - Most ESP32 boards with 4MB+ flash

## Hardware

??? question "Which board should I buy?"
    Depends on your use case:

    | Use Case | Recommended Board |
    |----------|-------------------|
    | General WiFi | ESP32 DevKit |
    | GPRS/Cellular | LilyGO T-Call |
    | Camera/Vision | ESP32-CAM |
    | Development | NodeMCU-32S |

??? question "Does ESP32 support 5GHz WiFi?"
    **No.** The ESP32 only supports 2.4GHz WiFi (802.11 b/g/n). This is a hardware limitation.

??? question "How long does battery last?"
    Typical battery life with 1500mAh Li-Po:

    | Mode | Runtime |
    |------|---------|
    | Idle (connected) | 10-14 hours |
    | Active commands | 6-10 hours |
    | Streaming | 3-5 hours |
    | Deep sleep | 100+ hours |

??? question "Can I use external antenna?"
    Yes, for boards with U.FL/IPEX connector:

    - LilyGO T-Call: Yes (GSM antenna included)
    - ESP32-CAM: Some variants
    - ESP32 DevKit: Rarely (most have PCB antenna)

## Software

??? question "Which ESP-IDF version is required?"
    Espilon requires **ESP-IDF v5.3.2** or compatible version. Using other versions may cause build errors.

??? question "Can I use Arduino instead of ESP-IDF?"
    Espilon is built with ESP-IDF, not Arduino. While ESP-IDF is more complex, it provides:

    - Better performance
    - Lower-level access
    - More features
    - Production-ready stability

??? question "How do I update the firmware?"
    ```bash
    cd espilon_bot
    git pull
    idf.py build
    idf.py -p /dev/ttyUSB0 flash
    ```

??? question "Can I add custom modules?"
    Yes! See the Module Development Guide for creating custom modules. Basic structure:

    1. Create module in `components/modules/`
    2. Register commands in command registry
    3. Enable in menuconfig
    4. Build and flash

## Connectivity

??? question "WiFi or GPRS - which should I use?"
    | Factor | WiFi | GPRS |
    |--------|------|------|
    | Range | 50-100m | Nationwide |
    | Speed | Fast | Slow (~50Kbps) |
    | Cost | Free | SIM + data plan |
    | Latency | Low | Medium |
    | Setup | Easy | Moderate |

    **Use WiFi** for local deployments. **Use GPRS** for remote/mobile.

??? question "Can I use both WiFi and GPRS?"
    Not simultaneously. You must choose one network backend at compile time. However, you can have multiple agents with different backends.

??? question "What encryption is used?"
    All C2 communication uses **ChaCha20** stream cipher with:

    - 256-bit key (32 bytes)
    - 96-bit nonce (12 bytes)
    - Per-message encryption

??? question "Can the C2 traffic be detected?"
    The traffic is encrypted but not hidden. Network monitoring can detect:

    - Connection to C2 IP/port
    - Traffic patterns
    - Data volume

    For stealth, use VPN or tunneling.

## C2 Server

??? question "Can C2 run on Windows?"
    Yes, via WSL2 (Windows Subsystem for Linux). Native Windows support is not tested.

??? question "How many agents can connect?"
    Default: 100 concurrent connections. Adjustable in config. Practical limit depends on:

    - Server resources
    - Network bandwidth
    - Command frequency

??? question "Can I control agents from mobile?"
    Not directly. C3PO is a CLI application. Options:

    - SSH to C2 server from mobile
    - Build a web interface (community contribution)
    - Use remote desktop

??? question "Is there a web interface?"
    Not built-in. C3PO is CLI-only. A web interface could be built using the Python API.

## Troubleshooting

??? question "Why won't my device flash?"
    Common causes:

    1. **Not in download mode**: Hold BOOT, press RESET
    2. **Wrong port**: Check with `ls /dev/ttyUSB*`
    3. **Permission denied**: Add user to dialout group
    4. **Bad cable**: Use data-capable USB cable

??? question "Why does my device keep rebooting?"
    Common causes:

    1. **Power issue**: Use better power supply
    2. **Brownout**: Add capacitor or reduce load
    3. **Code crash**: Check serial monitor for errors
    4. **Watchdog**: Increase timeout or fix blocking code

??? question "Why is my connection unstable?"
    Check:

    1. Power supply stability
    2. WiFi signal strength
    3. Network congestion
    4. C2 server resources
    5. Encryption key match

??? question "How do I factory reset?"
    ```bash
    # Erase everything
    idf.py -p /dev/ttyUSB0 erase_flash

    # Reflash
    idf.py -p /dev/ttyUSB0 flash
    ```

## Security

??? question "Is the communication secure?"
    Yes, all C2 traffic is encrypted with ChaCha20. However:

    - Keys must be kept secret
    - Compromised keys = compromised security
    - Traffic patterns may be analyzed

??? question "Can agents be hijacked?"
    With proper security:

    - Encryption prevents interception
    - Unique keys per deployment
    - No known vulnerabilities in protocol

    Without proper security:

    - Default keys are public
    - Unencrypted = fully exposed

??? question "What about physical security?"
    ESP32 has limited physical security:

    - Flash can be read without encryption
    - JTAG debug possible on some boards
    - Physical access = potential compromise

    For sensitive deployments, enable flash encryption.

## Contributing

??? question "How can I contribute?"
    Contributions welcome:

    1. Fork the repository
    2. Create feature branch
    3. Make changes
    4. Submit pull request

    Areas needing help:

    - Documentation improvements
    - New modules
    - Bug fixes
    - Testing

??? question "Where do I report bugs?"
    [GitHub Issues](https://github.com/Espilon-Net/espilon/issues)

    Include:

    - ESP-IDF version
    - Board type
    - Error messages
    - Steps to reproduce

??? question "Is there a community?"
    - **GitHub Discussions**: Q&A and ideas
    - **Issues**: Bug reports and features
    - **Documentation**: This site

---

**See also**: [Troubleshooting](troubleshooting.md) | [Getting Started](../getting-started/quickstart.md)
