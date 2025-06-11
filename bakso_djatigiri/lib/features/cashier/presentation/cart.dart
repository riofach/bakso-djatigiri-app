// Halaman Cart (Keranjang) - Menampilkan daftar menu yang akan dibeli
// Mengikuti desain Figma Bakso Djatigiri
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/color_pallete.dart';
import '../bloc/cashier_bloc.dart';

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Tidak perlu BlocProvider baru karena CashierBloc sudah tersedia di level aplikasi
    return const _CartPageView();
  }
}

class _CartPageView extends StatefulWidget {
  const _CartPageView();

  @override
  State<_CartPageView> createState() => _CartPageViewState();
}

class _CartPageViewState extends State<_CartPageView> {
  final TextEditingController _paymentController = TextEditingController();
  final NumberFormat _currencyFormat = NumberFormat.currency(
    locale: 'id',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  // Untuk menyimpan jumlah pembayaran saat ini
  int _currentPayment = 0;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    // Menambahkan listener untuk memperbarui jumlah pembayaran saat input berubah
    _paymentController.addListener(_updatePayment);
  }

  void _updatePayment() {
    if (_paymentController.text.isNotEmpty) {
      final paymentText =
          _paymentController.text.replaceAll(RegExp(r'[^\d]'), '');
      setState(() {
        _currentPayment = int.tryParse(paymentText) ?? 0;
      });
    } else {
      setState(() {
        _currentPayment = 0;
      });
    }
  }

  @override
  void dispose() {
    _paymentController.removeListener(_updatePayment);
    _paymentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: dark900),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Keranjang',
          style: TextStyle(
            color: dark900,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        centerTitle: true,
      ),
      body: BlocConsumer<CashierBloc, CashierState>(
        listener: (context, state) {
          // Handle success dan error states
          if (state is CashierLoaded && _isProcessing) {
            setState(() {
              _isProcessing = false;
            });

            // Tutup dialog loading jika masih terbuka
            if (Navigator.of(context).canPop()) {
              Navigator.of(context, rootNavigator: true).pop();
            }

            // Tampilkan dialog sukses
            _showSuccessDialog(context);
          } else if (state is CashierError) {
            setState(() {
              _isProcessing = false;
            });

            // Tutup dialog loading jika masih terbuka
            if (Navigator.of(context).canPop()) {
              Navigator.of(context, rootNavigator: true).pop();
            }

            // Tampilkan error dialog
            _showErrorDialog(context, state.message);
          } else if (state is CashierLoaded && state.message != null) {
            // Tampilkan pesan error validasi stok
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
          if (state is! CashierLoaded) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(primary950),
              ),
            );
          }

          final cartItems = state.cartItems;

          if (cartItems.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/empty_cart.png',
                    width: 200,
                    height: 200,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => const Icon(
                      Icons.shopping_cart_outlined,
                      size: 100,
                      color: gray800,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Keranjang Kosong',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: dark900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Silahkan tambahkan menu terlebih dahulu',
                    style: TextStyle(
                      fontSize: 14,
                      color: gray900,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 12,
                      ),
                      backgroundColor: primary950,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text(
                      'Kembali',
                      style: TextStyle(
                        color: white900,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          // Hitung total harga
          final totalPrice = cartItems.fold<int>(
            0,
            (sum, item) => sum + item.price,
          );

          return Column(
            children: [
              // List item keranjang
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async {
                    context.read<CashierBloc>().add(LoadMenusEvent());
                    return Future.delayed(const Duration(milliseconds: 500));
                  },
                  color: primary950,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: cartItems.length,
                    itemBuilder: (context, index) {
                      final item = cartItems[index];
                      return _buildCartItem(context, item, index);
                    },
                  ),
                ),
              ),

              // Panel pembayaran
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: white900,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Total
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: dark900,
                          ),
                        ),
                        Text(
                          _currencyFormat.format(totalPrice),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: primary950,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Input pembayaran
                    Container(
                      decoration: BoxDecoration(
                        color: white900,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: gray700),
                      ),
                      child: TextField(
                        controller: _paymentController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        onChanged: (value) {
                          // Format currency
                          if (value.isNotEmpty) {
                            final numValue = int.tryParse(value) ?? 0;
                            final formatted = _currencyFormat.format(numValue);
                            _paymentController.value = TextEditingValue(
                              text: formatted,
                              selection: TextSelection.collapsed(
                                offset: formatted.length,
                              ),
                            );
                          }
                        },
                        decoration: const InputDecoration(
                          hintText: 'Masukkan jumlah pembayaran',
                          labelText: 'Pembayaran',
                          prefixIcon: Icon(Icons.payments_outlined),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Tampilan kembalian secara real-time
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Kembalian',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: dark900,
                          ),
                        ),
                        Text(
                          _currencyFormat.format(_currentPayment > totalPrice
                              ? _currentPayment - totalPrice
                              : 0),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: _currentPayment >= totalPrice
                                ? Colors.green
                                : gray900,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Tombol Checkout
                    SizedBox(
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: null,
                          foregroundColor: white900,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ).copyWith(
                          backgroundColor: MaterialStateProperty.all(
                            Colors.transparent,
                          ),
                        ),
                        onPressed: _isProcessing
                            ? null
                            : () => _processCheckout(context, totalPrice),
                        child: Ink(
                          decoration: BoxDecoration(
                            gradient: _isProcessing ? null : horizontal01,
                            color: _isProcessing ? gray800 : null,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: _isProcessing
                                ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          white900),
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Text(
                                    'Checkout',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCartItem(BuildContext context, CartItem item, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
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
      child: Row(
        children: [
          // Gambar menu
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: gray600,
            ),
            clipBehavior: Clip.antiAlias,
            child: item.menu.imageUrl.isNotEmpty
                ? Image.network(
                    item.menu.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (c, e, s) => const Icon(
                      Icons.fastfood,
                      color: dark900,
                      size: 32,
                    ),
                  )
                : const Icon(
                    Icons.fastfood,
                    color: dark900,
                    size: 32,
                  ),
          ),
          const SizedBox(width: 12),
          // Detail menu
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.menu.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: dark900,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    // Tampilkan harga total (harga × quantity)
                    Text(
                      _currencyFormat.format(item.price),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: primary950,
                      ),
                    ),
                    if (item.quantity > 1)
                      Text(
                        ' (${item.quantity})',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: gray900,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),

          // Kontrol quantity
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: gray700),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                // Tombol kurangi
                InkWell(
                  onTap: () {
                    context.read<CashierBloc>().add(
                          DecreaseCartItemQuantityEvent(index),
                        );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    child: const Icon(
                      Icons.remove,
                      size: 18,
                      color: dark900,
                    ),
                  ),
                ),
                // Jumlah
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    '${item.quantity}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                // Tombol tambah
                InkWell(
                  onTap: () {
                    context.read<CashierBloc>().add(
                          IncreaseCartItemQuantityEvent(index),
                        );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    child: const Icon(
                      Icons.add,
                      size: 18,
                      color: dark900,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Tombol hapus
          IconButton(
            icon: const Icon(
              Icons.delete_outline,
              color: errorColor,
            ),
            onPressed: () {
              context.read<CashierBloc>().add(RemoveFromCartEvent(index));
            },
          ),
        ],
      ),
    );
  }

  void _processCheckout(BuildContext context, int totalPrice) {
    // Validasi pembayaran
    final paymentText =
        _paymentController.text.replaceAll(RegExp(r'[^\d]'), '');
    final payment = int.tryParse(paymentText) ?? 0;

    if (payment < totalPrice) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pembayaran kurang dari total harga'),
          backgroundColor: errorColor,
        ),
      );
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    // Proses checkout
    context.read<CashierBloc>().add(
          CheckoutEvent(
            payment: payment,
          ),
        );
  }

  void _showSuccessDialog(BuildContext context) {
    // Dapatkan data transaksi dari state CashierBloc
    final cashierState = context.read<CashierBloc>().state;

    if (cashierState is CashierLoaded) {
      // Ambil data transaksi terakhir dari state
      final totalPrice = cashierState.lastTransactionTotal ??
          cashierState.cartItems.fold<int>(0, (sum, item) => sum + item.price);

      final payment = cashierState.lastTransactionPayment ?? _currentPayment;
      final change = payment - totalPrice;

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) => WillPopScope(
          onWillPop: () async =>
              false, // Mencegah dialog ditutup dengan back button
          child: Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: white900,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Transaksi Berhasil',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: dark900,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFFEF4444),
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFFEF4444), Color(0xFFF97316)],
                      ),
                    ),
                    child: const Icon(
                      Icons.check,
                      color: white900,
                      size: 50,
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Total
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total:',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: dark900,
                          ),
                        ),
                        Text(
                          _currencyFormat.format(totalPrice),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: dark900,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Pembayaran
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Pembayaran:',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: dark900,
                          ),
                        ),
                        Text(
                          _currencyFormat.format(payment),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: dark900,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Kembalian
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Kembalian:',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: dark900,
                          ),
                        ),
                        Text(
                          _currencyFormat.format(change),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: null,
                        foregroundColor: white900,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ).copyWith(
                        backgroundColor: MaterialStateProperty.all(
                          Colors.transparent,
                        ),
                      ),
                      onPressed: () {
                        // Tutup dialog
                        Navigator.of(dialogContext).pop();

                        // Refresh data menu terlebih dahulu
                        if (context.mounted) {
                          context.read<CashierBloc>().add(LoadMenusEvent());
                        }

                        // Tunggu sebentar untuk memastikan state terupdate
                        Future.delayed(const Duration(milliseconds: 100), () {
                          // Kembali ke halaman utama dengan pop
                          if (context.mounted) {
                            if (Navigator.of(context).canPop()) {
                              Navigator.of(context).pop();
                            } else {
                              // Jika pop tidak berhasil, navigasi ke halaman home dengan pushReplacement
                              Navigator.of(context)
                                  .pushReplacementNamed('/home');
                            }
                          }
                        });
                      },
                      child: Ink(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            colors: [Color(0xFFEF4444), Color(0xFFF97316)],
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Center(
                          child: Text(
                            'OK',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }
  }

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
