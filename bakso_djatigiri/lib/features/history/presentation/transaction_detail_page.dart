// Halaman Detail Transaksi - Menampilkan detail transaksi beserta item-itemnya
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/color_pallete.dart';
import '../bloc/history_bloc.dart';
import 'package:get_it/get_it.dart';

class TransactionDetailPage extends StatelessWidget {
  final String transactionId;
  final String? transactionCode;

  const TransactionDetailPage({
    super.key,
    required this.transactionId,
    this.transactionCode,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => GetIt.instance<HistoryBloc>()
        ..add(GetTransactionDetailsEvent(transactionId,
            transactionCode: transactionCode)),
      child: _TransactionDetailView(
        transactionId: transactionId,
        transactionCode: transactionCode,
      ),
    );
  }
}

class _TransactionDetailView extends StatefulWidget {
  final String transactionId;
  final String? transactionCode;

  const _TransactionDetailView({
    required this.transactionId,
    this.transactionCode,
  });

  @override
  State<_TransactionDetailView> createState() => _TransactionDetailViewState();
}

class _TransactionDetailViewState extends State<_TransactionDetailView> {
  final NumberFormat _currencyFormat = NumberFormat.currency(
    locale: 'id',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        title: const Text(
          'Detail Transaksi',
          style: TextStyle(
            color: dark900,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: dark900),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: BlocBuilder<HistoryBloc, HistoryState>(
          builder: (context, state) {
            if (state is HistoryLoading) {
              return const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(primary950),
                ),
              );
            }

            if (state is HistoryError) {
              return Center(
                child: Text(
                  state.message,
                  style: const TextStyle(color: errorColor),
                ),
              );
            }

            if (state is TransactionDetailsLoaded) {
              final items = state.items;
              final transactionCode =
                  state.transactionCode ?? widget.transactionCode;

              if (items.isEmpty) {
                return const Center(
                  child: Text('Tidak ada item dalam transaksi ini'),
                );
              }

              // Calculate total amount
              int totalAmount =
                  items.fold(0, (sum, item) => sum + item.subtotal);

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Transaction Info Card
                  Container(
                    margin: const EdgeInsets.all(16),
                    padding: const EdgeInsets.all(16),
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Transaction Code
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Kode Transaksi:',
                              style: TextStyle(
                                fontSize: 14,
                                fontFamily: 'Poppins',
                                color: gray950,
                              ),
                            ),
                            Text(
                              transactionCode ?? 'Unknown',
                              style: const TextStyle(
                                fontSize: 14,
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w500,
                                color: primary950,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Total Amount
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Total:',
                              style: TextStyle(
                                fontSize: 16,
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w500,
                                color: dark900,
                              ),
                            ),
                            Text(
                              _currencyFormat.format(totalAmount),
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                fontFamily: 'Poppins',
                                color: dark900,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Items Title
                  const Padding(
                    padding: EdgeInsets.only(left: 16, top: 8, bottom: 8),
                    child: Text(
                      'Item Pesanan',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Poppins',
                        color: dark900,
                      ),
                    ),
                  ),

                  // Items List
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.only(bottom: 24),
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        final item = items[index];
                        return _buildItemCard(item);
                      },
                    ),
                  ),
                ],
              );
            }

            // Initial state, request for transaction details
            WidgetsBinding.instance.addPostFrameCallback((_) {
              context.read<HistoryBloc>().add(GetTransactionDetailsEvent(
                    widget.transactionId,
                    transactionCode: widget.transactionCode,
                  ));
            });

            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(primary950),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildItemCard(dynamic item) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: white900,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: gray300),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Quantity in circle
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: primary100,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '${item.quantity}x',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Poppins',
                  color: primary950,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Item details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Menu Name
                Text(
                  item.menuName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Poppins',
                    color: dark900,
                  ),
                ),
                const SizedBox(height: 4),

                // Price per item
                Text(
                  _currencyFormat.format(item.priceEach),
                  style: const TextStyle(
                    fontSize: 14,
                    fontFamily: 'Poppins',
                    color: gray950,
                  ),
                ),
              ],
            ),
          ),

          // Subtotal
          Text(
            _currencyFormat.format(item.subtotal),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              fontFamily: 'Poppins',
              color: dark900,
            ),
          ),
        ],
      ),
    );
  }
}
