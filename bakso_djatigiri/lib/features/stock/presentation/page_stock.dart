// Halaman Stock Product
// Menampilkan data dari Firestore collection 'ingredients' dan search bar
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mie_bakso_djatigiri/core/animation/page_transitions.dart';
import '../../../core/theme/color_pallete.dart';
import '../../../core/widgets/custom_navbar.dart';
import '../bloc/stock_bloc.dart';
import 'create_stock.dart';

class PageStock extends StatelessWidget {
  const PageStock({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => StockBloc()..add(LoadStocksEvent()),
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
            child: Container(
              width: 44,
              height: 44,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: white900,
              ),
              child: IconButton(
                icon: const Icon(Icons.add, color: dark900, size: 20),
                onPressed: () {
                  Navigator.of(
                    context,
                  ).push(FadeInPageRoute(page: const CreateStockPage()));
                },
              ),
            ),
          ),
        ],
      ),
      body: Column(
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
          const Padding(
            padding: EdgeInsets.only(left: 16, top: 16, bottom: 8),
            child: Text(
              'List Stock Product',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w600,
                fontSize: 16,
                color: dark900,
              ),
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
                  return const Center(child: CircularProgressIndicator());
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
                            border: Border.all(color: const Color(0xFFEFEFEF)),
                          ),
                          padding: const EdgeInsets.all(4),
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
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
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
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
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
                                  crossAxisAlignment: CrossAxisAlignment.start,
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
                                            Icons.shopping_bag,
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
      bottomNavigationBar: CustomNavBar(
        currentIndex: _selectedIndex,
        items: navBarItems,
      ),
    );
  }
}
