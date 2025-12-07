#!/bin/bash

# Quick IPA build script - Bypasses Xcode Archive sandbox issues
# Use this instead of Xcode Archive on macOS 26.1

set -e

PROJECT_DIR="$HOME/uzbekservice_app"

echo "🚀 Building IPA (bypassing Xcode Archive)..."
echo "============================================="
echo ""
echo "This uses Flutter's direct build system,"
echo "which bypasses Xcode Archive sandbox restrictions."
echo ""

cd "$PROJECT_DIR"

# Clean
echo "📦 Cleaning..."
flutter clean
echo "✅ Cleaned"
echo ""

# Get dependencies
echo "📥 Getting dependencies..."
flutter pub get
echo "✅ Dependencies ready"
echo ""

# Build IPA
echo "🔨 Building IPA (this may take 5-15 minutes)..."
echo ""
flutter build ipa --release

echo ""
echo "============================================="
echo ""

# Check if IPA was created
IPA_PATH=$(find "$PROJECT_DIR/build/ios/ipa" -name "*.ipa" 2>/dev/null | head -1)

if [ -n "$IPA_PATH" ]; then
    IPA_SIZE=$(du -h "$IPA_PATH" | cut -f1)
    IPA_NAME=$(basename "$IPA_PATH")
    
    echo "✅ SUCCESS! IPA created successfully!"
    echo ""
    echo "📦 File: $IPA_NAME"
    echo "📁 Location: $IPA_PATH"
    echo "💾 Size: $IPA_SIZE"
    echo ""
    echo "📤 Upload to TestFlight using Transporter:"
    echo ""
    echo "   1. Open Transporter app (from App Store)"
    echo "   2. Drag and drop: $IPA_PATH"
    echo "   3. Click 'Deliver'"
    echo ""
    echo "   Or open directly:"
    echo "   open -a Transporter $IPA_PATH"
    echo ""
else
    echo "❌ Build failed - IPA was not created"
    echo ""
    echo "Check the error messages above."
    echo ""
    exit 1
fi

