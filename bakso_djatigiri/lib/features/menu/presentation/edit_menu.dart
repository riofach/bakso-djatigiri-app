// Halaman Edit Menu
// Mengikuti desain Figma dan clean code
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:mie_bakso_djatigiri/core/animation/page_transitions.dart';
import './page_menu.dart';
import '../../../core/theme/color_pallete.dart';
import '../../../di/injection.dart';
import '../bloc/edit_menu_bloc.dart';
import '../domain/entities/menu_requirement_entity.dart';
import '../../stock/domain/entities/ingredient_entity.dart';
import './delete_menu_dialog.dart';

class EditMenuPage extends StatelessWidget {
  final String id;

  const EditMenuPage({super.key, required this.id});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => GetIt.instance<EditMenuBloc>()..add(LoadMenuEvent(id)),
      child: const _EditMenuView(),
    );
  }
}

class _EditMenuView extends StatefulWidget {
  const _EditMenuView();

  @override
  State<_EditMenuView> createState() => _EditMenuViewState();
}

class _EditMenuViewState extends State<_EditMenuView> {
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  final _currencyFormat = NumberFormat.currency(
    locale: 'id',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<EditMenuBloc, EditMenuState>(
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
            const SnackBar(content: Text('Menu berhasil diperbarui!')),
          );
          Navigator.of(context).pushAndRemoveUntil(
            FadeInPageRoute(page: const PageMenu()),
            (route) => false,
          );
        }

        if (state.isDeleted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Menu berhasil dihapus!')),
          );
          Navigator.of(context).pushAndRemoveUntil(
            FadeInPageRoute(page: const PageMenu()),
            (route) => false,
          );
        }
      },
      buildWhen: (previous, current) =>
          previous.name != current.name ||
          previous.price != current.price ||
          previous.imageUrl != current.imageUrl ||
          previous.imagePath != current.imagePath ||
          previous.isLoading != current.isLoading ||
          previous.selectedRequirements != current.selectedRequirements ||
          previous.availableIngredients != current.availableIngredients ||
          previous.isLoadingIngredients != current.isLoadingIngredients,
      builder: (context, state) {
        // Isi controller dengan data dari state jika belum diisi
        if (state.name.isNotEmpty && _nameController.text.isEmpty) {
          _nameController.text = state.name;
        }

        if (state.price.isNotEmpty && _priceController.text.isEmpty) {
          _priceController.text = state.price;
        }

        // Pastikan ingredients dan requirements sudah di-load
        if (!state.isLoadingIngredients &&
            state.availableIngredients.isEmpty &&
            state.id.isNotEmpty) {
          // Trigger load menu requirements hanya jika belum ada data
          debugPrint('EditMenu: Triggering load menu requirements from build');
          Future.microtask(() => context
              .read<EditMenuBloc>()
              .add(LoadMenuRequirementsEvent(state.id)));
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
              'Edit Menu Product',
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Upload Image
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: GestureDetector(
                          onTap: state.isLoading
                              ? null
                              : () => _pickImage(context),
                          child: Container(
                            height: 207,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: gray600,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: _buildImageWidget(state),
                          ),
                        ),
                      ),

                      // Nama Menu
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: white900,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: gray600),
                          ),
                          child: TextField(
                            controller: _nameController,
                            onChanged: (val) =>
                                context.read<EditMenuBloc>().add(
                                      NameChangedEvent(val),
                                    ),
                            decoration: const InputDecoration(
                              prefixIcon: Icon(Icons.fastfood, color: dark900),
                              hintText: 'Masukkan Nama Menu',
                              labelText: 'Nama Menu Product',
                              border: InputBorder.none,
                              contentPadding:
                                  EdgeInsets.symmetric(vertical: 16),
                            ),
                          ),
                        ),
                      ),
                      // Harga Menu
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: white900,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: gray600),
                          ),
                          child: TextField(
                            controller: _priceController,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly
                            ],
                            onChanged: (val) {
                              // Format currency
                              if (val.isNotEmpty) {
                                final numValue = int.tryParse(val) ?? 0;
                                final formatted =
                                    _currencyFormat.format(numValue);
                                _priceController.value = TextEditingValue(
                                  text: formatted,
                                  selection: TextSelection.collapsed(
                                    offset: formatted.length,
                                  ),
                                );
                              }
                              context.read<EditMenuBloc>().add(
                                    PriceChangedEvent(_priceController.text),
                                  );
                            },
                            decoration: const InputDecoration(
                              prefixIcon: Icon(
                                Icons.attach_money,
                                color: primary950,
                              ),
                              hintText: 'Masukkan Harga Menu',
                              labelText: 'Harga Menu Product',
                              border: InputBorder.none,
                              contentPadding:
                                  EdgeInsets.symmetric(vertical: 16),
                            ),
                          ),
                        ),
                      ),

                      // Ingredients Section - Selalu ditampilkan
                      Container(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Edit Menu & Stock Bahan',
                                  style: TextStyle(
                                    color: dark900,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                  ),
                                ),
                                // Circular gradient button
                                GestureDetector(
                                  onTap: () =>
                                      _openIngredientSelector(context, state),
                                  child: Container(
                                    width: 32,
                                    height: 32,
                                    decoration: BoxDecoration(
                                      gradient: vertical01,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.add,
                                      color: white900,
                                      size: 20,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Tambahkan bahan - bahan yang dipakai \nuntuk membuat menu, sehingga stock menu otomatis terbuat',
                              style: TextStyle(
                                color: gray800,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Selected Ingredients List
                      if (state.isLoadingIngredients)
                        const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Center(
                            child: CircularProgressIndicator(),
                          ),
                        )
                      else if (state.selectedRequirements.isEmpty)
                        const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Center(
                            child: Text(
                              'Belum ada bahan yang dipilih',
                              style: TextStyle(
                                color: gray900,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                        )
                      else
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Column(
                            children: state.selectedRequirements.map((req) {
                              return _buildIngredientCard(context, req);
                            }).toList(),
                          ),
                        ),

                      // Stok Info
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: gray600.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: gray600.withOpacity(0.5)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.inventory_2_outlined,
                                      size: 18, color: secondary950),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Stock: ${state.stock}',
                                    style: const TextStyle(
                                      color: dark900,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Stock menu dihitung otomatis berdasarkan ketersediaan bahan',
                                style: TextStyle(
                                  color: gray800,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Tombol Update (dipindahkan ke bagian paling bawah)
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              elevation: 0,
                              backgroundColor: null,
                              foregroundColor: white900,
                              textStyle: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
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
                                gradient: horizontal01,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Container(
                                alignment: Alignment.center,
                                height: 50,
                                child: state.isLoading
                                    ? const CircularProgressIndicator(
                                        color: white900,
                                      )
                                    : const Text('Update Menu Product'),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
        );
      },
    );
  }

  Widget _buildImageWidget(EditMenuState state) {
    if (state.imagePath != null) {
      // Tampilkan gambar yang baru dipilih
      return ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.file(
          File(state.imagePath!),
          fit: BoxFit.cover,
          width: double.infinity,
          height: 207,
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
          height: 207,
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
      context.read<EditMenuBloc>().add(PickImageEvent(picked.path));
    }
  }

  void _update(BuildContext context) {
    // Validasi form
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nama menu tidak boleh kosong')),
      );
      return;
    }

    final priceText = _priceController.text.replaceAll(RegExp(r'[^\d]'), '');
    if (priceText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Harga menu tidak boleh kosong')),
      );
      return;
    }

    final bloc = context.read<EditMenuBloc>();
    final state = bloc.state;

    // Log state untuk debugging
    debugPrint('Updating menu: ${state.id}');
    debugPrint('Menu name: ${_nameController.text}');
    debugPrint('Menu price: $priceText');
    debugPrint('Menu requirements count: ${state.selectedRequirements.length}');

    // Validate requirements
    if (state.selectedRequirements.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Menu harus memiliki minimal 1 bahan'),
        ),
      );
      return;
    }

    // Update nama dan harga di Bloc
    bloc.add(NameChangedEvent(_nameController.text));
    bloc.add(PriceChangedEvent(priceText));

    // Submit perubahan
    bloc.add(SubmitEditEvent());
  }

  void _showDeleteConfirmation(BuildContext context) {
    // Ambil data yang diperlukan dari state
    final menuId = context.read<EditMenuBloc>().state.id;
    final menuName = context.read<EditMenuBloc>().state.name;

    // Tampilkan dialog dengan BLoC terpisah
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => DeleteMenuDialog(
        id: menuId,
        name: menuName,
      ),
    );
  }

  void _openIngredientSelector(BuildContext context, EditMenuState state) {
    // Cara yang paling sederhana dan efektif
    final bloc = context.read<EditMenuBloc>();

    // Jika available ingredients kosong, reload data ingredients
    if (state.availableIngredients.isEmpty && !state.isLoadingIngredients) {
      debugPrint('Available ingredients empty, reloading data...');
      bloc.add(LoadMenuRequirementsEvent(state.id));
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext bottomSheetContext) {
        return MultiBlocProvider(
          providers: [
            BlocProvider<EditMenuBloc>.value(value: bloc),
          ],
          child: _IngredientSelectorBottomSheet(
            availableIngredients: state.availableIngredients,
            selectedRequirements: state.selectedRequirements,
          ),
        );
      },
    );
  }

  Widget _buildIngredientCard(BuildContext context, MenuRequirementEntity req) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: white900,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: secondary950.withAlpha(77)),
      ),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: Text(
              req.ingredientName,
              style: const TextStyle(
                color: primary950,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
          // Container untuk tombol - angka +
          Container(
            height: 30,
            decoration: BoxDecoration(
              color: gray600.withOpacity(0.5),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Decrease button
                GestureDetector(
                  onTap: () {
                    if (req.requiredAmount > 1) {
                      context.read<EditMenuBloc>().add(
                            UpdateIngredientAmountEvent(
                              ingredientId: req.ingredientId,
                              newAmount: req.requiredAmount - 1,
                            ),
                          );
                    }
                  },
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: const BoxDecoration(
                      color: white900,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.remove,
                      color: primary950,
                      size: 14,
                    ),
                  ),
                ),
                // Angka jumlah
                Container(
                  width: 40,
                  alignment: Alignment.center,
                  child: Text(
                    '${req.requiredAmount}',
                    style: const TextStyle(
                      color: dark900,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
                // Increase button
                GestureDetector(
                  onTap: () {
                    context.read<EditMenuBloc>().add(
                          UpdateIngredientAmountEvent(
                            ingredientId: req.ingredientId,
                            newAmount: req.requiredAmount + 1,
                          ),
                        );
                  },
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: const BoxDecoration(
                      color: white900,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.add,
                      color: secondary950,
                      size: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          // Delete button
          GestureDetector(
            onTap: () {
              context.read<EditMenuBloc>().add(
                    RemoveIngredientRequirementEvent(req.ingredientId),
                  );
            },
            child: Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: errorColor.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.close,
                color: errorColor,
                size: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _IngredientSelectorBottomSheet extends StatelessWidget {
  final List<IngredientEntity> availableIngredients;
  final List<MenuRequirementEntity> selectedRequirements;

  const _IngredientSelectorBottomSheet({
    required this.availableIngredients,
    required this.selectedRequirements,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: white900,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Edit Menu & Stock Bahan',
                style: TextStyle(
                  color: dark900,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const Text(
            'Tambahkan bahan - bahan yang dipakai \nuntuk membuat menu, sehingga stock menu otomatis terbuat',
            style: TextStyle(
              color: gray800,
              fontSize: 10,
            ),
          ),
          const SizedBox(height: 16),

          // Check if bloc is still loading ingredients
          BlocBuilder<EditMenuBloc, EditMenuState>(
            buildWhen: (previous, current) =>
                previous.isLoadingIngredients != current.isLoadingIngredients ||
                previous.availableIngredients != current.availableIngredients,
            builder: (context, state) {
              // Tampilkan loading indicator
              if (state.isLoadingIngredients) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24.0),
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              // Tampilkan pesan jika tidak ada bahan tersedia
              if (availableIngredients.isEmpty) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32.0),
                    child: Column(
                      children: [
                        Icon(Icons.info_outline, color: gray900, size: 48),
                        SizedBox(height: 16),
                        Text(
                          'Tidak ada bahan tersedia',
                          style: TextStyle(
                            color: dark900,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Silakan tambahkan bahan terlebih dahulu di halaman Stock',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: gray800,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              // Tampilkan daftar bahan yang tersedia
              return Column(
                children: availableIngredients.map((ingredient) {
                  final isSelected = selectedRequirements.any(
                    (req) => req.ingredientId == ingredient.id,
                  );
                  final amount = isSelected
                      ? selectedRequirements
                          .firstWhere(
                            (req) => req.ingredientId == ingredient.id,
                          )
                          .requiredAmount
                      : 0;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 14),
                    decoration: BoxDecoration(
                      color: white900,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: secondary950.withAlpha(77)),
                    ),
                    padding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 20),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            ingredient.name,
                            style: const TextStyle(
                              color: primary950,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        if (isSelected) ...[
                          // Container untuk tombol - angka +
                          Container(
                            height: 30,
                            decoration: BoxDecoration(
                              color: gray600.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Decrease button
                                GestureDetector(
                                  onTap: () {
                                    if (amount <= 1) {
                                      context.read<EditMenuBloc>().add(
                                            RemoveIngredientRequirementEvent(
                                              ingredient.id,
                                            ),
                                          );
                                    } else {
                                      context.read<EditMenuBloc>().add(
                                            UpdateIngredientAmountEvent(
                                              ingredientId: ingredient.id,
                                              newAmount: amount - 1,
                                            ),
                                          );
                                    }
                                  },
                                  child: Container(
                                    width: 30,
                                    height: 30,
                                    decoration: const BoxDecoration(
                                      color: white900,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.remove,
                                      color: primary950,
                                      size: 14,
                                    ),
                                  ),
                                ),
                                // Angka jumlah
                                Container(
                                  width: 40,
                                  alignment: Alignment.center,
                                  child: Text(
                                    '$amount',
                                    style: const TextStyle(
                                      color: dark900,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                                // Increase button
                                GestureDetector(
                                  onTap: () {
                                    context.read<EditMenuBloc>().add(
                                          UpdateIngredientAmountEvent(
                                            ingredientId: ingredient.id,
                                            newAmount: amount + 1,
                                          ),
                                        );
                                  },
                                  child: Container(
                                    width: 30,
                                    height: 30,
                                    decoration: const BoxDecoration(
                                      color: white900,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.add,
                                      color: secondary950,
                                      size: 14,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),
                          // Delete button
                          GestureDetector(
                            onTap: () {
                              context.read<EditMenuBloc>().add(
                                    RemoveIngredientRequirementEvent(
                                      ingredient.id,
                                    ),
                                  );
                            },
                            child: Container(
                              width: 30,
                              height: 30,
                              decoration: BoxDecoration(
                                color: errorColor.withOpacity(0.2),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.close,
                                color: errorColor,
                                size: 14,
                              ),
                            ),
                          ),
                        ] else ...[
                          // Add button
                          GestureDetector(
                            onTap: () {
                              context.read<EditMenuBloc>().add(
                                    AddIngredientRequirementEvent(
                                      ingredientId: ingredient.id,
                                      ingredientName: ingredient.name,
                                      requiredAmount: 1,
                                    ),
                                  );
                            },
                            child: Container(
                              width: 30,
                              height: 30,
                              decoration: const BoxDecoration(
                                color: white900,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.add,
                                color: primary950,
                                size: 14,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}
