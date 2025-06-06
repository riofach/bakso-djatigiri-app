// Halaman Home - List Menu
// Mengambil data dari Firestore collection 'menus' dan search bar
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/theme/color_pallete.dart';
import '../../../core/widgets/custom_navbar.dart';

class MenuModel {
  final String id;
  final String name;
  final int price;
  final int stock;
  final String imageUrl;
  final DateTime createdAt;

  MenuModel({
    required this.id,
    required this.name,
    required this.price,
    required this.stock,
    required this.imageUrl,
    required this.createdAt,
  });

  factory MenuModel.fromMap(Map<String, dynamic> map, String id) {
    return MenuModel(
      id: id,
      name: map['name'] ?? '',
      price: map['price'] ?? 0,
      stock: map['stock'] ?? 0,
      imageUrl: map['image_url'] ?? '',
      createdAt: (map['created_at'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _search = '';
  // ignore: prefer_final_fields
  int _selectedIndex = 2; // Home di tengah

  // Definisi global navBarItems
  final navBarItems = [
    CustomNavBarItem(
      icon: Icons.bar_chart,
      label: 'History',
      route: '/history',
    ),
    CustomNavBarItem(icon: Icons.menu_book, label: 'Menu', route: '/menu'),
    CustomNavBarItem(icon: Icons.description, label: 'Home', route: '/home'),
    CustomNavBarItem(icon: Icons.shopping_bag, label: 'Stock', route: '/stock'),
    CustomNavBarItem(icon: Icons.person, label: 'Profile', route: '/profile'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.notifications_none, color: dark900),
          onPressed: () {
            // TODO: Notifikasi
          },
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: const [
            Text('Welcome', style: TextStyle(fontSize: 14, color: gray950)),
            Text(
              'Bakso Djatigiri',
              style: TextStyle(
                fontSize: 18,
                color: dark900,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.shopping_cart_outlined, color: dark900),
            onPressed: () {
              // TODO: Cart
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Container(
              decoration: BoxDecoration(
                color: white900,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                onChanged: (val) => setState(() => _search = val),
                decoration: const InputDecoration(
                  hintText: 'Search',
                  prefixIcon: Icon(Icons.search, color: gray950),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ),
          // List Menu
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('menus')
                  .orderBy('created_at', descending: false)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('Belum ada menu'));
                }
                final allMenus = snapshot.data!.docs
                    .map(
                      (doc) => MenuModel.fromMap(
                        doc.data() as Map<String, dynamic>,
                        doc.id,
                      ),
                    )
                    .toList();
                final menus = _search.isEmpty
                    ? allMenus
                    : allMenus
                        .where(
                          (m) => m.name.toLowerCase().contains(
                                _search.toLowerCase(),
                              ),
                        )
                        .toList();
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: GridView.builder(
                    itemCount: menus.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 0.75,
                    ),
                    itemBuilder: (context, i) {
                      final menu = menus[i];
                      return Container(
                        decoration: BoxDecoration(
                          color: white900,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 4,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(16),
                                topRight: Radius.circular(16),
                              ),
                              child: Image.network(
                                menu.imageUrl,
                                height: 90,
                                width: double.infinity,
                                fit: BoxFit.cover,
                                errorBuilder: (c, e, s) => Container(
                                  height: 90,
                                  color: gray600,
                                  child: Icon(Icons.image, color: gray900),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    menu.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                      color: dark900,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.local_fire_department,
                                        color: errorColor,
                                        size: 16,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Stock: ${menu.stock}',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: errorColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Rp ${menu.price.toString().replaceAllMapped(RegExp(r"(\d{1,3})(?=(\d{3})+(?!\d))"), (Match m) => "${m[1]}.")}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      color: primary950,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: CustomNavBar(
        currentIndex: _selectedIndex,
        items: navBarItems,
        onTap: (index) {
          if (index != _selectedIndex) {
            Navigator.pushReplacementNamed(
              context,
              navBarItems[index].route,
            );
          }
        },
      ),
    );
  }
}
