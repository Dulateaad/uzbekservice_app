# 📦 Настройка Firebase Storage для ODO.UZ

## 📋 Содержание

1. [Структура хранилища](#структура-хранилища)
2. [Правила безопасности](#правила-безопасности)
3. [Использование в приложении](#использование-в-приложении)
4. [Развертывание](#развертывание)
5. [Примеры кода](#примеры-кода)

## 📁 Структура хранилища

### Структура папок:

```
gs://odo-uz-1f4d9.firebasestorage.app/
├── avatars/
│   └── {userId}/
│       └── {filename}.jpg
├── orders/
│   └── {orderId}/
│       └── {filename}.jpg
├── specialists/
│   └── {specialistId}/
│       └── documents/
│           └── {filename}.pdf
├── temp/
│   └── {userId}/
│       └── {filename}
└── public/
    └── {filename}
```

### Описание папок:

1. **`avatars/`** — Аватары пользователей
   - Путь: `avatars/{userId}/{filename}`
   - Формат: JPG, PNG, WebP
   - Максимальный размер: 10 МБ

2. **`orders/`** — Фотографии заказов
   - Путь: `orders/{orderId}/{filename}`
   - Формат: JPG, PNG, WebP
   - Максимальный размер: 10 МБ

3. **`specialists/{specialistId}/documents/`** — Документы специалистов
   - Путь: `specialists/{specialistId}/documents/{filename}`
   - Формат: PDF, DOC, DOCX, изображения
   - Максимальный размер: 10 МБ

4. **`temp/`** — Временные файлы
   - Путь: `temp/{userId}/{filename}`
   - Для временных загрузок перед обработкой
   - Автоматическая очистка рекомендуется

5. **`public/`** — Публичные файлы
   - Путь: `public/{filename}`
   - Логотипы, баннеры и т.д.
   - Доступны всем без аутентификации

## 🔒 Правила безопасности

Правила безопасности находятся в файле `storage.rules`.

### Основные принципы:

1. **Аутентификация**: Большинство операций требуют аутентификации
2. **Владелец**: Пользователь может управлять только своими файлами
3. **Валидация**: Проверка размера и типа файлов
4. **Безопасность**: Ограничения на загрузку и удаление

### Ограничения:

- **Максимальный размер файла**: 10 МБ
- **Разрешенные типы изображений**: `image/*`
- **Разрешенные типы документов**: PDF, DOC, DOCX

### Права доступа:

- **Аватары**: Все могут читать, только владелец может загружать/удалять
- **Фотографии заказов**: Участники заказа могут читать/загружать
- **Документы специалистов**: Все могут читать, только специалист может загружать/удалять
- **Временные файлы**: Только владелец имеет доступ
- **Публичные файлы**: Все могут читать, загрузка только через Cloud Functions

## 💻 Использование в приложении

### Инициализация Storage

```dart
import 'package:firebase_storage/firebase_storage.dart';

final storage = FirebaseStorage.instance;
```

### Загрузка аватара пользователя

```dart
Future<String> uploadUserAvatar(String userId, File imageFile) async {
  try {
    final ref = storage.ref('avatars/$userId/${DateTime.now().millisecondsSinceEpoch}.jpg');
    final uploadTask = ref.putFile(imageFile);
    final snapshot = await uploadTask;
    final downloadUrl = await snapshot.ref.getDownloadURL();
    return downloadUrl;
  } catch (e) {
    print('Ошибка загрузки аватара: $e');
    rethrow;
  }
}
```

### Загрузка фотографии заказа

```dart
Future<String> uploadOrderPhoto(String orderId, File imageFile) async {
  try {
    final ref = storage.ref('orders/$orderId/${DateTime.now().millisecondsSinceEpoch}.jpg');
    final uploadTask = ref.putFile(imageFile);
    final snapshot = await uploadTask;
    final downloadUrl = await snapshot.ref.getDownloadURL();
    return downloadUrl;
  } catch (e) {
    print('Ошибка загрузки фотографии заказа: $e');
    rethrow;
  }
}
```

### Загрузка документа специалиста

```dart
Future<String> uploadSpecialistDocument(String specialistId, File documentFile) async {
  try {
    final fileName = documentFile.path.split('/').last;
    final ref = storage.ref('specialists/$specialistId/documents/$fileName');
    final uploadTask = ref.putFile(documentFile);
    final snapshot = await uploadTask;
    final downloadUrl = await snapshot.ref.getDownloadURL();
    return downloadUrl;
  } catch (e) {
    print('Ошибка загрузки документа: $e');
    rethrow;
  }
}
```

### Удаление файла

```dart
Future<void> deleteFile(String path) async {
  try {
    final ref = storage.ref(path);
    await ref.delete();
    print('Файл удален: $path');
  } catch (e) {
    print('Ошибка удаления файла: $e');
    rethrow;
  }
}
```

### Получение URL файла

```dart
Future<String> getFileUrl(String path) async {
  try {
    final ref = storage.ref(path);
    return await ref.getDownloadURL();
  } catch (e) {
    print('Ошибка получения URL: $e');
    rethrow;
  }
}
```

### Загрузка с прогрессом

```dart
Future<String> uploadWithProgress(String path, File file, Function(double) onProgress) async {
  try {
    final ref = storage.ref(path);
    final uploadTask = ref.putFile(file);
    
    uploadTask.snapshotEvents.listen((snapshot) {
      final progress = snapshot.bytesTransferred / snapshot.totalBytes;
      onProgress(progress);
    });
    
    final snapshot = await uploadTask;
    return await snapshot.ref.getDownloadURL();
  } catch (e) {
    print('Ошибка загрузки: $e');
    rethrow;
  }
}
```

## 🚀 Развертывание

### Развернуть правила безопасности

```bash
cd ~/uzbekservice_app
firebase deploy --only storage
```

Или используйте скрипт:

```bash
./deploy_firestore.sh
```

Выберите опцию для развертывания Storage.

### Проверить в Firebase Console

Откройте [Firebase Console - Storage](https://console.firebase.google.com/project/odo-uz-1f4d9/storage)

## 📝 Примеры использования

### Пример 1: Загрузка аватара при регистрации

```dart
Future<void> registerUserWithAvatar({
  required String userId,
  required String name,
  required String phoneNumber,
  File? avatarFile,
}) async {
  String? avatarUrl;
  
  if (avatarFile != null) {
    avatarUrl = await uploadUserAvatar(userId, avatarFile);
  }
  
  final user = FirestoreUser(
    id: userId,
    name: name,
    phoneNumber: phoneNumber,
    userType: 'client',
    avatarUrl: avatarUrl,
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
    isVerified: false,
  );
  
  await FirestoreService.createUser(user);
}
```

### Пример 2: Загрузка нескольких фотографий заказа

```dart
Future<List<String>> uploadOrderPhotos(String orderId, List<File> photos) async {
  final urls = <String>[];
  
  for (var i = 0; i < photos.length; i++) {
    final url = await uploadOrderPhoto(orderId, photos[i]);
    urls.add(url);
  }
  
  return urls;
}
```

### Пример 3: Удаление старого аватара при обновлении

```dart
Future<String> updateUserAvatar(String userId, File newAvatarFile) async {
  // Получаем текущего пользователя
  final user = await FirestoreService.getUserById(userId);
  
  // Удаляем старый аватар, если он есть
  if (user?.avatarUrl != null) {
    try {
      final oldPath = user!.avatarUrl!.split('/').last;
      await deleteFile('avatars/$userId/$oldPath');
    } catch (e) {
      print('Ошибка удаления старого аватара: $e');
    }
  }
  
  // Загружаем новый аватар
  final newAvatarUrl = await uploadUserAvatar(userId, newAvatarFile);
  
  // Обновляем профиль пользователя
  await FirestoreService.updateUser(user!.copyWith(avatarUrl: newAvatarUrl));
  
  return newAvatarUrl;
}
```

## ⚠️ Важные замечания

1. **Размер файлов**: Ограничение 10 МБ. Для больших файлов используйте сжатие изображений перед загрузкой.

2. **Оптимизация изображений**: Рекомендуется сжимать изображения перед загрузкой:
   ```dart
   import 'package:image/image.dart' as img;
   
   Future<File> compressImage(File imageFile) async {
     final bytes = await imageFile.readAsBytes();
     final image = img.decodeImage(bytes);
     final compressed = img.copyResize(image!, width: 800);
     final compressedBytes = img.encodeJpg(compressed, quality: 85);
     return File(imageFile.path.replaceAll('.jpg', '_compressed.jpg'))
       ..writeAsBytesSync(compressedBytes);
   }
   ```

3. **Безопасность**: Всегда проверяйте права доступа перед загрузкой/удалением файлов.

4. **Очистка**: Регулярно очищайте временные файлы из папки `temp/`.

5. **Мониторинг**: Следите за использованием Storage в Firebase Console для контроля затрат.

## 🔗 Полезные ссылки

- [Firebase Console - Storage](https://console.firebase.google.com/project/odo-uz-1f4d9/storage)
- [Документация Firebase Storage](https://firebase.google.com/docs/storage)
- [Flutter Firebase Storage](https://firebase.flutter.dev/docs/storage/overview)

