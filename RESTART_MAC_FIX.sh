#!/bin/bash

# Complete fix that requires Mac restart
# This addresses the root sandbox issue

clear
echo "==================================================================="
echo "  🔧 Complete Sandbox Fix (Requires Mac Restart)"
echo "==================================================================="
echo ""

cd ~/uzbekservice_app

echo "This script will:"
echo "1. Fix DerivedData permissions"
echo "2. Clean problematic build directories"
echo "3. Prepare for rebuild"
echo ""
echo "⚠️  IMPORTANT: After running this, you MUST:"
echo "   1. Enable Full Disk Access for Xcode (if not already)"
echo "   2. RESTART YOUR MAC"
echo "   3. Then try building again"
echo ""
read -p "Continue? (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    exit 1
fi

echo ""
echo "==================================================================="
echo "  Step 1: Fixing Permissions (requires sudo password)"
echo "==================================================================="
echo ""

sudo chown -R $(whoami) ~/Library/Developer/Xcode/DerivedData/
sudo chmod -R u+w ~/Library/Developer/Xcode/DerivedData/

echo "✅ Permissions fixed"
echo ""

echo "==================================================================="
echo "  Step 2: Cleaning Build Directories"
echo "==================================================================="
echo ""

sudo rm -rf ~/Library/Developer/Xcode/DerivedData/Runner-apvymelgngogdbbmheixdzwnujrn
flutter clean

echo "✅ Cleaned"
echo ""

echo "==================================================================="
echo "  ✅ Fix Complete!"
echo "==================================================================="
echo ""
echo "📋 NEXT STEPS (CRITICAL):"
echo ""
echo "1. Verify Full Disk Access:"
echo "   System Settings → Privacy & Security → Full Disk Access"
echo "   - Xcode should be enabled (blue toggle)"
echo ""
echo "2. RESTART YOUR MAC:"
echo "   - Save all work"
echo "   - Restart completely"
echo "   - This is REQUIRED for Full Disk Access to work properly"
echo ""
echo "3. After restart, try building:"
echo "   cd ~/uzbekservice_app"
echo "   flutter build ipa --release"
echo ""
echo "==================================================================="
echo ""

