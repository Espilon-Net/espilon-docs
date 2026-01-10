# Espilon Documentation

Official documentation for Espilon - ESP32 Embedded Agent Framework for Security Research.

## 📚 About

This repository contains the complete documentation for Espilon, built with [MkDocs Material](https://squidfunk.github.io/mkdocs-material/).

**Live Documentation**: [https://docs.espilon.net](https://docs.espilon.net)

## 🌍 Languages

- 🇬🇧 English (default)
- 🇫🇷 Français

## 🚀 Quick Start

### Prerequisites

- Python 3.8+
- pip

### Local Development

1. **Clone the repository**
   ```bash
   git clone https://github.com/Espilon-Net/espilon-docs.git
   cd espilon-docs
   ```

2. **Install dependencies**
   ```bash
   pip install -r requirements.txt
   ```

3. **Run local server**
   ```bash
   mkdocs serve
   ```

4. **Open in browser**
   ```
   http://localhost:8000
   ```

## 🐳 Docker Deployment

### Build the image

```bash
docker build -t espilon-docs .
```

### Run the container

```bash
docker run -d -p 8080:80 --name espilon-docs espilon-docs
```

Access at `http://localhost:8080`

## 📁 Repository Structure

```
espilon-docs/
├── docs/               # Documentation source files
│   ├── index.md       # English homepage
│   ├── fr/            # French translations
│   ├── getting-started/
│   ├── hardware/
│   ├── modules/
│   ├── security/
│   └── stylesheets/
├── assets/            # Images and diagrams
│   ├── images/
│   └── diagrams/
├── mkdocs.yml         # MkDocs configuration
├── requirements.txt   # Python dependencies
└── Dockerfile         # Multi-stage Docker build
```

## 🔧 Build Static Site

Generate static HTML files:

```bash
mkdocs build
```

Output will be in `site/` directory.

## 🌐 Adding Translations

1. Create language directory: `docs/[lang]/`
2. Translate markdown files maintaining same structure
3. Update `mkdocs.yml` with new language configuration
4. See `docs/fr/README.md` for translation guidelines

## 📝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Submit a pull request

## 📖 Documentation Topics

- Getting Started & Installation
- Hardware Configuration (ESP32, LilyGO T-Call, ESP32-CAM)
- Module Reference & Commands
- Security Research & Best Practices
- Use Cases & Examples
- Architecture & Design

## ⚙️ Technology Stack

- [MkDocs](https://www.mkdocs.org/) - Documentation generator
- [Material for MkDocs](https://squidfunk.github.io/mkdocs-material/) - Theme
- [mkdocs-static-i18n](https://github.com/ultrabug/mkdocs-static-i18n) - Multilingual support
- [Mermaid](https://mermaid.js.org/) - Diagrams
- Docker - Containerization
- Nginx - Web server

## 📄 License

MIT License - See main [Espilon repository](https://github.com/Espilon-Net/espilon) for details.

## 🔗 Related Projects

- [Espilon Framework](https://github.com/Espilon-Net/espilon) - Main project repository
- [Espilon C2 Server](https://github.com/Espilon-Net/espilon) - Command & Control server

## 📧 Support

- **Issues**: [GitHub Issues](https://github.com/Espilon-Net/espilon-docs/issues)
- **Discussions**: [GitHub Discussions](https://github.com/Espilon-Net/espilon/discussions)

---

Built with ❤️ for the security research community
