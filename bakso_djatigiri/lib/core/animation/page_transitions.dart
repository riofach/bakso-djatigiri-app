// Template animasi perpindahan page/screen
import 'package:flutter/material.dart';

// Komentar: Fade In Transition
class FadeInPageRoute<T> extends PageRouteBuilder<T> {
  final Widget page;
  FadeInPageRoute({required this.page})
    : super(
        pageBuilder: (context, animation, secondaryAnimation) => page,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      );
}

// Komentar: Fade Out Transition
class FadeOutPageRoute<T> extends PageRouteBuilder<T> {
  final Widget page;
  FadeOutPageRoute({required this.page})
    : super(
        pageBuilder: (context, animation, secondaryAnimation) => page,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: Tween<double>(begin: 1.0, end: 0.0).animate(animation),
            child: child,
          );
        },
      );
}

// Komentar: Fade In Out Transition (masuk dan keluar smooth)
class FadeInOutPageRoute<T> extends PageRouteBuilder<T> {
  final Widget page;
  FadeInOutPageRoute({required this.page})
    : super(
        pageBuilder: (context, animation, secondaryAnimation) => page,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation.drive(
              Tween<double>(
                begin: 0.0,
                end: 1.0,
              ).chain(CurveTween(curve: Curves.easeInOut)),
            ),
            child: child,
          );
        },
      );
}

// Komentar: Slide Transition (opsional, dari kanan ke kiri)
class SlideLeftPageRoute<T> extends PageRouteBuilder<T> {
  final Widget page;
  SlideLeftPageRoute({required this.page})
    : super(
        pageBuilder: (context, animation, secondaryAnimation) => page,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          final tween = Tween(
            begin: begin,
            end: end,
          ).chain(CurveTween(curve: Curves.easeInOut));
          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
      );
}

// =========================
// Contoh Penggunaan:
//
// import '../../../../core/animation/page_transitions.dart';
//
// Navigator.of(context).push(FadeInPageRoute(page: YourPage()));
// Navigator.of(context).push(FadeOutPageRoute(page: YourPage()));
// Navigator.of(context).push(FadeInOutPageRoute(page: YourPage()));
// Navigator.of(context).push(SlideLeftPageRoute(page: YourPage()));
// =========================
