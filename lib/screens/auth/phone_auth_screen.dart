import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../constants/app_constants.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/gradient_button.dart';
import '../../widgets/glass_card.dart';
import '../../services/simple_sms_service.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/simple_country_selector.dart';

class PhoneAuthScreen extends ConsumerStatefulWidget {
  const PhoneAuthScreen({super.key});

  @override
  ConsumerState<PhoneAuthScreen> createState() => _PhoneAuthScreenState();
}

class _PhoneAuthScreenState extends ConsumerState<PhoneAuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _smsService = SimpleSmsService();
  bool _isLoading = false;
  String _selectedUserType = 'client'; // client или specialist
  String _selectedCountryCode = 'UZ';

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  String _getPhoneHint() {
    if (_selectedCountryCode == 'UZ') {
      return '+998 90 123 45 67';
    } else {
      return '+7 777 123 45 67';
    }
  }

  void _sendSms() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      if (_selectedUserType == 'client') {
        // Для клиентов - отправляем SMS через простой сервис
        final success = await _smsService.sendSmsCode(_phoneController.text);
        
        if (success) {
          if (mounted) {
            print('📱 Переходим на SMS экран с номером: ${_phoneController.text}');
            
            // Сохраняем номер телефона в AuthProvider
            ref.read(authProvider.notifier).setPhoneNumber(_phoneController.text);
            
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('SMS код отправлен! Проверьте консоль для получения кода.'),
                backgroundColor: Colors.green,
              ),
            );
            context.go('/auth/sms', extra: _phoneController.text);
          }
        } else {
          throw Exception('Ошибка отправки SMS');
        }
      } else {
        // Для специалистов - переходим к OneID
        if (mounted) {
          context.go('/auth/oneid', extra: _phoneController.text);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 40),
                
                // Логотип
                Center(
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: AppConstants.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(
                      Icons.phone_android,
                      size: 50,
                      color: AppConstants.primaryColor,
                    ),
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // Заголовок
                const Text(
                  'Введите номер телефона',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 8),
                
                // Подзаголовок
                const Text(
                  'Мы отправим SMS с кодом подтверждения',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 24),
                
                // Выбор типа пользователя
                const Text(
                  'Выберите тип входа:',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Клиент - SMS
                Card(
                  elevation: _selectedUserType == 'client' ? 4 : 1,
                  color: _selectedUserType == 'client' 
                      ? AppConstants.primaryColor.withOpacity(0.1) 
                      : Colors.white,
                  child: RadioListTile<String>(
                    title: const Text('Клиент'),
                    subtitle: const Text('Вход через SMS'),
                    value: 'client',
                    groupValue: _selectedUserType,
                    onChanged: (value) {
                      setState(() {
                        _selectedUserType = value!;
                      });
                    },
                    activeColor: AppConstants.primaryColor,
                  ),
                ),
                
                const SizedBox(height: 8),
                
                // Специалист - OneID
                Card(
                  elevation: _selectedUserType == 'specialist' ? 4 : 1,
                  color: _selectedUserType == 'specialist' 
                      ? AppConstants.secondaryColor.withOpacity(0.1) 
                      : Colors.white,
                  child: RadioListTile<String>(
                    title: const Text('Специалист'),
                    subtitle: const Text('Вход через OneID'),
                    value: 'specialist',
                    groupValue: _selectedUserType,
                    onChanged: (value) {
                      setState(() {
                        _selectedUserType = value!;
                      });
                    },
                    activeColor: AppConstants.secondaryColor,
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Выбор страны
                Text(
                  'Выберите страну',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 12),
                SimpleCountrySelector(
                  selectedCountryCode: _selectedCountryCode,
                  onChanged: (countryCode) {
                    setState(() {
                      _selectedCountryCode = countryCode;
                    });
                  },
                ),
                
                const SizedBox(height: 24),
                
                // Поле ввода телефона
                CustomTextField(
                  controller: _phoneController,
                  labelText: 'Номер телефона',
                  hintText: _getPhoneHint(),
                  keyboardType: TextInputType.phone,
                  prefixIcon: const Icon(Icons.phone),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Введите номер телефона';
                    }
                    if (value.length < 9) {
                      return 'Номер телефона слишком короткий';
                    }
                    // Проверяем на узбекские (+998) и казахские (+7) номера
                    if (!value.startsWith('+998') && !value.startsWith('+7')) {
                      return 'Введите корректный номер (+998 или +7)';
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: 32),
                
                // Кнопка отправки
                CustomButton(
                  text: _selectedUserType == 'client' ? 'Отправить SMS' : 'Войти через OneID',
                  onPressed: _isLoading ? null : _sendSms,
                  isLoading: _isLoading,
                ),
                
                const SizedBox(height: 24),
                
                // Информация о конфиденциальности
                const Text(
                  'Нажимая "Отправить код", вы соглашаетесь с условиями использования и политикой конфиденциальности',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}