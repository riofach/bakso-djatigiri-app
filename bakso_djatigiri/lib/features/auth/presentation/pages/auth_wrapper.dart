// Wrapper Autentikasi
// Mengatur redirect ke login/register/home sesuai status autentikasi
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../bloc/auth_bloc.dart';
import '../../../../core/theme/color_pallete.dart';
import '../../../../core/animation/page_transitions.dart';
import '../../../../core/services/role_based_navigation_service.dart';
import '../pages/login_page.dart';

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper>
    with SingleTickerProviderStateMixin {
  // Animator untuk efek pulsating pada loading indicator
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    // Setup animasi pulsating untuk loading indicator
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    // Trigger pengecekan user saat startup
    Future.microtask(() {
      // ignore: use_build_context_synchronously
      context.read<AuthBloc>().add(CheckCurrentUserEvent());
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // Mengecek status login dari shared_preferences dan status user di Firestore saat aplikasi dibuka
  // ignore: unused_element
  Future<void> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool('is_logged_in') ?? false;
    if (isLoggedIn) {
      // Ambil user dari FirebaseAuth dan cek status di Firestore
      try {
        final user = FirebaseAuth.instance.currentUser;
        if (user == null) {
          // Tidak ada user login, paksa logout
          // ignore: use_build_context_synchronously
          context.read<AuthBloc>().add(LogoutEvent());
          return;
        }
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        if (!userDoc.exists) {
          // Data user tidak ditemukan di Firestore, paksa logout
          // ignore: use_build_context_synchronously
          context.read<AuthBloc>().add(LogoutEvent());
          return;
        }
        final data = userDoc.data()!;
        if (data['status'] != 'active') {
          // Jika status user tidak aktif, paksa logout
          // ignore: use_build_context_synchronously
          context.read<AuthBloc>().add(LogoutEvent());
          // Optional: Tampilkan pesan ke user (gunakan snackbar atau dialog jika perlu)
          return;
        }
        // Jika status aktif, biarkan AuthBloc tetap Authenticated dan lanjut ke home
      } catch (e) {
        // Jika error (misal koneksi/firestore), paksa logout
        // ignore: use_build_context_synchronously
        context.read<AuthBloc>().add(LogoutEvent());
      }
    } else {
      // Jika belum login, trigger event logout agar AuthBloc ke Unauthenticated
      // ignore: use_build_context_synchronously
      context.read<AuthBloc>().add(LogoutEvent());
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listenWhen: (prev, curr) =>
          curr is Authenticated || curr is Unauthenticated,
      listener: (context, state) {
        if (state is AuthError) {
          // Menampilkan pesan error ke user
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(state.message),
            backgroundColor: errorColor,
          ));
        }
        if (state is Authenticated) {
          // Navigasi ke home dengan transisi fade berdasarkan role user
          // Untuk role kasir, pastikan hanya bisa akses halaman yang diizinkan
          final fallbackRoute =
              RoleBasedNavigationService.getFallbackRoute(state.role);
          Navigator.of(context).pushReplacementNamed(fallbackRoute);
        } else if (state is Unauthenticated) {
          // Navigasi ke login dengan transisi fade
          Navigator.of(context)
              .pushReplacement(FadeInOutPageRoute(page: const LoginPage()));
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
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo aplikasi (jika ada)
                Image.asset(
                  'assets/images/logo_bakso_djatigiri.png',
                  width: 120,
                  height: 120,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(
                      Icons.restaurant,
                      size: 80,
                      color: white900,
                    );
                  },
                ),

                const SizedBox(height: 24),

                // Teks aplikasi
                const Text(
                  'Bakso Djatigiri',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: white900,
                    fontFamily: 'Poppins',
                  ),
                ),

                const SizedBox(height: 8),

                const Text(
                  'Memeriksa status login...',
                  style: TextStyle(
                    fontSize: 14,
                    color: white900,
                    fontFamily: 'Poppins',
                  ),
                ),

                const SizedBox(height: 32),

                // Loading indicator dengan animasi pulsating
                AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _scaleAnimation.value,
                      child: Container(
                        width: 48,
                        height: 48,
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: white900.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(white900),
                          strokeWidth: 3,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
