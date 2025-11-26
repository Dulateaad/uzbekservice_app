# Доступ к приложению через интернет

## Вариант 1: ngrok (быстро, временно) ⚡

### Установка ngrok:

**Способ 1: Через официальный сайт**
1. Откройте https://ngrok.com/download
2. Скачайте для macOS
3. Распакуйте и переместите в `/usr/local/bin`:
   ```bash
   sudo mv ngrok /usr/local/bin/
   sudo chmod +x /usr/local/bin/ngrok
   ```

**Способ 2: Через Homebrew (если установлен)**
```bash
brew install ngrok/ngrok/ngrok
```

### Регистрация (бесплатно):
1. Зарегистрируйтесь на https://dashboard.ngrok.com/signup
2. Получите authtoken из Dashboard
3. Настройте:
   ```bash
   ngrok config add-authtoken YOUR_AUTHTOKEN
   ```

### Использование:

1. **Запустите приложение** (в одном терминале):
   ```bash
   flutter run -d chrome --web-port=8112
   ```

2. **Запустите ngrok** (в другом терминале):
   ```bash
   ngrok http 8112
   ```

3. **Скопируйте URL** из ngrok (например: `https://abc123.ngrok-free.app`)

4. **Поделитесь ссылкой** - теперь любой может открыть приложение через интернет!

### Ограничения бесплатного плана:
- ⚠️ URL меняется при каждом запуске (если не использовать статический домен)
- ⚠️ Ограничение по времени сессии
- ⚠️ Ограничение по количеству запросов

---

## Вариант 2: Firebase Hosting (рекомендуется для production) 🚀

### Шаг 1: Установка Firebase CLI

```bash
# Через npm (если установлен Node.js)
npm install -g firebase-tools

# Или через официальный установщик
curl -sL https://firebase.tools | bash
```

### Шаг 2: Вход в Firebase

```bash
firebase login
```

### Шаг 3: Инициализация Hosting

```bash
cd /Users/dulat/uzbekservice_app
firebase init hosting
```

Выберите:
- **Use an existing project:** `studio-3898272712-a12a4`
- **What do you want to use as your public directory?** `build/web`
- **Configure as a single-page app?** `Yes`
- **Set up automatic builds and deploys with GitHub?** `No` (пока)

### Шаг 4: Сборка и деплой

```bash
# Сборка для production
flutter build web --release

# Деплой на Firebase Hosting
firebase deploy --only hosting
```

### Доступ:
После деплоя приложение будет доступно по адресу:
- `https://studio-3898272712-a12a4.web.app`
- `https://studio-3898272712-a12a4.firebaseapp.com`

### Автоматический деплой при изменениях:

Создайте скрипт `deploy.sh`:
```bash
#!/bin/bash
echo "🔨 Сборка приложения..."
flutter build web --release

echo "🚀 Деплой на Firebase Hosting..."
firebase deploy --only hosting

echo "✅ Готово! Приложение доступно по адресу:"
echo "https://studio-3898272712-a12a4.web.app"
```

---

## Вариант 3: Cloudflare Tunnel (бесплатно, постоянно) 🌐

### Установка:

```bash
# Скачайте с https://developers.cloudflare.com/cloudflare-one/connections/connect-apps/install-and-setup/installation/
# Или через Homebrew
brew install cloudflare/cloudflare/cloudflared
```

### Использование:

```bash
# Запустите приложение
flutter run -d chrome --web-port=8112

# В другом терминале запустите туннель
cloudflared tunnel --url http://localhost:8112
```

---

## Вариант 4: Serveo (без установки) 🔗

```bash
# Запустите приложение
flutter run -d chrome --web-port=8112

# В другом терминале
ssh -R 80:localhost:8112 serveo.net
```

---

## Рекомендации

### Для быстрого тестирования:
→ **Вариант 1** (ngrok) или **Вариант 3** (Cloudflare Tunnel)

### Для production:
→ **Вариант 2** (Firebase Hosting)

### Для постоянного доступа без изменений:
→ **Вариант 2** (Firebase Hosting) - URL не меняется

---

## Быстрый старт с ngrok

1. Установите ngrok (см. выше)
2. Зарегистрируйтесь и получите authtoken
3. Запустите приложение:
   ```bash
   flutter run -d chrome --web-port=8112
   ```
4. В другом терминале:
   ```bash
   ngrok http 8112
   ```
5. Скопируйте HTTPS URL из ngrok и поделитесь!

---

## Настройка Firebase Hosting (детально)

После `firebase init hosting` создастся файл `firebase.json`:

```json
{
  "hosting": {
    "public": "build/web",
    "ignore": [
      "firebase.json",
      "**/.*",
      "**/node_modules/**"
    ],
    "rewrites": [
      {
        "source": "**",
        "destination": "/index.html"
      }
    ]
  }
}
```

После каждого изменения:
```bash
flutter build web --release
firebase deploy --only hosting
```

Приложение будет доступно по постоянному URL!

