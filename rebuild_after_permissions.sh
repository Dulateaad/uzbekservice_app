#!/bin/bash
# Quick rebuild script after fixing permissions

echo "🚀 Building IPA after permission fix..."
echo ""

cd ~/uzbekservice_app

# Clean
echo "Cleaning..."
flutter clean

# Get dependencies
echo "Getting dependencies..."
flutter pub get

# Build IPA
echo "Building IPA (this may take 5-15 minutes)..."
flutter build ipa --release

echo ""
echo "✅ Build complete!"
echo "📦 IPA location: ~/uzbekservice_app/build/ios/ipa/*.ipa"
echo ""
echo "📤 Upload to TestFlight using Transporter app"
