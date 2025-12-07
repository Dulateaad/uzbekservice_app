# Быстрая настройка Firebase для uzbekservice_app

## ✅ Что уже настроено

1. ✅ Google Services plugin добавлен в `android/settings.gradle.kts`
2. ✅ Google Services plugin применен в `android/app/build.gradle.kts`
3. ✅ Firebase проект настроен: `studio-3898272712-a12a4` (см. `.firebaserc`)
4. ✅ Код инициализации Firebase готов в `lib/config/firebase_config.dart`

## 📋 Что нужно сделать

### Шаг 1: Получить файлы конфигурации Firebase

#### Для Android:
1. Откройте [Firebase Console](https://console.firebase.google.com/)
2. Выберите проект `studio-3898272712-a12a4`
3. Перейдите в **Project Settings** (⚙️ → Project settings)
4. В разделе **Your apps** нажмите на иконку **Android** или **Add app** → **Android**
5. Введите:
   - **Package name**: `com.example.odo_uz_app`
   - **App nickname**: `Uzbekistan Service Android` (опционально)
6. Нажмите **"Register app"**
7. Скачайте файл `google-services.json`
8. **ВАЖНО**: Скопируйте `google-services.json` в папку `android/app/`

```bash
# После скачивания выполните:
cp ~/Downloads/google-services.json ~/uzbekservice_app/android/app/
```

#### Для iOS:
1. В Firebase Console в разделе **Your apps** нажмите **Add app** → **iOS**
2. Введите:
   - **Bundle ID**: `com.example.uzbekserviceApp`
   - **App nickname**: `Uzbekistan Service iOS` (опционально)
3. Нажмите **"Register app"**
4. Скачайте файл `GoogleService-Info.plist`
5. Откройте Xcode:
   ```bash
   open ios/Runner.xcworkspace
   ```
6. В Xcode перетащите `GoogleService-Info.plist` в папку `Runner`
7. Убедитесь, что файл добавлен в Target "Runner" (отметьте галочку в диалоге)

### Шаг 2: Настроить Firebase Authentication

1. В Firebase Console перейдите в **Authentication** → **Sign-in method**
2. Включите **Phone** (Телефон)
3. Настройте:
   - **Phone numbers for testing**: добавьте тестовые номера (например, `+998901234567`)
   - **App verification**: настройте reCAPTCHA для Android

### Шаг 3: Настроить Cloud Firestore

1. В Firebase Console перейдите в **Firestore Database**
2. Нажмите **"Create database"**
3. Выберите режим:
   - **Start in test mode** (для разработки) - ⚠️ **ВНИМАНИЕ**: Это небезопасно для продакшена!
   - **Start in production mode** (для продакшена)
4. Выберите регион (например, `europe-west` или ближайший к Узбекистану)
5. Нажмите **"Enable"**

### Шаг 4: Настроить Firebase Storage

1. В Firebase Console перейдите в **Storage**
2. Нажмите **"Get started"**
3. Выберите режим безопасности:
   - **Start in test mode** (для разработки)
   - **Start in production mode** (для продакшена)
4. Выберите регион
5. Нажмите **"Done"**

### Шаг 5: Настроить правила безопасности

#### Firestore Rules:
В Firebase Console → **Firestore Database** → **Rules**, замените на:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Правила для пользователей
    match /users/{userId} {
      allow read: if request.auth != null && request.auth.uid == userId;
      allow write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Правила для специалистов
    match /specialists/{specialistId} {
      allow read: if resource.data.isActive == true;
      allow write: if request.auth != null && request.auth.uid == specialistId;
    }
    
    // Правила для клиентов
    match /clients/{clientId} {
      allow read, write: if request.auth != null && request.auth.uid == clientId;
    }
    
    // Правила для заказов
    match /orders/{orderId} {
      allow read: if request.auth != null && 
        (request.auth.uid == resource.data.clientId || 
         request.auth.uid == resource.data.specialistId);
      allow create: if request.auth != null && 
        request.auth.uid == request.resource.data.clientId;
      allow update: if request.auth != null && 
        (request.auth.uid == resource.data.clientId || 
         request.auth.uid == resource.data.specialistId);
    }
    
    // Правила для отзывов
    match /reviews/{reviewId} {
      allow read: if true;
      allow create: if request.auth != null;
      allow update, delete: if request.auth != null && 
        request.auth.uid == resource.data.clientId;
    }
    
    // Правила для чатов
    match /chats/{chatId} {
      allow read, write: if request.auth != null && 
        (request.auth.uid == resource.data.clientId || 
         request.auth.uid == resource.data.specialistId);
    }
    
    // Правила для сообщений
    match /messages/{messageId} {
      allow read, write: if request.auth != null;
    }
    
    // Правила для избранного
    match /favorites/{favoriteId} {
      allow read, write: if request.auth != null && 
        request.auth.uid == resource.data.userId;
    }
  }
}
```

#### Storage Rules:
В Firebase Console → **Storage** → **Rules**, замените на:

```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    // Аватары пользователей
    match /avatars/{userId}/{fileName} {
      allow read: if true;
      allow write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Фото специалистов
    match /specialist_photos/{specialistId}/{fileName} {
      allow read: if true;
      allow write: if request.auth != null && request.auth.uid == specialistId;
    }
    
    // Общие файлы
    match /files/{allPaths=**} {
      allow read: if request.auth != null;
      allow write: if request.auth != null;
    }
  }
}
```

### Шаг 6: Проверка

1. Убедитесь, что файлы на месте:
   ```bash
   # Android
   ls -la android/app/google-services.json
   
   # iOS
   ls -la ios/Runner/GoogleService-Info.plist
   ```

2. Установите зависимости:
   ```bash
   flutter pub get
   cd ios && pod install && cd ..
   ```

3. Запустите приложение:
   ```bash
   flutter run
   ```

4. Проверьте логи - должно быть сообщение:
   ```
   ✅ Firebase инициализирован успешно!
   🔐 Готов к аутентификации пользователей
   ```

## 🔧 Решение проблем

### Проблема: "google-services.json not found"
**Решение**: Убедитесь, что файл находится в `android/app/google-services.json`

### Проблема: "GoogleService-Info.plist not found"
**Решение**: Откройте Xcode и убедитесь, что файл добавлен в проект

### Проблема: "FirebaseApp not initialized"
**Решение**: Убедитесь, что `FirebaseConfig.initialize()` вызывается в `main()` до `runApp()`

### Проблема: SMS код не приходит
**Решение**: 
- Проверьте настройки Phone Authentication в Firebase Console
- Убедитесь, что номер добавлен в тестовые номера (для разработки)
- Проверьте квоты Firebase

## 📝 Полезные ссылки

- [Firebase Console](https://console.firebase.google.com/)
- [Документация Firebase Flutter](https://firebase.flutter.dev/)
- [Firebase Authentication](https://firebase.google.com/docs/auth)
- [Cloud Firestore](https://firebase.google.com/docs/firestore)
- [Firebase Storage](https://firebase.google.com/docs/storage)

## ⚠️ Важно для продакшена

Перед публикацией приложения:
1. Обновите правила Firestore на продакшен-версию
2. Обновите правила Storage на продакшен-версию
3. Настройте App Check для защиты от злоупотреблений
4. Настройте APNs для iOS push-уведомлений
5. Проверьте все квоты и лимиты Firebase

