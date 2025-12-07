#!/bin/bash

echo "╔══════════════════════════════════════════════════════════════╗"
echo "║  📦 Установка CocoaPods через Homebrew                      ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo ""

# Проверяем Homebrew
if ! command -v brew &> /dev/null; then
    echo "📥 Homebrew не установлен. Устанавливаю..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    
    # Добавляем Homebrew в PATH (для Apple Silicon Mac)
    if [ -f /opt/homebrew/bin/brew ]; then
        echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zshrc
        eval "$(/opt/homebrew/bin/brew shellenv)"
    fi
else
    echo "✅ Homebrew уже установлен"
fi

echo ""
echo "📦 Устанавливаю CocoaPods..."
brew install cocoapods

echo ""
echo "✅ Проверяю установку..."
pod --version

echo ""
echo "✅ CocoaPods установлен!"
echo ""
echo "Теперь выполните:"
echo "  cd ios && pod install && cd .."
