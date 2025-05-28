// Custom Navigation Bar sesuai desain Figma Bakso Djatigiri
import 'package:flutter/material.dart';
import '../theme/color_pallete.dart';

class CustomNavBar extends StatelessWidget {
  final int currentIndex;
  final List<CustomNavBarItem> items;
  final Color activeColor;
  final Color inactiveColor;
  final Color backgroundColor;
  final ValueChanged<int>? onTap; // opsional, override jika perlu

  const CustomNavBar({
    Key? key,
    required this.currentIndex,
    required this.items,
    this.activeColor = primary950,
    this.inactiveColor = gray700,
    this.backgroundColor = white900,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100, // Menambah sedikit height untuk mengatasi overflow
      decoration: BoxDecoration(
        color: backgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      padding: const EdgeInsets.only(bottom: 24, top: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(items.length, (index) {
          final isActive = index == currentIndex;
          final item = items[index];

          // Menentukan icon yang akan ditampilkan berdasarkan label
          IconData getIconData() {
            switch (item.label.toLowerCase()) {
              case 'history':
                return Icons.bar_chart;
              case 'menu':
                return Icons.menu_book;
              case 'home':
                return Icons.description;
              case 'stock':
                return Icons.shopping_bag;
              case 'profile':
                return Icons.person;
              default:
                return item.icon;
            }
          }

          return GestureDetector(
            onTap: () {
              if (onTap != null) {
                onTap!(index);
              } else {
                // Navigasi otomatis ke route jika onTap tidak diisi
                if (ModalRoute.of(context)?.settings.name != item.route) {
                  Navigator.of(context).pushReplacementNamed(item.route);
                }
              }
            },
            child: Container(
              width: 72,
              // Menggunakan SizedBox dengan height yang cukup
              child: SizedBox(
                height: 68, // Tinggi yang cukup untuk menampung semua elemen
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isActive)
                      // Active item dengan lingkaran gradient
                      Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: vertical01,
                          boxShadow: [
                            BoxShadow(
                              color: primary950.withOpacity(0.2),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Icon(getIconData(), color: white950, size: 27),
                        ),
                      )
                    else
                      // Inactive item
                      SizedBox(
                        height: 46,
                        child: Center(
                          child: Icon(
                            getIconData(),
                            color: inactiveColor,
                            size: 27,
                          ),
                        ),
                      ),
                    const SizedBox(height: 4),
                    Text(
                      item.label,
                      style: TextStyle(
                        color: isActive ? activeColor : inactiveColor,
                        fontFamily: 'Poppins',
                        fontWeight:
                            isActive ? FontWeight.w600 : FontWeight.w400,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class CustomNavBarItem {
  final IconData icon;
  final String label;
  final String route;
  CustomNavBarItem({
    required this.icon,
    required this.label,
    required this.route,
  });
}

// =========================
// Definisi global navBarItems sesuai kebutuhan project:
//
// import 'package:flutter/material.dart';
// import 'custom_navbar.dart';
//
// final navBarItems = [
//   CustomNavBarItem(icon: Icons.bar_chart, label: 'History', route: '/history'),
//   CustomNavBarItem(icon: Icons.menu_book, label: 'Menu', route: '/menu'),
//   CustomNavBarItem(icon: Icons.description, label: 'Home', route: '/home'), // icon document, bulat di tengah
//   CustomNavBarItem(icon: Icons.shopping_bag, label: 'Stock', route: '/stock'),
//   CustomNavBarItem(icon: Icons.person, label: 'Profile', route: '/profile'),
// ];
//
// Scaffold(
//   body: _pages[_selectedIndex],
//   bottomNavigationBar: CustomNavBar(
//     currentIndex: _selectedIndex,
//     items: navBarItems,
//   ),
// )
// =========================
