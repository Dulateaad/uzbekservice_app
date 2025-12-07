# 🔧 Fix: Sandbox: rsync deny file-read-data Error

## ❌ Error:
```
Sandbox: rsync(5814) deny(1) file-read-data
/Users/dulatea/Library/Developer/Xcode/DerivedData/...
Failed to build iOS app
```

This error occurs when Xcode's rsync process is blocked by macOS sandbox restrictions (especially on macOS 26.1 beta).

## ✅ Solution 1: Full Disk Access (MOST IMPORTANT)

**This is the most critical fix. Do this first:**

1. **Open System Settings**
   - Click Apple logo 🍎 → **System Settings**
   - Go to **Privacy & Security**

2. **Enable Full Disk Access**
   - Scroll down to **Full Disk Access**
   - Click the lock icon (enter your password)
   - Click the **+** button
   - Navigate to `/Applications/Xcode.app`
   - Select Xcode and click **Open**
   - **ENABLE** the toggle switch next to Xcode (must be green/on)

3. **Also add Terminal** (if building via command line)
   - Click **+** again
   - Navigate to `/Applications/Utilities/Terminal.app`
   - Select Terminal and enable the toggle

4. **Restart Xcode**
   - Quit Xcode completely (`Cmd + Q`)
   - Reopen: `open ~/uzbekservice_app/ios/Runner.xcworkspace`

5. **Try Archive again**
   - Product → Clean Build Folder (`Shift + Cmd + K`)
   - Product → Archive

## ✅ Solution 2: Clean DerivedData and Rebuild

Run these commands in Terminal:

```bash
cd ~/uzbekservice_app

# Clean Flutter
flutter clean

# Remove DerivedData for this project
rm -rf ~/Library/Developer/Xcode/DerivedData/Runner-*

# Fix permissions (requires password)
sudo chown -R $(whoami) ~/Library/Developer/Xcode/DerivedData/
sudo chmod -R u+w ~/Library/Developer/Xcode/DerivedData/

# Rebuild Flutter files
flutter pub get

# Reinstall pods
cd ios
pod deintegrate
pod install
cd ..

# Try building
flutter build ios --release
```

## ✅ Solution 3: Build Archive Directly in Xcode

Sometimes building Archive directly in Xcode bypasses sandbox issues:

1. **Open Xcode workspace:**
   ```bash
   open ~/uzbekservice_app/ios/Runner.xcworkspace
   ```

2. **Configure Archive scheme:**
   - Select **"Any iOS Device"** (not simulator) from device dropdown
   - Product → Scheme → Edit Scheme...
   - Select **"Archive"** in left sidebar
   - Build Configuration: **Release**
   - Close the dialog

3. **Create Archive:**
   - Product → Archive
   - Wait for completion (5-15 minutes)

4. **Distribute:**
   - Window → Organizer (or Xcode → Organizer)
   - Select your archive
   - Click **Distribute App**
   - Choose **App Store Connect**
   - Follow the prompts

## ✅ Solution 4: Restart Mac

If the above doesn't work, restart your Mac:

1. Save all work
2. **Restart** Mac completely (not just logout)
3. After restart:
   - Open Xcode
   - Verify Full Disk Access is still enabled
   - Try Archive again

## ✅ Solution 5: Check macOS Version

macOS 26.1 appears to be a beta version with stricter sandbox rules:

```bash
sw_vers
```

If you're on a beta version:
- Consider updating to stable macOS version
- Or wait for macOS/Xcode updates that fix sandbox issues

## 🔍 Diagnostic Commands

Check if Xcode has proper permissions:

```bash
# Check Xcode version
xcodebuild -version

# Check DerivedData permissions
ls -la ~/Library/Developer/Xcode/DerivedData/

# Check sandbox logs (in Console.app)
# Open Console.app → Search for "sandbox" and "rsync"
```

## ⚠️ Important Notes

- **Full Disk Access is REQUIRED** for Xcode to read/write files during build
- Without it, rsync (used for copying build artifacts) will fail
- macOS 26.1 beta may have additional restrictions
- Archive method often bypasses sandbox issues better than command-line builds

## 📝 Quick Checklist

- [ ] Xcode added to Full Disk Access (enabled)
- [ ] Terminal added to Full Disk Access (if using command line)
- [ ] Xcode restarted after enabling Full Disk Access
- [ ] DerivedData cleaned
- [ ] Flutter clean and pub get completed
- [ ] Pods reinstalled
- [ ] Tried Archive in Xcode (not command line)
- [ ] Mac restarted if issues persist

---

**Most likely solution:** Enable Full Disk Access for Xcode and restart Xcode. This fixes 90% of rsync sandbox errors.

