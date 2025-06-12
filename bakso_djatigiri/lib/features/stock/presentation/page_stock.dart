// Halaman Stock Product
// Menampilkan data dari Firestore collection 'ingredients' dan search bar
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:mie_bakso_djatigiri/core/animation/page_transitions.dart';
import '../../../core/theme/color_pallete.dart';
import '../../../core/widgets/custom_navbar.dart';
import '../../../core/services/role_based_navigation_service.dart';
import '../bloc/stock_bloc.dart';
import 'create_stock.dart';
import 'edit_stock.dart';
import 'package:mie_bakso_djatigiri/features/auth/bloc/auth_bloc.dart';

class PageStock extends StatelessWidget {
  const PageStock({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => GetIt.instance<StockBloc>()..add(LoadStocksEvent()),
      child: const _PageStockView(),
    );
  }
}

class _PageStockView extends StatefulWidget {
  const _PageStockView();

  @override
  State<_PageStockView> createState() => _PageStockViewState();
}

class _PageStockViewState extends State<_PageStockView> {
  // ignore: prefer_final_fields
  int _selectedIndex = 3; // Stock di index ke-3
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
      final currentRoute = ModalRoute.of(context)?.settings.name ?? '/stock';
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

  // Fungsi untuk refresh stok
  Future<void> _refreshStocks() async {
    if (mounted) {
      setState(() {
        _isRefreshing = true;
      });

      try {
        context.read<StockBloc>().add(LoadStocksEvent());
        // Tambahkan delay kecil untuk memberi waktu UI memperbarui
        await Future.delayed(const Duration(milliseconds: 500));
      } catch (e) {
        debugPrint('Error refreshing stocks: $e');

        // Tampilkan snackbar error jika gagal refresh
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Gagal memperbarui stok: $e'),
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
        centerTitle: true,
        title: const Text(
          'Stock Product',
          style: TextStyle(
            color: dark900,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                  FadeInPageRoute(page: const CreateStockPage()),
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
        onRefresh: _refreshStocks,
        color: primary950,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Container(
                height: 48,
                decoration: BoxDecoration(
                  color: white900,
                  borderRadius: BorderRadius.circular(360),
                  border: Border.all(color: const Color(0xFFC7C7D1)),
                ),
                child: TextField(
                  onChanged: (val) =>
                      context.read<StockBloc>().add(SearchStocksEvent(val)),
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                  decoration: const InputDecoration(
                    hintText: 'Search',
                    hintStyle: TextStyle(
                      color: Color(0xFF989898),
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                    prefixIcon: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Icon(Icons.search, color: dark900, size: 24),
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ),

            // List Stock Product Title
            Padding(
              padding: const EdgeInsets.only(left: 16, top: 16, bottom: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'List Stock Product',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
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

            // List Stock Product
            Expanded(
              child: BlocConsumer<StockBloc, StockState>(
                listener: (context, state) {
                  if (state is StockError) {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text(state.message)));
                  }
                },
                builder: (context, state) {
                  if (state is StockInitial || state is StockLoading) {
                    return const Center(
                        child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(primary950),
                    ));
                  }

                  if (state is StockError) {
                    return Center(child: Text(state.message));
                  }

                  if (state is StockLoaded) {
                    final ingredients = state.filteredIngredients;

                    if (ingredients.isEmpty) {
                      return const Center(child: Text('Belum ada data stock'));
                    }

                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: GridView.builder(
                        itemCount: ingredients.length,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 11,
                          crossAxisSpacing: 11,
                          childAspectRatio: 0.75,
                        ),
                        itemBuilder: (context, i) {
                          final item = ingredients[i];
                          return Container(
                            decoration: BoxDecoration(
                              color: white900,
                              borderRadius: BorderRadius.circular(12),
                              border:
                                  Border.all(color: const Color(0xFFEFEFEF)),
                            ),
                            padding: const EdgeInsets.all(4),
                            child: InkWell(
                              onTap: () {
                                Navigator.of(context)
                                    .push(
                                  FadeInPageRoute(
                                    page: EditStockPage(id: item.id),
                                  ),
                                )
                                    .then((_) {
                                  // Refresh data setelah kembali dari halaman edit
                                  _refreshStocks();
                                });
                              },
                              borderRadius: BorderRadius.circular(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Image Container
                                  Container(
                                    height: 132,
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFEFEFEF),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: item.imageUrl.isNotEmpty &&
                                            Uri.parse(item.imageUrl)
                                                .isAbsolute &&
                                            (item.imageUrl
                                                    .startsWith('http://') ||
                                                item.imageUrl
                                                    .startsWith('https://'))
                                        ? ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            child: Image.network(
                                              item.imageUrl,
                                              fit: BoxFit.cover,
                                              errorBuilder: (c, e, s) => Center(
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: const [
                                                    Icon(
                                                      Icons.image,
                                                      color: dark900,
                                                      size: 24,
                                                    ),
                                                    SizedBox(height: 4),
                                                    Text(
                                                      'Image placeholder',
                                                      style: TextStyle(
                                                        color: dark900,
                                                        fontFamily: 'Poppins',
                                                        fontSize: 8,
                                                        fontWeight:
                                                            FontWeight.w400,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              loadingBuilder: (context, child,
                                                  loadingProgress) {
                                                if (loadingProgress == null)
                                                  return child;
                                                return Center(
                                                  child:
                                                      CircularProgressIndicator(
                                                    value: loadingProgress
                                                                .expectedTotalBytes !=
                                                            null
                                                        ? loadingProgress
                                                                .cumulativeBytesLoaded /
                                                            loadingProgress
                                                                .expectedTotalBytes!
                                                        : null,
                                                    valueColor:
                                                        const AlwaysStoppedAnimation<
                                                            Color>(primary950),
                                                  ),
                                                );
                                              },
                                            ),
                                          )
                                        : Center(
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: const [
                                                Icon(
                                                  Icons.image,
                                                  color: dark900,
                                                  size: 24,
                                                ),
                                                SizedBox(height: 4),
                                                Text(
                                                  'Image placeholder',
                                                  style: TextStyle(
                                                    color: dark900,
                                                    fontFamily: 'Poppins',
                                                    fontSize: 8,
                                                    fontWeight: FontWeight.w400,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                  ),

                                  // Text Content
                                  Padding(
                                    padding: const EdgeInsets.only(
                                      left: 4,
                                      right: 4,
                                      top: 8,
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item.name,
                                          style: const TextStyle(
                                            fontFamily: 'Poppins',
                                            fontWeight: FontWeight.w500,
                                            fontSize: 16,
                                            color: dark900,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            SizedBox(
                                              width: 12,
                                              height: 12,
                                              child: Icon(
                                                Icons.local_fire_department,
                                                color: primary900,
                                                size: 14,
                                              ),
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              'Stock: ${item.stockAmount}',
                                              style: const TextStyle(
                                                fontFamily: 'Poppins',
                                                fontSize: 13,
                                                fontWeight: FontWeight.w400,
                                                color: gray900,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  }

                  return const Center(child: Text('Terjadi kesalahan'));
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
}
