import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../constants/app_constants.dart';
import '../../providers/firestore_auth_provider.dart';
import '../../services/storage_service.dart';
import '../../services/firestore_service.dart';
import '../../widgets/ios_liquid_button.dart';

class FixedEditProfileScreen extends ConsumerStatefulWidget {
  const FixedEditProfileScreen({super.key});

  @override
  ConsumerState<FixedEditProfileScreen> createState() => _FixedEditProfileScreenState();
}

class _FixedEditProfileScreenState extends ConsumerState<FixedEditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _categoryController;
  late TextEditingController _descriptionController;
  late TextEditingController _pricePerHourController;
  
  File? _pickedImage;
  bool _isLoading = false;
  double _uploadProgress = 0.0;

  @override
  void initState() {
    super.initState();
    final authState = ref.read(firestoreAuthProvider);
    final user = authState.user;
    _nameController = TextEditingController(text: user?.name ?? '');
    _emailController = TextEditingController(text: user?.email ?? '');
    _categoryController = TextEditingController(text: user?.category ?? '');
    _descriptionController = TextEditingController(text: user?.description ?? '');
    _pricePerHourController = TextEditingController(text: user?.pricePerHour?.toString() ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _categoryController.dispose();
    _descriptionController.dispose();
    _pricePerHourController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final imageFile = await ImagePickerService.pickImageFromGallery();
      if (imageFile != null) {
        setState(() {
          _pickedImage = imageFile;
          _uploadProgress = 0.0;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка выбора изображения: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _uploadProgress = 0.0;
    });

    try {
      final authState = ref.read(firestoreAuthProvider);
      final currentUser = authState.user;

      if (currentUser == null) {
        throw Exception('Пользователь не авторизован');
      }

      String? avatarUrl = currentUser.avatarUrl;
      
      // Загружаем фото если выбрано
      if (_pickedImage != null) {
        print('📤 Загружаем фото в Firebase Storage...');
        
        // Загружаем с отслеживанием прогресса
        avatarUrl = await StorageService.uploadWithProgress(
          'avatars/${currentUser.id}/avatar_${DateTime.now().millisecondsSinceEpoch}.jpg',
          _pickedImage!,
          onProgress: (progress) {
            if (mounted) {
              setState(() {
                _uploadProgress = progress;
              });
            }
          },
        );
        
        // Удаляем старый аватар, если он есть
        if (currentUser.avatarUrl != null && currentUser.avatarUrl != avatarUrl) {
          await StorageService.deleteUserAvatar(currentUser.id, currentUser.avatarUrl);
        }
        
        print('✅ Фото загружено: $avatarUrl');
      }

      // Создаем обновленного пользователя
      final updatedUser = currentUser.copyWith(
        name: _nameController.text,
        email: _emailController.text.isEmpty ? null : _emailController.text,
        category: _categoryController.text.isEmpty ? null : _categoryController.text,
        description: _descriptionController.text.isEmpty ? null : _descriptionController.text,
        pricePerHour: _pricePerHourController.text.isEmpty ? null : double.tryParse(_pricePerHourController.text),
        avatarUrl: avatarUrl,
        updatedAt: DateTime.now(),
      );

      print('📝 Обновляем пользователя в Firestore...');
      // Обновляем пользователя в Firestore
      await FirestoreService.updateUser(updatedUser);

      print('🔄 Обновляем состояние в провайдере...');
      // Обновляем состояние в провайдере
      ref.read(firestoreAuthProvider.notifier).state = authState.copyWith(user: updatedUser);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Профиль успешно обновлен!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      print('❌ Ошибка обновления профиля: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка обновления профиля: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _uploadProgress = 0.0;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(firestoreAuthProvider);
    final user = authState.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Редактировать профиль'),
        backgroundColor: AppConstants.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Аватар
              Center(
                child: GestureDetector(
                  onTap: _pickImage,
                  child: Stack(
                    children: [
                      Stack(
                        children: [
                          CircleAvatar(
                            radius: 60,
                            backgroundColor: AppConstants.primaryColor.withValues(alpha: 0.1),
                            backgroundImage: _pickedImage != null
                                ? FileImage(_pickedImage!)
                                : (user?.avatarUrl != null 
                                    ? NetworkImage(user!.avatarUrl!) 
                                    : null) as ImageProvider?,
                            child: _pickedImage == null && user?.avatarUrl == null
                                ? const Icon(
                                    Icons.person,
                                    size: 60,
                                    color: Colors.grey,
                                  )
                                : null,
                          ),
                          if (_isLoading && _uploadProgress > 0)
                            Positioned.fill(
                              child: CircularProgressIndicator(
                                value: _uploadProgress,
                                strokeWidth: 3,
                                backgroundColor: Colors.white.withValues(alpha: 0.3),
                                valueColor: AlwaysStoppedAnimation<Color>(AppConstants.primaryColor),
                              ),
                            ),
                        ],
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppConstants.primaryColor,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: const Icon(
                            Icons.camera_alt,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              Center(
                child: TextButton(
                  onPressed: _pickImage,
                  child: const Text('Изменить фото профиля'),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Поля формы
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Имя',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Введите имя';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value != null && value.isNotEmpty && !value.contains('@')) {
                    return 'Введите корректный Email';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 16),
              
              if (user?.userType == 'specialist') ...[
                TextFormField(
                  controller: _categoryController,
                  decoration: const InputDecoration(
                    labelText: 'Категория специалиста',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.category),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Описание',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.description),
                  ),
                  maxLines: 3,
                ),
                
                const SizedBox(height: 16),
                
                TextFormField(
                  controller: _pricePerHourController,
                  decoration: const InputDecoration(
                    labelText: 'Цена за час',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.attach_money),
                  ),
                  keyboardType: TextInputType.number,
                ),
                
                const SizedBox(height: 16),
              ],
              
              // Кнопка сохранения
              IOSLiquidButton(
                text: 'Сохранить изменения',
                onPressed: _isLoading ? null : _saveProfile,
                isLoading: _isLoading,
                icon: Icons.save,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
