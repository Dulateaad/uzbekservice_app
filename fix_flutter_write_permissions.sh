#!/bin/bash

# Fix Flutter write permissions for DerivedData
# This script fixes the .last_build_id write error

set -e

echo "🔧 Fixing Flutter write permissions..."
echo "======================================"
echo ""
echo "This script will:"
echo "1. Fix permissions on DerivedData directory"
echo "2. Clean problematic build artifacts"
echo "3. Prepare for rebuild"
echo ""
echo "⚠️  Note: This requires sudo access (you'll be prompted for password)"
echo ""

# Fix ownership and permissions on DerivedData
echo "1️⃣  Fixing DerivedData ownership and permissions..."
sudo chown -R $(whoami) ~/Library/Developer/Xcode/DerivedData/
sudo chmod -R u+w ~/Library/Developer/Xcode/DerivedData/
echo "✅ Permissions fixed"
echo ""

# Remove problematic Runner build directory
echo "2️⃣  Removing problematic Runner build directory..."
rm -rf ~/Library/Developer/Xcode/DerivedData/Runner-apvymelgngogdbbmheixdzwnujrn
echo "✅ Cleaned Runner DerivedData"
echo ""

# Navigate to project
cd ~/uzbekservice_app

# Clean Flutter
echo "3️⃣  Cleaning Flutter build..."
flutter clean
echo "✅ Flutter cleaned"
echo ""

# Regenerate Flutter files
echo "4️⃣  Regenerating Flutter files..."
flutter pub get
echo "✅ Flutter files regenerated"
echo ""

echo "✅ All done!"
echo ""
echo "📋 NEXT STEPS:"
echo ""
echo "1. CRITICAL: Enable Full Disk Access for Xcode:"
echo "   System Settings → Privacy & Security → Full Disk Access"
echo "   - Add Xcode (if not already added)"
echo "   - Enable the toggle"
echo ""
echo "2. Restart Xcode completely (Cmd + Q, then reopen)"
echo ""
echo "3. Try building again:"
echo "   Option A - In Xcode:"
echo "   - Product → Clean Build Folder (Shift + Cmd + K)"
echo "   - Product → Archive"
echo ""
echo "   Option B - Command line:"
echo "   flutter build ipa"
echo ""

