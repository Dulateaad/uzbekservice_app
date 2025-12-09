# ⚡ Быстрая настройка GitHub Actions для TestFlight

## 🎯 3 простых шага:

### 1️⃣ Создать App-Specific Password (2 минуты)

1. Откройте: **https://appleid.apple.com**
2. Войдите → **Безопасность** → **Пароли для приложений**
3. **Создайте пароль** с названием `GitHub Actions`
4. **Скопируйте пароль** (формат: `xxxx-xxxx-xxxx-xxxx`)

### 2️⃣ Добавить Secrets в GitHub (3 минуты)

1. Откройте: **https://github.com/Dulateaad/uzbekservice_app/settings/secrets/actions**
2. Нажмите **"New repository secret"** и добавьте 3 секрета:

   **APPLE_ID**
   - Name: `APPLE_ID`
   - Value: ваш email Apple ID

   **APPLE_ID_PASSWORD**
   - Name: `APPLE_ID_PASSWORD`  
   - Value: пароль из шага 1

   **TEAM_ID**
   - Name: `TEAM_ID`
   - Value: `YQL6CG483C`

### 3️⃣ Запустить сборку (1 минута)

1. Откройте: **https://github.com/Dulateaad/uzbekservice_app/actions**
2. Выберите **"Build iOS IPA"**
3. Нажмите **"Run workflow"** → **"Run workflow"**
4. Дождитесь завершения (10-20 минут)

### 4️⃣ Скачать и загрузить IPA

1. После завершения → откройте workflow run
2. Прокрутите вниз → **Artifacts** → скачайте **"ios-ipa"**
3. Распакуйте → откройте **Transporter** app
4. Перетащите `.ipa` файл → нажмите **"Deliver"**

---

## ✅ Готово!

После загрузки проверьте в App Store Connect:
**https://appstoreconnect.apple.com** → TestFlight

---

## 🔗 Прямые ссылки:

- **Secrets:** https://github.com/Dulateaad/uzbekservice_app/settings/secrets/actions
- **Actions:** https://github.com/Dulateaad/uzbekservice_app/actions
- **Apple ID:** https://appleid.apple.com

