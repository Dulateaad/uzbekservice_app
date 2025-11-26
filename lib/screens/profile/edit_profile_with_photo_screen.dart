import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../constants/app_constants.dart';
import '../../models/user_model.dart';
import '../../providers/auth_provider.dart';
import '../../services/firebase_storage_service.dart';
import '../../services/firebase_firestore_service.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/gradient_button.dart';
import '../../widgets/animated_avatar.dart';
import '../../widgets/photo_picker_dialog.dart';

class EditProfileWithPhotoScreen extends ConsumerStatefulWidget {
  const EditProfileWithPhotoScreen({super.key});

  @override
  ConsumerState<EditProfileWithPhotoScreen> createState() => _EditProfileWithPhotoScreenState();
}

class _EditProfileWithPhotoScreenState extends ConsumerState<EditProfileWithPhotoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  
  final _storageService = FirebaseStorageService();
  final _firestoreService = FirebaseFirestoreService();
  
  bool _isLoading = false;
  String? _selectedCategory;
  String? _newAvatarUrl;
  XFile? _selectedImage;

  final List<String> _categories = [
    'Парикмахер',
    'Няня',
    'Домашний мастер',
    'Строительная бригада',
    'Уборщик',
    'Повар',
    'Водитель',
    'Репетитор',
    'Фотограф',
    'Другое',
  ];

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() {
    final authState = ref.read(authProvider);
    final user = authState.user;
    
    if (user != null) {
      _nameController.text = user.name;
      _emailController.text = user.email ?? '';
      _descriptionController.text = user.description ?? '';
      _priceController.text = user.pricePerHour?.toString() ?? '';
      _selectedCategory = user.category;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    PhotoPickerDialog.show(
      context: context,
      onPhotoSelected: (XFile image) async {
        setState(() {
          _selectedImage = image;
        });
        
        // Загружаем фото в Firebase Storage
        await _uploadPhoto();
      },
    );
  }

  Future<void> _uploadPhoto() async {
    if (_selectedImage == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final authState = ref.read(authProvider);
      final user = authState.user;
      
      if (user != null) {
        final avatarUrl = await _storageService.uploadAvatar(
          userId: user.id,
          imageFile: _selectedImage!,
        );

        if (avatarUrl != null) {
          setState(() {
            _newAvatarUrl = avatarUrl;
          });
          
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Фото успешно загружено!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ошибка загрузки фото: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
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
      
      if (currentUser != null) {
        final updatedUser = currentUser.copyWith(
          name: _nameController.text,
          email: _emailController.text.isNotEmpty ? _emailController.text : null,
          category: _selectedCategory,
          description: _descriptionController.text.isNotEmpty ? _descriptionController.text : null,
          pricePerHour: _priceController.text.isNotEmpty ? double.tryParse(_priceController.text) : null,
          avatar: _newAvatarUrl ?? currentUser.avatar,
          updatedAt: DateTime.now(),
        );

        // Обновляем в Firestore
        await _firestoreService.updateUser(updatedUser);
        
        // Обновляем состояние
        ref.read(authProvider.notifier).state = authState.copyWith(user: updatedUser);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Профиль успешно обновлен!'),
              backgroundColor: Colors.green,
            ),
          );
          context.pop();
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка обновления профиля: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final user = authState.user;
    
    if (user == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Редактировать профиль'),
        actions: [
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppConstants.primaryColor.withOpacity(0.1),
              AppConstants.secondaryColor.withOpacity(0.1),
              Colors.white,
            ],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Аватар
                Center(
                  child: Stack(
                    children: [
                      AnimatedAvatar(
                        imageUrl: _newAvatarUrl ?? user.avatar,
                        name: user.name,
                        size: 120,
                        showEditIcon: true,
                        onTap: _pickPhoto,
                      ),
                      if (_isLoading)
                        Positioned.fill(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.5),
                              shape: BoxShape.circle,
                            ),
                            child: const Center(
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 8),
                
                TextButton(
                  onPressed: _pickPhoto,
                  child: const Text('Изменить фото'),
                ),
                
                const SizedBox(height: 32),
                
                // Основная информация
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Основная информация',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 20),
                        
                        CustomTextField(
                          controller: _nameController,
                          labelText: 'Имя',
                          prefixIcon: const Icon(Icons.person),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Введите имя';
                            }
                            return null;
                          },
                        ),
                        
                        const SizedBox(height: 16),
                        
                        CustomTextField(
                          controller: _emailController,
                          labelText: 'Email (необязательно)',
                          keyboardType: TextInputType.emailAddress,
                          prefixIcon: const Icon(Icons.email),
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Информация специалиста
                if (user.userType == 'specialist') ...[
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Информация специалиста',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 20),
                          
                          // Категория
                          DropdownButtonFormField<String>(
                            value: _selectedCategory,
                            decoration: const InputDecoration(
                              labelText: 'Категория',
                              prefixIcon: Icon(Icons.category),
                            ),
                            items: _categories.map((category) {
                              return DropdownMenuItem(
                                value: category,
                                child: Text(category),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedCategory = value;
                              });
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Выберите категорию';
                              }
                              return null;
                            },
                          ),
                          
                          const SizedBox(height: 16),
                          
                          CustomTextField(
                            controller: _descriptionController,
                            labelText: 'Описание услуг',
                            maxLines: 3,
                            prefixIcon: const Icon(Icons.description),
                          ),
                          
                          const SizedBox(height: 16),
                          
                          CustomTextField(
                            controller: _priceController,
                            labelText: 'Цена за час (сум)',
                            keyboardType: TextInputType.number,
                            prefixIcon: const Icon(Icons.attach_money),
                            validator: (value) {
                              if (value != null && value.isNotEmpty) {
                                if (double.tryParse(value) == null) {
                                  return 'Введите корректную цену';
                                }
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                
                // Кнопка сохранения
                GradientButton(
                  text: 'Сохранить изменения',
                  onPressed: _isLoading ? null : _saveProfile,
                  isLoading: _isLoading,
                  icon: Icons.save,
                ),
                
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
