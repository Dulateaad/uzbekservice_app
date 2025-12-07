# ✅ Чеклист для публикации в TestFlight

## 📋 Перед началом

- [ ] Apple Developer Account активирован ($99/год)
- [ ] Xcode установлен и обновлен
- [ ] Проект открывается в Xcode без ошибок

## 🔧 Настройка проекта

### Xcode
- [ ] Открыть `ios/Runner.xcworkspace` в Xcode
- [ ] Выбрать проект `Runner` → Target `Runner`
- [ ] Вкладка **Signing & Capabilities**:
  - [ ] Выбрать **Team** (ваш Apple Developer Team)
  - [ ] **Bundle Identifier**: `com.odo.uzapp` (уникальный)
  - [ ] Автоматически создастся сертификат и профиль

### Capabilities
- [ ] **Push Notifications** - включено
- [ ] **Background Modes** → **Remote notifications** - включено
- [ ] Проверить, что нет ошибок с сертификатами

### Версия
- [ ] **Version** (CFBundleShortVersionString): `1.0.0`
- [ ] **Build** (CFBundleVersion): `1` (увеличивать при каждой загрузке)

## 📱 App Store Connect

### Создание приложения
- [ ] Войти в https://appstoreconnect.apple.com
- [ ] **My Apps** → **+** → **New App**
- [ ] Заполнить:
  - [ ] **Platform**: iOS
  - [ ] **Name**: ODO.UZ
  - [ ] **Primary Language**: Russian
  - [ ] **Bundle ID**: `com.odo.uzapp` (создать в Apple Developer если нужно)
  - [ ] **SKU**: `odo-uz-app-ios`

### Информация о приложении
- [ ] **Description**: Описание приложения
- [ ] **Keywords**: ключевые слова (через запятую)
- [ ] **Support URL**: https://odo-uz-1f4d9.web.app
- [ ] **Privacy Policy URL**: https://odo-uz-1f4d9.web.app/privacy-policy.html
- [ ] **Marketing URL**: (опционально)

### Графика
- [ ] **App Icon**: 1024x1024 px (PNG, без прозрачности)
- [ ] **Screenshots**: минимум 3 для iPhone 6.7" (1290x2796 px)
- [ ] **Screenshots**: минимум 3 для iPhone 6.5" (1284x2778 px)
- [ ] **Screenshots**: минимум 3 для iPhone 5.5" (1242x2208 px)

## 🔨 Сборка

### Подготовка
- [ ] Выполнить: `./build_ios_release.sh`
- [ ] Или вручную:
  ```bash
  flutter clean
  flutter pub get
  cd ios && pod install && cd ..
  flutter build ios --release
  ```

### Архивация
- [ ] Открыть `ios/Runner.xcworkspace` в Xcode
- [ ] Выбрать **Any iOS Device** (не симулятор!)
- [ ] **Product** → **Archive**
- [ ] Дождаться завершения

### Загрузка
- [ ] В **Organizer** (Window → Organizer)
- [ ] Выбрать архив
- [ ] **Distribute App**
- [ ] **App Store Connect** → **Next**
- [ ] **Upload** → **Next**
- [ ] Выбрать опции:
  - [ ] **Include bitcode** (если доступно)
  - [ ] **Upload your app's symbols**
- [ ] **Upload**
- [ ] Дождаться завершения загрузки

## 🔔 Push-уведомления (APNs)

### Создание APNs Key
- [ ] Открыть: https://developer.apple.com/account/resources/authkeys/list
- [ ] **+** → создать новый ключ
- [ ] Название: `ODO.UZ Push Notifications`
- [ ] Выбрать **Apple Push Notifications service (APNs)**
- [ ] **Continue** → **Register**
- [ ] **Скачать** `.p8` файл (сохранить!)

### Загрузка в Firebase
- [ ] Открыть: https://console.firebase.google.com/project/odo-uz-1f4d9/settings/cloudmessaging
- [ ] В разделе **Apple app configuration**
- [ ] **Upload** рядом с **APNs Authentication Key**
- [ ] Загрузить `.p8` файл
- [ ] Ввести **Key ID** (из Apple Developer)
- [ ] Ввести **Team ID** (из Apple Developer)
- [ ] **Upload**

## 🧪 TestFlight

### Ожидание обработки
- [ ] Проверить статус в App Store Connect → TestFlight
- [ ] Дождаться обработки (15-30 минут)
- [ ] Статус должен быть "Ready to Test"

### Internal Testing
- [ ] Перейти в **TestFlight** → **Internal Testing**
- [ ] Добавить версию
- [ ] Члены команды автоматически получат доступ

### External Testing
- [ ] Перейти в **TestFlight** → **External Testing**
- [ ] Создать группу тестировщиков
- [ ] Добавить email адреса
- [ ] Заполнить **Beta App Review**:
  - [ ] **What to Test**: Инструкции для тестировщиков
  - [ ] **Contact Information**: Ваш email
  - [ ] **Demo Account**: (если нужно)
  - [ ] **Notes**: Дополнительная информация
- [ ] **Submit for Review**
- [ ] Дождаться одобрения (24-48 часов)

## ✅ Финальная проверка

- [ ] Приложение собирается без ошибок
- [ ] Все функции работают
- [ ] Push-уведомления работают
- [ ] Нет критических багов
- [ ] Версия и build number правильные
- [ ] Bundle Identifier уникальный
- [ ] Графика загружена
- [ ] Информация о приложении заполнена

## 📚 Полезные ссылки

- **App Store Connect**: https://appstoreconnect.apple.com
- **Apple Developer**: https://developer.apple.com/account
- **Firebase Console**: https://console.firebase.google.com/project/odo-uz-1f4d9
- **TestFlight**: https://appstoreconnect.apple.com/apps/{app_id}/testflight

