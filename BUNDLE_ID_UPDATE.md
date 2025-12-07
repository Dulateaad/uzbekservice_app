# 🔄 Обновление Bundle Identifier

## ❌ Проблема
Bundle ID `com.odo.uzapp` уже занят или недоступен.

## ✅ Решение
Изменен Bundle ID на: `com.odo.uzapp.dev`

## 📋 Что обновлено

1. ✅ **Xcode проект** (`ios/Runner.xcodeproj/project.pbxproj`)
   - Bundle Identifier: `com.odo.uzapp.dev`

2. ✅ **GoogleService-Info.plist**
   - BUNDLE_ID: `com.odo.uzapp.dev`

3. ✅ **firebase_options.dart**
   - iosBundleId: `com.odo.uzapp.dev`

## ⚠️ ВАЖНО: Обновите Firebase Console

Новый Bundle ID нужно добавить в Firebase Console:

### Шаг 1: Добавить iOS приложение в Firebase

1. Откройте: https://console.firebase.google.com/project/odo-uz-1f4d9/settings/general
2. В разделе **Your apps** нажмите **+ Add app** → **iOS**
3. Введите:
   - **iOS bundle ID**: `com.odo.uzapp.dev`
   - **App nickname** (опционально): `ODO.UZ Dev`
4. Нажмите **Register app**

### Шаг 2: Скачать новый GoogleService-Info.plist

1. После регистрации скачайте `GoogleService-Info.plist`
2. Замените файл: `ios/Runner/GoogleService-Info.plist`

### Шаг 3: Обновить firebase_options.dart

После скачивания нового `GoogleService-Info.plist`:
- Обновите `appId` в `lib/firebase_options.dart` (если изменился)
- Или используйте FlutterFire CLI для автоматического обновления:
  ```bash
  flutterfire configure
  ```

## 🔄 Альтернативные Bundle ID

Если `com.odo.uzapp.dev` тоже занят, попробуйте:

- `com.odo.uzapp.test`
- `com.odo.uzapp.beta`
- `com.yourname.odo.uzapp`
- `com.odo.uzapp.ios`

## 📝 После обновления

1. В Xcode проверьте Bundle Identifier: `com.odo.uzapp.dev`
2. Попробуйте снова настроить Signing & Capabilities
3. Соберите проект:
   ```bash
   flutter build ios --release
   ```

