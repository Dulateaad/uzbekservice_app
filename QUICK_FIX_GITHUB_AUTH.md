# ⚡ Quick Fix: GitHub Authentication

## 🚨 The Error:

```
Password authentication is not supported for Git operations.
```

GitHub requires a **Personal Access Token** or **SSH keys** instead of password.

---

## ✅ Quick Solution (2 Options):

### Option 1: Use Personal Access Token (Easiest - 2 minutes)

1. **Create token:**
   - Go to: https://github.com/settings/tokens
   - Click **Generate new token** → **Generate new token (classic)**
   - Name: `uzbekservice_app`
   - Expiration: `90 days`
   - Check: ✅ `repo` ✅ `workflow`
   - Click **Generate token**
   - **COPY THE TOKEN** (you won't see it again!)

2. **Use token as password:**
   ```bash
   git push
   ```
   - Username: `Dulateaad`
   - Password: `[paste your token]`

**Done!** The token will be saved for future pushes.

---

### Option 2: Use SSH Keys (More Secure - 5 minutes)

Run the setup script:

```bash
cd ~/uzbekservice_app
./setup_github_auth.sh
```

Choose option 2 and follow the prompts.

---

## 🎯 Recommended: Use the Script

```bash
cd ~/uzbekservice_app
./setup_github_auth.sh
```

The script will guide you through either method!

---

## 📋 After Authentication:

Once authenticated, you can push:

```bash
git add .github/workflows/ios_build.yml
git commit -m "Add GitHub Actions iOS build workflow"
git push
```

Then your iOS app will build automatically in GitHub Actions! 🚀

---

## 💡 Which Method to Choose?

- **Personal Access Token**: Faster setup, works immediately
- **SSH Keys**: More secure, no expiration, better for long-term

Both work perfectly for pushing code to GitHub!

