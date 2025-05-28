// Entry point aplikasi
// Mengatur routing dan dependency injection
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:mie_bakso_djatigiri/config/supabase_storage.dart';
import 'config/firebase_options.dart';
import 'features/auth/bloc/auth_bloc.dart';
import 'features/auth/data/auth_data_source.dart';
import 'features/auth/data/auth_repository_impl.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/auth/presentation/pages/register_page.dart';
import 'features/cashier/presentation/home_page.dart';
import 'features/stock/presentation/page_stock.dart';
import 'features/auth/presentation/pages/auth_wrapper.dart';

// Komentar: Pastikan Firebase diinisialisasi sebelum runApp
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await SupabaseStorageService.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create:
              (_) => AuthBloc(repository: AuthRepositoryImpl(AuthDataSource())),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Bakso Djatigiri',
        theme: ThemeData(primarySwatch: Colors.blue),
        initialRoute: '/',
        routes: {
          '/': (context) => const AuthWrapper(),
          '/login': (context) => const LoginPage(),
          '/stock': (context) => const PageStock(),
          '/register': (context) => const RegisterPage(),
          '/home': (context) => const HomePage(),
        },
      ),
    );
  }
}
