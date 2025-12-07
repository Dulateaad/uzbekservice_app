# 🚀 Развертывание Cloud Functions (Ручная инструкция)

## ✅ Предварительные требования

- Node.js установлен (версия 18+) ✅
- Откройте **новый терминал** для выполнения команд

## 📝 Пошаговая инструкция

### Шаг 1: Установите Firebase CLI

```bash
npm install -g firebase-tools
```

Проверьте установку:
```bash
firebase --version
```

### Шаг 2: Авторизуйтесь в Firebase

```bash
firebase login
```

Откроется браузер для авторизации. Войдите в аккаунт Google, связанный с проектом `odo-uz-1f4d9`.

### Шаг 3: Перейдите в проект

```bash
cd ~/uzbekservice_app
```

### Шаг 4: Выберите проект Firebase

```bash
firebase use odo-uz-1f4d9
```

### Шаг 5: Установите зависимости функций

```bash
cd functions
npm install
cd ..
```

### Шаг 6: Разверните функции

**Вариант A: Все функции сразу**
```bash
firebase deploy --only functions
```

**Вариант B: Использовать скрипт**
```bash
./deploy_functions.sh
```

**Вариант C: По одной функции**
```bash
firebase deploy --only functions:sendOrderNotification
firebase deploy --only functions:sendChatNotification
firebase deploy --only functions:sendOrderStatusNotification
firebase deploy --only functions:sendReviewNotification
```

## ✅ Проверка развертывания

После успешного развертывания вы увидите:
```
✔  functions[sendOrderNotification(us-central1)] Successful create operation.
✔  functions[sendChatNotification(us-central1)] Successful create operation.
✔  functions[sendOrderStatusNotification(us-central1)] Successful create operation.
✔  functions[sendReviewNotification(us-central1)] Successful create operation.
```

## 📊 Просмотр функций

Откройте Firebase Console:
https://console.firebase.google.com/project/odo-uz-1f4d9/functions

## 📋 Просмотр логов

```bash
# Все логи
firebase functions:log

# Логи конкретной функции
firebase functions:log --only sendOrderNotification
```

## 🧪 Тестирование

1. Создайте тестовый заказ в приложении
2. Функция `sendOrderNotification` автоматически сработает
3. Специалист получит push-уведомление
4. Проверьте логи: `firebase functions:log`

## 🐛 Решение проблем

### Ошибка: "command not found: firebase"
- Убедитесь, что Firebase CLI установлен: `npm install -g firebase-tools`
- Перезапустите терминал

### Ошибка: "Permission denied"
- Используйте `sudo npm install -g firebase-tools` (не рекомендуется)
- Или настройте npm для работы без sudo: https://docs.npmjs.com/resolving-eacces-permissions-errors-when-installing-packages-globally

### Ошибка: "Project not found"
- Проверьте, что проект существует: `firebase projects:list`
- Убедитесь, что вы авторизованы: `firebase login`

### Ошибка при установке зависимостей
- Удалите `node_modules` и `package-lock.json` в `functions/`
- Выполните `npm install` снова

## 💰 Стоимость

Cloud Functions входят в бесплатный тариф Firebase:
- Первые 2 миллиона вызовов в месяц - бесплатно
- После этого: $0.40 за миллион вызовов

