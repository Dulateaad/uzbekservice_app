import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../constants/app_constants.dart';
import '../../providers/auth_provider.dart';
import '../../services/firebase_storage_service.dart';
import '../../services/firebase_firestore_service.dart';
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
  
  XFile? _pickedImage;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final user = ref.read(authProvider).user;
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
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _pickedImage = image;
      });
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final authState = ref.read(authProvider);
      final currentUser = authState.user;

      if (currentUser == null) {
        throw 'Пользователь не авторизован';
      }

      String? avatarUrl = currentUser.avatar;
      
      // Загружаем фото если выбрано
      if (_pickedImage != null) {
        print('Загружаем фото в Firebase Storage...');
        avatarUrl = await FirebaseStorageService().uploadFile(
          File(_pickedImage!.path),
          'avatars/${currentUser.id}',
        );
        print('Фото загружено: $avatarUrl');
      }

      // Создаем обновленного пользователя
      final updatedUser = currentUser.copyWith(
        name: _nameController.text,
        email: _emailController.text.isEmpty ? null : _emailController.text,
        category: _categoryController.text.isEmpty ? null : _categoryController.text,
        description: _descriptionController.text.isEmpty ? null : _descriptionController.text,
        pricePerHour: _pricePerHourController.text.isEmpty ? null : double.tryParse(_pricePerHourController.text),
        avatar: avatarUrl,
        updatedAt: DateTime.now(),
      );

      print('Обновляем пользователя в Firestore...');
      // Обновляем пользователя в Firestore
      await FirebaseFirestoreService().updateUser(updatedUser);

      print('Обновляем состояние в AuthProvider...');
      // Обновляем состояние в AuthProvider
      ref.read(authProvider.notifier).state = authState.copyWith(user: updatedUser);

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
      print('Ошибка обновления профиля: $e');
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
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider).user;

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
                      CircleAvatar(
                        radius: 60,
                        backgroundColor: AppConstants.primaryColor.withOpacity(0.1),
                        backgroundImage: _pickedImage != null
                            ? FileImage(File(_pickedImage!.path))
                            : (user?.avatar != null 
                                ? NetworkImage(user!.avatar!) 
                                : null) as ImageProvider?,
                        child: _pickedImage == null && user?.avatar == null
                            ? const Icon(
                                Icons.person,
                                size: 60,
                                color: Colors.grey,
                              )
                            : null,
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
