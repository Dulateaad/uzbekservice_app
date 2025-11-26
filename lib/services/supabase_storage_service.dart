import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';

class SupabaseStorageService {
  static final SupabaseStorageService _instance = SupabaseStorageService._internal();
  factory SupabaseStorageService() => _instance;
  SupabaseStorageService._internal();

  final SupabaseClient _client = SupabaseConfig.client;
  final ImagePicker _picker = ImagePicker();

  /// Загружает файл в Supabase Storage
  Future<String?> uploadFile(File file, String path) async {
    try {
      final fileName = path.split('/').last;
      final folderPath = path.substring(0, path.lastIndexOf('/'));
      
      await _client.storage.from('files').uploadBinary(
        folderPath.isEmpty ? fileName : '$folderPath/$fileName',
        file.readAsBytesSync(),
      );

      final url = _client.storage.from('files').getPublicUrl(
        folderPath.isEmpty ? fileName : '$folderPath/$fileName',
      );

      print('Файл загружен: $url');
      return url;
    } catch (e) {
      print('Ошибка загрузки файла: $e');
      return null;
    }
  }

  /// Загружает изображение в Supabase Storage
  Future<String?> uploadImage({
    required String userId,
    required String folder,
    required XFile imageFile,
  }) async {
    try {
      // Создаем уникальное имя файла
      final fileName = '${DateTime.now().millisecondsSinceEpoch}_${imageFile.name}';
      final path = '$folder/$userId/$fileName';
      
      // Читаем файл как байты
      final fileBytes = await imageFile.readAsBytes();
      
      // Загружаем в Supabase Storage
      await _client.storage.from('images').uploadBinary(path, fileBytes);

      // Получаем публичный URL
      final url = _client.storage.from('images').getPublicUrl(path);
      
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
      
      await _client.storage.from('images').remove([path]);
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
  String getPublicUrl(String bucket, String path) {
    return _client.storage.from(bucket).getPublicUrl(path);
  }
}

