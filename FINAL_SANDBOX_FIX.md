# 🔧 Final Sandbox Fix - Complete Solution

## ❌ Current Error:
```
Sandbox: rsync(23744) deny(1) file-read-data
Sandbox: dartvm(23680) deny(1) file-write-create
```

Even with Full Disk Access enabled, sandbox errors persist. This indicates Xcode needs to be restarted or permissions need deeper fixing.

## ✅ Complete Solution:

### Step 1: Quit Xcode Completely

**This is critical!** Xcode must be completely closed to reset its sandbox session:

1. In Xcode, press `Cmd + Q` (or Xcode → Quit Xcode)
2. Wait 5 seconds
3. Verify Xcode is closed (check Dock - no Xcode icon should be there)

### Step 2: Fix Permissions

Run the comprehensive fix script:

```bash
cd ~/uzbekservice_app
./fix_sandbox_complete.sh
```

This will:
- Fix DerivedData ownership and permissions (requires sudo)
- Remove problematic build directories
- Clean Flutter build cache
- Regenerate Flutter files

**Or manually:**

```bash
# Fix ownership
sudo chown -R $(whoami) ~/Library/Developer/Xcode/DerivedData/

# Fix write permissions
sudo chmod -R u+w ~/Library/Developer/Xcode/DerivedData/

# Remove problematic directory
sudo rm -rf ~/Library/Developer/Xcode/DerivedData/Runner-apvymelgngogdbbmheixdzwnujrn

# Clean Flutter
cd ~/uzbekservice_app
flutter clean
flutter pub get
```

### Step 3: Verify Full Disk Access

Double-check Full Disk Access is enabled:

1. System Settings → Privacy & Security → Full Disk Access
2. Verify **Xcode** toggle is **enabled** (blue)
3. Verify **Terminal** toggle is **enabled** (blue)
4. If toggles are off, enable them and restart Mac

### Step 4: Restart Xcode

After fixing permissions:

```bash
open ~/uzbekservice_app/ios/Runner.xcworkspace
```

### Step 5: Build Using Direct IPA Method (RECOMMENDED)

This bypasses Xcode Archive and often avoids sandbox issues:

```bash
cd ~/uzbekservice_app
./build_ipa_direct.sh
```

Or manually:
```bash
cd ~/uzbekservice_app
flutter clean
flutter pub get
flutter build ipa --release
```

The IPA will be at: `~/uzbekservice_app/build/ios/ipa/*.ipa`

Then upload using **Transporter** app.

### Alternative: Restart Mac

If errors persist after all steps:

1. Save all work
2. **Restart Mac** completely
3. After restart:
   - Verify Full Disk Access is still enabled
   - Open Xcode
   - Try building again

## 🔍 Why This Happens

- **macOS 26.1** (beta) has stricter sandbox rules
- Xcode's Archive process uses `rsync` which needs file access
- Even with Full Disk Access, Xcode needs to be restarted to acquire permissions
- DerivedData may have incorrect permissions from previous builds

## 📋 Complete Checklist

- [ ] Quit Xcode completely (`Cmd + Q`)
- [ ] Run `./fix_sandbox_complete.sh` (fixes permissions)
- [ ] Verify Full Disk Access is enabled for Xcode and Terminal
- [ ] Restart Xcode
- [ ] Try `./build_ipa_direct.sh` (direct IPA build)
- [ ] If still failing, restart Mac
- [ ] Try building again after restart

## 💡 Recommended Workflow

**For fastest resolution:**

1. ✅ Quit Xcode
2. ✅ Run: `./fix_sandbox_complete.sh`
3. ✅ Verify Full Disk Access enabled
4. ✅ Restart Xcode
5. ✅ Run: `./build_ipa_direct.sh`

If `build_ipa_direct.sh` succeeds, you can upload the IPA directly to TestFlight using the **Transporter** app, bypassing Xcode Archive entirely.

## ⚠️ Important Notes

- **Full Disk Access is REQUIRED** - without it, sandbox will always block
- **Xcode must be restarted** after enabling Full Disk Access or fixing permissions
- **Direct IPA build** (`flutter build ipa`) often works when Archive fails
- **macOS 26.1 beta** may have additional restrictions

---

**If nothing works:** Consider using CI/CD (GitHub Actions, Bitrise) or building on a different Mac with stable macOS version.
