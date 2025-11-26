# 🔥 Исправленные правила Firestore для продакшена

## 📋 Текущая проблема
Правила требуют аутентификации, но приложение использует коллекцию `users` для всех пользователей (клиентов и специалистов).

## ✅ Исправленные правила

Замените текущие правила на эти:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Общая коллекция пользователей (клиенты и специалисты)
    match /users/{userId} {
      // Разрешаем чтение всем аутентифицированным пользователям
      allow read: if request.auth != null;
      // Разрешаем запись только владельцу документа
      allow write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Заказы - только для участников
    match /orders/{orderId} {
      allow read, write: if request.auth != null && 
        (resource.data.clientId == request.auth.uid || 
         resource.data.specialistId == request.auth.uid);
    }
    
    // Отзывы - только для участников
    match /reviews/{reviewId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && 
        (resource.data.clientId == request.auth.uid);
    }
  }
}
```

## 🔧 Альтернативные правила (более строгие)

Если хотите более строгие правила:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Пользователи - только свои данные
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Публичные данные специалистов (только чтение)
    match /specialists/{specialistId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && request.auth.uid == specialistId;
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

## 🚀 Рекомендуемые правила (для разработки)

Для тестирования используйте эти правила:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Временные правила для разработки
    match /{document=**} {
      allow read, write: if request.auth != null;
    }
  }
}
```

## 📝 Инструкции по применению

1. Откройте [Firebase Console](https://console.firebase.google.com)
2. Выберите проект `odo-uz-app`
3. Перейдите в **Firestore Database > Rules**
4. Замените правила на один из вариантов выше
5. Нажмите **"Publish"**

## 🔍 Проверка

После применения правил:
- ✅ Аутентифицированные пользователи могут читать данные
- ✅ Пользователи могут изменять только свои данные
- ✅ Приложение будет работать корректно
