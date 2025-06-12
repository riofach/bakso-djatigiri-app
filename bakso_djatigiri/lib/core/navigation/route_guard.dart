// Route Guard untuk memeriksa akses route berdasarkan role user
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../features/auth/bloc/auth_bloc.dart';
import '../services/role_based_navigation_service.dart';

class RouteGuard {
  // Memeriksa apakah route diizinkan untuk user saat ini
  static bool canAccessRoute(BuildContext context, String route) {
    final authState = context.read<AuthBloc>().state;

    // Jika user belum login, arahkan ke login
    if (authState is! Authenticated) {
      return false;
    }

    // Periksa apakah route diizinkan untuk role user
    return RoleBasedNavigationService.isRouteAllowedForRole(
        route, authState.role);
  }

  // Mendapatkan route yang sesuai berdasarkan role
  static Route<dynamic> onGenerateRoute(
      RouteSettings settings, Widget Function(String) getPage) {
    return MaterialPageRoute(
      settings: settings,
      builder: (context) {
        // Jika route tidak diizinkan, redirect ke fallback route
        if (!canAccessRoute(context, settings.name ?? '')) {
          final authState = context.read<AuthBloc>().state;
          if (authState is Authenticated) {
            final fallbackRoute =
                RoleBasedNavigationService.getFallbackRoute(authState.role);
            return getPage(fallbackRoute);
          }
        }

        return getPage(settings.name ?? '/home');
      },
    );
  }
}
