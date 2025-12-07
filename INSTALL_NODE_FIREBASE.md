# 📦 Установка Node.js и Firebase CLI для Cloud Functions

## 🍎 macOS (через Homebrew)

### 1. Установите Homebrew (если еще не установлен)
```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

### 2. Установите Node.js
```bash
brew install node
```

Проверьте установку:
```bash
node --version  # Должно быть v18 или выше
npm --version
```

### 3. Установите Firebase CLI
```bash
npm install -g firebase-tools
```

Проверьте установку:
```bash
firebase --version
```

### 4. Авторизуйтесь в Firebase
```bash
firebase login
```

Откроется браузер для авторизации.

### 5. Выберите проект
```bash
cd ~/uzbekservice_app
firebase use odo-uz-1f4d9
```

## 🐧 Linux / Windows

### Node.js
- **Linux**: `sudo apt install nodejs npm` (Ubuntu/Debian) или используйте nvm
- **Windows**: Скачайте установщик с https://nodejs.org/

### Firebase CLI
```bash
npm install -g firebase-tools
```

## ✅ Проверка установки

После установки выполните:
```bash
node --version    # Должно быть v18+
npm --version     # Должно быть v9+
firebase --version # Должна быть последняя версия
```

## 🚀 Развертывание функций

После установки всех зависимостей:

```bash
cd ~/uzbekservice_app
./deploy_functions.sh
```

Или вручную:
```bash
cd ~/uzbekservice_app/functions
npm install
cd ..
firebase deploy --only functions
```

## 🔧 Альтернатива: Использование nvm (Node Version Manager)

Если хотите использовать nvm для управления версиями Node.js:

```bash
# Установите nvm
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash

# Перезагрузите терминал или выполните:
source ~/.nvm/nvm.sh

# Установите Node.js 18
nvm install 18
nvm use 18

# Установите Firebase CLI
npm install -g firebase-tools
```

## 📚 Дополнительные ресурсы

- [Node.js Downloads](https://nodejs.org/)
- [Firebase CLI Documentation](https://firebase.google.com/docs/cli)
- [Homebrew](https://brew.sh/)

