# Documentation Française - Guide de Traduction

## Structure

La documentation utilise le plugin `mkdocs-static-i18n` avec une structure en dossiers :

```
docs/
├── index.md              # Version anglaise (par défaut)
├── getting-started/
│   ├── quickstart.md
│   └── ...
└── fr/                   # Version française
    ├── index.md          # Page d'accueil traduite
    ├── getting-started/
    │   ├── quickstart.md
    │   └── ...
    └── ...
```

## Comment Traduire une Page

### Étape 1: Créer la Structure

Pour chaque page anglaise, créez la version française dans `docs/fr/` :

```bash
# Exemple : traduire getting-started/quickstart.md
mkdir -p docs/fr/getting-started
cp docs/getting-started/quickstart.md docs/fr/getting-started/quickstart.md
```

### Étape 2: Traduire le Contenu

Éditez le fichier copié et traduisez :

- **Titres et sous-titres**
- **Paragraphes de texte**
- **Admonitions** (!!!tip, !!!warning, etc.)
- **Liens internes** (gardez les mêmes chemins relatifs)
- **Tableaux**
- **Listes**

**Ne traduisez PAS** :
- ✅ Blocs de code
- ✅ Commandes shell
- ✅ Noms de fichiers
- ✅ URLs externes
- ✅ Diagrammes Mermaid (sauf les labels si vous voulez)

### Étape 3: Vérifier les Liens

Les liens relatifs fonctionnent automatiquement :

```markdown
<!-- Ces liens fonctionnent en français ET en anglais -->
[Guide d'installation](installation.md)
[Retour à l'accueil](../index.md)
```

## Pages Prioritaires à Traduire

### Haute Priorité (traduire en premier)

1. ✅ `index.md` - Page d'accueil (FAIT)
2. ⬜ `getting-started/quickstart.md` - Démarrage rapide
3. ⬜ `getting-started/installation.md` - Installation
4. ⬜ `hardware/index.md` - Vue d'ensemble matériel

### Moyenne Priorité

5. ⬜ `modules/commands.md` - Référence des commandes
6. ⬜ `getting-started/architecture.md` - Architecture
7. ⬜ `configuration/menuconfig.md` - Configuration
8. ⬜ `use-cases/index.md` - Cas d'usage

### Basse Priorité

9. ⬜ `security/index.md`
10. ⬜ `security/best-practices.md`
11. ⬜ Autres pages...

## Exemples de Traduction

### Admonitions

```markdown
<!-- Anglais -->
!!! tip "Quick Tip"
    This is a helpful tip

<!-- Français -->
!!! tip "Astuce Rapide"
    Ceci est une astuce utile
```

### Tableaux

```markdown
<!-- Anglais -->
| Command | Description |
|---------|-------------|
| `info` | Device information |

<!-- Français -->
| Commande | Description |
|----------|-------------|
| `info` | Informations sur l'appareil |
```

### Blocs de Code (NE PAS TRADUIRE)

```markdown
<!-- Gardez le code tel quel -->
```bash
idf.py build
mkdocs serve
```

<!-- Mais traduisez les descriptions -->
Lancez le serveur de développement :
```

## Tester Localement

```bash
# Rebuild avec les traductions
docker-compose -f docker-compose.docs.yml build
docker-compose -f docker-compose.docs.yml up -d

# Accédez à :
# - Anglais : http://localhost:8080/
# - Français : http://localhost:8080/fr/
```

## Sélecteur de Langue

Un sélecteur de langue apparaît automatiquement dans l'en-tête du site :

```
┌─────────────────────────────┐
│  Espilon Documentation  🌐 │
│                         ↓   │
│  • English              │
│  • Français (actuel)    │
└─────────────────────────────┘
```

## Fallback Automatique

Si une page n'existe pas en français, elle affichera automatiquement la version anglaise avec un avertissement.

## Conventions de Traduction

### Termes Techniques (à garder en anglais)

- WiFi
- GPRS
- ESP32
- C2 (Command & Control)
- ARP
- TCP/IP
- IoT
- CTF
- API
- Docker

### Termes à Traduire

- Network → Réseau
- Commands → Commandes
- Hardware → Matériel
- Configuration → Configuration
- Security → Sécurité
- Device → Appareil/Dispositif
- Agent → Agent
- Server → Serveur
- Quick Start → Démarrage Rapide
- Getting Started → Démarrage

## Aide à la Traduction

### Outils Utiles

- [DeepL](https://www.deepl.com/) - Traduction de qualité
- [Linguee](https://www.linguee.com/) - Contexte technique
- [Reverso](https://www.reverso.net/) - Vérification

### Cohérence

Utilisez toujours les mêmes traductions pour les termes récurrents :

| Anglais | Français |
|---------|----------|
| Getting Started | Démarrage |
| Quick Start | Démarrage Rapide |
| Hardware | Matériel |
| Device | Appareil |
| Command | Commande |
| Network | Réseau |
| Configuration | Configuration |
| Security | Sécurité |

## Contribution

Pour contribuer à la traduction :

1. Forkez le repo
2. Créez une branche `feature/translate-french`
3. Traduisez les pages
4. Testez localement
5. Créez une Pull Request

---

**Besoin d'aide ?** Ouvrez une issue sur GitHub !
