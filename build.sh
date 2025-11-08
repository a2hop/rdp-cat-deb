#!/bin/bash
# Local build script for RDP-Cat Debian package
set -e

echo "===================================="
echo "RDP-Cat Package Builder"
echo "===================================="
echo ""

# Check if we're in the right directory
if [ ! -f "deb_version" ] || [ ! -d "pkg/DEBIAN" ]; then
    echo "Error: Must run from rdp-cat-deb directory"
    exit 1
fi

# Read versions from deb_version file
source deb_version
if [ -z "$DEB" ] || [ -z "$BIN" ]; then
    echo "Error: deb_version file must contain DEB and BIN variables"
    exit 1
fi

DEB_VERSION="$DEB"
RDP_CAT_VERSION="$BIN"

echo "Building package version: $DEB_VERSION"
echo "RDP-Cat binary version: $RDP_CAT_VERSION"

# Detect architecture
ARCH=$(dpkg --print-architecture)
echo "Architecture: $ARCH"

# Download binary from GitHub
echo ""
echo "Downloading rdp-cat binary..."
BINARY_URL="https://github.com/a2hop/rdp-cat/releases/download/${RDP_CAT_VERSION}/rdp-cat"

if [ -f "rdp-cat" ]; then
    rm -f rdp-cat
fi

if ! curl -L -o rdp-cat "$BINARY_URL"; then
    echo "Error: Failed to download rdp-cat binary"
    exit 1
fi

# Verify binary was downloaded
if [ ! -f "rdp-cat" ]; then
    echo "Error: Binary file not found after download"
    exit 1
fi

# Make binary executable
chmod 755 rdp-cat

# Show binary info
echo ""
echo "Binary info:"
ls -lh rdp-cat
file rdp-cat

# Copy binary to package
echo ""
echo "Copying binary to package..."
mkdir -p pkg/usr/local/bin
cp rdp-cat pkg/usr/local/bin/
chmod 755 pkg/usr/local/bin/rdp-cat

# Set permissions for maintainer scripts
echo ""
echo "Setting permissions..."
chmod 755 pkg/DEBIAN/postinst
chmod 755 pkg/DEBIAN/prerm
chmod 755 pkg/DEBIAN/postrm
chmod 644 pkg/DEBIAN/control

# Update version in control file
sed -i "s/^Version: .*/Version: ${DEB_VERSION}/" pkg/DEBIAN/control
sed -i "s/Architecture: .*/Architecture: ${ARCH}/" pkg/DEBIAN/control

# Build package
echo ""
echo "Building Debian package..."
PKG_NAME="picx--rdpcat_${DEB_VERSION}_${ARCH}.deb"
dpkg-deb --build pkg "$PKG_NAME"

# Verify package
if [ ! -f "$PKG_NAME" ]; then
    echo "Error: Failed to create package"
    exit 1
fi

echo ""
echo "===================================="
echo "Package created successfully!"
echo "===================================="
echo ""
ls -lh "$PKG_NAME"
echo ""

# Show package info
echo "Package information:"
dpkg -I "$PKG_NAME"

echo ""
echo "Package contents:"
dpkg -c "$PKG_NAME"

# Cleanup
echo ""
read -p "Remove downloaded binary? [y/N] " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    rm -f rdp-cat
    echo "Binary removed"
fi

echo ""
echo "To install: sudo apt install ./$PKG_NAME"
echo "To test: dpkg -c $PKG_NAME"
