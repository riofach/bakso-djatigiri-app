// Wrapper Autentikasi
// Mengatur redirect ke login/register/home sesuai status autentikasi
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../bloc/auth_bloc.dart';

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  @override
  void initState() {
    super.initState();
    // Komentar: Trigger pengecekan user saat startup
    Future.microtask(() {
      context.read<AuthBloc>().add(CheckCurrentUserEvent());
    });
  }

  // Komentar: Mengecek status login dari shared_preferences dan status user di Firestore saat aplikasi dibuka
  Future<void> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool('is_logged_in') ?? false;
    if (isLoggedIn) {
      // Komentar: Ambil user dari FirebaseAuth dan cek status di Firestore
      try {
        final user = FirebaseAuth.instance.currentUser;
        if (user == null) {
          // Tidak ada user login, paksa logout
          context.read<AuthBloc>().add(LogoutEvent());
          return;
        }
        final userDoc =
            await FirebaseFirestore.instance
                .collection('users')
                .doc(user.uid)
                .get();
        if (!userDoc.exists) {
          // Data user tidak ditemukan di Firestore, paksa logout
          context.read<AuthBloc>().add(LogoutEvent());
          return;
        }
        final data = userDoc.data()!;
        if (data['status'] != 'active') {
          // Jika status user tidak aktif, paksa logout
          context.read<AuthBloc>().add(LogoutEvent());
          // Optional: Tampilkan pesan ke user (gunakan snackbar atau dialog jika perlu)
          return;
        }
        // Jika status aktif, biarkan AuthBloc tetap Authenticated dan lanjut ke home
      } catch (e) {
        // Jika error (misal koneksi/firestore), paksa logout
        context.read<AuthBloc>().add(LogoutEvent());
      }
    } else {
      // Komentar: Jika belum login, trigger event logout agar AuthBloc ke Unauthenticated
      context.read<AuthBloc>().add(LogoutEvent());
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listenWhen:
          (prev, curr) => curr is Authenticated || curr is Unauthenticated,
      listener: (context, state) {
        if (state is AuthError) {
          // Komentar: Menampilkan pesan error ke user
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
        }
        if (state is Authenticated) {
          Navigator.pushReplacementNamed(context, '/home');
        } else if (state is Unauthenticated) {
          Navigator.pushReplacementNamed(context, '/login');
        }
      },
      child: const Scaffold(body: Center(child: CircularProgressIndicator())),
    );
  }
}
