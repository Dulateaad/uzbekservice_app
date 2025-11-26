# Миграция с Firebase на Supabase

## Обзор

Этот документ описывает процесс миграции проекта uzbekservice_app с Firebase на Supabase.

## Преимущества Supabase

- ✅ **PostgreSQL** - мощная реляционная база данных
- ✅ **Realtime** - подписки на изменения в реальном времени
- ✅ **Storage** - хранение файлов
- ✅ **Auth** - аутентификация (включая OTP для SMS)
- ✅ **Edge Functions** - серверные функции
- ✅ **Row Level Security** - безопасность на уровне строк
- ✅ **Open Source** - можно самовыделить

## Шаги миграции

### 1. Создание проекта Supabase

1. Перейдите на https://supabase.com
2. Создайте новый проект
3. Скопируйте URL и anon key из Settings > API
4. Обновите `lib/config/supabase_config.dart` с реальными ключами

### 2. Настройка базы данных

1. Откройте SQL Editor в Supabase Dashboard
2. Выполните SQL скрипт из `supabase_schema.sql`
3. Проверьте созданные таблицы в Table Editor

### 3. Настройка Storage

1. Перейдите в Storage в Supabase Dashboard
2. Создайте bucket `images` для изображений
3. Создайте bucket `files` для других файлов
4. Настройте политики доступа (Public для изображений)

### 4. Настройка аутентификации

1. Перейдите в Authentication > Providers
2. Включите Phone provider (требует настройки Twilio или другого SMS провайдера)
3. Или используйте Edge Functions для отправки SMS

### 5. Обновление зависимостей

```bash
flutter pub get
```

### 6. Обновление кода

Сервисы уже созданы:
- ✅ `lib/services/supabase_auth_service.dart`
- ✅ `lib/services/supabase_database_service.dart`
- ✅ `lib/services/supabase_storage_service.dart`

### 7. Замена использования Firebase на Supabase

Нужно обновить провайдеры и экраны для использования новых сервисов:

**Пример замены:**
```dart
// Было:
final authService = FirebaseAuthService();

// Стало:
final authService = SupabaseAuthService();
```

## Структура базы данных

### Таблицы:
- `users` - основная таблица пользователей
- `specialists` - специалисты
- `clients` - клиенты
- `orders` - заказы
- `reviews` - отзывы
- `chats` - чаты
- `messages` - сообщения
- `favorites` - избранное

## Особенности миграции

### SMS аутентификация

Supabase не имеет встроенной SMS аутентификации. Варианты:
1. Использовать Edge Functions с Twilio/SMS.ru
2. Использовать внешний сервис для SMS
3. Использовать OTP через email

### Push уведомления

Supabase не имеет встроенных push уведомлений. Варианты:
1. Использовать Supabase Realtime для уведомлений в приложении
2. Интегрировать внешний сервис (OneSignal, Pusher)
3. Использовать Edge Functions для отправки уведомлений

### Миграция данных

Если нужно перенести данные из Firebase:
1. Экспортируйте данные из Firestore
2. Преобразуйте формат данных
3. Импортируйте в Supabase через SQL или API

## Следующие шаги

1. ✅ Добавлены зависимости Supabase
2. ✅ Созданы сервисы Supabase
3. ✅ Обновлен main.dart
4. ⏳ Обновить провайдеры для использования Supabase
5. ⏳ Обновить экраны для работы с Supabase
6. ⏳ Настроить SMS аутентификацию
7. ⏳ Настроить push уведомления
8. ⏳ Протестировать все функции
9. ⏳ Удалить Firebase зависимости (опционально)

## Полезные ссылки

- [Supabase Documentation](https://supabase.com/docs)
- [Supabase Flutter SDK](https://supabase.com/docs/reference/dart/introduction)
- [Supabase Auth](https://supabase.com/docs/guides/auth)
- [Supabase Storage](https://supabase.com/docs/guides/storage)
- [Supabase Realtime](https://supabase.com/docs/guides/realtime)

