import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:secret_location_chat/core/theme/app_colors.dart';
import 'package:secret_location_chat/core/widgets/slc_button.dart';
import 'package:secret_location_chat/features/app/presentation/bloc/app_auth_bloc.dart';

/// Стартовый экран — заглушка с кнопками «Включить локацию» и «Играть»
/// Стиль: маска + красная спираль на чёрном фоне (Cyberpunk / Y2K)
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _spiralController;

  @override
  void initState() {
    super.initState();
    _spiralController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();

    // Проверяем авторизацию при старте
    context.read<AppAuthBloc>().add(AppAuthCheckEvent());
  }

  @override
  void dispose() {
    _spiralController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AppAuthBloc, AppAuthState>(
      listener: (context, state) {
        if (state is AppAuthAuthenticatedState) {
          context.go('/map');
        } else if (state is AppAuthUnauthenticatedState) {
          // Остаёмся на сплаше — пользователь нажимает кнопки
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: Stack(
          children: [
            // ── Фоновая анимированная спираль ──
            Positioned.fill(
              child: AnimatedBuilder(
                animation: _spiralController,
                builder: (context, child) {
                  return CustomPaint(
                    painter: _SpiralPainter(_spiralController.value),
                  );
                },
              ),
            ),

            // ── Основной контент ──
            SafeArea(
              child: Column(
                children: [
                  const Spacer(flex: 2),

                  // Логотип / маска
                  _MaskLogo(),

                  const SizedBox(height: 16),

                  // Название
                  const Text(
                    'SECRET\nLOCATION\nCHAT',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.neonRed,
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 6,
                      height: 1.1,
                    ),
                  ),

                  const SizedBox(height: 8),
                  const Text(
                    '// АНОНИМНЫЙ ГЕО-МЕССЕНДЖЕР //',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 10,
                      letterSpacing: 2,
                    ),
                  ),

                  const Spacer(flex: 2),

                  // Кнопки
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Column(
                      children: [
                        SlcButton(
                          text: '⦿  Включить локацию',
                          onTap: () => context.go('/map'),
                        ),
                        const SizedBox(height: 16),
                        SlcButton(
                          text: 'Войти',
                          isOutlined: true,
                          onTap: () => context.go('/auth'),
                        ),
                        const SizedBox(height: 12),
                        GestureDetector(
                          onTap: () => context.go('/register'),
                          child: const Text(
                            'Нет аккаунта? Регайся →',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 13,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 48),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Рисует анимированную красную спираль на чёрном фоне
class _SpiralPainter extends CustomPainter {
  final double progress;

  _SpiralPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.neonRed.withValues(alpha: 0.12)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final center = Offset(size.width / 2, size.height / 2);
    const turns = 6;
    const pointsPerTurn = 100;

    final path = Path();
    bool first = true;

    for (int i = 0; i < turns * pointsPerTurn; i++) {
      final t = i / (turns * pointsPerTurn);
      final angle = t * turns * 2 * 3.14159 + progress * 2 * 3.14159;
      final radius = t * (size.width * 0.45);
      final x = center.dx + radius * (0 + 1 * (i % 2 == 0 ? 1 : -1)) *
          (0.5 * (angle - progress * 6.28).abs() % 3.14159 < 1.57 ? 1 : -1);
      // Упрощённая спираль
      final px = center.dx + radius * _cos(angle);
      final py = center.dy + radius * _sin(angle);

      if (first) {
        path.moveTo(px, py);
        first = false;
      } else {
        path.lineTo(px, py);
      }
    }

    canvas.drawPath(path, paint);
  }

  double _cos(double radians) {
    // dart:math не импортирован здесь, используем приближение через серию
    return _sin(radians + 1.5707963);
  }

  double _sin(double radians) {
    // Нормализуем к [-π, π]
    double r = radians % (2 * 3.14159265);
    if (r > 3.14159265) r -= 2 * 3.14159265;
    if (r < -3.14159265) r += 2 * 3.14159265;
    // Приближение Тейлора
    return r - (r * r * r) / 6 + (r * r * r * r * r) / 120;
  }

  @override
  bool shouldRepaint(_SpiralPainter old) => old.progress != progress;
}

/// Иконка маски (ASCII-арт стиль с виджетами)
class _MaskLogo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.neonRed, width: 2),
        boxShadow: [
          BoxShadow(
            color: AppColors.neonRedGlow,
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: const Center(
        child: Text(
          '◉',
          style: TextStyle(
            fontSize: 48,
            color: AppColors.neonRed,
          ),
        ),
      ),
    );
  }
}
