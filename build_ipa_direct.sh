#!/bin/bash

# Direct IPA build script that bypasses Xcode Archive
# This method often avoids sandbox issues

set -e

PROJECT_DIR="$HOME/uzbekservice_app"

echo "🚀 Building IPA directly (bypassing Xcode Archive)..."
echo "====================================================="
echo ""
echo "This method uses Flutter's build system directly,"
echo "which often bypasses Xcode sandbox restrictions."
echo ""

cd "$PROJECT_DIR"

# Clean
echo "1️⃣  Cleaning previous builds..."
flutter clean
echo "✅ Cleaned"
echo ""

# Get dependencies
echo "2️⃣  Getting dependencies..."
flutter pub get
echo "✅ Dependencies ready"
echo ""

# Build IPA directly
echo "3️⃣  Building IPA..."
echo "   This may take 5-15 minutes..."
echo "   Building for Release configuration..."
echo ""

flutter build ipa --release --no-codesign

echo ""
echo "✅ Build complete!"
echo ""

# Check if IPA was created
IPA_PATH=$(find "$PROJECT_DIR/build/ios/ipa" -name "*.ipa" 2>/dev/null | head -1)

if [ -n "$IPA_PATH" ]; then
    IPA_SIZE=$(du -h "$IPA_PATH" | cut -f1)
    echo "📦 IPA created successfully!"
    echo "   Location: $IPA_PATH"
    echo "   Size: $IPA_SIZE"
    echo ""
    echo "📤 To upload to TestFlight:"
    echo ""
    echo "   Option 1 - Using Transporter app:"
    echo "   1. Open 'Transporter' app (from Mac App Store)"
    echo "   2. Drag and drop the IPA file"
    echo "   3. Click 'Deliver'"
    echo ""
    echo "   Option 2 - Using Xcode Organizer:"
    echo "   1. Open Xcode"
    echo "   2. Window → Organizer"
    echo "   3. Click '+' → 'Add an Archive...'"
    echo "   4. Select: $IPA_PATH"
    echo "   5. Click 'Distribute App' → App Store Connect"
else
    echo "❌ IPA was not created. Check the build output above for errors."
    echo ""
    echo "If you see sandbox errors, try:"
    echo "1. Run: ./fix_sandbox_complete.sh"
    echo "2. Restart Xcode"
    echo "3. Run this script again"
    exit 1
fi

echo ""

