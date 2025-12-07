# 🚀 GitHub Actions Setup for iOS Builds

## ✅ Why Use GitHub Actions?

- **Free** for public repositories
- **Free** 2000 minutes/month for private repositories
- **No local sandbox issues** - builds in clean cloud environment
- **Automatic builds** on every push
- **No Mac required** - builds in GitHub's cloud Mac runners

---

## 📋 Setup Instructions

### Step 1: Create GitHub Repository

If you don't have one yet:

1. Go to https://github.com/new
2. Create a new repository
3. Name it (e.g., `uzbekservice_app`)
4. Choose public (free) or private (free tier available)

### Step 2: Push Your Code

```bash
cd ~/uzbekservice_app

# Initialize git if not already done
git init

# Add all files
git add .

# Commit
git commit -m "Initial commit"

# Add remote (replace YOUR_USERNAME and REPO_NAME)
git remote add origin https://github.com/YOUR_USERNAME/REPO_NAME.git

# Push to GitHub
git branch -M main
git push -u origin main
```

### Step 3: Add Secrets (For Code Signing)

If your app needs code signing for TestFlight:

1. Go to your GitHub repository
2. Click **Settings** → **Secrets and variables** → **Actions**
3. Click **New repository secret**
4. Add these secrets:

   - `APPLE_ID`: Your Apple Developer account email
   - `APPLE_ID_PASSWORD`: App-specific password (create at appleid.apple.com)
   - `TEAM_ID`: Your Apple Developer Team ID (YQL6CG483C)
   - `MATCH_PASSWORD`: If using fastlane match (optional)

### Step 4: Trigger Build

The workflow will automatically run when you:
- Push to `main`, `master`, or `develop` branches
- Create a pull request
- Manually trigger from **Actions** tab → **Build iOS IPA** → **Run workflow**

---

## 📦 Downloading the IPA

After build completes:

1. Go to your GitHub repository
2. Click **Actions** tab
3. Click on the completed workflow run
4. Scroll down to **Artifacts**
5. Click **ios-ipa** to download
6. Upload to TestFlight using **Transporter** app

---

## 🔧 Customizing the Workflow

Edit `.github/workflows/ios_build.yml` to:

- Change Flutter version
- Add environment variables
- Change build configuration
- Add code signing (see below)

---

## 🔐 Adding Code Signing

If you need automatic code signing, update the workflow:

```yaml
- name: Setup code signing
  run: |
    # Install fastlane if needed
    sudo gem install fastlane
    
    # Setup certificates and profiles
    # (Configure based on your setup)

- name: Build IPA with signing
  run: flutter build ipa --release
  env:
    APPLE_ID: ${{ secrets.APPLE_ID }}
    APPLE_ID_PASSWORD: ${{ secrets.APPLE_ID_PASSWORD }}
    TEAM_ID: ${{ secrets.TEAM_ID }}
```

---

## 🎯 Quick Start Commands

### Push code to GitHub:

```bash
cd ~/uzbekservice_app

# Add the workflow file
git add .github/workflows/ios_build.yml

# Commit
git commit -m "Add iOS build workflow"

# Push
git push
```

### Check build status:

1. Go to: `https://github.com/YOUR_USERNAME/REPO_NAME/actions`
2. See build progress in real-time
3. Download IPA when complete

---

## 💡 Benefits

✅ **No local build issues** - cloud Mac runners  
✅ **Free** for public repos, free tier for private  
✅ **Automatic** - builds on every push  
✅ **Reliable** - clean environment every time  
✅ **Download IPA** directly from GitHub  

---

## 📋 Workflow File Location

The workflow file is at:
```
.github/workflows/ios_build.yml
```

You can edit it to customize the build process.

---

## ⚠️ Important Notes

- **Public repos**: Unlimited free minutes
- **Private repos**: 2000 free minutes/month (usually enough for ~30 builds)
- **Build time**: ~10-15 minutes per build
- **IPA download**: Available for 30 days after build

---

## 🆘 Troubleshooting

### Build fails?

1. Check **Actions** tab for error logs
2. Check build logs in the artifact
3. Verify Flutter version in workflow matches your local version
4. Check CocoaPods installation step

### Need different Flutter version?

Edit `.github/workflows/ios_build.yml`:
```yaml
flutter-version: '3.38.3'  # Change to your version
```

### Need to build on specific branch?

Edit the trigger:
```yaml
on:
  push:
    branches: [ main, your-branch-name ]
```

---

**Ready to start? Push your code to GitHub and watch it build! 🚀**

