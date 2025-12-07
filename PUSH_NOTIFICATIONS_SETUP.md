# 📱 Настройка Push-уведомлений (Firebase Cloud Messaging)

## ✅ Что уже настроено

1. **Зависимости**: `firebase_messaging: ^15.2.0` добавлен в `pubspec.yaml`
2. **Сервис**: `PushNotificationService` создан и интегрирован
3. **Инициализация**: Push-уведомления инициализируются в `main.dart`
4. **Сохранение токенов**: Токены автоматически сохраняются в профиле пользователя при входе/регистрации

## 🔧 Дополнительная настройка для платформ

### Android

1. **Google Services**: Уже настроен через `google-services.json`

2. **Разрешения**: Добавьте в `android/app/src/main/AndroidManifest.xml`:
   ```xml
   <uses-permission android:name="android.permission.INTERNET"/>
   <uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
   ```

3. **Иконка уведомлений**: Создайте иконку для уведомлений в `android/app/src/main/res/drawable/notification_icon.png`

### iOS

1. **Capabilities**: В Xcode добавьте:
   - Push Notifications
   - Background Modes → Remote notifications

2. **Разрешения**: В `ios/Runner/Info.plist` добавьте:
   ```xml
   <key>UIBackgroundModes</key>
   <array>
     <string>remote-notification</string>
   </array>
   ```

3. **APNs Certificate**: Загрузите сертификат APNs в Firebase Console:
   - Firebase Console → Project Settings → Cloud Messaging
   - Загрузите APNs Authentication Key или Certificate

### Web

1. **Service Worker**: Firebase Messaging для web использует service worker
2. **Разрешения**: Браузер запросит разрешение автоматически

## 📤 Отправка уведомлений

### Через Firebase Console

1. Перейдите в Firebase Console → Cloud Messaging
2. Нажмите "Send your first message"
3. Заполните заголовок и текст
4. Выберите целевую аудиторию (по токенам устройств или топикам)

### Через Cloud Functions (рекомендуется)

Создайте Cloud Function для отправки уведомлений:

```javascript
const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();

exports.sendOrderNotification = functions.firestore
  .document('orders/{orderId}')
  .onCreate(async (snap, context) => {
    const order = snap.data();
    const specialistId = order.specialistId;
    
    // Получаем токены специалиста
    const specialistDoc = await admin.firestore()
      .collection('users')
      .doc(specialistId)
      .get();
    
    const tokens = specialistDoc.data()?.deviceTokens || [];
    
    if (tokens.length === 0) return;
    
    const message = {
      notification: {
        title: 'Новый заказ!',
        body: `У вас новый заказ от ${order.clientName}`,
      },
      data: {
        type: 'order',
        orderId: context.params.orderId,
      },
      tokens: tokens,
    };
    
    await admin.messaging().sendMulticast(message);
  });
```

### Через REST API

```bash
curl -X POST https://fcm.googleapis.com/v1/projects/odo-uz-1f4d9/messages:send \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "message": {
      "token": "DEVICE_FCM_TOKEN",
      "notification": {
        "title": "Новый заказ",
        "body": "У вас новый заказ!"
      },
      "data": {
        "type": "order",
        "orderId": "order123"
      }
    }
  }'
```

## 🎯 Типы уведомлений

### 1. Уведомления о заказах

```dart
// Данные для отправки:
{
  "type": "order",
  "orderId": "order123",
  "status": "pending" // pending, accepted, completed, cancelled
}
```

### 2. Уведомления о чатах

```dart
{
  "type": "chat",
  "chatId": "chat123",
  "senderName": "Иван Иванов"
}
```

### 3. Уведомления о специалистах

```dart
{
  "type": "specialist",
  "specialistId": "specialist123",
  "action": "new_review" // new_review, new_order, etc.
}
```

## 🔔 Подписки на топики

Пользователи могут подписываться на топики:

```dart
// Подписка на категорию
await PushNotificationService.subscribeToTopic('category_barber');

// Подписка на город
await PushNotificationService.subscribeToTopic('city_tashkent');

// Отписка
await PushNotificationService.unsubscribeFromTopic('category_barber');
```

## 📊 Проверка работы

1. **Проверка токена**: После входа проверьте в консоли:
   ```
   📱 FCM Token получен: ...
   ✅ Токен сохранен в профиле пользователя
   ```

2. **Проверка в Firestore**: Убедитесь, что токен сохранен в `users/{userId}/deviceTokens`

3. **Тестовая отправка**: Используйте Firebase Console для отправки тестового уведомления

## 🐛 Отладка

### Проблемы с токенами

- Проверьте разрешения на уведомления
- Убедитесь, что Firebase инициализирован до запроса токена
- Проверьте логи: `flutter logs`

### Проблемы с получением уведомлений

- **Android**: Проверьте, что Google Services настроен
- **iOS**: Проверьте APNs сертификат в Firebase Console
- **Web**: Проверьте, что service worker зарегистрирован

## 📚 Дополнительные ресурсы

- [Firebase Cloud Messaging Documentation](https://firebase.google.com/docs/cloud-messaging)
- [Flutter Firebase Messaging Plugin](https://pub.dev/packages/firebase_messaging)

