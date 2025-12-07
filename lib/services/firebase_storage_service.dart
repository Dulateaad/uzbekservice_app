import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class FirebaseStorageService {
  static final FirebaseStorageService _instance = FirebaseStorageService._internal();
  factory FirebaseStorageService() => _instance;
  FirebaseStorageService._internal();

  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _picker = ImagePicker();

  /// Загружает файл в Firebase Storage
  Future<String?> uploadFile(File file, String path) async {
    try {
      final ref = _storage.ref().child(path);
      await ref.putFile(file);
      final url = await ref.getDownloadURL();
      print('Файл загружен: $url');
      return url;
    } catch (e) {
      print('Ошибка загрузки файла: $e');
      return null;
    }
  }

  /// Загружает изображение в Firebase Storage
  Future<String?> uploadImage({
    required String userId,
    required String folder,
    required XFile imageFile,
  }) async {
    try {
      // Создаем уникальное имя файла
      final fileName = '${DateTime.now().millisecondsSinceEpoch}_${imageFile.name}';
      final path = '$folder/$userId/$fileName';
      
      // Загружаем в Firebase Storage
      final ref = _storage.ref().child(path);
      await ref.putFile(File(imageFile.path));
      
      // Получаем публичный URL
      final url = await ref.getDownloadURL();
      
      print('Изображение загружено: $url');
      return url;
    } catch (e) {
      print('Ошибка загрузки изображения: $e');
      return null;
    }
  }

  /// Загружает аватар пользователя
  Future<String?> uploadAvatar({
    required String userId,
    required XFile imageFile,
  }) async {
    return await uploadImage(
      userId: userId,
      folder: 'avatars',
      imageFile: imageFile,
    );
  }

  /// Загружает фото специалиста
  Future<String?> uploadSpecialistPhoto({
    required String specialistId,
    required XFile imageFile,
  }) async {
    return await uploadImage(
      userId: specialistId,
      folder: 'specialist_photos',
      imageFile: imageFile,
    );
  }

  /// Удаляет изображение из Storage
  Future<bool> deleteImage(String imageUrl) async {
    try {
      // Извлекаем путь из URL
      final uri = Uri.parse(imageUrl);
      final path = uri.pathSegments.last;
      
      await _storage.ref().child(path).delete();
      print('Изображение удалено: $imageUrl');
      return true;
    } catch (e) {
      print('Ошибка удаления изображения: $e');
      return false;
    }
  }

  /// Выбирает изображение из галереи
  Future<XFile?> pickImageFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      return image;
    } catch (e) {
      print('Ошибка выбора изображения: $e');
      return null;
    }
  }

  /// Делает фото с камеры
  Future<XFile?> takePhotoWithCamera() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      return image;
    } catch (e) {
      print('Ошибка съемки фото: $e');
      return null;
    }
  }

  /// Получает публичный URL файла
  Future<String> getPublicUrl(String path) async {
    try {
      final ref = _storage.ref().child(path);
      return await ref.getDownloadURL();
    } catch (e) {
      print('Ошибка получения URL: $e');
      rethrow;
    }
  }
}
