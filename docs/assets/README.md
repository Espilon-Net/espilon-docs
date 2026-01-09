# Assets Directory

## Structure

```
assets/
├── images/          # Screenshots, photos, logos
├── diagrams/        # Architecture diagrams, flowcharts
└── README.md        # This file
```

## Adding Images

### Logo

Place your Espilon logo here:
- `images/logo.png` - Main logo (recommended: 512x512px)
- `images/logo-light.png` - Logo for light mode (optional)
- `images/logo-dark.png` - Logo for dark mode (optional)

### Screenshots

Add screenshots in `images/` with descriptive names:
- `c2-interface.png` - C2 server interface
- `flasher-gui.png` - Flasher tool
- `device-list.png` - Device management
- etc.

### Diagrams

Create or export diagrams to `diagrams/`:
- `architecture.png` - System architecture
- `network-flow.png` - Network communication flow
- `module-structure.png` - Module organization

## Usage in Markdown

### Basic Image

```markdown
![Alt text](assets/images/logo.png)
```

### Image with Caption

```markdown
<figure markdown>
  ![C2 Interface](assets/images/c2-interface.png)
  <figcaption>The Espilon C2 Server Interface</figcaption>
</figure>
```

### Sized Image

```markdown
![Logo](assets/images/logo.png){ width="300" }
```

### Image in Admonition

```markdown
!!! example "Example Screenshot"
    ![](assets/images/example.png)
```

## Tips

- Use PNG for screenshots and logos (with transparency if needed)
- Use JPEG for photos
- Keep images under 500KB for fast loading
- Use descriptive filenames (no spaces, use hyphens)
- Optimize images before adding them
