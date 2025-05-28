// Dialog untuk konfirmasi delete stock
// File ini berisi widget dialog untuk konfirmasi delete stock
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mie_bakso_djatigiri/core/animation/page_transitions.dart';
import 'package:mie_bakso_djatigiri/features/stock/presentation/page_stock.dart';
import '../../../core/theme/color_pallete.dart';
import '../bloc/delete_stock_bloc.dart';

class DeleteStockDialog extends StatelessWidget {
  final String stockId;
  final String stockName;
  final String imageUrl;

  const DeleteStockDialog({
    super.key,
    required this.stockId,
    required this.stockName,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => DeleteStockBloc(),
      child: _DeleteStockDialogContent(
        stockId: stockId,
        stockName: stockName,
        imageUrl: imageUrl,
      ),
    );
  }
}

class _DeleteStockDialogContent extends StatelessWidget {
  final String stockId;
  final String stockName;
  final String imageUrl;

  const _DeleteStockDialogContent({
    required this.stockId,
    required this.stockName,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return BlocListener<DeleteStockBloc, DeleteStockState>(
      listener: (context, state) {
        if (state is DeleteStockSuccess) {
          Navigator.of(context).pop(); // Tutup dialog
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Stock berhasil dihapus!')),
          );
          Navigator.of(context).pushAndRemoveUntil(
            FadeInPageRoute(page: const PageStock()),
            (route) => false,
          );
        } else if (state is DeleteStockError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      child: AlertDialog(
        title: const Text('Konfirmasi Hapus'),
        content: RichText(
          text: TextSpan(
            style: const TextStyle(color: dark900, fontFamily: 'Poppins'),
            children: [
              const TextSpan(
                  text: 'Apakah Anda yakin ingin menghapus stock bahan '),
              TextSpan(
                text: stockName,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const TextSpan(text: '?'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Batal'),
          ),
          BlocBuilder<DeleteStockBloc, DeleteStockState>(
            builder: (context, state) {
              return ElevatedButton(
                onPressed: state is DeleteStockLoading
                    ? null
                    : () {
                        context.read<DeleteStockBloc>().add(
                              DeleteStockItemEvent(
                                id: stockId,
                                imageUrl: imageUrl,
                              ),
                            );
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: errorColor,
                  foregroundColor: white900,
                ),
                child: state is DeleteStockLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: white900,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text('Hapus'),
              );
            },
          ),
        ],
      ),
    );
  }
}
