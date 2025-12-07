import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../constants/app_constants.dart';
import '../../services/oneid_service.dart';
import '../../services/firestore_service.dart';
import '../../models/firestore_models.dart';
import '../../providers/firestore_auth_provider.dart';

class SpecialistOneIdLoginScreen extends ConsumerStatefulWidget {
  const SpecialistOneIdLoginScreen({super.key});

  @override
  ConsumerState<SpecialistOneIdLoginScreen> createState() =>
      _SpecialistOneIdLoginScreenState();
}

class _SpecialistOneIdLoginScreenState
    extends ConsumerState<SpecialistOneIdLoginScreen> {
  final _oneIdService = OneIdService();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.spacingXL),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 60),
              
              // Логотип
              Center(
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    gradient: AppConstants.primaryGradient,
                    borderRadius: BorderRadius.circular(AppConstants.radiusXL),
                    boxShadow: [
                      BoxShadow(
                        color: AppConstants.primaryColor.withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.person_outline,
                    size: 50,
                    color: Colors.white,
                  ),
                ),
              ),
              
              const SizedBox(height: AppConstants.spacingXL),
              
              // Заголовок
              Text(
                'Вход для специалистов',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppConstants.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: AppConstants.spacingMD),
              
              Text(
                'Используйте OneID для быстрой и безопасной авторизации',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppConstants.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 60),
              
              // OneID Button
              _buildOneIdButton(),
              
              if (_errorMessage != null) ...[
                const SizedBox(height: AppConstants.spacingLG),
                _buildErrorMessage(),
              ],
              
              const SizedBox(height: AppConstants.spacingXL),
              
              // Преимущества
              _buildBenefitsSection(),
              
              const SizedBox(height: AppConstants.spacingXL),
              
              // Кнопка назад
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text(
                  'Вернуться назад',
                  style: TextStyle(
                    color: AppConstants.textSecondary,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOneIdButton() {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0066CC), Color(0xFF0052A3)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppConstants.radiusLG),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0066CC).withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _isLoading ? null : _handleOneIdLogin,
          borderRadius: BorderRadius.circular(AppConstants.radiusLG),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_isLoading)
                  const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                else ...[
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.fingerprint,
                      color: Color(0xFF0066CC),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Text(
                    'Войти через OneID',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorMessage() {
    return Container(
      padding: const EdgeInsets.all(AppConstants.spacingMD),
      decoration: BoxDecoration(
        color: AppConstants.errorColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppConstants.radiusLG),
        border: Border.all(
          color: AppConstants.errorColor.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.error_outline,
            color: AppConstants.errorColor,
          ),
          const SizedBox(width: AppConstants.spacingMD),
          Expanded(
            child: Text(
              _errorMessage!,
              style: TextStyle(
                color: AppConstants.errorColor,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBenefitsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Преимущества OneID:',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppConstants.spacingMD),
        _buildBenefitItem(
          Icons.security,
          'Безопасность',
          'Государственная система идентификации',
        ),
        _buildBenefitItem(
          Icons.flash_on,
          'Быстрота',
          'Вход за несколько секунд',
        ),
        _buildBenefitItem(
          Icons.verified_user,
          'Верификация',
          'Автоматическая проверка данных',
        ),
      ],
    );
  }

  Widget _buildBenefitItem(IconData icon, String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppConstants.spacingMD),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: AppConstants.primaryGradient.scale(0.2),
              borderRadius: BorderRadius.circular(AppConstants.radiusLG),
            ),
            child: Icon(
              icon,
              color: AppConstants.primaryColor,
              size: 24,
            ),
          ),
          const SizedBox(width: AppConstants.spacingMD),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                Text(
                  description,
                  style: TextStyle(
                    color: AppConstants.textSecondary,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleOneIdLogin() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Запускаем OAuth flow
      final started = await _oneIdService.startAuthFlow();

      if (!started) {
        setState(() {
          _errorMessage = 'Не удалось открыть OneID. Проверьте подключение к интернету.';
          _isLoading = false;
        });
        return;
      }

      // Callback будет обработан через deep link
      // См. _handleDeepLink в main.dart
      
      // Здесь можно показать подсказку пользователю
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Завершите авторизацию в браузере'),
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Ошибка: $e';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// Обработка результата OneID авторизации
  Future<void> handleOneIdCallback(OneIdAuthResult result) async {
    if (!result.success) {
      setState(() {
        _errorMessage = result.error ?? 'Ошибка авторизации';
        _isLoading = false;
      });
      return;
    }

    if (result.user == null || result.accessToken == null) {
      setState(() {
        _errorMessage = 'Не удалось получить данные пользователя';
        _isLoading = false;
      });
      return;
    }

    try {
      // Создаём или обновляем пользователя в Firestore
      final user = await _createOrUpdateUser(result.user!, result.accessToken!);

      // Обновляем состояние провайдера авторизации
      final authState = ref.read(firestoreAuthProvider);
      ref.read(firestoreAuthProvider.notifier).state = authState.copyWith(user: user);

      // Переходим на главный экран
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/home');
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Ошибка сохранения данных: $e';
        _isLoading = false;
      });
    }
  }

  Future<FirestoreUser> _createOrUpdateUser(
    OneIdUser oneIdUser,
    String accessToken,
  ) async {
    // Проверяем, существует ли пользователь по номеру телефона
    final existingUser = await FirestoreService.getUserByPhone(oneIdUser.phoneNumber ?? '');

    FirestoreUser user;

    if (existingUser != null) {
      // Обновляем существующего пользователя
      user = existingUser.copyWith(
        name: oneIdUser.fullNameLatin ?? oneIdUser.fullNameCyrillic ?? existingUser.name,
        email: oneIdUser.email ?? existingUser.email,
        phoneNumber: oneIdUser.phoneNumber ?? existingUser.phoneNumber,
        updatedAt: DateTime.now(),
      );

      await FirestoreService.updateUser(user);
    } else {
      // Создаём нового пользователя
      user = FirestoreUser(
        id: '', // Будет заполнено в createUser
        phoneNumber: oneIdUser.phoneNumber ?? '',
        name: oneIdUser.fullNameLatin ?? oneIdUser.fullNameCyrillic ?? 'Специалист',
        userType: 'specialist',
        email: oneIdUser.email,
        oneIdSub: null, // OneID sub будет сохранен отдельно если нужно
        isVerified: true, // OneID пользователи автоматически верифицированы
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      user = await FirestoreService.createUser(user);
    }

    print('✅ Пользователь сохранён: ${user.name} (${user.id})');
    return user;
  }
}

