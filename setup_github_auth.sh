#!/bin/bash

# GitHub Authentication Setup Script

clear
echo "==================================================================="
echo "  🔐 GitHub Authentication Setup"
echo "==================================================================="
echo ""

echo "GitHub no longer accepts passwords. We need to set up authentication."
echo ""
echo "Choose your method:"
echo ""
echo "1) Personal Access Token (PAT) - Easier, recommended"
echo "2) SSH Keys - More secure, better long-term"
echo ""
read -p "Enter choice (1 or 2): " choice

case $choice in
  1)
    echo ""
    echo "==================================================================="
    echo "  📝 Personal Access Token Setup"
    echo "==================================================================="
    echo ""
    echo "Step 1: Create a token at:"
    echo "  https://github.com/settings/tokens"
    echo ""
    echo "Step 2: Click 'Generate new token (classic)'"
    echo ""
    echo "Step 3: Settings:"
    echo "  - Name: uzbekservice_app"
    echo "  - Expiration: 90 days (or your choice)"
    echo "  - Scopes: Check 'repo' and 'workflow'"
    echo ""
    echo "Step 4: Generate and COPY the token"
    echo ""
    read -p "Have you created the token? (y/n): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
      echo ""
      echo "Please create the token first, then run this script again."
      exit 1
    fi
    
    echo ""
    echo "Step 5: Enter your token (it will be hidden):"
    read -s TOKEN
    
    if [ -z "$TOKEN" ]; then
      echo "❌ Token cannot be empty!"
      exit 1
    fi
    
    echo ""
    echo "Updating remote URL with token..."
    git remote set-url origin https://$TOKEN@github.com/Dulateaad/uzbekservice_app.git
    
    echo ""
    echo "✅ Remote URL updated!"
    echo ""
    echo "Testing connection..."
    git ls-remote origin > /dev/null 2>&1
    
    if [ $? -eq 0 ]; then
      echo "✅ Authentication successful!"
      echo ""
      echo "You can now push:"
      echo "  git push"
    else
      echo "❌ Authentication failed. Please check your token."
      exit 1
    fi
    ;;
    
  2)
    echo ""
    echo "==================================================================="
    echo "  🔑 SSH Key Setup"
    echo "==================================================================="
    echo ""
    
    # Check for existing key
    if [ -f ~/.ssh/id_ed25519.pub ] || [ -f ~/.ssh/id_rsa.pub ]; then
      echo "Found existing SSH key!"
      PUBKEY=$(ls ~/.ssh/id_*.pub | head -1)
      echo ""
      echo "Your public key is:"
      echo "----------------------------------------"
      cat $PUBKEY
      echo "----------------------------------------"
      echo ""
      echo "Copy the key above and add it to GitHub:"
      echo "  https://github.com/settings/keys"
      echo ""
      read -p "Have you added the key to GitHub? (y/n): " -n 1 -r
      echo
      if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Please add the key first, then run this script again."
        exit 1
      fi
    else
      echo "No SSH key found. Generating one..."
      echo ""
      read -p "Enter your email for the key: " EMAIL
      
      if [ -z "$EMAIL" ]; then
        EMAIL="Dulateaad@users.noreply.github.com"
      fi
      
      ssh-keygen -t ed25519 -C "$EMAIL" -f ~/.ssh/id_ed25519 -N ""
      
      echo ""
      echo "✅ SSH key generated!"
      echo ""
      echo "Your public key is:"
      echo "----------------------------------------"
      cat ~/.ssh/id_ed25519.pub
      echo "----------------------------------------"
      echo ""
      echo "Copy the key above and add it to GitHub:"
      echo "  https://github.com/settings/keys"
      echo ""
      echo "Steps:"
      echo "  1. Click 'New SSH key'"
      echo "  2. Title: MacBook Air"
      echo "  3. Paste the key"
      echo "  4. Click 'Add SSH key'"
      echo ""
      read -p "Have you added the key to GitHub? (y/n): " -n 1 -r
      echo
      if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Please add the key first, then run this script again."
        exit 1
      fi
    fi
    
    echo ""
    echo "Testing SSH connection..."
    ssh -T git@github.com -o StrictHostKeyChecking=no 2>&1 | grep -q "successfully authenticated"
    
    if [ $? -eq 0 ]; then
      echo "✅ SSH connection successful!"
      echo ""
      echo "Updating remote URL to use SSH..."
      git remote set-url origin git@github.com:Dulateaad/uzbekservice_app.git
      echo "✅ Remote URL updated!"
      echo ""
      echo "You can now push:"
      echo "  git push"
    else
      echo "⚠️  SSH test returned unexpected result."
      echo "Trying to update remote URL anyway..."
      git remote set-url origin git@github.com:Dulateaad/uzbekservice_app.git
      echo "✅ Remote URL updated to SSH."
      echo ""
      echo "Try pushing: git push"
      echo "If it fails, check: https://github.com/settings/keys"
    fi
    ;;
    
  *)
    echo "Invalid choice. Exiting."
    exit 1
    ;;
esac

echo ""

