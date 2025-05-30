// Halaman Menu - Menampilkan daftar menu dari Firestore
// Mengikuti desain Figma Bakso Djatigiri
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/color_pallete.dart';
import '../../../core/widgets/custom_navbar.dart';
import '../bloc/menu_bloc.dart';

class PageMenu extends StatelessWidget {
  const PageMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => MenuBloc()..add(LoadMenusEvent()),
      child: const _PageMenuView(),
    );
  }
}

class _PageMenuView extends StatefulWidget {
  const _PageMenuView();

  @override
  State<_PageMenuView> createState() => _PageMenuViewState();
}

class _PageMenuViewState extends State<_PageMenuView> {
  // ignore: prefer_final_fields
  int _selectedIndex = 1; // Menu di index ke-1
  final TextEditingController _searchController = TextEditingController();
  final NumberFormat _currencyFormat = NumberFormat.currency(
    locale: 'id',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

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
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Menu Product',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            fontFamily: 'Poppins',
            color: dark900,
          ),
        ),
        actions: [
          // Tombol Add
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: GestureDetector(
              onTap: () {
                // Navigasi ke halaman tambah menu
              },
              child: Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(
                  color: white900,
                  borderRadius: BorderRadius.all(Radius.circular(100)),
                ),
                child: Center(
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: white900,
                    ),
                    child: Stack(
                      children: [
                        // Horizontal line
                        Positioned(
                          left: 6.19,
                          top: 9.24,
                          child: Container(
                            width: 7.61,
                            height: 1.5,
                            color: dark900,
                          ),
                        ),
                        // Vertical line
                        Positioned(
                          left: 9.25,
                          top: 6.19,
                          child: Container(
                            width: 1.5,
                            height: 7.61,
                            color: dark900,
                          ),
                        ),
                        // Border
                        Positioned(
                          left: 0.92,
                          top: 0.92,
                          child: Container(
                            width: 18.17,
                            height: 18.17,
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: dark900,
                                width: 1,
                              ),
                              borderRadius: BorderRadius.circular(5),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Container(
                decoration: BoxDecoration(
                  color: white900,
                  borderRadius: BorderRadius.circular(360),
                  border: Border.all(color: gray700),
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: (value) {
                    context.read<MenuBloc>().add(SearchMenusEvent(value));
                  },
                  decoration: const InputDecoration(
                    hintText: 'Search',
                    hintStyle: TextStyle(
                      color: gray950,
                      fontFamily: 'Poppins',
                      fontSize: 14,
                    ),
                    prefixIcon: Icon(Icons.search, color: dark900),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
            ),

            // List Menu Title
            const Padding(
              padding: EdgeInsets.only(left: 16, top: 8, bottom: 8),
              child: Text(
                'List Menu',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Poppins',
                  color: dark900,
                ),
              ),
            ),

            // Menu Grid
            Expanded(
              child: BlocBuilder<MenuBloc, MenuState>(
                builder: (context, state) {
                  if (state is MenuLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (state is MenuError) {
                    return Center(
                      child: Text(
                        state.message,
                        style: const TextStyle(color: errorColor),
                      ),
                    );
                  }

                  if (state is MenuLoaded) {
                    final menus = state.filteredMenus;

                    if (menus.isEmpty) {
                      return const Center(
                        child: Text('Tidak ada menu yang ditemukan'),
                      );
                    }

                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: GridView.builder(
                        padding: const EdgeInsets.only(bottom: 100),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 11,
                          crossAxisSpacing: 11,
                          childAspectRatio: 0.75,
                        ),
                        itemCount: menus.length,
                        itemBuilder: (context, index) {
                          final menu = menus[index];
                          return _buildMenuCard(menu);
                        },
                      ),
                    );
                  }

                  return const Center(
                    child: Text('Tidak ada data menu'),
                  );
                },
              ),
            ),
          ],
        ),
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

  Widget _buildMenuCard(MenuModel menu) {
    return Container(
      decoration: BoxDecoration(
        color: white900,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color.fromARGB(255, 241, 241, 241)),
      ),
      padding: const EdgeInsets.all(4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image
          Container(
            height: 132,
            decoration: BoxDecoration(
              color: gray600,
              borderRadius: BorderRadius.circular(8),
            ),
            child: menu.imageUrl.isNotEmpty
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      menu.imageUrl,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: 132,
                      errorBuilder: (c, e, s) => _buildImagePlaceholder(),
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                                : null,
                          ),
                        );
                      },
                    ),
                  )
                : _buildImagePlaceholder(),
          ),
          const SizedBox(height: 8),
          // Menu Name
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              menu.name,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                fontFamily: 'Poppins',
                color: dark900,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 4),
          // Stock
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              children: [
                const Icon(
                  Icons.local_fire_department,
                  color: primary950,
                  size: 13,
                ),
                const SizedBox(width: 4),
                Text(
                  'Stock: ${menu.stock}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontFamily: 'Poppins',
                    color: gray950,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          // Price
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              _currencyFormat.format(menu.price),
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                fontFamily: 'Poppins',
                color: dark900,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: const [
        Icon(Icons.image, color: dark900, size: 24),
        SizedBox(height: 4),
        Text(
          'Image placeholder',
          style: TextStyle(
            fontSize: 8,
            fontFamily: 'Poppins',
            color: dark900,
          ),
        ),
      ],
    );
  }
}
