// Splash Screen untuk aplikasi Bakso Djatigiri
// Menampilkan logo dan nama aplikasi saat startup

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/color_pallete.dart';
import '../../../features/auth/bloc/auth_bloc.dart';
import 'dart:async';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  // Animator untuk efek fade in logo
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    // Setup animasi fade in dan scale untuk logo
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.2, 0.8, curve: Curves.easeOutBack),
      ),
    );

    // Mulai animasi
    _animationController.forward();

    // Delay sebelum navigasi ke halaman berikutnya
    Timer(const Duration(seconds: 3), () {
      // Trigger pengecekan user saat startup
      context.read<AuthBloc>().add(CheckCurrentUserEvent());
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is Authenticated) {
          // Navigasi ke home jika sudah login
          Navigator.of(context).pushReplacementNamed('/home');
        } else if (state is Unauthenticated) {
          // Navigasi ke login jika belum login
          Navigator.of(context).pushReplacementNamed('/login');
        }
      },
      child: Scaffold(
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
                        // Logo aplikasi
                        Container(
                          width: 180,
                          height: 180,
                          // decoration: BoxDecoration(
                          //   shape: BoxShape.circle,
                          //   color: white900.withOpacity(0.9),
                          //   boxShadow: [
                          //     BoxShadow(
                          //       color: Colors.black.withOpacity(0.1),
                          //       blurRadius: 20,
                          //       offset: const Offset(0, 10),
                          //     ),
                          //   ],
                          // ),
                          padding: const EdgeInsets.all(20),
                          child: Image.asset(
                            'assets/images/logo_bakso_djatigiri.png',
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(
                                Icons.restaurant,
                                size: 100,
                                color: primary950,
                              );
                            },
                          ),
                        ),

                        const SizedBox(height: 32),

                        // Nama aplikasi
                        const Text(
                          'Bakso Djatigiri',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: white900,
                            fontFamily: 'Poppins',
                            shadows: [
                              Shadow(
                                color: Colors.black26,
                                blurRadius: 5,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 8),

                        // Tagline
                        Text(
                          'Sistem Kasir & Manajemen Stok',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                            color: white900.withOpacity(0.9),
                            fontFamily: 'Poppins',
                          ),
                        ),

                        const SizedBox(height: 48),

                        // Loading indicator
                        SizedBox(
                          width: 30,
                          height: 30,
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(white900),
                            strokeWidth: 2.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
