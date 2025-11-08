# RDP-Cat Debian Package

This directory contains the build configuration for creating a Debian package for RDP-Cat.

## Package Information

- **Package Name**: `picx--rdpcat`
- **Binary Location**: `/usr/local/bin/rdp-cat`
- **Dependencies**: 
  - `freerdp2x`
  - `libssh2-1`

## Building Locally

### Prerequisites

- Debian-based Linux system (Ubuntu, Debian, etc.)
- `dpkg-deb` (usually pre-installed)
- `curl` for downloading the binary

### Build Steps

1. Navigate to this directory:
   ```bash
   cd rdp-cat-deb
   ```

2. Run the build script:
   ```bash
   chmod +x build.sh
   ./build.sh
   ```

3. Install the generated package:
   ```bash
   sudo apt install ./picx--rdpcat_*.deb
   ```

## GitHub Actions CI/CD

The package is automatically built and released via GitHub Actions when:
- Changes are pushed to the `main` branch
- Changes are made to:
  - `deb_version` file
  - `pkg/**` directory
  - Workflow file

### Release Process

1. Update the versions in `deb_version`:
   - `DEB=x.y.z` - Debian package version
   - `BIN=x.y.z` - rdp-cat binary version
2. Commit and push changes
3. GitHub Actions will:
   - Build packages for amd64, arm64, and armv7
   - Download the specified binary version from GitHub
   - Create a GitHub release
   - Upload `.deb` packages and checksums

## Versioning

The `deb_version` file contains two version numbers:
- `DEB` - The Debian package version (used for releases and package naming)
- `BIN` - The rdp-cat binary version to download from upstream

Example:
```bash
DEB=1.0.0
BIN=1.0.0
```

## Package Structure

```
rdp-cat-deb/
├── deb_version           # Version file (DEB and BIN variables)
├── build.sh              # Local build script
├── pkg/
│   └── DEBIAN/
│       ├── control       # Package metadata
│       ├── postinst      # Post-installation script
│       ├── prerm         # Pre-removal script
│       └── postrm        # Post-removal script
└── .github/
    └── workflows/
        └── build_and_release.yaml
```

## Usage

After installation:

```bash
rdp-cat --help
```

## Uninstallation

```bash
sudo apt remove picx--rdpcat
```

## Notes

- The binary is downloaded from the official rdp-cat GitHub releases
- Architecture-specific binaries are attempted first, falling back to amd64 if unavailable
- The package follows Debian packaging standards
