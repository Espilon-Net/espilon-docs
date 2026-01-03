# Espilon Documentation

Welcome to the Espilon documentation! This directory contains comprehensive guides, API references, and technical specifications for the Espilon ESP32 agent framework.

---

## Documentation Index

### Getting Started

| Document | Description |
|----------|-------------|
| [Installation Guide](INSTALL.md) | Complete setup instructions for ESP-IDF, firmware building, flashing, and C2 server |
| [Hardware Guide](HARDWARE.md) | Supported boards, pinouts, wiring diagrams, and hardware requirements |
| [Quick Start](../README.en.md) | Overview and quick start guide (main README) |

### Core Documentation

| Document | Description |
|----------|-------------|
| [Architecture](ARCHITECTURE.md) | System architecture, component design, data flow, and concurrency model |
| [Protocol Specification](PROTOCOL.md) | Complete C2 communication protocol documentation (protobuf, crypto, framing) |
| [Module API](MODULES.md) | Complete command reference for all modules (system, network, fakeap, recon) |
| [Security](SECURITY.md) | Security best practices, threat model, cryptography details, and responsible use |

### Development

| Document | Description |
|----------|-------------|
| [Contributing Guidelines](../CONTRIBUTING.md) | How to contribute code, documentation, and bug reports |
| [Examples](examples/README.md) | Practical examples and use case scenarios |

### Legal

| Document | Description |
|----------|-------------|
| [License](../LICENSE) | MIT License with additional terms for security research tools |

---

## Quick Navigation

### I want to...

**...get started quickly**
→ Read [Installation Guide](INSTALL.md) and follow the Quick Start section

**...understand how Espilon works**
→ Read [Architecture](ARCHITECTURE.md) and [Protocol Specification](PROTOCOL.md)

**...see what commands are available**
→ Check [Module API](MODULES.md) for complete command reference

**...set up hardware (GPRS, camera, etc.)**
→ Consult [Hardware Guide](HARDWARE.md) for wiring diagrams and pinouts

**...use Espilon securely**
→ Review [Security](SECURITY.md) for best practices and security considerations

**...contribute to the project**
→ Read [Contributing Guidelines](../CONTRIBUTING.md)

**...see practical examples**
→ Explore [Examples](examples/README.md) for use cases and scenarios

---

## Documentation by Role

### For Users (Deploying Espilon)

1. [Installation Guide](INSTALL.md) - Set up environment
2. [Hardware Guide](HARDWARE.md) - Connect your hardware
3. [Module API](MODULES.md) - Learn available commands
4. [Security](SECURITY.md) - Deploy securely
5. [Examples](examples/README.md) - See practical use cases

### For Developers (Extending Espilon)

1. [Architecture](ARCHITECTURE.md) - Understand the system
2. [Protocol Specification](PROTOCOL.md) - Learn communication protocol
3. [Module API](MODULES.md) - See how to create modules
4. [Contributing Guidelines](../CONTRIBUTING.md) - Contribution process
5. [Examples](examples/README.md) - Study existing implementations

### For Security Researchers

1. [Security](SECURITY.md) - Security analysis and recommendations
2. [Protocol Specification](PROTOCOL.md) - Protocol details for analysis
3. [Architecture](ARCHITECTURE.md) - Attack surface understanding
4. [Module API](MODULES.md) - Understand capabilities

### For Educators

1. [Examples](examples/README.md) - Teaching scenarios
2. [Architecture](ARCHITECTURE.md) - System design concepts
3. [Module API](MODULES.md) - Practical exercises
4. [Security](SECURITY.md) - Security awareness training

---

## Document Status

| Document | Status | Last Updated |
|----------|--------|--------------|
| INSTALL.md | Complete | 2025-12-26 |
| HARDWARE.md | Complete | 2025-12-26 |
| ARCHITECTURE.md | Complete | 2025-12-26 |
| PROTOCOL.md | Complete | 2025-12-26 |
| MODULES.md | Complete | 2025-12-26 |
| SECURITY.md | Complete | 2025-12-26 |
| examples/README.md | Complete | 2025-12-26 |

---

## Document Descriptions

### INSTALL.md
Complete installation guide covering:
- ESP-IDF setup for multiple platforms (Linux, macOS, Windows)
- Firmware configuration via menuconfig
- Building and flashing procedures
- C2 server setup
- Multi-device flashing
- Troubleshooting common issues

### HARDWARE.md
Hardware reference including:
- Supported ESP32 variants and boards
- Pin mappings and GPIO usage
- GPRS module (SIM800) wiring diagrams
- ESP32-CAM setup and programming
- Power requirements and considerations
- Antenna selection and placement

### ARCHITECTURE.md
Technical architecture documentation:
- System overview and component breakdown
- Firmware layered architecture
- C2 server design (Python asyncio)
- Concurrency model (FreeRTOS tasks)
- Memory management strategies
- Network stack details
- Design patterns used

### PROTOCOL.md
Communication protocol specification:
- Protocol stack (application to wire)
- Message format and encoding
- Cryptography (ChaCha20, Base64)
- Protocol Buffers schema
- Message flow diagrams
- Connection management
- Error handling

### MODULES.md
Complete API reference:
- All available commands with syntax
- Parameter descriptions and constraints
- Return value formats
- Usage examples for each command
- Module creation guide
- Best practices

### SECURITY.md
Security documentation:
- Legal disclaimer and authorized use policy
- Current security architecture
- Known vulnerabilities and limitations
- Security best practices for deployment
- Recommended enhancements
- Incident response procedures
- Vulnerability reporting process

### examples/README.md
Practical examples:
- Basic usage scenarios
- Network reconnaissance (authorized)
- Security awareness training setups
- IoT penetration testing workflows
- Educational use cases
- Multi-device coordination
- Best practices for all scenarios

---

## Multilingual Documentation

| Language | Main README | Documentation Status |
|----------|-------------|----------------------|
| **English** | [README.en.md](../README.en.md) | Complete |
| **Français** | [README.md](../README.md) | To be updated for open source |

---

## Contributing to Documentation

Documentation improvements are always welcome!

**How to contribute**:
1. Fix typos or unclear explanations
2. Add missing information
3. Improve examples
4. Translate to other languages
5. Add diagrams or screenshots

**Process**:
1. Fork the repository
2. Make your changes in `docs/` directory
3. Ensure markdown formatting is correct
4. Test all code examples
5. Submit pull request

See [Contributing Guidelines](../CONTRIBUTING.md) for detailed instructions.

---

## Getting Help

**Can't find what you're looking for?**

1. **Search documentation**: Use Ctrl+F in your browser or `grep` in the docs folder
2. **Check examples**: [examples/README.md](examples/README.md) has practical scenarios
3. **GitHub Discussions**: Ask questions in [Discussions](https://github.com/yourusername/epsilon/discussions)
4. **GitHub Issues**: Report documentation bugs or request clarifications

**Found an error?**
Please open an issue or submit a pull request to fix it!

---

## Documentation License

The documentation in this directory is licensed under [CC BY 4.0](https://creativecommons.org/licenses/by/4.0/).

You are free to:
- **Share** — copy and redistribute the material
- **Adapt** — remix, transform, and build upon the material

Under the following terms:
- **Attribution** — You must give appropriate credit to the Espilon project

The code examples in the documentation follow the same license as the project ([MIT License](../LICENSE)).

---

## Documentation Roadmap

### Planned Documentation

- [ ] **TROUBLESHOOTING.md** - Common issues and solutions
- [ ] **FAQ.md** - Frequently asked questions
- [ ] **API_REFERENCE.md** - Complete C API reference for firmware
- [ ] **TESTING.md** - Testing guide and test infrastructure
- [ ] **DEPLOYMENT.md** - Production deployment guide
- [ ] **Video Tutorials** - Step-by-step video guides
- [ ] **Interactive Demos** - Browser-based demos (WebSocket C2)

### Improvements Needed

- [ ] Add more diagrams and flowcharts
- [ ] Video tutorials for installation and setup
- [ ] Expanded examples section
- [ ] Performance tuning guide
- [ ] Advanced configuration guide
- [ ] Integration guides (Docker, Ansible, etc.)

**Want to help?** Pick an item from the roadmap and contribute!

---

## External Resources

### ESP-IDF Documentation
- [ESP-IDF Programming Guide](https://docs.espressif.com/projects/esp-idf/)
- [ESP32 Technical Reference](https://www.espressif.com/sites/default/files/documentation/esp32_technical_reference_manual_en.pdf)
- [FreeRTOS Documentation](https://www.freertos.org/Documentation/RTOS_book.html)

### Protocols and Standards
- [Protocol Buffers](https://protobuf.dev/)
- [ChaCha20 (RFC 8439)](https://tools.ietf.org/html/rfc8439)
- [Base64 (RFC 4648)](https://tools.ietf.org/html/rfc4648)

### Security Resources
- [OWASP IoT Top 10](https://owasp.org/www-project-internet-of-things/)
- [NIST Cybersecurity Framework](https://www.nist.gov/cyberframework)

---

**Last Updated**: 2025-12-26

**Maintained by**: Espilon Project Contributors

**Questions or suggestions?** Open an issue or discussion on GitHub!
