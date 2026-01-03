# Espilon Documentation

Official documentation for the Espilon ESP32 embedded agent framework.

**Live Documentation**: https://docs.espilon.net

**Main Project**: https://github.com/Espilon-Net

## About

Complete documentation for Espilon, built with [MkDocs](https://www.mkdocs.org/) and the [Material theme](https://squidfunk.github.io/mkdocs-material/).

## Documentation Contents

- **Getting Started**: Installation, quick start, and overview
- **Hardware**: Supported boards and setup guides
- **Configuration**: Menuconfig and network settings
- **Tools**: Flasher and C2 server
- **Modules**: Command reference and module system
- **Security**: Best practices and encryption

## Quick Start

### Local Development

```bash
# Clone
git clone https://github.com/Espilon-Net/espilon-docs.git
cd espilon-docs

# Setup
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt

# Run
mkdocs serve
```

Documentation available at http://localhost:8000

### Docker Build

```bash
# Build
docker build -t espilon-docs .

# Run
docker run -p 8080:80 espilon-docs
```

Access at http://localhost:8080

## Deployment

### Self-Hosted with Docker Compose

```bash
docker-compose -f docker-compose.docs.yml up -d
```

The service will be available on port 80 and can be proxied via Nginx.

### Configuration Example (Nginx)

```nginx
server {
    listen 443 ssl;
    server_name docs.espilon.net;

    ssl_certificate /etc/letsencrypt/live/espilon.net/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/espilon.net/privkey.pem;

    location / {
        proxy_pass http://espilon-docs:80;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
}
```

## Repository Structure

```
espilon-docs/
├── docs/                    # Markdown files
├── mkdocs.yml              # MkDocs config
├── requirements.txt        # Python dependencies
├── Dockerfile              # Multi-stage build
├── docker-compose.docs.yml # Docker Compose config
└── .github/workflows/      # CI/CD
```

## Contributing

1. Fork the repository
2. Create your feature branch
3. Make changes and test locally with `mkdocs serve`
4. Commit your changes
5. Push and create a Pull Request

## License

Documentation for the Espilon project.

---

**Built with MkDocs Material**
