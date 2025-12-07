import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../constants/app_constants.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/gradient_button.dart';
import '../../widgets/glass_card.dart';
import '../../services/firebase_auth_service.dart';
import '../../providers/firestore_auth_provider.dart';
import '../../widgets/simple_country_selector.dart';

class PhoneAuthScreen extends ConsumerStatefulWidget {
  const PhoneAuthScreen({super.key});

  @override
  ConsumerState<PhoneAuthScreen> createState() => _PhoneAuthScreenState();
}

class _PhoneAuthScreenState extends ConsumerState<PhoneAuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _firebaseAuthService = FirebaseAuthService();
  bool _isLoading = false;
  String _selectedUserType = 'client'; // client или specialist
  String _selectedCountryCode = 'UZ';
  String? _verificationId;

  @override
  void initState() {
    super.initState();
    // Устанавливаем начальный префикс в зависимости от выбранной страны
    _phoneController.text = _selectedCountryCode == 'UZ' ? '+998' : '+7';
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  String _getPhoneHint() {
    if (_selectedCountryCode == 'UZ') {
      return '90 123 45 67';
    } else {
      return '777 123 45 67';
    }
  }
  
  // Обновляет префикс в поле ввода при смене страны
  void _updatePhonePrefix(String countryCode) {
    final currentText = _phoneController.text.trim();
    
    // Убираем старый префикс если есть
    String numberWithoutPrefix = currentText;
    if (numberWithoutPrefix.startsWith('+998')) {
      numberWithoutPrefix = numberWithoutPrefix.substring(4);
    } else if (numberWithoutPrefix.startsWith('+7')) {
      numberWithoutPrefix = numberWithoutPrefix.substring(2);
    } else if (numberWithoutPrefix.startsWith('998')) {
      numberWithoutPrefix = numberWithoutPrefix.substring(3);
    } else if (numberWithoutPrefix.startsWith('7') && numberWithoutPrefix.length > 10) {
      numberWithoutPrefix = numberWithoutPrefix.substring(1);
    }
    
    // Убираем все пробелы, дефисы
    numberWithoutPrefix = numberWithoutPrefix.replaceAll(RegExp(r'[\s\-\(\)]'), '');
    
    // Добавляем новый префикс
    String newPrefix = countryCode == 'UZ' ? '+998' : '+7';
    String newText = numberWithoutPrefix.isEmpty ? newPrefix : '$newPrefix$numberWithoutPrefix';
    
    _phoneController.text = newText;
    // Перемещаем курсор в конец
    _phoneController.selection = TextSelection.fromPosition(
      TextPosition(offset: _phoneController.text.length),
    );
  }

  void _sendSms() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      if (_selectedUserType == 'client') {
        // Форматируем номер телефона
        String phoneNumber = _phoneController.text.trim();
        
        // Убираем все пробелы, дефисы и скобки
        phoneNumber = phoneNumber.replaceAll(RegExp(r'[\s\-\(\)]'), '');
        
        if (!phoneNumber.startsWith('+')) {
          if (_selectedCountryCode == 'UZ') {
            // Узбекистан: +998XXXXXXXXX (13 символов)
            if (phoneNumber.startsWith('998')) {
              phoneNumber = '+$phoneNumber';
            } else if (phoneNumber.startsWith('9') && phoneNumber.length == 9) {
              // 9XXXXXXXX (9 цифр) -> +9989XXXXXXXX
              phoneNumber = '+998$phoneNumber';
            } else if (phoneNumber.length >= 9) {
              phoneNumber = '+998$phoneNumber';
            } else {
              phoneNumber = '+998$phoneNumber';
            }
          } else if (_selectedCountryCode == 'KZ') {
            // Казахстан: +7XXXXXXXXXX (12 символов, 11 цифр после +)
            if (phoneNumber.startsWith('7') && phoneNumber.length == 11) {
              // 7XXXXXXXXXX (11 цифр, начинается с 7) -> +7XXXXXXXXXX
              phoneNumber = '+$phoneNumber';
            } else if (phoneNumber.startsWith('7') && phoneNumber.length == 10) {
              // 7XXXXXXXXX (10 цифр) -> +7XXXXXXXXXX (добавляем еще одну цифру? Нет, это неправильно)
              // Если 10 цифр начинается с 7, возможно это уже правильный формат без первой 7
              phoneNumber = '+7$phoneNumber';
            } else if (!phoneNumber.startsWith('7') && phoneNumber.length == 10) {
              // XXXXXXXXXX (10 цифр, не начинается с 7) -> +7XXXXXXXXXX
              phoneNumber = '+7$phoneNumber';
            } else if (phoneNumber.length == 9) {
              // XXXXXXXXX (9 цифр) -> +7XXXXXXXXXX (добавляем 7 в начало)
              phoneNumber = '+7$phoneNumber';
            } else {
              // По умолчанию добавляем +7
              phoneNumber = '+7$phoneNumber';
            }
          }
        }
        
        print('🌍 Страна: $_selectedCountryCode, Введенный номер: ${_phoneController.text}, Отформатированный: $phoneNumber');

        print('📱 Отправка SMS на номер: $phoneNumber');
        
        // Сохраняем номер телефона в провайдере
        ref.read(firestoreAuthProvider.notifier).setPhoneNumber(phoneNumber);
        
        // Отправляем SMS через Firebase Phone Authentication
        final result = await _firebaseAuthService.sendSmsCode(phoneNumber);
        
        if (result['success'] == true) {
          _verificationId = result['verificationId'] as String?;
          
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('✅ SMS код отправлен! Проверьте телефон.'),
                backgroundColor: Colors.green,
                duration: Duration(seconds: 3),
              ),
            );
            
            // Переходим на экран ввода кода
            context.go('/auth/sms', extra: {
              'phoneNumber': phoneNumber,
              'verificationId': _verificationId,
            });
          }
        } else {
          throw Exception(result['error'] ?? 'Ошибка отправки SMS');
        }
      } else {
        // Для специалистов - переходим к OneID
        if (mounted) {
          context.go('/auth/oneid', extra: _phoneController.text);
        }
      }
    } catch (e) {
      print('❌ Ошибка отправки SMS: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
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
                      // Автоматически добавляем префикс при смене страны
                      _updatePhonePrefix(countryCode);
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
                  prefixIcon: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(width: 12),
                      const Icon(Icons.phone),
                      const SizedBox(width: 8),
                      Text(
                        _selectedCountryCode == 'UZ' ? '+998' : '+7',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppConstants.primaryColor,
                        ),
                      ),
                    ],
                  ),
                  onChanged: (value) {
                    // Автоматически добавляем префикс если его нет
                    if (!value.startsWith('+')) {
                      final prefix = _selectedCountryCode == 'UZ' ? '+998' : '+7';
                      if (!value.startsWith(prefix)) {
                        _phoneController.value = TextEditingValue(
                          text: prefix + value,
                          selection: TextSelection.collapsed(offset: (prefix + value).length),
                        );
                      }
                    }
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Введите номер телефона';
                    }
                    // Проверяем, что номер начинается с правильного префикса
                    final expectedPrefix = _selectedCountryCode == 'UZ' ? '+998' : '+7';
                    if (!value.startsWith(expectedPrefix)) {
                      return 'Номер должен начинаться с $expectedPrefix';
                    }
                    // Проверяем минимальную длину (префикс + минимум 9 цифр)
                    final numberOnly = value.replaceAll(RegExp(r'[^\d]'), '');
                    if (numberOnly.length < (_selectedCountryCode == 'UZ' ? 12 : 11)) {
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