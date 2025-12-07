# Настройка Firebase для iOS

## 📱 Информация о проекте

- **Bundle ID**: `com.example.uzbekserviceApp`
- **Firebase проект**: `odo-uz-1f4d9`
- **Project number**: `747555139152`

## 🚀 Пошаговая инструкция

### Шаг 1: Получить GoogleService-Info.plist из Firebase Console

1. Откройте [Firebase Console](https://console.firebase.google.com/)
2. Выберите проект **odo-uz-1f4d9**
3. Нажмите на **шестеренку (⚙️)** → **"Project settings"**
4. В разделе **"Your apps"** найдите iOS приложение или нажмите **"Add app"** → **iOS**

#### Если iOS приложение еще НЕ добавлено:
1. Введите:
   - **Bundle ID**: `com.example.uzbekserviceApp`
   - **App nickname**: `Uzbekistan Service iOS` (опционально)
   - **App Store ID**: (можно оставить пустым)
2. Нажмите **"Register app"**
3. Скачайте файл **GoogleService-Info.plist**

#### Если iOS приложение уже добавлено:
1. Найдите приложение с иконкой iOS (🍎) в списке
2. Нажмите на него
3. Скачайте файл **GoogleService-Info.plist**

### Шаг 2: Добавить GoogleService-Info.plist в Xcode проект

#### Способ 1: Через Xcode (рекомендуется)

1. Откройте проект в Xcode:
   ```bash
   open ios/Runner.xcworkspace
   ```
   ⚠️ **ВАЖНО**: Используйте `.xcworkspace`, а не `.xcodeproj`!

2. В Xcode:
   - Найдите папку **Runner** в левой панели (Project Navigator)
   - **Перетащите** файл `GoogleService-Info.plist` из Finder в папку **Runner**
   - В диалоге выберите:
     - ✅ **"Copy items if needed"**
     - ✅ **"Add to targets: Runner"**
   - Нажмите **"Finish"**

3. Проверьте, что файл добавлен:
   - Файл должен появиться в папке Runner
   - В правой панели (File Inspector) убедитесь, что **Target Membership** → **Runner** отмечен

#### Способ 2: Через терминал (альтернативный)

```bash
cd ~/uzbekservice_app

# Скопируйте файл в папку Runner
cp ~/Downloads/GoogleService-Info.plist ios/Runner/

# Откройте Xcode и добавьте файл в проект вручную
open ios/Runner.xcworkspace
```

### Шаг 3: Установить CocoaPods зависимости

```bash
cd ~/uzbekservice_app/ios
pod install
cd ..
```

### Шаг 4: Проверка

```bash
# Проверьте, что файл на месте
ls -la ios/Runner/GoogleService-Info.plist

# Должно показать что-то вроде:
# -rw-r--r--@ 1 dulatea staff 1234 Nov 29 16:30 ios/Runner/GoogleService-Info.plist
```

## ✅ Проверка конфигурации

### Проверка Bundle ID

Убедитесь, что Bundle ID в `GoogleService-Info.plist` совпадает с Bundle ID в Xcode:

```bash
# Проверка Bundle ID в GoogleService-Info.plist
grep -A 1 "BUNDLE_ID" ios/Runner/GoogleService-Info.plist

# Проверка Bundle ID в Xcode проекте
grep "PRODUCT_BUNDLE_IDENTIFIER" ios/Runner.xcodeproj/project.pbxproj | head -1
```

Оба должны показывать: `com.example.uzbekserviceApp`

## 🧪 Тестирование

1. Запустите приложение на iOS симуляторе или устройстве:
   ```bash
   flutter run
   ```

2. Проверьте логи - должно появиться:
   ```
   ✅ Firebase инициализирован успешно!
   🔐 Готов к аутентификации пользователей
   ```

## 🔧 Настройка для Phone Authentication на iOS

### Шаг 1: Настроить APNs (Apple Push Notification service)

Для работы Phone Authentication на iOS требуется APNs:

1. В Firebase Console → Project Settings → Cloud Messaging
2. В разделе **Apple app configuration**:
   - Загрузите **APNs Authentication Key** (.p8 файл)
   - Или загрузите **APNs Certificates** (.p12 файл)

### Шаг 2: Настроить Capabilities в Xcode

1. Откройте `ios/Runner.xcworkspace` в Xcode
2. Выберите проект **Runner** в левой панели
3. Выберите target **Runner**
4. Перейдите на вкладку **"Signing & Capabilities"**
5. Нажмите **"+ Capability"** и добавьте:
   - **Push Notifications** (если нужно)
   - **Background Modes** → **Remote notifications** (если нужно)

## ⚠️ Важные моменты

### Используйте .xcworkspace, а не .xcodeproj

⚠️ **ВАЖНО**: Всегда открывайте проект через `.xcworkspace`:
```bash
open ios/Runner.xcworkspace  # ✅ Правильно
open ios/Runner.xcodeproj     # ❌ Неправильно
```

### Проверка файла в Xcode

После добавления файла убедитесь:
1. Файл виден в Project Navigator
2. Файл добавлен в Target "Runner"
3. Файл не в красном цвете (не отсутствует)

### Очистка и пересборка

Если возникают проблемы:
```bash
cd ~/uzbekservice_app
flutter clean
cd ios
rm -rf Pods Podfile.lock
pod install
cd ..
flutter pub get
```

## 🐛 Решение проблем

### Проблема: "GoogleService-Info.plist not found"
**Решение**: 
- Убедитесь, что файл находится в `ios/Runner/GoogleService-Info.plist`
- Проверьте, что файл добавлен в Target "Runner" в Xcode

### Проблема: "FirebaseApp not initialized"
**Решение**: 
- Убедитесь, что `FirebaseConfig.initialize()` вызывается в `main()` до `runApp()`
- Проверьте, что файл `GoogleService-Info.plist` правильно добавлен в проект

### Проблема: "CocoaPods not installed"
**Решение**: 
```bash
sudo gem install cocoapods
cd ios
pod install
```

### Проблема: "No such module 'FirebaseCore'"
**Решение**: 
```bash
cd ios
pod deintegrate
pod install
cd ..
flutter clean
flutter pub get
```

## 📝 Следующие шаги

После настройки iOS:

1. ✅ Настроить Phone Authentication для iOS
2. ✅ Настроить APNs для push-уведомлений
3. ✅ Протестировать вход через SMS на iOS устройстве
4. ✅ Настроить правила безопасности Firestore
5. ✅ Настроить правила Storage

## 🔗 Полезные ссылки

- [Firebase Console - iOS App](https://console.firebase.google.com/project/odo-uz-1f4d9/settings/general/ios:com.example.uzbekserviceApp)
- [Firebase iOS Setup Guide](https://firebase.google.com/docs/ios/setup)
- [CocoaPods Guide](https://guides.cocoapods.org/)

