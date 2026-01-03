# Security Documentation

## Legal Disclaimer

**Espilon is a security research and educational tool designed for authorized penetration testing, security research, and educational purposes only.**

### Authorized Use Cases

This tool is intended for:

- **Authorized Penetration Testing**: Only on systems you own or have explicit written permission to test
- **Controlled Security Research**: In isolated lab environments
- **Educational Purposes**: Learning about IoT security, embedded systems, and network protocols
- **CTF Competitions**: Capture The Flag challenges and security competitions
- **Defensive Security**: Understanding attack vectors to improve defenses
- **Personal Networks**: Testing your own equipment and infrastructure

### Prohibited Use Cases

**NEVER use this tool for:**

- Unauthorized access to networks, systems, or devices
- Malicious attacks or criminal activities
- Privacy violations or surveillance without consent
- Disruption of services (DoS/DDoS)
- Corporate espionage or competitive intelligence gathering
- Any activity that violates local, state, national, or international laws

### Legal Responsibility

**By using this software, you agree that:**

1. You are solely responsible for your actions
2. You will only use it in authorized, legal contexts
3. You have obtained proper permissions before testing any systems
4. You will comply with all applicable laws and regulations
5. The authors bear no responsibility for misuse or damages

**Unauthorized access to computer systems is illegal in most jurisdictions and may result in:**
- Criminal prosecution
- Civil liability
- Significant fines
- Imprisonment

---

## Security Architecture

### Current Implementation

Espilon uses the following security mechanisms:

#### 1. Encryption

**Algorithm**: ChaCha20 (stream cipher)
- **Key Size**: 256 bits (32 bytes)
- **Nonce**: 96 bits (12 bytes)
- **Implementation**: mbedTLS library

**Protocol Flow**:
```
Plaintext → Protocol Buffers → ChaCha20 Encrypt → Base64 Encode → TCP
```

**Configuration**:
```c
// File: espilon_bot/main/Kconfig
CONFIG_CRYPTO_KEY="your-32-byte-key-here-exactly"
CONFIG_CRYPTO_NONCE="12byte-nonce"
```

#### 2. Authentication

**Method**: Implicit authentication via encryption
- Devices that can successfully decrypt messages are considered authenticated
- No explicit handshake or certificate exchange
- Symmetric key must be pre-shared between C2 and all agents

**Device Identification**:
- Each device has a unique ID (CRC32-based)
- ID is included in all messages
- C2 tracks devices by ID and IP address

#### 3. Data Serialization

**Protocol Buffers (nanoPB)**:
- Type-safe message encoding
- Small binary footprint (optimized for embedded)
- Schema validation

---

## 🚨 Security Limitations

### Critical Issues

#### 1. **Static Nonce** HIGH SEVERITY

**Problem**: The same nonce is used for all messages

**Impact**:
- Violates ChaCha20 security model
- Reusing key+nonce pair leaks information
- Stream cipher becomes predictable over time

**Current Implementation**:
```c
// crypto.c - INSECURE
unsigned char nonce[12] = CONFIG_CRYPTO_NONCE;  // Same for every message
```

**Recommendation**:
```c
// Use counter-based nonce
unsigned char nonce[12];
uint64_t counter = get_message_counter();
memcpy(nonce, &counter, sizeof(counter));
```

#### 2. **No Authenticated Encryption** HIGH SEVERITY

**Problem**: ChaCha20 provides confidentiality but not integrity

**Impact**:
- No protection against message tampering
- No authentication of sender
- Vulnerable to bit-flipping attacks
- Cannot detect MITM modifications

**Recommendation**:
```c
// Use ChaCha20-Poly1305 AEAD instead
mbedtls_chachapoly_auth_decrypt(...)
```

#### 3. **Hardcoded Default Keys** CRITICAL SEVERITY

**Problem**: Default test credentials in source code

**Current Defaults**:
```c
CONFIG_CRYPTO_KEY="testde32chars0000000000000000000"
CONFIG_CRYPTO_NONCE="noncenonceno"
```

**Impact**:
- Anyone can decrypt traffic if defaults are used
- Complete compromise of all devices using defaults

**Mitigation**:
```bash
# Generate secure random keys
openssl rand -hex 32  # 256-bit key
openssl rand -hex 12  # 96-bit nonce

# Configure in menuconfig before building
idf.py menuconfig
# → Espilon Configuration → Cryptography Settings
```

#### 4. **No Forward Secrecy**

**Problem**: Single static key for device lifetime

**Impact**:
- If key is compromised, all past communications are compromised
- No session-based key derivation

**Recommendation**:
- Implement Diffie-Hellman key exchange
- Use ephemeral session keys
- Implement key rotation protocol

#### 5. **No Device Enrollment/Revocation**

**Problem**: No mechanism to add/remove devices securely

**Impact**:
- Lost devices can't be revoked
- New devices require firmware rebuild with new keys
- No certificate authority or PKI

**Recommendation**:
- Implement device registration protocol
- Use asymmetric crypto for enrollment
- Maintain device certificate database

---

## 🛡️ Security Best Practices

### For Deployment

#### 1. Change Default Credentials (MANDATORY)

```bash
# Before building, generate unique keys
cd espilon_bot
idf.py menuconfig

# Navigate to: Espilon Configuration → Cryptography
# Set unique values for:
# - Crypto Key (32 bytes)
# - Nonce (12 bytes) - though this should be dynamic
```

#### 2. Network Isolation

- Deploy C2 server on isolated network segment
- Use firewall rules to restrict C2 port access
- Consider VPN or SSH tunnel for C2 communication
- Monitor network traffic for anomalies

#### 3. Physical Security

- Secure ESP32 devices physically
- Disable UART/JTAG debugging in production
- Use flash encryption (ESP-IDF feature)
- Enable secure boot if supported

#### 4. C2 Server Hardening

```bash
# Run C2 as non-root user
useradd -r -s /bin/false epsilon-c2

# Use systemd service with restrictions
[Service]
User=epsilon-c2
NoNewPrivileges=true
PrivateTmp=true
ProtectSystem=strict
ProtectHome=true
```

#### 5. Logging and Monitoring

- Enable C2 connection logging
- Monitor for unusual command patterns
- Track device connection history
- Alert on new unknown devices

---

## 🔐 Recommended Security Enhancements

### Short-term Fixes

#### 1. Implement ChaCha20-Poly1305 AEAD

**Priority**: HIGH

```c
// Replace in crypto.c
#include "mbedtls/chachapoly.h"

int encrypt_message(const uint8_t *plaintext, size_t len,
                    uint8_t *ciphertext, uint8_t *tag) {
    mbedtls_chachapoly_context ctx;
    uint8_t nonce[12];

    // Generate unique nonce (counter-based)
    generate_unique_nonce(nonce);

    mbedtls_chachapoly_init(&ctx);
    mbedtls_chachapoly_setkey(&ctx, key);
    mbedtls_chachapoly_encrypt_and_tag(&ctx, len, nonce, NULL, 0,
                                        plaintext, ciphertext, tag);
    mbedtls_chachapoly_free(&ctx);
    return 0;
}
```

#### 2. Dynamic Nonce Generation

```c
// Implement message counter
static uint64_t message_counter = 0;

void generate_unique_nonce(uint8_t *nonce) {
    // Counter + random component
    uint64_t counter = __sync_fetch_and_add(&message_counter, 1);
    uint32_t random = esp_random();

    memcpy(nonce, &counter, 8);
    memcpy(nonce + 8, &random, 4);
}
```

#### 3. Remove Hardcoded Defaults

```c
// Kconfig - Require user to set keys
config CRYPTO_KEY
    string "ChaCha20 Encryption Key (32 bytes)"
    help
        SECURITY WARNING: You MUST change this value!
        Generate with: openssl rand -hex 32
    # No default value - force user to set

config CRYPTO_NONCE_BASE
    string "Nonce Base (12 bytes)"
    help
        Base value for nonce generation.
        Generate with: openssl rand -hex 12
    # No default value
```

### Long-term Enhancements

#### 1. TLS/DTLS Transport Layer

```c
// Use mbedTLS for transport security
#include "mbedtls/ssl.h"

// Wrap TCP connection in TLS
mbedtls_ssl_context ssl;
mbedtls_ssl_config conf;
mbedtls_ssl_init(&ssl);
mbedtls_ssl_setup(&ssl, &conf);
```

Benefits:
- Authenticated encryption (AES-GCM, ChaCha20-Poly1305)
- Forward secrecy (ECDHE key exchange)
- Certificate-based authentication
- Industry-standard protocol

#### 2. Device PKI (Public Key Infrastructure)

```
C2 Server (Certificate Authority)
    ├── Device 1 Certificate (signed)
    ├── Device 2 Certificate (signed)
    └── Device N Certificate (signed)
```

Implementation:
- Generate device key pairs
- C2 signs device certificates
- Mutual TLS authentication
- Certificate revocation list (CRL)

#### 3. Secure OTA Updates

```c
// Signed firmware updates
typedef struct {
    uint8_t firmware[MAX_SIZE];
    uint8_t signature[64];      // Ed25519 signature
    uint8_t public_key[32];     // Verify against known keys
} ota_package_t;
```

---

## 🧪 Security Testing

### Recommended Tests

#### 1. Network Security Audit

```bash
# Monitor C2 traffic
tcpdump -i any port 2626 -w epsilon-traffic.pcap

# Analyze encryption
# - Verify ChaCha20 is active
# - Check for plaintext leaks
# - Validate Base64 encoding
```

#### 2. Fuzzing

```python
# Fuzz C2 server input
from boofuzz import *

session = Session(target=Target(connection=TCPSocketConnection("127.0.0.1", 2626)))

s_initialize("c2_message")
s_string("AAA", name="base64_data", fuzzable=True)
s_static("\n")

session.connect(s_get("c2_message"))
session.fuzz()
```

#### 3. Key Exposure Testing

```bash
# Check for keys in:
- Binary strings output
- Flash memory dumps
- UART debug output
- Core dumps
```

#### 4. Replay Attack Testing

```bash
# Capture and replay messages
tcpdump -i any port 2626 -w capture.pcap
# Replay captured packets
tcpreplay -i eth0 capture.pcap

# Expected: Should be rejected (needs unique nonce per message)
```

---

## Security Checklist

### Pre-Deployment

- [ ] Changed default crypto keys (CRITICAL)
- [ ] Generated unique device IDs
- [ ] Disabled debug UART output
- [ ] Enabled flash encryption (ESP-IDF)
- [ ] Enabled secure boot (if available)
- [ ] Configured C2 server firewall rules
- [ ] Set up C2 logging and monitoring
- [ ] Tested in isolated network first
- [ ] Documented authorized use scope
- [ ] Obtained necessary permissions

### Post-Deployment

- [ ] Monitor C2 connection logs
- [ ] Regular key rotation schedule
- [ ] Track device inventory
- [ ] Audit command execution history
- [ ] Review security alerts
- [ ] Update firmware regularly
- [ ] Test incident response plan

---

## 🚨 Incident Response

### If Device is Compromised

1. **Immediate Actions**:
   - Disconnect device from network
   - Revoke device from C2 (if possible)
   - Change all crypto keys
   - Rebuild firmware with new credentials

2. **Investigation**:
   - Review C2 logs for unauthorized commands
   - Analyze network traffic captures
   - Check device flash dump for modifications
   - Identify compromise vector

3. **Recovery**:
   - Flash device with clean firmware
   - Verify integrity before redeployment
   - Update security configurations
   - Document lessons learned

### If C2 Server is Compromised

1. **Immediate Actions**:
   - Shut down C2 server
   - Disconnect all devices
   - Preserve logs and forensic data

2. **Response**:
   - Rebuild C2 server from scratch
   - Generate new crypto keys for all devices
   - Reflash all devices with new configuration
   - Audit network for lateral movement

---

## Reporting Security Vulnerabilities

If you discover a security vulnerability in Espilon:

1. **DO NOT** open a public GitHub issue
2. Email: [security contact - to be added]
3. Include:
   - Description of vulnerability
   - Steps to reproduce
   - Potential impact
   - Suggested fix (if any)

We will acknowledge within 48 hours and provide updates on fixes.

---

## References

### Cryptography

- [ChaCha20 and Poly1305 (RFC 8439)](https://tools.ietf.org/html/rfc8439)
- [mbedTLS Documentation](https://mbed-tls.readthedocs.io/)
- [ESP-IDF Security Features](https://docs.espressif.com/projects/esp-idf/en/latest/esp32/security/index.html)

### Security Best Practices

- [OWASP IoT Top 10](https://owasp.org/www-project-internet-of-things/)
- [NIST Cybersecurity Framework](https://www.nist.gov/cyberframework)
- [CIS Benchmarks](https://www.cisecurity.org/cis-benchmarks/)

### Legal

- [Computer Fraud and Abuse Act (CFAA)](https://www.justice.gov/criminal-ccips/ccips-documents-and-reports)
- [GDPR (EU Data Protection)](https://gdpr.eu/)
- [Local cybersecurity laws in your jurisdiction]

---

**Last Updated**: 2025-12-26
**Version**: 1.0

**Maintainers**: Please keep this document updated as security features evolve.
