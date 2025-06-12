// Splash screen untuk aplikasi Bakso Djatigiri
// Menampilkan logo dengan animasi fade dan gradient background
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:mie_bakso_djatigiri/core/theme/color_pallete.dart';
import 'package:mie_bakso_djatigiri/core/animation/page_transitions.dart';
// Tidak perlu mengimport AuthWrapper karena kita akan menggunakan named route
// import 'package:mie_bakso_djatigiri/features/auth/presentation/pages/auth_wrapper.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  // Animator untuk efek fade in dan scaling
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  // Flag untuk mencegah navigasi berulang
  bool _isNavigating = false;

  @override
  void initState() {
    super.initState();

    // Setup animasi
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.7, curve: Curves.easeInOut),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.2, 0.8, curve: Curves.easeInOut),
      ),
    );

    // Jalankan animasi
    _animationController.forward();

    // Navigasi ke halaman auth setelah selesai splash screen
    Timer(
      const Duration(seconds: 3),
      () {
        // Cek flag untuk mencegah navigasi berulang
        if (!_isNavigating && mounted) {
          setState(() {
            _isNavigating = true;
          });

          // Menggunakan named route untuk navigasi ke halaman auth
          Navigator.of(context).pushReplacementNamed('/auth');
        }
      },
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Dapatkan ukuran layar untuk layout yang responsive
    final Size screenSize = MediaQuery.of(context).size;
    final double logoSize =
        screenSize.width * 0.5 > 200 ? 200 : screenSize.width * 0.5;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: diagonal01, // Gradient dari color_pallete.dart
        ),
        child: Center(
          child: AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return FadeTransition(
                opacity: _fadeAnimation,
                child: Transform.scale(
                  scale: _scaleAnimation.value,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Logo dengan error handling dan nama file tanpa spasi
                      Image.asset(
                        'assets/images/logo_bakso_djatigiri.png',
                        width: logoSize,
                        height: logoSize,
                        errorBuilder: (context, error, stackTrace) {
                          debugPrint('Error loading logo: $error');
                          // Coba alternatif nama file jika yang pertama gagal
                          return Image.asset(
                            'assets/images/logo BD 1.png',
                            width: logoSize,
                            height: logoSize,
                            errorBuilder: (context, error, stackTrace) {
                              debugPrint(
                                  'Error loading alternative logo: $error');
                              // Fallback jika kedua gambar tidak dapat dimuat
                              return Container(
                                width: logoSize,
                                height: logoSize,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.restaurant,
                                  size: 80,
                                  color: white900,
                                ),
                              );
                            },
                          );
                        },
                      ),

                      const SizedBox(height: 32),

                      // Nama aplikasi
                      const Text(
                        'Bakso Djatigiri',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: white900,
                        ),
                      ),

                      const SizedBox(height: 8),

                      // Tagline
                      const Text(
                        'Nikmat - Hangat - Terjangkau',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          color: white900,
                        ),
                      ),

                      // Indikator loading
                      const SizedBox(height: 40),
                      const CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(white900),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
