// Halaman Home
// Menampilkan data user yang login
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../bloc/auth_bloc.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  // Fungsi untuk menghapus status login dari shared_preferences
  Future<void> _logoutAndClearPrefs(BuildContext context) async {
    // Komentar: Menghapus status login dari shared_preferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('is_logged_in');
    // Komentar: Memicu event logout pada AuthBloc
    // ignore: use_build_context_synchronously
    context.read<AuthBloc>().add(LogoutEvent());
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is Unauthenticated) {
          // Komentar: Redirect ke login dan hapus semua route sebelumnya
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/login',
            (route) => false,
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Home'),
          actions: [
            // Komentar: Tombol Logout di AppBar
            IconButton(
              icon: const Icon(Icons.logout),
              tooltip: 'Logout',
              onPressed: () => _logoutAndClearPrefs(context),
            ),
          ],
        ),
        body: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            if (state is Authenticated) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Hello, ${state.name}',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(state.email, style: const TextStyle(fontSize: 18)),
                    const SizedBox(height: 8),
                    Text(
                      'Role: ${state.role}',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              );
            }
            return const Center(child: Text('Tidak ada data user'));
          },
        ),
      ),
    );
  }
}
