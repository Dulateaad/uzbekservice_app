# Быстрый доступ через интернет

## Вариант 1: Serveo (без установки, мгновенно) ⚡

### Использование:

1. **Запустите приложение** (в одном терминале):
   ```bash
   flutter run -d chrome --web-port=8112
   ```

2. **Откройте другой терминал** и выполните:
   ```bash
   ssh -R 80:localhost:8112 serveo.net
   ```

3. **Скопируйте URL** который появится (например: `https://abc123.serveo.net`)

4. **Поделитесь ссылкой** - теперь любой может открыть приложение!

**Преимущества:**
- ✅ Не требует установки
- ✅ Работает сразу
- ✅ HTTPS автоматически
- ✅ Бесплатно

**Недостатки:**
- ⚠️ URL меняется при каждом запуске
- ⚠️ Работает пока терминал открыт

---

## Вариант 2: Установка Firebase CLI и деплой

### Шаг 1: Установка Firebase CLI

**Через npm (если установлен Node.js):**
```bash
npm install -g firebase-tools
```

**Или через официальный установщик:**
```bash
curl -sL https://firebase.tools | bash
```

### Шаг 2: Вход в Firebase

```bash
firebase login
```

Откроется браузер для авторизации.

### Шаг 3: Деплой

```bash
cd /Users/dulat/uzbekservice_app
./deploy.sh
```

Или вручную:
```bash
flutter build web --release
firebase deploy --only hosting
```

### Доступ:
После деплоя приложение будет доступно по адресу:
- `https://studio-3898272712-a12a4.web.app`
- `https://studio-3898272712-a12a4.firebaseapp.com`

**Преимущества:**
- ✅ Постоянный URL
- ✅ HTTPS автоматически
- ✅ Бесплатно
- ✅ Быстрый доступ

---

## Вариант 3: Cloudflare Tunnel (рекомендуется)

### Установка:

Скачайте с https://developers.cloudflare.com/cloudflare-one/connections/connect-apps/install-and-setup/installation/

Или через curl:
```bash
curl -L https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-darwin-amd64 -o cloudflared
chmod +x cloudflared
sudo mv cloudflared /usr/local/bin/
```

### Использование:

1. Запустите приложение:
   ```bash
   flutter run -d chrome --web-port=8112
   ```

2. В другом терминале:
   ```bash
   cloudflared tunnel --url http://localhost:8112
   ```

3. Скопируйте URL из вывода

---

## Самый быстрый способ (прямо сейчас):

```bash
# Терминал 1: Запустите приложение
flutter run -d chrome --web-port=8112

# Терминал 2: Создайте туннель
ssh -R 80:localhost:8112 serveo.net
```

Скопируйте URL и поделитесь!

