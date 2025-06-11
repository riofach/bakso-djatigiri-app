// Entry point aplikasi
// Mengatur routing dan dependency injection
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:mie_bakso_djatigiri/config/supabase_storage.dart';
import 'package:mie_bakso_djatigiri/core/services/notification_service.dart';
import 'package:mie_bakso_djatigiri/di/injection.dart';
import 'config/firebase_options.dart';
import 'features/auth/bloc/auth_bloc.dart';
import 'features/auth/data/auth_data_source.dart';
import 'features/auth/data/auth_repository_impl.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/auth/presentation/pages/register_page.dart';
import 'features/cashier/presentation/home_page.dart';
import 'features/stock/presentation/page_stock.dart';
import 'features/auth/presentation/pages/auth_wrapper.dart';
import 'features/menu/presentation/page_menu.dart';
import 'features/history/presentation/page_history.dart';
import 'features/profile/presentation/page_profile.dart';
import 'features/cashier/bloc/cashier_bloc.dart';
import 'features/cashier/bloc/notification_bloc.dart';
import 'features/cashier/presentation/notification.dart';
import 'package:get_it/get_it.dart';

// Komentar: Pastikan Firebase diinisialisasi sebelum runApp
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Inisialisasi Supabase Storage
  await SupabaseStorageService.init();

  // Inisialisasi Notification Service
  await NotificationService().init();

  // Inisialisasi format tanggal untuk locale Indonesia
  await initializeDateFormatting('id_ID', null);

  // Setup dependency injection
  setupDependencies();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) =>
              AuthBloc(repository: AuthRepositoryImpl(AuthDataSource())),
        ),
        BlocProvider(
          create: (_) => GetIt.instance<CashierBloc>()..add(LoadMenusEvent()),
        ),
        BlocProvider(
          create: (_) => GetIt.instance<NotificationBloc>(),
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
          '/menu': (context) => const PageMenu(),
          '/history': (context) => const PageHistory(),
          '/profile': (context) => const PageProfile(),
          '/notification': (context) => const NotificationPage(),
        },
      ),
    );
  }
}
