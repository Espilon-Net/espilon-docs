# Espilon Documentation

Official documentation for Espilon - ESP32 Embedded Agent Framework for Security Research.

## About

This repository contains the complete documentation for Espilon, built with [MkDocs Material](https://squidfunk.github.io/mkdocs-material/).

**Live Documentation**: [https://docs.espilon.net](https://docs.espilon.net)

## Languages

- English (default)
- Francais

## Quick Start

### Prerequisites

- Python 3.8+
- pip

### Local Development

```bash
# Clone the repository
git clone https://github.com/Espilon-Net/espilon-docs.git
cd espilon-docs

# Install dependencies
pip install -r requirements.txt

# Run local server
mkdocs serve

# Open http://localhost:8000
```

## Docker Deployment

```bash
# Build
docker build -t espilon-docs .

# Run
docker run -d -p 8008:8008 --name espilon-docs espilon-docs

# Access at http://localhost:8008
```

## Repository Structure

```
espilon-docs/
├── docs/
│   ├── index.md              # Homepage
│   ├── fr/                   # French translations
│   ├── getting-started/      # Quick start, installation, architecture
│   ├── hardware/             # ESP32, LilyGO T-Call, ESP32-CAM guides
│   ├── configuration/        # Menuconfig, network settings
│   ├── tools/                # C2 Server, Flasher
│   ├── modules/              # Command reference
│   ├── use-cases/            # Examples & scenarios
│   ├── security/             # Best practices
│   ├── reference/            # Troubleshooting, FAQ
│   └── stylesheets/          # Custom CSS
├── assets/                   # Images and diagrams
├── mkdocs.yml               # MkDocs configuration
├── requirements.txt         # Python dependencies
├── Dockerfile               # Multi-stage Docker build
└── nginx.conf               # Nginx configuration
```

## Documentation Contents

### Getting Started
- Overview of Espilon framework
- System architecture
- Quick start guide
- Installation instructions

### Hardware
- Supported boards comparison
- LilyGO T-Call (GPRS) setup
- ESP32-CAM (Camera) setup
- Pinouts and wiring diagrams

### Tools
- C2 Server (C3PO) complete guide
- Flasher utility

### Modules
- Command reference (600+ lines)
- Module API documentation

### Reference
- Troubleshooting guide
- FAQ

## Build Static Site

```bash
mkdocs build
# Output in site/ directory
```

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Submit a pull request

## Technology Stack

- [MkDocs](https://www.mkdocs.org/) - Documentation generator
- [Material for MkDocs](https://squidfunk.github.io/mkdocs-material/) - Theme
- [mkdocs-static-i18n](https://github.com/ultrabug/mkdocs-static-i18n) - Multilingual
- [Mermaid](https://mermaid.js.org/) - Diagrams
- Docker + Nginx - Deployment

## License

MIT License - See [Espilon repository](https://github.com/Espilon-Net/espilon) for details.

## Related

- [Espilon Framework](https://github.com/Espilon-Net/espilon) - Main project
- [GitHub Issues](https://github.com/Espilon-Net/espilon-docs/issues) - Bug reports
- [GitHub Discussions](https://github.com/Espilon-Net/espilon/discussions) - Q&A

---

Built for the security research community
