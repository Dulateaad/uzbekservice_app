import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../constants/app_constants.dart';
import '../../providers/auth_provider.dart';

class LottieSplashScreen extends ConsumerStatefulWidget {
  const LottieSplashScreen({super.key});

  @override
  ConsumerState<LottieSplashScreen> createState() => _LottieSplashScreenState();
}

class _LottieSplashScreenState extends ConsumerState<LottieSplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _mainController;
  late AnimationController _textController;
  late AnimationController _progressController;
  
  late Animation<double> _logoScaleAnimation;
  late Animation<double> _logoRotationAnimation;
  late Animation<double> _logoOpacityAnimation;
  late Animation<Offset> _textSlideAnimation;
  late Animation<double> _textOpacityAnimation;
  late Animation<double> _progressAnimation;
  late Animation<double> _backgroundAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startAnimationSequence();
  }

  void _initializeAnimations() {
    // Основной контроллер
    _mainController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    
    // Контроллер для текста
    _textController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    // Контроллер для прогресса
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    // Анимации логотипа
    _logoScaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _mainController,
      curve: const Interval(0.0, 0.6, curve: Curves.elasticOut),
    ));

    _logoRotationAnimation = Tween<double>(
      begin: -0.2,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _mainController,
      curve: const Interval(0.0, 0.8, curve: Curves.easeOutBack),
    ));

    _logoOpacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _mainController,
      curve: const Interval(0.0, 0.4, curve: Curves.easeIn),
    ));

    // Анимации текста
    _textSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.8),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _textController,
      curve: Curves.easeOutCubic,
    ));

    _textOpacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _textController,
      curve: Curves.easeIn,
    ));

    // Анимация прогресса
    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeInOut,
    ));

    // Анимация фона
    _backgroundAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _mainController,
      curve: Curves.easeInOut,
    ));
  }

  void _startAnimationSequence() async {
    // Запускаем основную анимацию
    await _mainController.forward();
    
    // Запускаем анимацию текста
    await _textController.forward();
    
    // Запускаем анимацию прогресса
    await _progressController.forward();
    
    // Небольшая задержка для демонстрации
    await Future.delayed(const Duration(milliseconds: 500));
    
    // Проверяем статус аутентификации
    _checkAuthStatus();
  }

  @override
  void dispose() {
    _mainController.dispose();
    _textController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  void _checkAuthStatus() {
    final authState = ref.read(authProvider);
    
    if (authState.isAuthenticated) {
      context.go('/home');
    } else {
      context.go('/auth/phone');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: _backgroundAnimation,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppConstants.primaryColor,
                  AppConstants.primaryColor.withOpacity(0.8),
                  AppConstants.secondaryColor,
                  AppConstants.secondaryColor.withOpacity(0.9),
                ],
                stops: [
                  0.0,
                  0.3 * _backgroundAnimation.value,
                  0.7 * _backgroundAnimation.value,
                  1.0,
                ],
              ),
            ),
            child: Stack(
              children: [
                // Анимированный фон
                _buildAnimatedBackground(),
                
                // Основной контент
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Анимированный логотип
                      _buildAnimatedLogo(),
                      
                      const SizedBox(height: 50),
                      
                      // Анимированный текст
                      _buildAnimatedText(),
                      
                      const SizedBox(height: 80),
                      
                      // Анимированный прогресс
                      _buildAnimatedProgress(),
                    ],
                  ),
                ),
                
                // Дополнительные элементы
                _buildFloatingElements(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildAnimatedBackground() {
    return CustomPaint(
      painter: AnimatedBackgroundPainter(_backgroundAnimation.value),
      size: Size.infinite,
    );
  }

  Widget _buildAnimatedLogo() {
    return AnimatedBuilder(
      animation: _mainController,
      builder: (context, child) {
        return Transform.scale(
          scale: _logoScaleAnimation.value,
          child: Transform.rotate(
            angle: _logoRotationAnimation.value,
            child: Opacity(
              opacity: _logoOpacityAnimation.value,
              child: Container(
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white,
                      Colors.white.withOpacity(0.95),
                      Colors.white.withOpacity(0.9),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(40),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 40,
                      offset: const Offset(0, 20),
                    ),
                    BoxShadow(
                      color: Colors.white.withOpacity(0.4),
                      blurRadius: 30,
                      offset: const Offset(0, -10),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    // Основной логотип
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Главный текст
                          ShaderMask(
                            shaderCallback: (bounds) => LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                AppConstants.primaryColor,
                                AppConstants.secondaryColor,
                                AppConstants.primaryColor,
                              ],
                            ).createShader(bounds),
                            child: const Text(
                              'ODO',
                              style: TextStyle(
                                fontSize: 42,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: 2,
                              ),
                            ),
                          ),
                          
                          const SizedBox(height: 6),
                          
                          // Подтекст
                          Text(
                            '.UZ',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: AppConstants.primaryColor,
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Декоративные элементы
                    Positioned(
                      top: 20,
                      right: 20,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: AppConstants.primaryColor.withOpacity(0.6),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    
                    Positioned(
                      bottom: 20,
                      left: 20,
                      child: Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: AppConstants.secondaryColor.withOpacity(0.6),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAnimatedText() {
    return SlideTransition(
      position: _textSlideAnimation,
      child: FadeTransition(
        opacity: _textOpacityAnimation,
        child: Column(
          children: [
            // Название приложения
            ShaderMask(
              shaderCallback: (bounds) => LinearGradient(
                colors: [
                  Colors.white,
                  Colors.white.withOpacity(0.9),
                ],
              ).createShader(bounds),
              child: const Text(
                'ODO.UZ',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 1,
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Подзаголовок
            const Text(
              'Найдите специалиста рядом с вами',
              style: TextStyle(
                fontSize: 18,
                color: Colors.white70,
                fontWeight: FontWeight.w400,
                letterSpacing: 0.5,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 12),
            
            // Дополнительный текст
            const Text(
              'Быстро • Надежно • Удобно',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white60,
                fontWeight: FontWeight.w300,
                letterSpacing: 0.3,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedProgress() {
    return AnimatedBuilder(
      animation: _progressAnimation,
      builder: (context, child) {
        return Column(
          children: [
            // Кастомный прогресс бар
            Container(
              width: 250,
              height: 6,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(3),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: _progressAnimation.value,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.white,
                        Colors.white.withOpacity(0.8),
                        Colors.white,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Текст загрузки с анимацией
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Загрузка',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white.withOpacity(0.9),
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(width: 8),
                _buildLoadingDots(),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildLoadingDots() {
    return Row(
      children: List.generate(3, (index) {
        return AnimatedBuilder(
          animation: _progressController,
          builder: (context, child) {
            final delay = index * 0.2;
            final animationValue = (_progressController.value - delay).clamp(0.0, 1.0);
            final opacity = (1.0 - animationValue) * 0.5 + 0.5;
            
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 2),
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(opacity),
                shape: BoxShape.circle,
              ),
            );
          },
        );
      }),
    );
  }

  Widget _buildFloatingElements() {
    return Stack(
      children: [
        // Плавающие элементы
        Positioned(
          top: 100,
          right: 60,
          child: AnimatedBuilder(
            animation: _mainController,
            builder: (context, child) {
              return Transform.rotate(
                angle: _mainController.value * 2 * 3.14159,
                child: Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                ),
              );
            },
          ),
        ),
        
        Positioned(
          bottom: 150,
          left: 40,
          child: AnimatedBuilder(
            animation: _mainController,
            builder: (context, child) {
              return Transform.rotate(
                angle: -_mainController.value * 2 * 3.14159,
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.08),
                    shape: BoxShape.circle,
                  ),
                ),
              );
            },
          ),
        ),
        
        Positioned(
          top: 200,
          left: 80,
          child: AnimatedBuilder(
            animation: _mainController,
            builder: (context, child) {
              return Transform.rotate(
                angle: _mainController.value * 3.14159,
                child: Container(
                  width: 15,
                  height: 15,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.06),
                    shape: BoxShape.circle,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

// Кастомный painter для анимированного фона
class AnimatedBackgroundPainter extends CustomPainter {
  final double animationValue;

  AnimatedBackgroundPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.05)
      ..style = PaintingStyle.fill;

    // Создаем волны
    final path = Path();
    final waveHeight = 50.0;
    final waveLength = size.width / 3;
    
    path.moveTo(0, size.height * 0.3);
    
    for (double x = 0; x <= size.width; x += 1) {
      final y = size.height * 0.3 + 
                waveHeight * math.sin((x / waveLength) * 2 * math.pi + animationValue * 2 * math.pi);
      path.lineTo(x, y);
    }
    
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// Импорт для math
import 'dart:math' as math;
