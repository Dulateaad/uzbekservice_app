#!/bin/bash

# Complete sandbox fix script
# This script addresses rsync and dartvm sandbox errors

set -e

echo "🔧 Complete Sandbox Fix for iOS Build"
echo "======================================"
echo ""
echo "This script will:"
echo "1. Fix DerivedData permissions"
echo "2. Clean problematic build directories"
echo "3. Prepare for rebuild"
echo ""
echo "⚠️  This requires sudo (you'll be prompted for password)"
echo ""

# Step 1: Stop Xcode processes (if safe)
echo "1️⃣  Checking Xcode processes..."
if pgrep -x "Xcode" > /dev/null; then
    echo "   ⚠️  Xcode is running. Please quit Xcode first (Cmd + Q)"
    echo "   Then run this script again."
    read -p "   Continue anyway? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi
echo ""

# Step 2: Fix DerivedData permissions
echo "2️⃣  Fixing DerivedData permissions..."
sudo chown -R $(whoami) ~/Library/Developer/Xcode/DerivedData/
sudo chmod -R u+w ~/Library/Developer/Xcode/DerivedData/
echo "✅ Permissions fixed"
echo ""

# Step 3: Remove problematic Runner build
echo "3️⃣  Removing problematic Runner build directory..."
sudo rm -rf ~/Library/Developer/Xcode/DerivedData/Runner-apvymelgngogdbbmheixdzwnujrn
echo "✅ Cleaned Runner DerivedData"
echo ""

# Step 4: Navigate to project
cd ~/uzbekservice_app

# Step 5: Clean Flutter
echo "4️⃣  Cleaning Flutter build..."
flutter clean
echo "✅ Flutter cleaned"
echo ""

# Step 6: Regenerate Flutter files
echo "5️⃣  Regenerating Flutter files..."
flutter pub get
echo "✅ Flutter files regenerated"
echo ""

echo "✅ Cleanup completed!"
echo ""
echo "📋 NEXT STEPS:"
echo ""
echo "1. RESTART XCODE:"
echo "   - Quit Xcode completely (Cmd + Q)"
echo "   - Wait 5 seconds"
echo "   - Reopen: open ~/uzbekservice_app/ios/Runner.xcworkspace"
echo ""
echo "2. VERIFY Full Disk Access is enabled:"
echo "   System Settings → Privacy & Security → Full Disk Access"
echo "   - Xcode should be enabled (blue toggle)"
echo "   - Terminal should be enabled (blue toggle)"
echo ""
echo "3. TRY BUILDING:"
echo ""
echo "   Option A - Build IPA directly (RECOMMENDED):"
echo "   cd ~/uzbekservice_app"
echo "   flutter build ipa --release"
echo ""
echo "   Option B - Archive in Xcode:"
echo "   - Select 'Any iOS Device'"
echo "   - Product → Clean Build Folder (Shift + Cmd + K)"
echo "   - Product → Archive"
echo ""
echo "⚠️  Important: Restart Xcode after fixing permissions!"
echo ""

