import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../constants/app_constants.dart';
import '../../config/oneid_config.dart';
import '../../providers/firestore_auth_provider.dart';
import '../../services/oneid_service.dart';
import '../../widgets/ios_liquid_button.dart';

class OneIdAuthScreen extends ConsumerStatefulWidget {
  final String phoneNumber;
  final String? code;
  final String? state;
  
  const OneIdAuthScreen({
    super.key,
    required this.phoneNumber,
    this.code,
    this.state,
  });

  @override
  ConsumerState<OneIdAuthScreen> createState() => _OneIdAuthScreenState();
}

class _OneIdAuthScreenState extends ConsumerState<OneIdAuthScreen> {
  final _oneIdService = OneIdService();
  bool _isLoading = false;
  bool _hasCheckedCallback = false;

  @override
  void initState() {
    super.initState();
    // Если есть code из deep link, обрабатываем его
    if (widget.code != null && !_hasCheckedCallback) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _handleOneIdCallback(widget.code!, widget.state);
      });
    }
  }

  /// Обрабатывает callback от OneID с кодом авторизации
  Future<void> _handleOneIdCallback(String code, String? state) async {
    if (_hasCheckedCallback) return;
    _hasCheckedCallback = true;

    setState(() {
      _isLoading = true;
    });

    try {
      print('🔐 Получен код от OneID: $code');
      
      // Обмениваем код на токен через backend
      final backendResponse = await _oneIdService.exchangeCodeForTokenViaBackend(
        code,
        OneIdConfig.redirectUri,
      );

      if (backendResponse == null || backendResponse.user == null) {
        throw 'Не удалось получить данные пользователя от backend';
      }

      final userInfo = backendResponse.user!;
      print('🔐 Получена информация о пользователе: ${userInfo.name}');
      
      // Логиним/создаем пользователя через OneID
      await ref.read(firestoreAuthProvider.notifier).loginWithOneId(
        oneIdSub: userInfo.sub,
        phoneNumber: userInfo.phoneNumber ?? widget.phoneNumber,
        name: userInfo.name,
        email: userInfo.email,
        userType: 'specialist',
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Успешный вход через OneID!'),
            backgroundColor: Colors.green,
          ),
        );
        
        context.go('/home');
      }
    } catch (e) {
      print('❌ Ошибка обработки callback OneID: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка входа: $e'),
            backgroundColor: Colors.red,
          ),
        );
        // Возвращаемся на экран авторизации
        context.go('/auth/oneid');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// Запускает процесс авторизации OneID (открывает браузер)
  Future<void> _loginWithOneId() async {
    setState(() {
      _isLoading = true;
    });

    try {
      print('🔐 Начинаем вход через OneID');
      
      // Открываем браузер для авторизации OneID
      final launched = await _oneIdService.launchAuthorization();
      
      if (!launched) {
        throw 'Не удалось открыть браузер для авторизации';
      }
      
      // Показываем сообщение, что нужно авторизоваться в браузере
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Откройте браузер и авторизуйтесь через OneID'),
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      print('❌ Ошибка запуска авторизации OneID: $e');
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
      appBar: AppBar(
        title: const Text('Вход через OneID'),
        backgroundColor: AppConstants.secondaryColor,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              
              // Логотип OneID
              Center(
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: AppConstants.secondaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppConstants.secondaryColor.withOpacity(0.3),
                      width: 2,
                    ),
                  ),
                  child: const Icon(
                    Icons.verified_user,
                    size: 60,
                    color: AppConstants.secondaryColor,
                  ),
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Заголовок
              const Text(
                'Вход через OneID',
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
                'Специалист: ${widget.phoneNumber}',
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 48),
              
              // Кнопка входа
              IOSLiquidButton(
                text: 'Войти через OneID',
                icon: Icons.login,
                onPressed: _isLoading ? null : _loginWithOneId,
                isLoading: _isLoading,
                backgroundColor: AppConstants.secondaryColor,
              ),
              
              const SizedBox(height: 24),
              
              // Информация
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.info_outline,
                        color: AppConstants.secondaryColor,
                        size: 24,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'OneID - это единая система идентификации для специалистов в Казахстане и Узбекистане',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppConstants.secondaryColor,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Client ID: odo_uz',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
