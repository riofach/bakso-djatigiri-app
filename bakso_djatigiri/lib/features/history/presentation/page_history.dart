// Halaman History - Menampilkan daftar transaksi dari Firestore
// Mengikuti desain Figma Bakso Djatigiri
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/color_pallete.dart';
import '../../../core/widgets/custom_navbar.dart';
import '../../../core/services/role_based_navigation_service.dart';
import '../../../core/animation/page_transitions.dart';
import '../bloc/history_bloc.dart';
import 'transaction_detail_page.dart';
import 'package:get_it/get_it.dart';
import 'package:mie_bakso_djatigiri/features/auth/bloc/auth_bloc.dart';

class PageHistory extends StatelessWidget {
  const PageHistory({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          GetIt.instance<HistoryBloc>()..add(LoadTransactionsEvent()),
      child: const _PageHistoryView(),
    );
  }
}

class _PageHistoryView extends StatefulWidget {
  const _PageHistoryView();

  @override
  State<_PageHistoryView> createState() => _PageHistoryViewState();
}

class _PageHistoryViewState extends State<_PageHistoryView> {
  int _selectedIndex = 0; // History di index ke-0
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
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
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

      final currentRoute = ModalRoute.of(context)?.settings.name ?? '/history';
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

  // Fungsi untuk refresh transaksi
  Future<void> _refreshTransactions() async {
    if (mounted) {
      setState(() {
        _isRefreshing = true;
      });

      try {
        context.read<HistoryBloc>().add(RefreshTransactionsEvent());
        // Tambahkan delay kecil untuk memberi waktu UI memperbarui
        await Future.delayed(const Duration(milliseconds: 500));
      } catch (e) {
        debugPrint('Error refreshing transactions: $e');

        // Tampilkan snackbar error jika gagal refresh
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Gagal memperbarui transaksi: $e'),
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

  // Format tanggal untuk dikelompokkan
  String _formatDate(DateTime date) {
    return DateFormat('dd MMM yyyy', 'id_ID').format(date);
  }

  // Format waktu
  String _formatTime(DateTime date) {
    return DateFormat('HH:mm', 'id_ID').format(date);
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
          'Riwayat Transaksi',
          style: TextStyle(
            color: dark900,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: _refreshTransactions,
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
                      context
                          .read<HistoryBloc>()
                          .add(FilterTransactionsEvent(value));
                    },
                    decoration: const InputDecoration(
                      hintText: 'Cari Transaksi',
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

              // List Transaksi Title
              Padding(
                padding: const EdgeInsets.only(left: 16, top: 8, bottom: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Daftar Transaksi',
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

              // Transaction List
              Expanded(
                child: BlocBuilder<HistoryBloc, HistoryState>(
                  builder: (context, state) {
                    if (state is HistoryLoading) {
                      return const Center(
                          child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(primary950),
                      ));
                    }

                    if (state is HistoryError) {
                      return Center(
                        child: Text(
                          state.message,
                          style: const TextStyle(color: errorColor),
                        ),
                      );
                    }

                    if (state is HistoryLoaded) {
                      final transactions = state.filteredTransactions;

                      if (transactions.isEmpty) {
                        return const Center(
                          child: Text('Tidak ada transaksi yang ditemukan'),
                        );
                      }

                      // Group transactions by date
                      final Map<String, List<dynamic>> groupedTransactions = {};

                      for (var transaction in transactions) {
                        final dateKey = _formatDate(transaction.timestamp);
                        if (!groupedTransactions.containsKey(dateKey)) {
                          groupedTransactions[dateKey] = [];
                        }
                        groupedTransactions[dateKey]!.add(transaction);
                      }

                      // Sort the keys by date (newest first)
                      final sortedDates = groupedTransactions.keys.toList()
                        ..sort((a, b) => DateFormat('dd MMM yyyy', 'id_ID')
                            .parse(b)
                            .compareTo(
                                DateFormat('dd MMM yyyy', 'id_ID').parse(a)));

                      return ListView.builder(
                        padding: const EdgeInsets.only(bottom: 100),
                        itemCount: sortedDates.length,
                        itemBuilder: (context, index) {
                          final dateKey = sortedDates[index];
                          final transactionsForDate =
                              groupedTransactions[dateKey]!;

                          return _buildDateSection(
                              dateKey, transactionsForDate);
                        },
                      );
                    }

                    return const Center(
                      child: Text('Tidak ada data transaksi'),
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

  Widget _buildDateSection(String dateKey, List<dynamic> transactions) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Date header
        Padding(
          padding: const EdgeInsets.only(left: 16, top: 16, bottom: 8),
          child: Text(
            dateKey,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              fontFamily: 'Poppins',
              color: gray950,
            ),
          ),
        ),

        // Transactions for this date
        ...transactions
            .map((transaction) => _buildTransactionCard(transaction)),
      ],
    );
  }

  Widget _buildTransactionCard(dynamic transaction) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          FadeInPageRoute(
            page: TransactionDetailPage(
              transactionId: transaction.id,
              transactionCode: transaction.transactionCode,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: white900,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Time and Transaction Code
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _formatTime(transaction.timestamp),
                    style: const TextStyle(
                      fontSize: 12,
                      fontFamily: 'Poppins',
                      color: gray950,
                    ),
                  ),
                  Text(
                    transaction.transactionCode,
                    style: const TextStyle(
                      fontSize: 12,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w500,
                      color: primary950,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Cashier Name
              Text(
                'Kasir: ${transaction.cashierName}',
                style: const TextStyle(
                  fontSize: 14,
                  fontFamily: 'Poppins',
                  color: dark900,
                ),
              ),
              const SizedBox(height: 8),

              // Amount
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total:',
                    style: TextStyle(
                      fontSize: 14,
                      fontFamily: 'Poppins',
                      color: dark900,
                    ),
                  ),
                  Text(
                    _currencyFormat.format(transaction.total),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Poppins',
                      color: dark900,
                    ),
                  ),
                ],
              ),

              // View Details hint at the bottom
              const Align(
                alignment: Alignment.centerRight,
                child: Text(
                  'Tekan untuk melihat detail',
                  style: TextStyle(
                    fontSize: 10,
                    fontStyle: FontStyle.italic,
                    color: gray900,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
