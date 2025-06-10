// Halaman Home (Kasir) - Menampilkan daftar menu yang tersedia untuk dijual
// Mengikuti desain Figma Bakso Djatigiri
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/color_pallete.dart';
import '../../../core/widgets/custom_navbar.dart';
import '../../menu/domain/entities/menu_entity.dart';
import '../bloc/cashier_bloc.dart';
import '../bloc/notification_bloc.dart';
import '../presentation/cart.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const _HomePageView();
  }
}

class _HomePageView extends StatefulWidget {
  const _HomePageView();

  @override
  State<_HomePageView> createState() => _HomePageViewState();
}

class _HomePageViewState extends State<_HomePageView> {
  final int _selectedIndex = 2; // Home di index ke-2
  final TextEditingController _searchController = TextEditingController();
  final NumberFormat _currencyFormat = NumberFormat.currency(
    locale: 'id',
    symbol: 'Rp ',
    decimalDigits: 0,
  );
  bool _isRefreshing = false;

  final navBarItems = [
    CustomNavBarItem(
      icon: Icons.bar_chart,
      label: 'History',
      route: '/history',
    ),
    CustomNavBarItem(icon: Icons.menu_book, label: 'Menu', route: '/menu'),
    CustomNavBarItem(icon: Icons.home, label: 'Home', route: '/home'),
    CustomNavBarItem(icon: Icons.shopping_bag, label: 'Stock', route: '/stock'),
    CustomNavBarItem(icon: Icons.person, label: 'Profile', route: '/profile'),
  ];

  @override
  void initState() {
    super.initState();
    // Reload menu saat halaman dibuka untuk mendapatkan stok terbaru
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _refreshMenus();
      }
    });
  }

  // Fungsi untuk refresh menu
  Future<void> _refreshMenus() async {
    if (mounted) {
      setState(() {
        _isRefreshing = true;
      });

      try {
        context.read<CashierBloc>().add(LoadMenusEvent());

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
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: GestureDetector(
            onTap: () {
              // Navigasi ke halaman notifikasi
              Navigator.pushNamed(context, '/notification');
            },
            child: Stack(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: const BoxDecoration(
                    color: white900,
                    borderRadius: BorderRadius.all(Radius.circular(100)),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.notifications_outlined,
                      color: dark900,
                      size: 24,
                    ),
                  ),
                ),
                // Badge untuk menampilkan jumlah notifikasi yang belum dibaca
                BlocBuilder<NotificationBloc, NotificationState>(
                  builder: (context, state) {
                    int unreadCount = 0;
                    if (state is NotificationLoaded) {
                      unreadCount = state.unreadCount;
                    }

                    if (unreadCount > 0) {
                      return Positioned(
                        top: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: primary950,
                            shape: BoxShape.circle,
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 18,
                            minHeight: 18,
                          ),
                          child: Text(
                            unreadCount > 9 ? '9+' : '$unreadCount',
                            style: const TextStyle(
                              color: white900,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ],
            ),
          ),
        ),
        title: Column(
          children: const [
            Text(
              'Welcome',
              style: TextStyle(
                color: gray900,
                fontWeight: FontWeight.w400,
                fontSize: 12,
              ),
            ),
            Text(
              'Bakso Djatigiri',
              style: TextStyle(
                color: dark900,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ],
        ),
        centerTitle: true,
        actions: [
          // Tombol Refresh
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            // child: IconButton(
            //   icon: _isRefreshing
            //       ? const SizedBox(
            //           width: 20,
            //           height: 20,
            //           child: CircularProgressIndicator(
            //             color: primary950,
            //             strokeWidth: 2,
            //           ),
            //         )
            //       : const Icon(Icons.refresh, color: primary950),
            //   onPressed: _isRefreshing ? null : _refreshMenus,
            //   tooltip: 'Refresh Menu',
            // ),
          ),
          // Tombol Cart di pojok kanan atas
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: GestureDetector(
              onTap: () {
                // Navigate to cart page dengan BlocProvider.value
                final cashierBloc = BlocProvider.of<CashierBloc>(context);
                Navigator.of(context)
                    .push(
                  MaterialPageRoute(
                    builder: (context) => BlocProvider.value(
                      value: cashierBloc,
                      child: const CartPage(),
                    ),
                  ),
                )
                    .then((_) {
                  // Refresh menu ketika kembali dari cart page
                  // untuk memastikan menu yang ditampilkan terupdate
                  _refreshMenus();
                });
              },
              child: BlocBuilder<CashierBloc, CashierState>(
                builder: (context, state) {
                  int cartItemCount = 0;
                  if (state is CashierLoaded) {
                    // Hitung total quantity dari semua item
                    cartItemCount = state.cartItems.fold(
                      0,
                      (sum, item) => sum + item.quantity,
                    );
                  }

                  return Stack(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: const BoxDecoration(
                          color: white900,
                          borderRadius: BorderRadius.all(Radius.circular(100)),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.shopping_cart_outlined,
                            color: dark900,
                            size: 24,
                          ),
                        ),
                      ),
                      if (cartItemCount > 0)
                        Positioned(
                          top: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: primary950,
                              shape: BoxShape.circle,
                            ),
                            constraints: const BoxConstraints(
                              minWidth: 18,
                              minHeight: 18,
                            ),
                            child: Text(
                              cartItemCount > 9 ? '9+' : '$cartItemCount',
                              style: const TextStyle(
                                color: white900,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                    ],
                  );
                },
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
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                child: Container(
                  decoration: BoxDecoration(
                    color: white900,
                    borderRadius: BorderRadius.circular(360),
                    border: Border.all(color: gray700),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        spreadRadius: 1,
                        blurRadius: 4,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (value) {
                      context.read<CashierBloc>().add(SearchMenusEvent(value));
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

              // List Menu Title and Refresh Indicator
              Padding(
                padding: const EdgeInsets.only(
                    left: 16, right: 16, top: 8, bottom: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'List Menu',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Poppins',
                        color: dark900,
                      ),
                    ),
                    // Status indikator refresh
                    if (_isRefreshing)
                      const Text(
                        'Memperbarui...',
                        style: TextStyle(
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                          color: primary950,
                        ),
                      ),
                  ],
                ),
              ),

              // Menu Grid
              Expanded(
                child: BlocConsumer<CashierBloc, CashierState>(
                  listener: (context, state) {
                    // Tampilkan pesan error validasi stok
                    if (state is CashierLoaded && state.message != null) {
                      ScaffoldMessenger.of(context).hideCurrentSnackBar();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(state.message!),
                          backgroundColor: errorColor,
                          behavior: SnackBarBehavior.floating,
                          margin: const EdgeInsets.all(10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      );
                    }
                  },
                  builder: (context, state) {
                    if (state is CashierLoading) {
                      return const Center(
                          child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(primary950),
                      ));
                    }

                    if (state is CashierError) {
                      return Center(
                        child: Text(
                          state.message,
                          style: const TextStyle(color: errorColor),
                        ),
                      );
                    }

                    if (state is CashierLoaded) {
                      final menus = state.filteredMenus;
                      final cartItems = state.cartItems;

                      if (menus.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(
                                Icons.search_off,
                                size: 64,
                                color: gray800,
                              ),
                              SizedBox(height: 16),
                              Text(
                                'Tidak ada menu yang ditemukan',
                                style: TextStyle(
                                  color: gray900,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: GridView.builder(
                          padding: const EdgeInsets.only(bottom: 100),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 16,
                            crossAxisSpacing: 16,
                            childAspectRatio: 0.7,
                          ),
                          itemCount: menus.length,
                          itemBuilder: (context, index) {
                            final menu = menus[index];

                            // Cek apakah menu ini ada di keranjang
                            final cartItem = cartItems.firstWhere(
                              (item) => item.menu.id == menu.id,
                              orElse: () => CartItem(menu: menu, quantity: 0),
                            );

                            return _buildMenuCard(menu, cartItem.quantity);
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

  Widget _buildMenuCard(MenuEntity menu, int currentQuantity) {
    return GestureDetector(
      onTap: () {
        // Tambahkan menu ke keranjang
        context.read<CashierBloc>().add(AddToCartEvent(menu));

        // Tampilkan snackbar sebagai konfirmasi jika berhasil
        // Pesan error validasi stok akan ditangani oleh BlocConsumer
      },
      child: Container(
        decoration: BoxDecoration(
          color: white900,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              spreadRadius: 1,
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            Stack(
              children: [
                Container(
                  height: 132,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: gray600,
                  ),
                  child: menu.imageUrl.isNotEmpty &&
                          Uri.parse(menu.imageUrl).isAbsolute &&
                          (menu.imageUrl.startsWith('http://') ||
                              menu.imageUrl.startsWith('https://'))
                      ? Image.network(
                          menu.imageUrl,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: 132,
                          errorBuilder: (c, e, s) => _buildImagePlaceholder(),
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Center(
                              child: CircularProgressIndicator(
                                value: loadingProgress.expectedTotalBytes !=
                                        null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
                                    : null,
                                valueColor: const AlwaysStoppedAnimation<Color>(
                                    primary950),
                              ),
                            );
                          },
                        )
                      : _buildImagePlaceholder(),
                ),
                // Add to cart button overlay
                Positioned(
                  bottom: 8,
                  right: 8,
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: const BoxDecoration(
                      color: primary950,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      icon: const Icon(
                        Icons.add,
                        color: white900,
                        size: 18,
                      ),
                      onPressed: () {
                        context.read<CashierBloc>().add(AddToCartEvent(menu));

                        // Tampilkan snackbar sebagai konfirmasi jika berhasil
                        // Pesan error validasi stok akan ditangani oleh BlocConsumer
                      },
                    ),
                  ),
                ),
                // Badge jika item sudah ada di keranjang
                if (currentQuantity > 0)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: primary950,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '$currentQuantity',
                        style: const TextStyle(
                          color: white900,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            // Menu details
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Menu Name
                  Text(
                    menu.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Poppins',
                      color: dark900,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  // Stock
                  Row(
                    children: [
                      const Icon(
                        Icons.local_fire_department,
                        color: primary950,
                        size: 14,
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
                  const SizedBox(height: 8),
                  // Price
                  Text(
                    _currencyFormat.format(menu.price),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Poppins',
                      color: primary950,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return SizedBox(
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
