// Halaman Menu - Menampilkan daftar menu dari Firestore
// Mengikuti desain Figma Bakso Djatigiri
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/color_pallete.dart';
import '../../../core/widgets/custom_navbar.dart';
import '../../../core/services/role_based_navigation_service.dart';
import '../bloc/menu_bloc.dart';
import 'package:mie_bakso_djatigiri/core/animation/page_transitions.dart';
import 'package:mie_bakso_djatigiri/features/menu/presentation/create_menu.dart';
import 'package:mie_bakso_djatigiri/features/menu/presentation/edit_menu.dart';
import 'package:mie_bakso_djatigiri/features/auth/bloc/auth_bloc.dart';

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
  bool _isRefreshing = false;
  late List<CustomNavBarItem> navBarItems;
  bool _navBarInitialized = false;

  @override
  void initState() {
    super.initState();
    // Tidak perlu inisialisasi yang memerlukan context di sini
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Inisialisasi navBarItems di sini karena didChangeDependencies aman untuk menggunakan context
    if (!_navBarInitialized) {
      _initNavBarItems();
      _navBarInitialized = true;
    }
  }

  // Inisialisasi item navbar berdasarkan role user
  void _initNavBarItems() {
    final authState = context.read<AuthBloc>().state;
    if (authState is Authenticated) {
      navBarItems =
          RoleBasedNavigationService.getNavBarItemsByRole(authState.role);

      // Gunakan helper method untuk mendapatkan index yang benar
      final currentRoute = ModalRoute.of(context)?.settings.name ?? '/menu';
      _selectedIndex = RoleBasedNavigationService.getDefaultSelectedIndex(
          currentRoute, navBarItems);
    } else {
      // Default items jika belum login (seharusnya tidak terjadi)
      navBarItems = [
        CustomNavBarItem(
          icon: Icons.bar_chart,
          label: 'History',
          route: '/history',
        ),
        CustomNavBarItem(icon: Icons.menu_book, label: 'Menu', route: '/menu'),
        CustomNavBarItem(
            icon: Icons.description, label: 'Home', route: '/home'),
        CustomNavBarItem(
            icon: Icons.shopping_bag, label: 'Stock', route: '/stock'),
        CustomNavBarItem(
            icon: Icons.person, label: 'Profile', route: '/profile'),
      ];
    }
  }

  // Fungsi untuk refresh menu
  Future<void> _refreshMenus() async {
    if (mounted) {
      setState(() {
        _isRefreshing = true;
      });

      try {
        context.read<MenuBloc>().add(LoadMenusEvent());
        // Tambahkan delay kecil untuk memberi waktu UI memperbarui
        await Future.delayed(const Duration(milliseconds: 500));
      } catch (e) {
        debugPrint('Error refreshing menus: $e');

        // Tampilkan snackbar error jika gagal refresh
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Gagal memperbarui menu: $e'),
              backgroundColor: errorColor,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isRefreshing = false;
          });
        }
      }
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Pastikan navBarItems sudah diinisialisasi
    if (!_navBarInitialized) {
      _initNavBarItems();
      _navBarInitialized = true;
    }

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        title: const Text(
          'Daftar Menu',
          style: TextStyle(
            color: dark900,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        centerTitle: true,
        actions: [
          // Tombol Add di pojok kanan atas
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                  FadeInPageRoute(page: const CreateMenuPage()),
                );
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
      body: RefreshIndicator(
        onRefresh: _refreshMenus,
        color: primary950,
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Search Bar
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
              Padding(
                padding: const EdgeInsets.only(left: 16, top: 8, bottom: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'List Menu',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Poppins',
                        color: dark900,
                      ),
                    ),
                    // Status indikator refresh
                    if (_isRefreshing)
                      Padding(
                        padding: const EdgeInsets.only(right: 16),
                        child: Text(
                          'Memperbarui...',
                          style: TextStyle(
                            fontSize: 12,
                            fontStyle: FontStyle.italic,
                            color: primary950,
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              // Menu Grid
              Expanded(
                child: BlocBuilder<MenuBloc, MenuState>(
                  builder: (context, state) {
                    if (state is MenuLoading) {
                      return const Center(
                          child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(primary950),
                      ));
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
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          FadeInPageRoute(page: EditMenuPage(id: menu.id)),
        );
      },
      child: Container(
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
              child: menu.imageUrl.isNotEmpty &&
                      Uri.parse(menu.imageUrl).isAbsolute &&
                      (menu.imageUrl.startsWith('http://') ||
                          menu.imageUrl.startsWith('https://'))
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
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                  primary950),
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
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      width: double.infinity,
      height: 132,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.image, color: dark900, size: 32),
          SizedBox(height: 4),
          Text(
            'Image placeholder',
            style: TextStyle(
              fontSize: 10,
              fontFamily: 'Poppins',
              color: dark900,
            ),
          ),
        ],
      ),
    );
  }
}
