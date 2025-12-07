#!/bin/bash

# THE CORRECT WAY TO BUILD IPA
# This bypasses Xcode Archive and avoids sandbox errors

set -e

echo "🚀 Building IPA (The CORRECT Way)"
echo "=================================="
echo ""
echo "This uses: flutter build ipa"
echo "NOT: flutter build ios + Archive"
echo ""

cd ~/uzbekservice_app

# Clean
echo "📦 Cleaning..."
flutter clean
echo ""

# Get dependencies
echo "📥 Getting dependencies..."
flutter pub get
echo ""

# Build IPA directly (NOT Archive!)
echo "🔨 Building IPA (this bypasses Xcode Archive)..."
echo "   This may take 5-15 minutes..."
echo ""
flutter build ipa --release

echo ""
echo "=================================="
echo ""

# Check result
IPA_PATH=$(find build/ios/ipa -name "*.ipa" 2>/dev/null | head -1)

if [ -n "$IPA_PATH" ]; then
    IPA_SIZE=$(du -h "$IPA_PATH" | cut -f1)
    echo "✅ SUCCESS! IPA created!"
    echo ""
    echo "📦 File: $(basename "$IPA_PATH")"
    echo "💾 Size: $IPA_SIZE"
    echo "📁 Location: $IPA_PATH"
    echo ""
    echo "📤 Next step: Upload to TestFlight"
    echo ""
    echo "   1. Open Transporter app (from App Store)"
    echo "   2. Drag and drop: $IPA_PATH"
    echo "   3. Click 'Deliver'"
    echo ""
else
    echo "❌ Build failed - check errors above"
    exit 1
fi

