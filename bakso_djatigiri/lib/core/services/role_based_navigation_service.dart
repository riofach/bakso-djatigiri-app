// Service untuk mengelola navigasi berdasarkan role user
// Mengimplementasikan pembatasan akses menu berdasarkan role

import 'package:flutter/material.dart';
import '../widgets/custom_navbar.dart';

class RoleBasedNavigationService {
  // Menu yang diizinkan untuk role kasir
  static const List<String> _cashierAllowedRoutes = [
    '/home', // Halaman kasir
    '/history', // Riwayat transaksi
    '/profile', // Profil user
    '/notification', // Halaman notifikasi
  ];

  // Mendapatkan item navbar berdasarkan role
  static List<CustomNavBarItem> getNavBarItemsByRole(String role) {
    // Semua item navbar
    final allNavBarItems = [
      CustomNavBarItem(
        icon: Icons.bar_chart,
        label: 'History',
        route: '/history',
      ),
      CustomNavBarItem(
        icon: Icons.menu_book,
        label: 'Menu',
        route: '/menu',
      ),
      CustomNavBarItem(
        icon: Icons.description,
        label: 'Home',
        route: '/home',
      ),
      CustomNavBarItem(
        icon: Icons.shopping_bag,
        label: 'Stock',
        route: '/stock',
      ),
      CustomNavBarItem(
        icon: Icons.person,
        label: 'Profile',
        route: '/profile',
      ),
    ];

    // Jika role adalah owner, tampilkan semua menu
    if (role.toLowerCase() == 'owner') {
      return allNavBarItems;
    }

    // Jika role adalah kasir, filter menu yang diizinkan saja
    return allNavBarItems
        .where((item) => _cashierAllowedRoutes.contains(item.route))
        .toList();
  }

  // Mengecek apakah route diizinkan untuk role tertentu
  static bool isRouteAllowedForRole(String route, String role) {
    if (role.toLowerCase() == 'owner') {
      return true; // Owner bisa akses semua route
    }
    return _cashierAllowedRoutes.contains(route);
  }

  // Mendapatkan route default jika mencoba mengakses route yang tidak diizinkan
  static String getFallbackRoute(String role) {
    return '/home'; // Default fallback ke home
  }

  // Mendapatkan index default untuk navbar berdasarkan route saat ini
  static int getDefaultSelectedIndex(
      String currentRoute, List<CustomNavBarItem> navBarItems) {
    // Default index untuk setiap halaman
    final Map<String, int> defaultIndices = {
      '/history': 0,
      '/menu': 1,
      '/home': 2,
      '/stock': 3,
      '/profile': 4,
    };

    // Jika route ada di navBarItems, cari indexnya
    for (int i = 0; i < navBarItems.length; i++) {
      if (navBarItems[i].route == currentRoute) {
        return i;
      }
    }

    // Jika tidak ditemukan, gunakan default index atau 0
    return defaultIndices[currentRoute] ?? 0;
  }
}
