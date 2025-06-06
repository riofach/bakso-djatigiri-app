// Halaman Tambah Menu
// Mengikuti desain Figma dan clean code
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:mie_bakso_djatigiri/core/animation/page_transitions.dart';
import 'package:mie_bakso_djatigiri/features/menu/bloc/create_menu_bloc.dart';
import 'package:mie_bakso_djatigiri/features/menu/presentation/page_menu.dart';
import '../../../core/theme/color_pallete.dart';
import '../../../features/stock/domain/entities/ingredient_entity.dart';
import '../domain/entities/menu_requirement_entity.dart';

class CreateMenuPage extends StatelessWidget {
  const CreateMenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          GetIt.instance<CreateMenuBloc>()..add(LoadIngredientsEvent()),
      child: const _CreateMenuView(),
    );
  }
}

class _CreateMenuView extends StatefulWidget {
  const _CreateMenuView();

  @override
  State<_CreateMenuView> createState() => _CreateMenuViewState();
}

class _CreateMenuViewState extends State<_CreateMenuView> {
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

  Future<void> _pickImage(BuildContext context) async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      // ignore: use_build_context_synchronously
      context.read<CreateMenuBloc>().add(PickImageEvent(picked.path));
    }
  }

  void _openIngredientSelector(BuildContext context, CreateMenuState state) {
    // Cara yang paling sederhana dan efektif
    final bloc = context.read<CreateMenuBloc>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext bottomSheetContext) {
        return MultiBlocProvider(
          providers: [
            BlocProvider<CreateMenuBloc>.value(value: bloc),
          ],
          child: _IngredientSelectorBottomSheet(
            availableIngredients: state.availableIngredients,
            selectedRequirements: state.selectedRequirements,
          ),
        );
      },
    );
  }

  Future<void> _submit(BuildContext context) async {
    final bloc = context.read<CreateMenuBloc>();
    bloc.add(SubmitMenuEvent());
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CreateMenuBloc, CreateMenuState>(
      listener: (context, state) {
        if (state.error != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.error!)),
          );
        }
        if (state.isSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Menu berhasil ditambahkan!')),
          );
          Navigator.of(context).pushAndRemoveUntil(
            FadeInPageRoute(page: const PageMenu()),
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
              'Tambah Menu Product',
              style: TextStyle(
                color: dark900,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
            centerTitle: true,
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Upload Image
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: GestureDetector(
                      onTap: state.isLoading ? null : () => _pickImage(context),
                      child: Container(
                        height: 207,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: gray600,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: state.imagePath == null
                            ? Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Icon(Icons.image, color: dark900, size: 32),
                                  SizedBox(height: 8),
                                  Text(
                                    'Upload Images',
                                    style: TextStyle(color: dark900),
                                  ),
                                ],
                              )
                            : ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.file(
                                  File(state.imagePath!),
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  height: 207,
                                ),
                              ),
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
                        onChanged: (val) => context.read<CreateMenuBloc>().add(
                              NameChangedEvent(val),
                            ),
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.fastfood, color: dark900),
                          hintText: 'Masukkan Nama Menu',
                          labelText: 'Nama Menu Product',
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(vertical: 16),
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
                            final formatted = _currencyFormat.format(numValue);
                            _priceController.value = TextEditingValue(
                              text: formatted,
                              selection: TextSelection.collapsed(
                                offset: formatted.length,
                              ),
                            );
                          }
                          context.read<CreateMenuBloc>().add(
                                PriceChangedEvent(_priceController.text),
                              );
                        },
                        decoration: const InputDecoration(
                          prefixIcon:
                              Icon(Icons.attach_money, color: primary950),
                          hintText: 'Masukkan Harga Menu',
                          labelText: 'Harga Menu Product',
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ),
                  ),

                  // Ingredients Section
                  Container(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Tambah Menu & Stock Bahan',
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
                  if (state.selectedRequirements.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        children: state.selectedRequirements.map((req) {
                          return _buildIngredientCard(context, req);
                        }).toList(),
                      ),
                    ),

                  // Submit Button
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
                            state.isLoading ? null : () => _submit(context),
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
                                : const Text('Tambah Menu Product'),
                          ),
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
          Text(
            '${req.requiredAmount}',
            style: const TextStyle(
              color: dark900,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
          const SizedBox(width: 10),
          // Decrease button
          GestureDetector(
            onTap: () {
              if (req.requiredAmount > 1) {
                context.read<CreateMenuBloc>().add(
                      UpdateIngredientAmountEvent(
                        ingredientId: req.ingredientId,
                        newAmount: req.requiredAmount - 1,
                      ),
                    );
              }
            },
            child: Container(
              width: 24,
              height: 24,
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
          const SizedBox(width: 10),
          // Increase button
          GestureDetector(
            onTap: () {
              context.read<CreateMenuBloc>().add(
                    UpdateIngredientAmountEvent(
                      ingredientId: req.ingredientId,
                      newAmount: req.requiredAmount + 1,
                    ),
                  );
            },
            child: Container(
              width: 24,
              height: 24,
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
                'Tambah Menu & Stock Bahan',
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
          // List ingredients
          availableIngredients.isEmpty
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Text('Tidak ada bahan tersedia'),
                  ),
                )
              : Column(
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
                            Text(
                              '$amount',
                              style: const TextStyle(
                                color: dark900,
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(width: 10),
                            // Decrease button
                            GestureDetector(
                              onTap: () {
                                if (amount <= 1) {
                                  context.read<CreateMenuBloc>().add(
                                        RemoveIngredientRequirementEvent(
                                          ingredient.id,
                                        ),
                                      );
                                } else {
                                  context.read<CreateMenuBloc>().add(
                                        UpdateIngredientAmountEvent(
                                          ingredientId: ingredient.id,
                                          newAmount: amount - 1,
                                        ),
                                      );
                                }
                              },
                              child: Container(
                                width: 24,
                                height: 24,
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
                            const SizedBox(width: 10),
                            // Increase button
                            GestureDetector(
                              onTap: () {
                                context.read<CreateMenuBloc>().add(
                                      UpdateIngredientAmountEvent(
                                        ingredientId: ingredient.id,
                                        newAmount: amount + 1,
                                      ),
                                    );
                              },
                              child: Container(
                                width: 24,
                                height: 24,
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
                          ] else ...[
                            // Add button
                            GestureDetector(
                              onTap: () {
                                context.read<CreateMenuBloc>().add(
                                      AddIngredientRequirementEvent(
                                        ingredientId: ingredient.id,
                                        ingredientName: ingredient.name,
                                        requiredAmount: 1,
                                      ),
                                    );
                              },
                              child: Container(
                                width: 24,
                                height: 24,
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
                ),
        ],
      ),
    );
  }
}
