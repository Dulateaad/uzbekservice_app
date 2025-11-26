# Установка Firebase CLI для деплоя

## Способ 1: Официальный установщик (рекомендуется, не требует Node.js)

```bash
curl -sL https://firebase.tools | bash
```

После установки перезапустите терминал или выполните:
```bash
source ~/.zshrc
# или
source ~/.bash_profile
```

Проверка:
```bash
firebase --version
```

## Способ 2: Через Homebrew (если установлен)

```bash
brew install firebase-cli
```

## Способ 3: Через npm (если установлен Node.js)

```bash
npm install -g firebase-tools
```

## После установки

1. Войдите в Firebase:
   ```bash
   firebase login
   ```

2. Выберите проект:
   ```bash
   firebase use studio-3898272712-a12a4
   ```

3. Задеплойте приложение:
   ```bash
   ./deploy.sh
   ```

## Быстрый деплой

После установки Firebase CLI просто выполните:
```bash
cd /Users/dulat/uzbekservice_app
./deploy.sh
```

Приложение будет доступно по адресу:
- https://studio-3898272712-a12a4.web.app
- https://studio-3898272712-a12a4.firebaseapp.com

