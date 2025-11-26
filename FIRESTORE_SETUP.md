# 🔥 Настройка Firebase Firestore для ODO.UZ

## 📋 Пошаговая инструкция

### 1. Настройка Firestore в Firebase Console

1. **Откройте [Firebase Console](https://console.firebase.google.com)**
2. **Выберите проект `odo-uz-app`**
3. **Перейдите в Firestore Database**
4. **Создайте базу данных:**
   - Нажмите "Create database"
   - Выберите "Start in test mode" (для разработки)
   - Выберите ближайший регион (например, `europe-west1`)

### 2. Настройка правил безопасности

В Firebase Console → Firestore → Rules:

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

### 3. Структура данных

#### Коллекция `users`:
```json
{
  "id": "string", // номер телефона
  "phoneNumber": "string",
  "name": "string",
  "userType": "client" | "specialist",
  "email": "string?",
  "category": "string?", // для специалистов
  "description": "string?", // для специалистов
  "pricePerHour": "number?", // для специалистов
  "avatarUrl": "string?",
  "createdAt": "timestamp",
  "updatedAt": "timestamp",
  "isVerified": "boolean",
  "location": {
    "lat": "number",
    "lng": "number"
  },
  "skills": ["string"], // для специалистов
  "rating": "number?", // средний рейтинг
  "totalOrders": "number?" // количество заказов
}
```

#### Коллекция `orders`:
```json
{
  "id": "string",
  "clientId": "string",
  "specialistId": "string",
  "category": "string",
  "title": "string",
  "description": "string",
  "status": "pending" | "accepted" | "in_progress" | "completed" | "cancelled",
  "price": "number",
  "address": "string?",
  "location": {
    "lat": "number",
    "lng": "number"
  },
  "scheduledDate": "timestamp",
  "createdAt": "timestamp",
  "updatedAt": "timestamp",
  "images": ["string"],
  "notes": "string?",
  "rating": "number?",
  "review": "string?"
}
```

#### Коллекция `reviews`:
```json
{
  "id": "string",
  "orderId": "string",
  "clientId": "string",
  "specialistId": "string",
  "rating": "number",
  "comment": "string",
  "createdAt": "timestamp"
}
```

### 4. Индексы для производительности

В Firebase Console → Firestore → Indexes создайте составные индексы:

1. **Для поиска специалистов:**
   - Collection: `users`
   - Fields: `userType` (Ascending), `rating` (Descending)

2. **Для поиска по категории:**
   - Collection: `users`
   - Fields: `userType` (Ascending), `category` (Ascending), `rating` (Descending)

3. **Для заказов клиента:**
   - Collection: `orders`
   - Fields: `clientId` (Ascending), `createdAt` (Descending)

4. **Для заказов специалиста:**
   - Collection: `orders`
   - Fields: `specialistId` (Ascending), `createdAt` (Descending)

### 5. Тестовые данные

Создайте тестовых пользователей:

```javascript
// Клиент
{
  "id": "+998901234567",
  "phoneNumber": "+998901234567",
  "name": "Алишер Усманов",
  "userType": "client",
  "email": "alisher@example.com",
  "createdAt": "2024-01-01T00:00:00Z",
  "updatedAt": "2024-01-01T00:00:00Z",
  "isVerified": true
}

// Специалист
{
  "id": "+998901234568",
  "phoneNumber": "+998901234568",
  "name": "Ахмед Барбер",
  "userType": "specialist",
  "category": "barber",
  "description": "Опытный парикмахер с 5-летним стажем",
  "pricePerHour": 50000,
  "createdAt": "2024-01-01T00:00:00Z",
  "updatedAt": "2024-01-01T00:00:00Z",
  "isVerified": true,
  "rating": 4.8,
  "totalOrders": 25,
  "skills": ["стрижка", "борода", "усы"]
}
```

### 6. Мониторинг и аналитика

1. **Включите аналитику:**
   - Firebase Console → Analytics
   - Настройте события для отслеживания

2. **Мониторинг производительности:**
   - Firebase Console → Performance
   - Отслеживайте время загрузки

3. **Логи ошибок:**
   - Firebase Console → Crashlytics
   - Настройте отчеты об ошибках

### 7. Безопасность

1. **Ограничения по IP** (опционально):
   - Firebase Console → Authentication → Settings
   - Добавьте разрешенные IP адреса

2. **Ограничения по домену:**
   - Настройте разрешенные домены для веб-приложения

3. **Регулярные бэкапы:**
   - Настройте автоматические бэкапы
   - Экспортируйте данные регулярно

### 8. Оптимизация

1. **Кэширование:**
   - Используйте локальное кэширование
   - Настройте offline поддержку

2. **Пагинация:**
   - Ограничивайте количество документов в запросах
   - Используйте `limit()` и `startAfter()`

3. **Индексы:**
   - Создавайте индексы для часто используемых запросов
   - Мониторьте производительность запросов

---

## 🚀 Готово!

Firestore настроен и готов к использованию. Все сервисы и провайдеры созданы и готовы к интеграции с вашим приложением.

**Следующие шаги:**
1. Обновите экраны для использования новых провайдеров
2. Протестируйте создание и получение данных
3. Настройте реальную аутентификацию Firebase
4. Добавьте обработку ошибок и загрузки
