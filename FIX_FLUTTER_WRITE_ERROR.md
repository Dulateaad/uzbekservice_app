# 🔧 Fix: Flutter .last_build_id Write Error

## ❌ Error:
```
error: Sandbox: dartvm(11780) deny(1) file-write-create 
/Users/dulatea/Library/Developer/Xcode/DerivedData/.../.last_build_id

Flutter failed to write to a file at ".../.last_build_id".
Please ensure that the SDK and/or project is installed in a location 
that has read/write permissions for the current user.
```

## 🔍 Root Cause:

This error occurs when:
1. **Sandbox restrictions** prevent Flutter from writing build files
2. **Permission issues** on DerivedData directory
3. **macOS 26.1 beta** has stricter sandbox rules
4. **Full Disk Access** not enabled for Xcode

## ✅ Solution 1: Fix Permissions (RUN THIS FIRST)

### Option A: Using the Fix Script (Recommended)

```bash
cd ~/uzbekservice_app
./fix_flutter_write_permissions.sh
```

This script will:
- Fix DerivedData ownership and permissions (requires sudo password)
- Clean problematic build artifacts
- Prepare for rebuild

### Option B: Manual Fix

Run these commands (requires sudo password):

```bash
# Fix ownership
sudo chown -R $(whoami) ~/Library/Developer/Xcode/DerivedData/

# Fix write permissions
sudo chmod -R u+w ~/Library/Developer/Xcode/DerivedData/

# Remove problematic build directory
sudo rm -rf ~/Library/Developer/Xcode/DerivedData/Runner-apvymelgngogdbbmheixdzwnujrn

# Clean Flutter
cd ~/uzbekservice_app
flutter clean
flutter pub get
```

## ✅ Solution 2: Enable Full Disk Access (CRITICAL)

**This is ESSENTIAL for macOS 26.1:**

1. **Open System Settings**
   - Apple menu → System Settings
   - Go to **Privacy & Security**

2. **Full Disk Access**
   - Scroll to **Full Disk Access**
   - Click lock icon (enter password)
   - Click **+** button
   - Navigate to `/Applications/Xcode.app`
   - Select Xcode → **Open**
   - **ENABLE** the toggle (must be green/on)

3. **Also add Terminal** (if building via command line)
   - Click **+** again
   - Add `/Applications/Utilities/Terminal.app`
   - Enable toggle

4. **Restart Xcode**
   ```bash
   # Quit Xcode completely (Cmd + Q), then:
   open ~/uzbekservice_app/ios/Runner.xcworkspace
   ```

## ✅ Solution 3: Build IPA Directly (Bypasses Xcode Sandbox)

Use Flutter's build system directly, which often bypasses sandbox issues:

### Option A: Using Script
```bash
cd ~/uzbekservice_app
./build_ipa_alternative.sh
```

### Option B: Manual Command
```bash
cd ~/uzbekservice_app
flutter clean
flutter pub get
flutter build ipa --release
```

The IPA will be created at:
```
~/uzbekservice_app/build/ios/ipa/*.ipa
```

Then upload to TestFlight using:
- **Transporter app** (from Mac App Store), or
- **Xcode Organizer** → Import the IPA file

## ✅ Solution 4: Clean Build in Xcode

After fixing permissions and enabling Full Disk Access:

1. **Open Xcode:**
   ```bash
   open ~/uzbekservice_app/ios/Runner.xcworkspace
   ```

2. **Clean Build Folder:**
   - Product → Clean Build Folder (`Shift + Cmd + K`)

3. **Archive:**
   - Select **"Any iOS Device"** (not simulator)
   - Product → Archive
   - Wait for completion

4. **Distribute:**
   - Window → Organizer
   - Select archive → **Distribute App**
   - Choose **App Store Connect**

## ✅ Solution 5: Restart Mac

If issues persist, restart your Mac:

1. Save all work
2. **Restart** Mac completely
3. After restart:
   - Verify Full Disk Access is still enabled
   - Try building again

## 🔍 Why This Happens

- **macOS 26.1** appears to be a beta version with stricter sandbox restrictions
- Xcode's build process uses `rsync` and `dartvm` which need file access
- Without Full Disk Access, these tools are blocked by macOS sandbox
- DerivedData directory may have incorrect ownership/permissions

## 📋 Complete Checklist

Run through this checklist:

- [ ] **Run permission fix script:** `./fix_flutter_write_permissions.sh`
- [ ] **Enable Full Disk Access** for Xcode (System Settings)
- [ ] **Enable Full Disk Access** for Terminal (if using command line)
- [ ] **Restart Xcode** after enabling Full Disk Access
- [ ] **Clean Flutter:** `flutter clean && flutter pub get`
- [ ] **Try build:** Either Archive in Xcode or `flutter build ipa`
- [ ] **Restart Mac** if issues persist

## 💡 Recommended Approach

**For fastest resolution:**

1. ✅ Run `./fix_flutter_write_permissions.sh` (fixes permissions)
2. ✅ Enable Full Disk Access for Xcode (critical!)
3. ✅ Restart Xcode
4. ✅ Try `flutter build ipa --release` (often bypasses sandbox issues)

If `flutter build ipa` works, you can upload the IPA directly to TestFlight using Transporter app.

---

**Most Important:** Full Disk Access is REQUIRED. Without it, Xcode cannot write build files, causing the `.last_build_id` write error.

