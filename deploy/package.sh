#!/bin/bash

# Miner Website Packaging Script
# Creates a deployment-ready package for cloud VM deployment

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
PACKAGE_NAME="miner-website-deployment-$(date +%Y%m%d-%H%M%S)"
PACKAGE_DIR="/tmp/$PACKAGE_NAME"

echo "Creating deployment package: $PACKAGE_NAME"

# Create package directory
mkdir -p "$PACKAGE_DIR"

# Copy all website files
echo "Copying website files..."
cp -r "$PROJECT_DIR"/* "$PACKAGE_DIR/"

# Make scripts executable
chmod +x "$PACKAGE_DIR/deploy/startup.sh"

# Create deployment archive
echo "Creating deployment archive..."
cd /tmp
tar -czf "$PACKAGE_NAME.tar.gz" "$PACKAGE_NAME"

# Create zip for Windows compatibility
zip -r "$PACKAGE_NAME.zip" "$PACKAGE_NAME" > /dev/null

echo "Package created successfully!"
echo "Archive: /tmp/$PACKAGE_NAME.tar.gz"
echo "Zip file: /tmp/$PACKAGE_NAME.zip"
echo ""
echo "Upload instructions:"
echo "1. Upload the archive to your cloud VM"
echo "2. Extract: tar -xzf $PACKAGE_NAME.tar.gz"
echo "3. Run: sudo bash $PACKAGE_NAME/deploy/startup.sh"

# Cleanup
rm -rf "$PACKAGE_DIR"
