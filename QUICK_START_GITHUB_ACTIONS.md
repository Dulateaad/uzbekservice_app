# 🚀 Quick Start: GitHub Actions for iOS Builds

## ✅ What This Does:

Builds your iOS app in GitHub's cloud Mac runners - **no local sandbox issues!**

---

## 📋 Setup (5 Minutes):

### Step 1: Push Code to GitHub

If you don't have a GitHub repository yet:

```bash
cd ~/uzbekservice_app

# Initialize git (if not already)
git init

# Add the workflow file
git add .github/workflows/ios_build.yml
git add GITHUB_ACTIONS_SETUP.md

# Commit
git commit -m "Add GitHub Actions iOS build workflow"

# Create repo on GitHub first, then:
git remote add origin https://github.com/YOUR_USERNAME/REPO_NAME.git
git branch -M main
git push -u origin main
```

If you already have a GitHub repo:

```bash
cd ~/uzbekservice_app
git add .github/workflows/ios_build.yml
git commit -m "Add GitHub Actions iOS build workflow"
git push
```

### Step 2: Wait for Build

1. Go to your GitHub repository
2. Click **Actions** tab
3. Watch the build run automatically!

### Step 3: Download IPA

After build completes (10-15 minutes):

1. In **Actions** tab, click on the completed workflow
2. Scroll down to **Artifacts**
3. Click **ios-ipa** to download
4. Upload to TestFlight using **Transporter** app

---

## 🎯 Manual Trigger:

You can also trigger builds manually:

1. Go to **Actions** tab
2. Click **Build iOS IPA** in left sidebar
3. Click **Run workflow** button
4. Select branch and click **Run workflow**

---

## 💡 Benefits:

✅ **Free** for public repositories  
✅ **Free** 2000 minutes/month for private repos  
✅ **No local build issues** - builds in clean cloud  
✅ **Automatic** - builds on every push  
✅ **Download IPA** directly from GitHub  

---

## 📦 What Gets Built:

- Release IPA file
- Ready for TestFlight upload
- Same as local build, but in cloud!

---

## 🔧 Customize:

Edit `.github/workflows/ios_build.yml` to:
- Change Flutter version
- Add environment variables
- Change build branches

---

**That's it! Push your code and watch it build in the cloud! 🎉**

