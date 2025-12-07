# 🚀 Bypass Xcode Archive - Build IPA Directly

## ❌ Problem:

Xcode Archive is blocked by sandbox restrictions on macOS 26.1:
```
Sandbox: rsync deny file-read-data
Sandbox: dartvm deny file-write-create
```

## ✅ Solution: Use Flutter's Direct Build (Bypasses Xcode Archive)

**Stop using Xcode Archive!** Use Flutter's direct build instead - it often bypasses these sandbox issues.

### Quick Build (Recommended):

```bash
cd ~/uzbekservice_app

# Clean and build
flutter clean
flutter pub get
flutter build ipa --release
```

The IPA will be created at:
```
~/uzbekservice_app/build/ios/ipa/*.ipa
```

### Upload to TestFlight:

After building, upload using **Transporter** app:

1. Open **Transporter** app (from Mac App Store, or `/Applications/Transporter.app`)
2. Drag and drop your IPA file
3. Click **Deliver**
4. Done!

---

## 🔍 Why This Works:

- `flutter build ipa` uses Flutter's build system directly
- Bypasses Xcode Archive process entirely
- Avoids rsync and other sandbox-restricted tools
- Creates a valid IPA file ready for TestFlight

## 📋 Complete Steps:

1. **Stop using Xcode Archive** - it's blocked by sandbox
2. **Use direct Flutter build:**
   ```bash
   cd ~/uzbekservice_app
   flutter clean
   flutter pub get
   flutter build ipa --release
   ```
3. **Upload IPA using Transporter app**

That's it! No Xcode Archive needed.

---

**Note:** You can still use Xcode for development and debugging. Just use `flutter build ipa` for creating releases for TestFlight/App Store.

