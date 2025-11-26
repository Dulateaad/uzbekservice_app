# 🔐 Настройка правил безопасности Firestore

## ❌ Проблема
```
[cloud_firestore/permission-denied] Missing or insufficient permissions.
```

## ✅ Решение

### 1. Откройте Firebase Console
1. Перейдите на [Firebase Console](https://console.firebase.google.com)
2. Выберите проект `odo-uz-app`
3. Перейдите в **Firestore Database**
4. Нажмите на вкладку **"Rules"**

### 2. Замените правила на следующие:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Временные правила для разработки (ОТКРЫТЫЙ ДОСТУП)
    // ⚠️ НЕ ИСПОЛЬЗУЙТЕ В ПРОДАКШЕНЕ!
    match /{document=**} {
      allow read, write: if true;
    }
  }
}
```

### 3. Нажмите "Publish"

## 🚨 ВАЖНО! Безопасность

### Для разработки (текущие правила):
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      allow read, write: if true;
    }
  }
}
```

### Для продакшена (рекомендуемые правила):
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Пользователи
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
      allow read: if request.auth != null; // Для поиска специалистов
    }
    
    // Заказы
    match /orders/{orderId} {
      allow read, write: if request.auth != null && 
        (resource.data.clientId == request.auth.uid || 
         resource.data.specialistId == request.auth.uid);
    }
    
    // Отзывы
    match /reviews/{reviewId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && 
        (resource.data.clientId == request.auth.uid);
    }
  }
}
```

## 🔧 Альтернативное решение

Если не хотите менять правила, можно использовать Firebase Authentication:

### 1. Включите анонимную аутентификацию:
1. Firebase Console → Authentication → Sign-in method
2. Включите "Anonymous"
3. Сохраните

### 2. Обновите код для анонимной аутентификации:
```dart
// В main.dart или в инициализации
await FirebaseAuth.instance.signInAnonymously();
```

## 📋 Пошаговая инструкция

1. **Откройте Firebase Console**
2. **Выберите проект odo-uz-app**
3. **Перейдите в Firestore Database**
4. **Нажмите на вкладку "Rules"**
5. **Замените правила на:**
   ```javascript
   rules_version = '2';
   service cloud.firestore {
     match /databases/{database}/documents {
       match /{document=**} {
         allow read, write: if true;
       }
     }
   }
   ```
6. **Нажмите "Publish"**
7. **Перезапустите приложение**

## ✅ Проверка

После настройки правил вы должны увидеть в логах:
```
✅ Пользователь создан в Firestore: +998901234567
✅ Пользователь зарегистрирован: Dulati
```

Вместо:
```
❌ Ошибка создания пользователя: [cloud_firestore/permission-denied]
```

---

**После настройки правил приложение будет работать корректно! 🎉**
