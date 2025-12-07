# ⚠️ IMPORTANT: How to Build IPA Without Archive Errors

## ❌ DO NOT USE:

**DO NOT run:**
- `flutter build ios --release` (then Archive in Xcode)
- `flutter build ios` (then Archive)
- Xcode → Product → Archive
- Any command that uses "Archive"

These all trigger the sandbox errors you're seeing!

---

## ✅ USE THIS INSTEAD:

### The Correct Command:

```bash
cd ~/uzbekservice_app
flutter build ipa --release
```

That's it! This bypasses Xcode Archive completely.

---

## 🚀 Quick Start:

1. **Open Terminal**

2. **Run:**
   ```bash
   cd ~/uzbekservice_app
   flutter build ipa --release
   ```

3. **Wait for build to complete** (5-15 minutes)

4. **Find your IPA:**
   ```bash
   ls -lh ~/uzbekservice_app/build/ios/ipa/*.ipa
   ```

5. **Upload to TestFlight:**
   - Open **Transporter** app (from Mac App Store)
   - Drag and drop the IPA file
   - Click "Deliver"

---

## 🔍 What's the Difference?

### ❌ WRONG (Uses Archive - Fails):
```bash
flutter build ios --release
# Then: Xcode → Product → Archive  ← This fails!
```

### ✅ CORRECT (Bypasses Archive - Works):
```bash
flutter build ipa --release  ← This works!
```

---

## 📋 Complete Build Process:

```bash
# 1. Clean (optional, but recommended)
cd ~/uzbekservice_app
flutter clean

# 2. Get dependencies
flutter pub get

# 3. Build IPA directly (NOT Archive!)
flutter build ipa --release

# 4. Verify IPA was created
ls -lh build/ios/ipa/*.ipa

# 5. Upload using Transporter app
```

---

## ⚠️ Key Points:

- **`flutter build ipa`** = Creates IPA directly (USE THIS!)
- **`flutter build ios` + Archive** = Uses Xcode Archive (DOESN'T WORK!)

The command `flutter build ipa` creates a complete IPA file ready for TestFlight, bypassing Xcode Archive entirely.

---

## 🎯 If You Still See Errors:

Make sure you're running:
```bash
flutter build ipa --release
```

NOT:
```bash
flutter build ios --release  # This is wrong!
```

The difference is `ipa` vs `ios` - use `ipa`!

