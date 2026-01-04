import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:kreo_weather/app/theme/app_colors.dart';

class SplashScreen extends StatefulWidget {
  final VoidCallback onComplete;

  const SplashScreen({super.key, required this.onComplete});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  double _progress = 0.0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    );

    _controller.addListener(() {
      setState(() {
        _progress = _controller.value;
      });
    });

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onComplete();
      }
    });

    // Start loading animation
    Future.delayed(const Duration(milliseconds: 300), () {
      _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo
              ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: Image.asset(
                      'assets/images/kreo_weather_logo.jpg',
                      width: 120,
                      height: 120,
                      fit: BoxFit.cover,
                    ),
                  )
                  .animate()
                  .fadeIn(duration: 600.ms)
                  .scale(
                    begin: const Offset(0.8, 0.8),
                    end: const Offset(1, 1),
                  ),

              const SizedBox(height: 40),

              // App Name
              Text(
                'KREO WEATHER',
                style: AppTextStyles.label(
                  color: AppColors.primary,
                ).copyWith(letterSpacing: 6, fontSize: 14),
              ).animate().fadeIn(delay: 300.ms),

              const SizedBox(height: 48),

              // Progress Bar
              Container(
                width: 200,
                height: 2,
                decoration: BoxDecoration(
                  color: AppColors.divider,
                  borderRadius: BorderRadius.circular(1),
                ),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 50),
                    width: 200 * _progress,
                    height: 2,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(1),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Loading Text
              Text(
                '${(_progress * 100).toInt()}%',
                style: AppTextStyles.labelSmall(
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
