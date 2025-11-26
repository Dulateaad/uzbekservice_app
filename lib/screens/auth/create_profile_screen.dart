import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../constants/app_constants.dart';
import '../../providers/firestore_auth_provider.dart';
import '../../widgets/design_system_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/odo_logo.dart';

class CreateProfileScreen extends ConsumerStatefulWidget {
  const CreateProfileScreen({super.key});

  @override
  ConsumerState<CreateProfileScreen> createState() => _CreateProfileScreenState();
}

class _CreateProfileScreenState extends ConsumerState<CreateProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  
  bool _isLoading = false;
  String? _selectedAvatar;

  // Предустановленные аватары
  final List<String> _avatarOptions = [
    '👨', '👩', '👨‍💼', '👩‍💼', '👨‍🎨', '👩‍🎨', 
    '👨‍🔧', '👩‍🔧', '👨‍⚕️', '👩‍⚕️', '👨‍🍳', '👩‍🍳'
  ];

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _completeRegistration() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedAvatar == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Пожалуйста, выберите аватар'),
          backgroundColor: AppConstants.errorColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.radiusMD),
          ),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final authNotifier = ref.read(firestoreAuthProvider.notifier);
      final authState = ref.read(firestoreAuthProvider);
      
      // Получаем сохраненные данные регистрации
      final phoneNumber = authState.currentPhoneNumber ?? '';
      final userType = authState.registrationUserType ?? 'client';
      final fullName = '${_firstNameController.text.trim()} ${_lastNameController.text.trim()}';
      
      print('📝 Создание профиля для: $fullName ($userType)');
      
      // Регистрируем пользователя с полными данными
      await authNotifier.register(
        phoneNumber: phoneNumber,
        name: fullName,
        userType: userType,
        email: _emailController.text.isNotEmpty ? _emailController.text.trim() : null,
      );

      if (mounted) {
        // Показываем успешное сообщение
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Text('Профиль создан успешно!'),
              ],
            ),
            backgroundColor: AppConstants.successColor,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppConstants.radiusMD),
            ),
          ),
        );
        
        // Небольшая задержка перед переходом
        await Future.delayed(const Duration(milliseconds: 500));
        
        // Переходим на главный экран
        if (mounted) {
          context.go('/home');
        }
      }
    } catch (e) {
      print('❌ Ошибка создания профиля: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(
                  child: Text('Ошибка создания профиля: ${e.toString()}'),
                ),
              ],
            ),
            backgroundColor: AppConstants.errorColor,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppConstants.radiusMD),
            ),
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
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),
                
                // Логотип
                Center(
                  child: OdoLogo(
                    width: 100,
                    height: 50,
                  ),
                ),
                
                const SizedBox(height: 40),
                
                // Заголовок
                Text(
                  'Создание профиля',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppConstants.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 8),
                
                Text(
                  'Добавьте информацию о себе для завершения регистрации',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppConstants.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 40),
                  
                // Выбор аватара
                Text(
                  'Выберите аватар',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppConstants.textPrimary,
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // Сетка аватаров
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppConstants.surfaceColor,
                    borderRadius: BorderRadius.circular(AppConstants.radiusLG),
                    border: Border.all(
                      color: AppConstants.borderColor,
                      width: 1,
                    ),
                  ),
                  child: GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 6,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    itemCount: _avatarOptions.length,
                    itemBuilder: (context, index) {
                      final avatar = _avatarOptions[index];
                      final isSelected = _selectedAvatar == avatar;
                      
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedAvatar = avatar;
                          });
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          decoration: BoxDecoration(
                            color: isSelected 
                                ? AppConstants.primaryColor.withOpacity(0.1)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(AppConstants.radiusMD),
                            border: Border.all(
                              color: isSelected 
                                  ? AppConstants.primaryColor
                                  : AppConstants.borderColor,
                              width: isSelected ? 2 : 1,
                            ),
                            boxShadow: isSelected ? [
                              BoxShadow(
                                color: AppConstants.primaryColor.withOpacity(0.2),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ] : null,
                          ),
                          child: Center(
                            child: Text(
                              avatar,
                              style: TextStyle(
                                fontSize: 24,
                                color: isSelected ? AppConstants.primaryColor : null,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                  
                const SizedBox(height: 32),
                
                // Поле имени
                CustomTextField(
                  controller: _firstNameController,
                  hintText: 'Имя',
                  prefixIcon: const Icon(Icons.person_outline),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Пожалуйста, введите имя';
                    }
                    if (value.length < 2) {
                      return 'Имя должно содержать минимум 2 символа';
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: 16),
                
                // Поле фамилии
                CustomTextField(
                  controller: _lastNameController,
                  hintText: 'Фамилия',
                  prefixIcon: const Icon(Icons.person_outline),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Пожалуйста, введите фамилию';
                    }
                    if (value.length < 2) {
                      return 'Фамилия должна содержать минимум 2 символа';
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: 16),
                
                // Поле email (опционально)
                CustomTextField(
                  controller: _emailController,
                  hintText: 'Email (опционально)',
                  prefixIcon: const Icon(Icons.email_outlined),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value != null && value.isNotEmpty) {
                      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                        return 'Введите корректный email';
                      }
                    }
                    return null;
                  },
                ),
                  
                const SizedBox(height: 40),
                
                // Кнопка завершения регистрации
                DesignSystemButton(
                  text: 'Завершить регистрацию',
                  onPressed: _isLoading ? null : _completeRegistration,
                  isLoading: _isLoading,
                  type: ButtonType.primary,
                  isFullWidth: true,
                ),
                
                const SizedBox(height: 20),
                
                // Информация о конфиденциальности
                Text(
                  'Нажимая "Завершить регистрацию", вы соглашаетесь с нашими условиями использования и политикой конфиденциальности',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppConstants.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      );
  }
}
