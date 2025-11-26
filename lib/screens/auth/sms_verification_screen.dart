import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../constants/app_constants.dart';
import '../../providers/firestore_auth_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/odo_logo.dart';

class SmsVerificationScreen extends ConsumerStatefulWidget {
  final String phoneNumber;
  
  const SmsVerificationScreen({
    super.key,
    required this.phoneNumber,
  });

  @override
  ConsumerState<SmsVerificationScreen> createState() => _SmsVerificationScreenState();
}

class _SmsVerificationScreenState extends ConsumerState<SmsVerificationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();
  bool _isLoading = false;
  int _resendTimer = 0;

  @override
  void initState() {
    super.initState();
    _startResendTimer();
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  void _startResendTimer() {
    setState(() {
      _resendTimer = 60;
    });
    
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (mounted) {
        setState(() {
          _resendTimer--;
        });
        return _resendTimer > 0;
      }
      return false;
    });
  }

  void _verifyCode() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Получаем номер телефона из FirestoreAuthProvider или из widget
      final authState = ref.read(firestoreAuthProvider);
      final phoneNumber = authState.currentPhoneNumber ?? widget.phoneNumber;
      
      print('🔍 Проверяем код для номера: "$phoneNumber"');
      print('🔍 Введенный код: "${_codeController.text}"');
      print('🔍 Номер из widget: "${widget.phoneNumber}"');
      print('🔍 Номер из FirestoreAuthProvider: "${authState.currentPhoneNumber}"');
      
      // Вызываем логин через FirestoreAuthProvider
      await ref.read(firestoreAuthProvider.notifier).login(phoneNumber, _codeController.text);
      
      if (mounted) {
        final authState = ref.read(firestoreAuthProvider);
        
        if (authState.isAuthenticated) {
          // Проверяем, нужно ли создать профиль
          final user = authState.user;
          if (user != null && (user.name == 'Пользователь' || user.name.isEmpty)) {
            // Новый пользователь - переходим к созданию профиля
            context.go('/auth/create-profile');
          } else {
            // Пользователь с полным профилем - переходим на главную
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Успешная авторизация!'),
                backgroundColor: Colors.green,
              ),
            );
            context.go('/home');
          }
        } else if (authState.error != null) {
          // Проверяем тип ошибки
          if (authState.error!.contains('не найден')) {
            // Пользователь не найден - переходим к созданию профиля
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Создайте профиль для завершения регистрации'),
                backgroundColor: Colors.orange,
              ),
            );
            context.go('/auth/create-profile');
          } else {
            // Другие ошибки
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Ошибка: ${authState.error}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        } else {
          // Если пользователь не аутентифицирован, переходим к регистрации
          context.go('/auth/specialist-registration');
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка: $e'),
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

  void _resendCode() async {
    if (_resendTimer > 0) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Здесь будет логика повторной отправки SMS
      await Future.delayed(const Duration(seconds: 1)); // Имитация запроса
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Text('Код отправлен повторно'),
              ],
            ),
            backgroundColor: AppConstants.successColor,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppConstants.radiusMD),
            ),
          ),
        );
        _startResendTimer();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка: $e'),
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
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                const SizedBox(height: 40),
                
                // Логотип
                Center(
                  child: OdoLogo(
                    width: 100,
                    height: 50,
                  ),
                ),
                
                const SizedBox(height: 40),
                
                // Иконка
                Center(
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: AppConstants.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(
                      Icons.sms,
                      size: 50,
                      color: AppConstants.primaryColor,
                    ),
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // Заголовок
                const Text(
                  'Введите код из SMS',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 8),
                
                // Подзаголовок
                Text(
                  'Код отправлен на номер\n${ref.watch(firestoreAuthProvider).currentPhoneNumber ?? widget.phoneNumber}',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 16),
                
                // Подсказка о тестовом коде
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue.withOpacity(0.3)),
                  ),
                  child: const Text(
                    '💡 Для тестирования используйте код: 123456',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.blue,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                
                const SizedBox(height: 48),
                
                // Поле ввода кода
                CustomTextField(
                  controller: _codeController,
                  labelText: 'Код подтверждения',
                  hintText: '123456',
                  keyboardType: TextInputType.number,
                  prefixIcon: const Icon(Icons.security),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Введите код';
                    }
                    if (value.length != 6) {
                      return 'Код должен содержать 6 цифр';
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: 32),
                
                // Кнопка подтверждения
                CustomButton(
                  text: 'Подтвердить',
                  onPressed: _isLoading ? null : _verifyCode,
                  isLoading: _isLoading,
                ),
                
                const SizedBox(height: 24),
                
                // Кнопка повторной отправки
                TextButton(
                  onPressed: _resendTimer > 0 ? null : _resendCode,
                  child: Text(
                    _resendTimer > 0 
                        ? 'Отправить повторно через $_resendTimer сек'
                        : 'Отправить код повторно',
                    style: TextStyle(
                      color: _resendTimer > 0 ? Colors.grey : AppConstants.primaryColor,
                    ),
                  ),
                ),
                
                const SizedBox(height: 40),
              ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}