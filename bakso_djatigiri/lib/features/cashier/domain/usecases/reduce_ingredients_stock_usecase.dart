// Use case untuk mengurangi stok bahan saat checkout
import 'package:injectable/injectable.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../../menu/domain/entities/menu_requirement_entity.dart';
import '../../../menu/domain/repositories/menu_repository.dart';
import '../../../stock/domain/entities/ingredient_entity.dart';
import '../../../stock/domain/usecases/get_ingredients_usecase.dart';
import '../../data/models/transaction_item_model.dart';

@injectable
class ReduceIngredientsStockUseCase {
  final FirebaseFirestore _firestore;
  final GetIngredientsUseCase _getIngredientsUseCase;

  ReduceIngredientsStockUseCase({
    required FirebaseFirestore firestore,
    required GetIngredientsUseCase getIngredientsUseCase,
    required MenuRepository menuRepository,
  })  : _firestore = firestore,
        _getIngredientsUseCase = getIngredientsUseCase;

  Future<void> call(List<TransactionItemModel> items) async {
    try {
      debugPrint(
          'ReduceIngredientsStockUseCase: Memulai proses pengurangan stok...');

      // 1. Ambil semua menu yang dibeli
      final menuIds = items.map((item) => item.menuId).toList();
      final menuQuantities = <String, int>{};

      // Hitung jumlah setiap menu yang dibeli
      for (var item in items) {
        menuQuantities[item.menuId] =
            (menuQuantities[item.menuId] ?? 0) + item.quantity;
      }

      debugPrint(
          'ReduceIngredientsStockUseCase: Menu yang dibeli: ${menuQuantities.length} jenis');
      for (var entry in menuQuantities.entries) {
        final menuId = entry.key;
        final quantity = entry.value;
        debugPrint(
            'ReduceIngredientsStockUseCase: - Menu ID: $menuId, Quantity: $quantity');
      }

      // 2. Ambil semua menu requirements untuk menu yang dibeli
      final requirementsQuery = await _firestore
          .collection('menu_requirements')
          .where('menu_id', whereIn: menuIds)
          .get();

      final requirements = requirementsQuery.docs.map((doc) {
        final data = doc.data();
        return MenuRequirementEntity(
          id: doc.id,
          menuId: data['menu_id'] ?? '',
          ingredientId: data['ingredient_id'] ?? '',
          ingredientName: data['ingredient_name'] ?? '',
          requiredAmount: data['required_amount'] ?? 0,
        );
      }).toList();

      // 3. Kelompokkan requirements berdasarkan menu_id
      final Map<String, List<MenuRequirementEntity>> menuRequirements = {};
      for (var req in requirements) {
        if (!menuRequirements.containsKey(req.menuId)) {
          menuRequirements[req.menuId] = [];
        }
        menuRequirements[req.menuId]!.add(req);
      }

      // 4. Ambil semua data menu untuk diupdate
      final menuDocs = await _firestore
          .collection('menus')
          .where(FieldPath.documentId, whereIn: menuIds)
          .get();

      final menuData = {
        for (var doc in menuDocs.docs) doc.id: doc.data(),
      };

      // 4. Ambil hanya ingredients yang dibutuhkan dalam transaksi
      final Set<String> usedIngredientIds =
          requirements.map((req) => req.ingredientId).toSet();
      final allIngredients = await _getIngredientsUseCase();

      // Filter hanya ingredients yang digunakan dalam transaksi
      final usedIngredients = allIngredients
          .where((ingredient) => usedIngredientIds.contains(ingredient.id))
          .toList();

      debugPrint(
          'ReduceIngredientsStockUseCase: Bahan yang digunakan: ${usedIngredients.length} jenis');
      for (var ingredient in usedIngredients) {
        debugPrint(
            'ReduceIngredientsStockUseCase: - ${ingredient.name} (ID: ${ingredient.id}) - Stok awal: ${ingredient.stockAmount}');
      }

      // Mapping ingredient untuk akses cepat
      final Map<String, IngredientEntity> ingredientMap = {
        for (var ingredient in allIngredients) ingredient.id: ingredient
      };

      // 5. Hitung total bahan yang digunakan dalam transaksi
      final Map<String, int> ingredientUsage = {};

      for (var item in items) {
        final menuReqs = menuRequirements[item.menuId] ?? [];
        for (var req in menuReqs) {
          // Akumulasi penggunaan bahan berdasarkan jumlah menu yang dibeli
          final usageAmount = req.requiredAmount * item.quantity;
          ingredientUsage[req.ingredientId] =
              (ingredientUsage[req.ingredientId] ?? 0) + usageAmount;

          debugPrint(
              'ReduceIngredientsStockUseCase: Menu ${item.menuName} (qty: ${item.quantity}) membutuhkan ${req.ingredientName}: ${usageAmount} unit');
        }
      }

      // 6. Update stok bahan di Firestore menggunakan batch
      final writeBatch = _firestore.batch();

      // 6.1 Update ingredient stock
      for (var entry in ingredientUsage.entries) {
        final ingredientId = entry.key;
        final usedAmount = entry.value;

        final ingredient = ingredientMap[ingredientId];
        if (ingredient != null) {
          final newStock = ingredient.stockAmount - usedAmount;
          if (newStock < 0) {
            throw Exception(
                'Stok bahan ${ingredient.name} tidak mencukupi (${ingredient.stockAmount} < $usedAmount)');
          }

          // Update stok di Firestore
          final ingredientRef =
              _firestore.collection('ingredients').doc(ingredientId);
          writeBatch.update(ingredientRef, {
            'stock_amount': newStock,
            'updated_at': FieldValue.serverTimestamp(),
          });

          debugPrint(
              'ReduceIngredientsStockUseCase: Bahan ${ingredient.name} - stok ${ingredient.stockAmount} -> $newStock (dikurangi $usedAmount)');
        }
      }

      // 6.2 Update menu stock dalam batch yang sama
      for (var entry in menuQuantities.entries) {
        final menuId = entry.key;
        final quantity = entry.value;

        final data = menuData[menuId];
        if (data != null) {
          final currentStock = data['stock'] ?? 0;
          final menuName = data['name'] ?? 'Unknown Menu';

          // Hitung stok baru (pastikan tidak negatif)
          final newStock =
              currentStock > quantity ? currentStock - quantity : 0;

          debugPrint(
              'ReduceIngredientsStockUseCase: Menu $menuName - stok $currentStock -> $newStock (dikurangi $quantity)');

          // Update stok menu dalam batch
          final menuRef = _firestore.collection('menus').doc(menuId);
          writeBatch.update(menuRef, {
            'stock': newStock,
            'updated_at': FieldValue.serverTimestamp(),
          });
        }
      }

      // 7. Commit semua perubahan dalam satu transaksi
      await writeBatch.commit();
      debugPrint(
          'ReduceIngredientsStockUseCase: Batch update berhasil - stok bahan dan menu berhasil diperbarui');

      // 8. Verifikasi update berhasil dengan mengambil data terbaru
      final updatedMenus = await _firestore
          .collection('menus')
          .where(FieldPath.documentId, whereIn: menuIds)
          .get();

      for (var doc in updatedMenus.docs) {
        final data = doc.data();
        final menuName = data['name'] ?? 'Unknown';
        final stock = data['stock'] ?? 0;
        debugPrint(
            'ReduceIngredientsStockUseCase: [VERIFY] Menu $menuName - stok terbaru: $stock');
      }

      debugPrint(
          'ReduceIngredientsStockUseCase: Proses pengurangan stok selesai');
    } catch (e) {
      debugPrint('ReduceIngredientsStockUseCase: Error - $e');
      throw Exception('Gagal mengurangi stok bahan: $e');
    }
  }
}
