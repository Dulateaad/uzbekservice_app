# 🚀 Настройка GitHub Actions для сборки IPA

## 📋 Что нужно сделать:

### Шаг 1: Создать App-Specific Password для Apple ID

1. Откройте: **https://appleid.apple.com**
2. Войдите в свой Apple ID
3. Перейдите в **"Безопасность"** → **"Пароли для приложений"**
4. Нажмите **"Создать пароль для приложений"**
5. Введите название: `GitHub Actions`
6. **СКОПИРУЙТЕ ПАРОЛЬ** (он показывается только один раз!)
   - Формат: `xxxx-xxxx-xxxx-xxxx`

### Шаг 2: Добавить Secrets в GitHub

1. Перейдите: **https://github.com/Dulateaad/uzbekservice_app/settings/secrets/actions**
2. Нажмите **"New repository secret"** и добавьте:

#### Secret 1: APPLE_ID
- **Name:** `APPLE_ID`
- **Value:** Ваш email Apple ID (например: `your.email@example.com`)

#### Secret 2: APPLE_ID_PASSWORD  
- **Name:** `APPLE_ID_PASSWORD`
- **Value:** App-Specific Password из Шага 1 (не обычный пароль!)

#### Secret 3: TEAM_ID
- **Name:** `TEAM_ID`
- **Value:** `YQL6CG483C` (ваш Team ID)

### Шаг 3: Запустить сборку

1. Перейдите: **https://github.com/Dulateaad/uzbekservice_app/actions**
2. Выберите workflow **"Build iOS IPA"**
3. Нажмите **"Run workflow"** → **"Run workflow"**
4. Дождитесь завершения (10-20 минут)

### Шаг 4: Скачать IPA

1. После завершения сборки откройте workflow run
2. Прокрутите вниз до раздела **"Artifacts"**
3. Нажмите **"ios-ipa"** для скачивания
4. Распакуйте архив - внутри будет `.ipa` файл

### Шаг 5: Загрузить в TestFlight

1. Откройте **Transporter** app (из Mac App Store)
2. Перетащите `.ipa` файл в окно
3. Нажмите **"Deliver"**
4. Дождитесь загрузки (5-10 минут)
5. Проверьте в App Store Connect: **https://appstoreconnect.apple.com**

---

## ⚠️ Важно:

- **App-Specific Password** показывается только один раз - сохраните его!
- Используйте **App-Specific Password**, а не обычный пароль Apple ID
- Team ID уже известен: `YQL6CG483C`
- Первая сборка может занять больше времени

---

## 🔗 Полезные ссылки:

- **GitHub Actions:** https://github.com/Dulateaad/uzbekservice_app/actions
- **Secrets:** https://github.com/Dulateaad/uzbekservice_app/settings/secrets/actions
- **App Store Connect:** https://appstoreconnect.apple.com
- **Apple ID:** https://appleid.apple.com

---

**После настройки secrets, запустите workflow!**

