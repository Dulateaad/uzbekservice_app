#!/bin/bash

# Fix rsync sandbox error for iOS builds
# This script cleans build artifacts and prepares for rebuild

set -e

PROJECT_DIR="$HOME/uzbekservice_app"
echo "🔧 Fixing rsync sandbox error..."
echo "================================"
echo ""

cd "$PROJECT_DIR"

# Step 1: Clean Flutter
echo "1️⃣  Cleaning Flutter build..."
flutter clean
echo "✅ Flutter cleaned"
echo ""

# Step 2: Clean Xcode DerivedData
echo "2️⃣  Cleaning Xcode DerivedData..."
rm -rf ~/Library/Developer/Xcode/DerivedData/Runner-* 2>/dev/null || true
echo "✅ DerivedData cleaned"
echo ""

# Step 3: Regenerate Flutter files
echo "3️⃣  Regenerating Flutter files..."
flutter pub get
echo "✅ Flutter files regenerated"
echo ""

# Step 4: Reinstall pods
echo "4️⃣  Reinstalling CocoaPods..."
cd ios
pod deintegrate 2>/dev/null || true
pod install
cd ..
echo "✅ Pods reinstalled"
echo ""

echo "✅ Cleanup completed!"
echo ""
echo "📋 NEXT STEPS:"
echo ""
echo "1. CRITICAL: Enable Full Disk Access for Xcode:"
echo "   System Settings → Privacy & Security → Full Disk Access"
echo "   Add Xcode and enable the toggle"
echo ""
echo "2. Restart Xcode:"
echo "   Cmd + Q to quit, then reopen"
echo ""
echo "3. Try Archive in Xcode:"
echo "   - Open: open $PROJECT_DIR/ios/Runner.xcworkspace"
echo "   - Select 'Any iOS Device'"
echo "   - Product → Archive"
echo ""
echo "⚠️  Note: Fixing permissions on DerivedData requires sudo:"
echo "   sudo chown -R \$(whoami) ~/Library/Developer/Xcode/DerivedData/"
echo "   sudo chmod -R u+w ~/Library/Developer/Xcode/DerivedData/"
echo ""

