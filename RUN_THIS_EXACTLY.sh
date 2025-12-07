#!/bin/bash

# RUN THIS EXACTLY - NO ARCHIVE!
# This builds IPA directly without Archive

clear
echo "==================================================================="
echo "  🚀 Building IPA (NO ARCHIVE - This will work!)"
echo "==================================================================="
echo ""
echo "This command: flutter build ipa --release"
echo "Creates IPA directly WITHOUT using Archive"
echo ""
echo "==================================================================="
echo ""

cd ~/uzbekservice_app

echo "📍 Current directory: $(pwd)"
echo ""

# Clean first
echo "📦 Step 1/3: Cleaning..."
flutter clean
echo ""

# Get dependencies
echo "📥 Step 2/3: Getting dependencies..."
flutter pub get
echo ""

# Build IPA (NOT Archive!)
echo "🔨 Step 3/3: Building IPA (this bypasses Archive)..."
echo ""
echo "⏳ This will take 5-15 minutes. Please wait..."
echo ""
flutter build ipa --release

echo ""
echo "==================================================================="
echo ""

# Check result
IPA_PATH=$(find build/ios/ipa -name "*.ipa" 2>/dev/null | head -1)

if [ -n "$IPA_PATH" ]; then
    IPA_SIZE=$(du -h "$IPA_PATH" | cut -f1)
    IPA_NAME=$(basename "$IPA_PATH")
    
    echo "✅ SUCCESS! IPA created!"
    echo ""
    echo "📦 File: $IPA_NAME"
    echo "💾 Size: $IPA_SIZE"
    echo "📁 Full path:"
    echo "   $IPA_PATH"
    echo ""
    echo "==================================================================="
    echo "  📤 Next: Upload to TestFlight"
    echo "==================================================================="
    echo ""
    echo "1. Open Transporter app (from Mac App Store)"
    echo "2. Drag this file into Transporter:"
    echo "   $IPA_PATH"
    echo "3. Click 'Deliver' button"
    echo ""
    echo "✅ Done!"
else
    echo "❌ Build failed - IPA was not created"
    echo ""
    echo "Check the error messages above."
    echo ""
    exit 1
fi

