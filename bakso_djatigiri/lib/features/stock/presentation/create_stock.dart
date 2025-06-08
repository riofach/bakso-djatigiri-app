// Halaman Tambah Stock Bahan
// Mengikuti desain Figma dan clean code
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mie_bakso_djatigiri/core/animation/page_transitions.dart';
import 'package:mie_bakso_djatigiri/features/stock/presentation/page_stock.dart';
import '../../../core/theme/color_pallete.dart';
import '../bloc/create_stock_bloc.dart';

class CreateStockPage extends StatelessWidget {
  const CreateStockPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => GetIt.instance<CreateStockBloc>(),
      child: const _CreateStockView(),
    );
  }
}

class _CreateStockView extends StatefulWidget {
  const _CreateStockView();

  @override
  State<_CreateStockView> createState() => _CreateStockViewState();
}

class _CreateStockViewState extends State<_CreateStockView> {
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(BuildContext context) async {
    final picked = await _picker.pickImage(
      source: ImageSource.gallery,
      // Tidak perlu imageQuality di sini karena akan dikompresi di BLoC
    );
    if (picked != null) {
      // ignore: use_build_context_synchronously
      context.read<CreateStockBloc>().add(PickImageEvent(picked.path));
    }
  }

  Future<void> _submit(BuildContext context, CreateStockState state) async {
    final bloc = context.read<CreateStockBloc>();
    bloc.add(SubmitStockEvent());
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CreateStockBloc, CreateStockState>(
      listener: (context, state) {
        if (state.error != null) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.error!)));
        }
        if (state.isSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Stock berhasil ditambahkan!')),
          );
          Navigator.of(context).pushAndRemoveUntil(
            FadeInPageRoute(page: const PageStock()),
            (route) => false,
          );
        }
      },
      builder: (context, state) {
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
              'Tambah Stock Bahan',
              style: TextStyle(
                color: dark900,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
            centerTitle: true,
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 21),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Upload Image
                  GestureDetector(
                    onTap: state.isLoading ? null : () => _pickImage(context),
                    child: Container(
                      height: 160,
                      decoration: BoxDecoration(
                        color: gray600,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: state.imagePath == null
                          ? Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Icon(Icons.image, color: dark900, size: 48),
                                SizedBox(height: 8),
                                Text(
                                  'Upload Images',
                                  style: TextStyle(color: dark900),
                                ),
                              ],
                            )
                          : ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Image.file(
                                File(state.imagePath!),
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: 160,
                              ),
                            ),
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
                      onChanged: (val) => context.read<CreateStockBloc>().add(
                            NameChangedEvent(val),
                          ),
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.inventory_2, color: dark900),
                        hintText: 'Masukkan Nama Stock',
                        labelText: 'Nama Stock Bahan',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 16),
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
                      onChanged: (val) => context.read<CreateStockBloc>().add(
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
                        contentPadding: EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                  // Info
                  Container(
                    margin: const EdgeInsets.only(bottom: 24),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: gray600.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: gray800.withOpacity(0.1)),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.info_outline, color: primary950, size: 18),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Stock bahan akan otomatis digunakan saat menu yang berkaitan dijual',
                            style: TextStyle(
                              fontSize: 12,
                              color: dark900,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Tombol Submit
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
                      onPressed: state.isLoading
                          ? null
                          : () => _submit(context, state),
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
                              : const Text('Tambah Stock Bahan'),
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
}
