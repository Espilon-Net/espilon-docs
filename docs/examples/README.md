# Espilon Examples and Use Cases

This directory contains practical examples and use case scenarios for Espilon. All examples assume authorized testing environments only.

---

## Table of Contents

- [Basic Usage](#basic-usage)
- [Network Reconnaissance](#network-reconnaissance)
- [Security Awareness Training](#security-awareness-training)
- [IoT Penetration Testing](#iot-penetration-testing)
- [Educational Scenarios](#educational-scenarios)

---

## Basic Usage

### Example 1: Device Health Monitoring

Monitor the health and status of deployed ESP32 devices.

**Scenario**: You have multiple ESP32 devices deployed and want to monitor their status.

**Commands**:
```bash
# List all connected devices
c3po> list

# Check uptime of each device
c3po> send all system_uptime

# Monitor memory usage
c3po> send all system_mem

# Create monitoring group
c3po> group add monitors ce4f626b a91dd021 f34592e0

# Periodic health check
c3po> send group monitors system_mem
```

**Expected Output**:
```
c3po> send group monitors system_mem

[<] ce4f626b: Free heap: 245678 bytes
[<] a91dd021: Free heap: 198234 bytes
[<] f34592e0: Free heap: 212456 bytes
```

**Use Case**:
- Fleet management
- Detecting memory leaks
- Identifying unstable devices

---

### Example 2: Network Discovery

Discover devices on a local network.

**Scenario**: You want to identify all devices on your test network (192.168.1.0/24).

**Commands**:
```bash
# Scan entire subnet
c3po> send ce4f626b arp_scan 192.168.1.0/24

# Verify connectivity to discovered devices
c3po> send ce4f626b ping 192.168.1.42
```

**Expected Output**:
```
[<] ce4f626b: {"ip": "192.168.1.1", "mac": "00:11:22:33:44:55"}
[<] ce4f626b: {"ip": "192.168.1.5", "mac": "aa:bb:cc:dd:ee:ff"}
[<] ce4f626b: {"ip": "192.168.1.42", "mac": "12:34:56:78:9a:bc"}
...
[<] ce4f626b: {"eof": true, "total": 15}
```

**Use Case**:
- Network inventory
- Detecting unauthorized devices
- Network mapping for security assessments

---

## Network Reconnaissance

### Example 3: Testing Wireless Security (Authorized)

Test wireless network security awareness in a controlled environment.

**Scenario**: Security awareness training - demonstrating rogue AP risks.

**Setup**:
1. Authorized training environment
2. Participants informed and consented
3. Isolated network segment

**Commands**:
```bash
# Start a fake access point mimicking company WiFi
c3po> send ce4f626b fakeap_start "Company-WiFi" "Password123" 6

# Start captive portal
c3po> send ce4f626b portal_start

# Monitor connections
# (Wait for devices to connect)

# Stop after demonstration
c3po> send ce4f626b fakeap_stop
```

**Expected Behavior**:
- Clients see "Company-WiFi" SSID
- Clients connect (if password matches their saved network)
- Captive portal captures connection attempts
- Educational discussion about rogue AP risks

**Learning Outcomes**:
- Awareness of evil twin attacks
- Importance of VPN
- Certificate validation
- HTTPS everywhere

**CRITICAL**:
- Only in controlled, authorized training environments
- All participants must be informed and consent
- Clear legal authorization required
- Debrief participants afterward

---

### Example 4: WiFi Packet Analysis

Analyze WiFi traffic patterns on your own network.

**Scenario**: Audit your own wireless network to understand traffic patterns.

**Commands**:
```bash
# Start packet sniffer on channel 6 for 60 seconds
c3po> send ce4f626b sniffer_start 6 60

# Analyze beacon frames to identify APs
# Analyze probe requests to see what networks clients search for
```

**Expected Output**:
```
[<] Beacon: SSID="MyNetwork" BSSID=aa:bb:cc:dd:ee:ff RSSI=-45
[<] Probe Req: Device=11:22:33:44:55:66 for "Home WiFi"
[<] Beacon: SSID="Neighbor-WiFi" BSSID=ff:ee:dd:cc:bb:aa RSSI=-67
[<] Data: aa:bb:cc:dd:ee:ff → 11:22:33:44:55:66 (encrypted)
```

**Analysis**:
- Count of visible APs
- Signal strength distribution
- Hidden SSIDs in probe requests
- Network traffic patterns

**Use Case**:
- Site survey for WiFi deployment
- Interference analysis
- Channel optimization
- Security posture assessment

---

## Security Awareness Training

### Example 5: Captive Portal Phishing Demo

Demonstrate captive portal phishing risks (educational only).

**Scenario**: Training session about public WiFi risks.

**Setup**:
```bash
# Create fake "Free WiFi" network
c3po> send ce4f626b fakeap_start "Free WiFi"

# Start portal with custom page
c3po> send ce4f626b portal_start "<html><h1>Free WiFi Login</h1>
<form><input name='email' placeholder='Email'><input name='password' type='password' placeholder='Password'><button>Login</button></form></html>"
```

**Training Points**:
- Never enter credentials on unknown WiFi
- Check for HTTPS with valid certificate
- Use VPN on public networks
- Understand captive portal legitimacy indicators

**Ethical Considerations**:
- Clearly mark as training exercise
- Don't capture real credentials
- Debrief immediately after
- Provide actionable security advice

---

### Example 6: Network Eavesdropping Demo

Demonstrate risks of unencrypted communication (local, authorized).

**Scenario**: Show why HTTPS and encryption matter.

**Setup**:
```bash
# Start sniffer
c3po> send ce4f626b sniffer_start

# Have participant visit HTTP site (test environment)
# Show captured traffic metadata (not content)
```

**Demonstration**:
- Which sites are visited (DNS queries, HTTP headers)
- Timestamps of activity
- Device fingerprinting via User-Agent
- Lack of privacy on unencrypted connections

**Key Takeaway**: Always use HTTPS, VPN, and encrypted protocols

---

## IoT Penetration Testing

### Example 7: IoT Device Discovery

Discover IoT devices on a network during authorized pentest.

**Scenario**: Client engagement to assess IoT security posture.

**Methodology**:
```bash
# 1. Network discovery
c3po> send ce4f626b arp_scan 10.0.0.0/24

# 2. Analyze results for IoT devices (specific MAC OUIs)
# 3. Test connectivity
c3po> send ce4f626b ping 10.0.0.100

# 4. Document findings
```

**Reporting**:
- Number of IoT devices found
- Device types (cameras, sensors, smart TVs, etc.)
- Segmentation analysis (are they isolated?)
- Recommendations for network segmentation

---

### Example 8: Wireless Camera Security Assessment

Assess security of wireless cameras (authorized testing).

**Scenario**: Test security of client's wireless surveillance system.

**Commands**:
```bash
# Discover cameras via ARP scan
c3po> send ce4f626b arp_scan 192.168.10.0/24

# Test for default credentials (using proxy)
c3po> send ce4f626b proxy_start 8080 192.168.10.50 80

# From testing machine:
# curl -u admin:admin http://<esp32-ip>:8080/
# (tests common default credentials)

# Stop proxy
c3po> send ce4f626b proxy_stop
```

**Assessment Checklist**:
- [ ] Cameras use strong passwords
- [ ] Cameras on isolated VLAN
- [ ] Cameras use encrypted streams
- [ ] Firmware up-to-date
- [ ] Admin interface not exposed to internet

---

## Educational Scenarios

### Example 9: Understanding TCP/IP Stack

Educational demonstration of network protocols.

**Scenario**: University networking class - practical demonstration.

**Exercise**:
```bash
# 1. Demonstrate ARP (Layer 2)
c3po> send ce4f626b arp_scan 192.168.1.0/28
# Discuss: MAC addresses, ARP cache poisoning risks

# 2. Demonstrate ICMP (Layer 3)
c3po> send ce4f626b ping 8.8.8.8 10
# Discuss: IP routing, TTL, packet loss

# 3. Demonstrate TCP (Layer 4)
c3po> send ce4f626b proxy_start 9000 example.com 80
# Use browser to connect via proxy
# Discuss: 3-way handshake, ports, stateful connections
```

**Learning Objectives**:
- OSI model layers in practice
- Protocol headers and fields
- Network troubleshooting
- Security implications at each layer

---

### Example 10: Embedded Systems Programming

Use Espilon as a platform for learning ESP32 development.

**Scenario**: Embedded systems course - students extend Espilon.

**Project Ideas**:

**Beginner**: Add Simple Command
```c
// Student implements temperature sensor reading
static int cmd_temperature(int argc, char **argv, const char *req_id, void *ctx)
{
    float temp = read_temperature_sensor();  // Student implements
    char result[64];
    snprintf(result, sizeof(result), "Temperature: %.2f°C", temp);
    msg_info("sensor", result, req_id);
    return 0;
}
```

**Intermediate**: Add I2C Sensor Module
- Read from I2C sensor (BME280, etc.)
- Parse sensor data
- Send formatted results to C2

**Advanced**: Implement Mesh Networking
- Bot-to-bot communication over WiFi/BLE
- Distributed routing
- Message forwarding

**Learning Outcomes**:
- ESP-IDF framework
- FreeRTOS task management
- Network programming
- Protocol design
- Hardware interfacing

---

## Advanced Scenarios

### Example 11: Multi-Device Coordination

Coordinate multiple devices for coverage or load distribution.

**Scenario**: Deploy multiple ESP32s for wide-area monitoring.

**Setup**:
```bash
# Create geographic groups
c3po> group add building-a ce4f626b a91dd021
c3po> group add building-b f34592e0 6a4cc35a

# Coordinate scanning
c3po> send group building-a arp_scan 10.10.0.0/24
c3po> send group building-b arp_scan 10.20.0.0/24

# Aggregate results for complete picture
```

**Use Cases**:
- Campus-wide network assessment
- Large-scale RF surveys
- Distributed monitoring systems

---

### Example 12: Continuous Monitoring

Set up continuous monitoring with logging.

**Scenario**: Long-term network behavior analysis.

**Implementation**:
```python
# Python script for continuous monitoring
import time
from c2_client import C2Client

client = C2Client(host='localhost', port=2626)

while True:
    # Scan network every 5 minutes
    result = client.send_command('ce4f626b', 'arp_scan', ['192.168.1.0/24'])

    # Log results
    timestamp = time.time()
    with open('network_log.json', 'a') as f:
        f.write(f'{{"time": {timestamp}, "devices": {result}}}\n')

    time.sleep(300)  # 5 minutes
```

**Analysis**:
- Devices appearing/disappearing
- New devices joining network
- Traffic patterns over time
- Anomaly detection

---

## Best Practices for All Examples

### Legal and Ethical

**Always**:
- Obtain written authorization
- Work within defined scope
- Document all activities
- Protect captured data
- Debrief participants (if training)

**Never**:
- Test without permission
- Retain sensitive captured data
- Use in production networks without approval
- Disclose findings without authorization

### Technical

**Best Practices**:
- Test in isolated environment first
- Have rollback plan
- Monitor device resources (memory)
- Log all activities
- Use request IDs for tracking

**Avoid**:
- Running multiple heavy commands simultaneously
- Flooding network with traffic
- Leaving devices in compromised state
- Ignoring error messages

---

## Contributing Examples

Have a use case to share? Please contribute!

1. Ensure it's educational and ethical
2. Document clearly with expected outputs
3. Include learning objectives
4. Add appropriate warnings
5. Submit PR with your example

See [CONTRIBUTING.md](../../CONTRIBUTING.md) for guidelines.

---

## Additional Resources

- [MODULES.md](../MODULES.md) - Complete command reference
- [SECURITY.md](../SECURITY.md) - Security best practices
- [INSTALL.md](../INSTALL.md) - Setup instructions
- [HARDWARE.md](../HARDWARE.md) - Hardware configurations

---

**Last Updated**: 2025-12-26

**Remember**: All examples require explicit authorization. Unauthorized use is illegal and unethical.
