# Пошаговая инструкция по настройке Firebase

## Шаг 1: Создание проекта в Firebase Console

1. Перейдите на [Firebase Console](https://console.firebase.google.com/)
2. Нажмите **"Добавить проект"** (Add project)
3. Введите название проекта: `uzbekservice-app` (или другое на ваше усмотрение)
4. Отключите Google Analytics (или включите, если нужно)
5. Нажмите **"Создать проект"**

## Шаг 2: Добавление Android приложения

1. В Firebase Console выберите ваш проект
2. Нажмите на иконку **Android** (или **Add app** → **Android**)
3. Введите:
   - **Package name**: `com.example.odo_uz_app` (проверьте в `android/app/build.gradle`)
   - **App nickname**: `Uzbekistan Service Android`
   - **Debug signing certificate SHA-1**: (опционально, для тестирования)
4. Нажмите **"Зарегистрировать приложение"**
5. Скачайте файл `google-services.json`
6. Скопируйте `google-services.json` в папку `android/app/`

## Шаг 3: Настройка Android проекта

1. Откройте файл `android/build.gradle`:
   ```gradle
   buildscript {
       dependencies {
           // Добавьте эту строку
           classpath 'com.google.gms:google-services:4.4.0'
       }
   }
   ```

2. Откройте файл `android/app/build.gradle`:
   ```gradle
   // В конце файла добавьте:
   apply plugin: 'com.google.gms.google-services'
   ```

## Шаг 4: Добавление iOS приложения

1. В Firebase Console нажмите на иконку **iOS** (или **Add app** → **iOS**)
2. Введите:
   - **Bundle ID**: `com.example.odoUzApp` (проверьте в `ios/Runner.xcodeproj`)
   - **App nickname**: `Uzbekistan Service iOS`
   - **App Store ID**: (опционально)
3. Нажмите **"Зарегистрировать приложение"**
4. Скачайте файл `GoogleService-Info.plist`
5. Откройте Xcode:
   ```bash
   open ios/Runner.xcworkspace
   ```
6. Перетащите `GoogleService-Info.plist` в папку `Runner` в Xcode
7. Убедитесь, что файл добавлен в Target "Runner"

## Шаг 5: Настройка Firebase Authentication

1. В Firebase Console перейдите в **Authentication** → **Sign-in method**
2. Включите **Phone** (Телефон)
3. Настройте:
   - **Phone numbers for testing**: добавьте тестовые номера (опционально)
   - **App verification**: настройте reCAPTCHA для Android

## Шаг 6: Настройка Cloud Firestore

1. В Firebase Console перейдите в **Firestore Database**
2. Нажмите **"Создать базу данных"**
3. Выберите режим:
   - **Режим тестирования** (для разработки)
   - **Режим продакшена** (для продакшена)
4. Выберите регион (например, `europe-west` или ближайший к Узбекистану)
5. Нажмите **"Включить"**

### Создание структуры коллекций

После создания базы данных, создайте следующие коллекции через Firebase Console или кодом:

- `users` - пользователи
- `specialists` - специалисты
- `clients` - клиенты
- `orders` - заказы
- `reviews` - отзывы
- `chats` - чаты
- `messages` - сообщения
- `favorites` - избранное

## Шаг 7: Настройка Firebase Storage

1. В Firebase Console перейдите в **Storage**
2. Нажмите **"Начать"**
3. Выберите режим безопасности:
   - **Режим тестирования** (для разработки)
   - **Режим продакшена** (для продакшена)
4. Выберите регион
5. Нажмите **"Готово"**

### Создание папок в Storage

Создайте следующие папки (buckets):
- `avatars/` - аватары пользователей
- `specialist_photos/` - фото специалистов
- `files/` - общие файлы

## Шаг 8: Настройка Firebase Cloud Messaging (FCM)

1. В Firebase Console перейдите в **Cloud Messaging**
2. Для Android:
   - Убедитесь, что `google-services.json` правильно настроен
   - Настройте серверный ключ (если нужен)
3. Для iOS:
   - Загрузите APNs сертификат (для push-уведомлений)
   - Или используйте APNs Auth Key

## Шаг 9: Настройка правил безопасности Firestore

В Firebase Console → **Firestore Database** → **Правила**, добавьте:

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

## Шаг 10: Настройка правил безопасности Storage

В Firebase Console → **Storage** → **Правила**, добавьте:

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

## Шаг 11: Установка зависимостей Flutter

```bash
cd uzbekservice_app
flutter pub get
```

## Шаг 12: Проверка конфигурации

1. Убедитесь, что файлы конфигурации на месте:
   - `android/app/google-services.json`
   - `ios/Runner/GoogleService-Info.plist`

2. Проверьте, что в `pubspec.yaml` есть все необходимые пакеты:
   ```yaml
   firebase_core: ^2.24.2
   firebase_auth: ^4.15.3
   cloud_firestore: ^4.13.6
   firebase_storage: ^11.5.6
   firebase_messaging: ^14.7.10
   ```

## Шаг 13: Тестирование

1. Запустите приложение:
   ```bash
   flutter run
   ```

2. Проверьте:
   - ✅ Инициализация Firebase (должно быть сообщение в консоли)
   - ✅ Аутентификация через SMS
   - ✅ Создание пользователя в Firestore
   - ✅ Загрузка файлов в Storage

## Шаг 14: Настройка для продакшена

1. **Firestore**: Переключите на режим продакшена
2. **Storage**: Обновите правила безопасности
3. **Authentication**: Настройте домены для веб-версии
4. **Cloud Messaging**: Настройте APNs для iOS
5. **App Check**: Включите защиту от злоупотреблений

## Полезные ссылки

- [Firebase Console](https://console.firebase.google.com/)
- [Документация Firebase Flutter](https://firebase.flutter.dev/)
- [Firebase Authentication](https://firebase.google.com/docs/auth)
- [Cloud Firestore](https://firebase.google.com/docs/firestore)
- [Firebase Storage](https://firebase.google.com/docs/storage)

## Решение проблем

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

## Контакты и поддержка

При возникновении проблем:
1. Проверьте логи в Firebase Console
2. Проверьте логи Flutter (`flutter run -v`)
3. Обратитесь к [документации Firebase](https://firebase.google.com/docs)

