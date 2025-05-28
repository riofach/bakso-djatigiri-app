// Halaman Edit Stock Bahan
// Mengikuti desain Figma dan clean code
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mie_bakso_djatigiri/core/animation/page_transitions.dart';
import 'package:mie_bakso_djatigiri/features/stock/presentation/page_stock.dart';
import '../../../core/theme/color_pallete.dart';
import '../bloc/edit_stock_bloc.dart';
import 'package:mie_bakso_djatigiri/features/stock/presentation/delete_stock_dialog.dart';

class EditStockPage extends StatelessWidget {
  final String stockId;

  const EditStockPage({
    super.key,
    required this.stockId,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => EditStockBloc()..add(LoadStockEvent(stockId)),
      child: const _EditStockView(),
    );
  }
}

class _EditStockView extends StatefulWidget {
  const _EditStockView();

  @override
  State<_EditStockView> createState() => _EditStockViewState();
}

class _EditStockViewState extends State<_EditStockView> {
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<EditStockBloc, EditStockState>(
      listenWhen: (previous, current) =>
          previous.isSuccess != current.isSuccess ||
          previous.isDeleted != current.isDeleted ||
          previous.error != current.error,
      listener: (context, state) {
        if (state.error != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.error!)),
          );
        }

        if (state.isSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Stock berhasil diperbarui!')),
          );
          Navigator.of(context).pushAndRemoveUntil(
            FadeInPageRoute(page: const PageStock()),
            (route) => false,
          );
        }

        if (state.isDeleted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Stock berhasil dihapus!')),
          );
          Navigator.of(context).pushAndRemoveUntil(
            FadeInPageRoute(page: const PageStock()),
            (route) => false,
          );
        }
      },
      buildWhen: (previous, current) =>
          previous.name != current.name ||
          previous.amount != current.amount ||
          previous.imageUrl != current.imageUrl ||
          previous.imagePath != current.imagePath ||
          previous.isLoading != current.isLoading,
      builder: (context, state) {
        // Isi controller dengan data dari state jika belum diisi
        if (state.name.isNotEmpty && _nameController.text.isEmpty) {
          _nameController.text = state.name;
        }

        if (state.amount.isNotEmpty && _amountController.text.isEmpty) {
          _amountController.text = state.amount;
        }

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
              'Edit Stock Bahan',
              style: TextStyle(
                color: dark900,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
            centerTitle: true,
            actions: [
              // Tombol Delete
              Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: IconButton(
                  icon: const Icon(Icons.delete_outline, color: errorColor),
                  onPressed: state.isLoading
                      ? null
                      : () => _showDeleteConfirmation(context),
                ),
              ),
            ],
          ),
          body: state.isLoading && state.name.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 21),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Upload Image
                        GestureDetector(
                          onTap: state.isLoading
                              ? null
                              : () => _pickImage(context),
                          child: Container(
                            height: 160,
                            decoration: BoxDecoration(
                              color: gray600,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: _buildImageWidget(state),
                          ),
                        ),
                        const SizedBox(height: 24),
                        // Nama Stock
                        Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: white900,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: gray600),
                          ),
                          child: TextField(
                            controller: _nameController,
                            onChanged: (val) =>
                                context.read<EditStockBloc>().add(
                                      NameChangedEvent(val),
                                    ),
                            decoration: const InputDecoration(
                              prefixIcon:
                                  Icon(Icons.inventory_2, color: dark900),
                              hintText: 'Masukkan Nama Stock',
                              labelText: 'Nama Stock Bahan',
                              border: InputBorder.none,
                              contentPadding:
                                  EdgeInsets.symmetric(vertical: 16),
                            ),
                          ),
                        ),
                        // Jumlah Stock
                        Container(
                          margin: const EdgeInsets.only(bottom: 24),
                          decoration: BoxDecoration(
                            color: white900,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: gray600),
                          ),
                          child: TextField(
                            controller: _amountController,
                            keyboardType: TextInputType.number,
                            onChanged: (val) =>
                                context.read<EditStockBloc>().add(
                                      AmountChangedEvent(val),
                                    ),
                            decoration: const InputDecoration(
                              prefixIcon: Icon(
                                Icons.local_fire_department,
                                color: errorColor,
                              ),
                              hintText: 'Masukkan Jumlah Stock',
                              labelText: 'Jumlah Stock Bahan',
                              border: InputBorder.none,
                              contentPadding:
                                  EdgeInsets.symmetric(vertical: 16),
                            ),
                          ),
                        ),
                        // Tombol Update
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24),
                              ),
                              elevation: 0,
                              backgroundColor: null,
                              foregroundColor: white900,
                              textStyle: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ).copyWith(
                              // ignore: deprecated_member_use
                              backgroundColor: MaterialStateProperty.all(
                                Colors.transparent,
                              ),
                              // ignore: deprecated_member_use
                              shadowColor: MaterialStateProperty.all(
                                Colors.transparent,
                              ),
                            ),
                            onPressed:
                                state.isLoading ? null : () => _update(context),
                            child: Ink(
                              decoration: BoxDecoration(
                                gradient: vertical01,
                                borderRadius: BorderRadius.circular(24),
                              ),
                              child: Container(
                                alignment: Alignment.center,
                                height: 48,
                                child: state.isLoading
                                    ? const CircularProgressIndicator(
                                        color: white900,
                                      )
                                    : const Text('Update Stock Bahan'),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
        );
      },
    );
  }

  Widget _buildImageWidget(EditStockState state) {
    if (state.imagePath != null) {
      // Tampilkan gambar yang baru dipilih
      return ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.file(
          File(state.imagePath!),
          fit: BoxFit.cover,
          width: double.infinity,
          height: 160,
        ),
      );
    } else if (state.imageUrl.isNotEmpty) {
      // Tampilkan gambar dari URL
      return ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.network(
          state.imageUrl,
          fit: BoxFit.cover,
          width: double.infinity,
          height: 160,
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
          errorBuilder: (c, e, s) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.error_outline, color: dark900, size: 24),
                SizedBox(height: 4),
                Text(
                  'Gagal memuat gambar',
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
      );
    } else {
      // Tampilkan placeholder
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.image, color: dark900, size: 48),
          SizedBox(height: 8),
          Text(
            'Upload Images',
            style: TextStyle(color: dark900),
          ),
        ],
      );
    }
  }

  Future<void> _pickImage(BuildContext context) async {
    final picked = await _picker.pickImage(
      source: ImageSource.gallery,
    );
    if (picked != null) {
      // ignore: use_build_context_synchronously
      context.read<EditStockBloc>().add(PickImageEvent(picked.path));
    }
  }

  void _update(BuildContext context) {
    context.read<EditStockBloc>().add(UpdateStockEvent());
  }

  void _showDeleteConfirmation(BuildContext context) {
    // Ambil data yang diperlukan dari state
    final stockId = context.read<EditStockBloc>().state.id;
    final stockName = context.read<EditStockBloc>().state.name;
    final imageUrl = context.read<EditStockBloc>().state.imageUrl;

    // Tampilkan dialog dengan BLoC terpisah
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => DeleteStockDialog(
        stockId: stockId,
        stockName: stockName,
        imageUrl: imageUrl,
      ),
    );
  }
}
