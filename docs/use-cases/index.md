# Use Cases & Examples

Real-world applications and deployment scenarios for Espilon.

!!! warning "Authorized Use Only"
    All use cases described here are for **authorized security testing**, educational purposes, or controlled research environments only.

---

## 1. Network Penetration Testing

### Scenario: Internal Network Assessment

<figure markdown>
  ![Penetration Testing Setup](../assets/images/usecase-pentest.png){ width="800" }
  <figcaption>Typical penetration testing deployment</figcaption>
</figure>

**Objective**: Assess internal network security during authorized pentest engagement.

**Setup**:
- Deploy ESP32 agent inside target network
- C2 server on external VPS or pentester laptop
- Agent connects via WiFi or GPRS

**Commands Used**:
```bash
# Network discovery
arp_scan

# Service enumeration
port_scan 192.168.1.0/24

# WiFi reconnaissance
wifi_scan
wifi_monitor start
```

**Benefits**:
- ✅ Small form factor - easy to deploy
- ✅ Low cost - disposable if needed
- ✅ Persistent access via C2
- ✅ Remote control from anywhere

---

## 2. IoT Security Research

### Scenario: Smart Home Device Testing

<figure markdown>
  ![IoT Research Lab](../assets/images/usecase-iot-research.png){ width="800" }
  <figcaption>Research lab monitoring IoT devices</figcaption>
</figure>

**Objective**: Research IoT device communication patterns and security.

**Setup**:
- Multiple ESP32 agents in test environment
- Isolated network for IoT devices
- C2 server for data collection

**Commands Used**:
```bash
# Discover IoT devices
arp_scan

# Monitor WiFi traffic
wifi_monitor start

# Scan BLE devices
ble_scan 30

# Packet capture
sniffer start
```

**Research Applications**:
- Protocol analysis
- Security vulnerability discovery
- Traffic pattern analysis
- Device fingerprinting

---

## 3. Wireless Security Assessment

### Scenario: Corporate WiFi Audit

![WiFi Security Assessment](../assets/images/usecase-wifi-audit.png)

**Objective**: Assess wireless security controls during authorized audit.

**Setup**:
- ESP32 agents at various locations
- Coverage testing across facility
- Rogue AP detection

**Commands Used**:
```bash
# Site survey
wifi_scan

# Rogue AP testing
fakeap start "CorpWiFi_Guest"

# Client behavior analysis
wifi_monitor start
```

**Findings Collected**:
- Signal strength mapping
- Encryption weaknesses
- Rogue AP detection
- Client connection behavior

---

## 4. Educational Lab Exercises

### Scenario: Cybersecurity Training Course

<figure markdown>
  ![Training Lab Setup](../assets/images/usecase-education.png){ width="700" }
  <figcaption>Student lab environment</figcaption>
</figure>

**Objective**: Teach network security concepts hands-on.

**Lab Exercises**:

#### Exercise 1: Network Discovery
```
Students learn:
- ARP scanning techniques
- Network mapping
- Device enumeration
```

#### Exercise 2: Wireless Security
```
Students learn:
- WiFi scanning
- Encryption types
- Signal analysis
```

#### Exercise 3: Protocol Analysis
```
Students learn:
- Packet capture
- Protocol dissection
- Traffic analysis
```

**Equipment Per Student**:
- 1x ESP32 DevKit
- Access to shared C2 server
- Isolated test network

---

## 5. Red Team Operations

### Scenario: Physical Security Assessment

![Red Team Deployment](../assets/images/usecase-redteam.png)

**Objective**: Test physical security controls and network monitoring.

**Deployment Methods**:

#### Drop Box Deployment
```
Equipment:
- ESP32 with battery
- Hidden in common object
- GPRS or WiFi connection
- Persistent C2 beacon
```

#### Mobile Deployment
```
Equipment:
- LilyGO T-Call with GPRS
- Battery powered
- Carried by operator
- Real-time reconnaissance
```

**Operational Commands**:
```bash
# Silent network mapping
arp_scan

# Identify targets
port_scan 192.168.1.0/24

# Monitor for response
wifi_monitor start

# Establish persistence
tcp_proxy 8080 10.0.0.50 80
```

---

## 6. CTF Competitions

### Scenario: Capture The Flag Event

<figure markdown>
  ![CTF Competition](../assets/images/usecase-ctf.png){ width="700" }
  <figcaption>CTF network challenge</figcaption>
</figure>

**Use in CTF**:

#### Challenge Creation
```
Scenario: "The Rogue Device"
- Hidden ESP32 agent on network
- Players must discover it
- Capture flags from C2 traffic
- Points for detection and mitigation
```

#### Network Attacks
```
Players deploy Espilon to:
- Scan for vulnerable services
- Enumerate targets
- Establish footholds
- Lateral movement practice
```

**Learning Outcomes**:
- Network reconnaissance
- Traffic analysis
- Detection techniques
- Incident response

---

## 7. WiFi Mapping & Coverage Testing

### Scenario: Site Survey

![Site Survey](../assets/images/usecase-site-survey.png)

**Objective**: Map WiFi coverage across facility.

**Method**:

1. **Deploy Multiple Agents**
   ```
   - Agents at strategic locations
   - Battery powered for portability
   - Continuous WiFi scanning
   ```

2. **Data Collection**
   ```bash
   # Each agent runs
   wifi_scan

   # Reports back to C2
   {
     "location": "Floor 2 East",
     "networks": [...],
     "signal_strength": -45
   }
   ```

3. **Heatmap Generation**
   ```
   - Aggregate data from all agents
   - Generate coverage heatmap
   - Identify dead zones
   - Optimize AP placement
   ```

---

## 8. IoT Honeypot

### Scenario: Threat Intelligence Collection

<figure markdown>
  ![IoT Honeypot](../assets/images/usecase-honeypot.png){ width="700" }
  <figcaption>Honeypot monitoring setup</figcaption>
</figure>

**Objective**: Monitor for attacks on IoT devices.

**Setup**:
```
Components:
- ESP32 as fake IoT device
- Open services (HTTP, Telnet)
- Logging all connection attempts
- C2 for alert aggregation
```

**Detection**:
```bash
# Monitor for scanning
tcp_proxy 23 localhost 2323  # Fake telnet
tcp_proxy 80 localhost 8080  # Fake web interface

# Log all attempts
# Alert on suspicious activity
```

---

## 9. Emergency Communication

### Scenario: Disaster Response

![Emergency Mesh Network](../assets/images/usecase-emergency.png)

**Objective**: Establish communication when infrastructure is down.

**Deployment**:
```
Setup:
- Multiple ESP32 agents
- GPRS fallback connectivity
- Mesh network capability
- Solar battery charging
```

**Use Cases**:
- Emergency coordination
- Status reporting
- Resource tracking
- Communication relay

---

## 10. Supply Chain Security Testing

### Scenario: Product Security Audit

**Objective**: Test product security before deployment.

**Testing Process**:

1. **Network Behavior Analysis**
   ```bash
   wifi_scan          # What networks does it search for?
   wifi_monitor start # What data does it transmit?
   sniffer start      # What protocols does it use?
   ```

2. **BLE Security**
   ```bash
   ble_scan          # What BLE services are exposed?
   ```

3. **Port Analysis**
   ```bash
   port_scan <device_ip>  # What ports are open?
   ```

**Findings**:
- Unexpected network connections
- Insecure protocols
- Hardcoded credentials
- Backdoor detection

---

## Deployment Configurations

### Configuration 1: Stealth Mode

```yaml
Device: ESP32 DevKit
Network: WiFi
Power: Battery (18650)
Modules: Network only
Beacon: Every 5 minutes
Use: Long-term monitoring
```

### Configuration 2: Active Scanning

```yaml
Device: LilyGO T-Call
Network: GPRS
Power: USB power bank
Modules: All enabled
Beacon: Continuous
Use: Active reconnaissance
```

### Configuration 3: Mobile Unit

```yaml
Device: ESP32-CAM
Network: WiFi
Power: LiPo battery
Modules: Recon + Camera
Beacon: On-demand
Use: Physical assessment
```

---

## Case Study Examples

### Case Study 1: Corporate Network Assessment

```
Client: Fortune 500 Company
Scope: Internal network security audit
Duration: 2 weeks
Agents: 5x ESP32 DevKit

Results:
- 247 hosts discovered
- 15 unauthorized devices found
- 3 rogue access points detected
- 8 critical vulnerabilities identified

Outcome: Network segmentation recommendations
```

### Case Study 2: University Research

```
Institution: Tech University
Project: IoT Security Research
Duration: 6 months
Agents: 12x ESP32 + 4x LilyGO T-Call

Research:
- 500+ IoT devices analyzed
- 12 CVEs discovered
- 3 research papers published
- 50+ students trained

Outcome: Enhanced IoT security curriculum
```

---

## Best Practices by Use Case

### Penetration Testing
- ✅ Get written authorization
- ✅ Define scope clearly
- ✅ Use secure C2 channels
- ✅ Document all findings
- ✅ Decommission after testing

### Research
- ✅ Use isolated networks
- ✅ Obtain IRB approval if needed
- ✅ Protect research data
- ✅ Share findings responsibly

### Education
- ✅ Controlled environments only
- ✅ Clear learning objectives
- ✅ Supervised activities
- ✅ Ethics training required

---

## Hardware Recommendations by Use Case

| Use Case | Recommended Board | Network | Modules |
|----------|------------------|---------|---------|
| Pentest (Indoor) | ESP32 DevKit | WiFi | Network + Recon |
| Pentest (Outdoor) | LilyGO T-Call | GPRS | Network + Recon |
| Research Lab | ESP32 DevKit | WiFi | All modules |
| Red Team | LilyGO T-Call | GPRS | Network only |
| CTF | ESP32 DevKit | WiFi | All modules |
| Education | ESP32 DevKit | WiFi | Network + System |

---

## Safety and Legal Considerations

### Always Required
- 📋 Written authorization
- 📋 Defined scope document
- 📋 Legal compliance check
- 📋 Data protection measures
- 📋 Incident response plan

### Never Do
- ❌ Unauthorized deployment
- ❌ Public WiFi attacks
- ❌ Critical infrastructure
- ❌ Personal data collection
- ❌ Malicious activities

---

## Next Steps

Ready to deploy? Check out:

- [Quick Start Guide](../getting-started/quickstart.md) - Get started in 30 minutes
- [Hardware Guide](../hardware/index.md) - Choose the right board
- [Command Reference](../modules/commands.md) - Learn all commands
- [Security Best Practices](../security/best-practices.md) - Deploy safely

---

**Questions?** Check the [FAQ](../reference/faq.md) or [GitHub Discussions](https://github.com/Espilon-Net/espilon-docs/discussions)
