#!/bin/bash

# Alternative IPA build method that bypasses Xcode sandbox issues
# This uses Flutter's build system directly

set -e

PROJECT_DIR="$HOME/uzbekservice_app"

echo "🚀 Building IPA using Flutter (bypasses Xcode sandbox)..."
echo "========================================================="
echo ""

cd "$PROJECT_DIR"

# Step 1: Clean
echo "1️⃣  Cleaning previous builds..."
flutter clean
echo "✅ Cleaned"
echo ""

# Step 2: Get dependencies
echo "2️⃣  Getting dependencies..."
flutter pub get
echo "✅ Dependencies ready"
echo ""

# Step 3: Build IPA directly (this often bypasses sandbox issues)
echo "3️⃣  Building IPA..."
echo "   This may take 5-15 minutes..."
flutter build ipa --release

echo ""
echo "✅ Build complete!"
echo ""
echo "📦 IPA location:"
echo "   $PROJECT_DIR/build/ios/ipa/*.ipa"
echo ""
echo "📤 To upload to TestFlight:"
echo "   - Use Transporter app, or"
echo "   - Use Xcode Organizer with the generated IPA"
echo ""

