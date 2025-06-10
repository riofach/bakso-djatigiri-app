// Data Source untuk cashier (data layer)
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:injectable/injectable.dart';
import 'package:flutter/material.dart';
import '../models/transaction_item_model.dart';
import '../../../menu/domain/entities/menu_requirement_entity.dart';
import '../../../stock/domain/entities/ingredient_entity.dart';

abstract class CashierDataSource {
  Future<void> createTransaction({
    required String userId,
    required String cashierName,
    required int totalPrice,
    required int payment,
    required List<TransactionItemModel> items,
  });

  Future<void> reduceIngredientsStock({
    required List<TransactionItemModel> items,
  });
}

@Injectable(as: CashierDataSource)
class CashierDataSourceImpl implements CashierDataSource {
  final FirebaseFirestore _firestore;

  CashierDataSourceImpl({required FirebaseFirestore firestore})
      : _firestore = firestore;

  @override
  Future<void> createTransaction({
    required String userId,
    required String cashierName,
    required int totalPrice,
    required int payment,
    required List<TransactionItemModel> items,
  }) async {
    try {
      // Generate transaction code
      final transactionCode = 'TRX-${DateTime.now().millisecondsSinceEpoch}';

      // Create transaction document
      final transactionRef = await _firestore.collection('transactions').add({
        'transaction_code': transactionCode,
        'timestamp': FieldValue.serverTimestamp(),
        'cashier_id': userId,
        'cashier_name': cashierName,
        'total': totalPrice,
        'customer_payment': payment,
        'change': payment - totalPrice,
      });

      // Add transaction items
      final batch = _firestore.batch();
      for (var item in items) {
        final itemRef = _firestore.collection('transaction_items').doc();
        batch.set(itemRef, {
          'transaction_id': transactionRef.id,
          'menu_id': item.menuId,
          'menu_name': item.menuName,
          'quantity': item.quantity,
          'price_each': item.priceEach,
          'subtotal': item.subtotal,
        });
      }
      await batch.commit();

      debugPrint('Transaction created successfully: $transactionCode');
    } catch (e) {
      debugPrint('Error creating transaction: $e');
      throw Exception('Gagal membuat transaksi: $e');
    }
  }

  @override
  Future<void> reduceIngredientsStock({
    required List<TransactionItemModel> items,
  }) async {
    try {
      debugPrint('===== PENGURANGAN STOK BAHAN DIMULAI =====');
      debugPrint('Item yang dibeli: ${items.length} menu');

      // 1. Ambil semua menu yang dibeli
      final menuIds = items.map((item) => item.menuId).toList();
      debugPrint('Menu IDs: $menuIds');

      // 2. Ambil semua menu requirements untuk menu yang dibeli
      final requirementsQuery = await _firestore
          .collection('menu_requirements')
          .where('menu_id', whereIn: menuIds)
          .get();

      debugPrint(
          'Menu requirements ditemukan: ${requirementsQuery.docs.length} dokumen');

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

      // Log detail requirements per menu
      menuRequirements.forEach((menuId, reqs) {
        debugPrint('Menu ID: $menuId membutuhkan ${reqs.length} bahan:');
        for (var req in reqs) {
          debugPrint(
              '  - ${req.ingredientName} (${req.ingredientId}): ${req.requiredAmount} unit');
        }
      });

      // 4. Ambil semua ingredients yang dibutuhkan
      final ingredientsQuery = await _firestore.collection('ingredients').get();
      final allIngredients = ingredientsQuery.docs.map((doc) {
        final data = doc.data();
        return IngredientEntity(
          id: doc.id,
          name: data['name'] ?? '',
          stockAmount: data['stock_amount'] ?? 0,
          imageUrl: data['image_url'] ?? '',
          createdAt:
              (data['created_at'] as Timestamp?)?.toDate() ?? DateTime.now(),
        );
      }).toList();

      debugPrint('Total ingredients di database: ${allIngredients.length}');

      // Mapping ingredient untuk akses cepat
      final Map<String, IngredientEntity> ingredientMap = {
        for (var ingredient in allIngredients) ingredient.id: ingredient
      };

      // Log detail ingredients
      ingredientMap.forEach((id, ingredient) {
        debugPrint(
            'Ingredient: ${ingredient.name} (ID: $id) - Stock: ${ingredient.stockAmount}');
      });

      // 5. Hitung total bahan yang digunakan dalam transaksi
      final Map<String, int> ingredientUsage = {};

      for (var item in items) {
        debugPrint(
            'Processing item: ${item.menuName} (${item.menuId}), quantity: ${item.quantity}');
        final menuReqs = menuRequirements[item.menuId] ?? [];

        if (menuReqs.isEmpty) {
          debugPrint(
              'PERINGATAN: Tidak ada requirements untuk menu: ${item.menuName}');
        }

        for (var req in menuReqs) {
          // Akumulasi penggunaan bahan berdasarkan jumlah yang dibeli
          final currentUsage = ingredientUsage[req.ingredientId] ?? 0;
          final additionalUsage = req.requiredAmount * item.quantity;
          ingredientUsage[req.ingredientId] = currentUsage + additionalUsage;

          debugPrint(
              '  - Menggunakan ${req.ingredientName}: $additionalUsage unit (total: ${currentUsage + additionalUsage})');
        }
      }

      debugPrint('Ringkasan penggunaan bahan:');
      ingredientUsage.forEach((ingredientId, amount) {
        final ingredient = ingredientMap[ingredientId];
        debugPrint('  - ${ingredient?.name ?? ingredientId}: $amount unit');
      });

      // 6. Update stok bahan di Firestore
      final batch = _firestore.batch();

      debugPrint('Memulai update stok bahan:');
      for (var entry in ingredientUsage.entries) {
        final ingredientId = entry.key;
        final usedAmount = entry.value;

        final ingredient = ingredientMap[ingredientId];
        if (ingredient != null) {
          final oldStock = ingredient.stockAmount;
          final newStock = oldStock - usedAmount;

          debugPrint(
              '  - Updating ${ingredient.name}: $oldStock -> $newStock (dikurangi $usedAmount)');

          if (newStock < 0) {
            throw Exception(
                'Stok bahan ${ingredient.name} tidak mencukupi (${ingredient.stockAmount} < $usedAmount)');
          }

          // Update stok di Firestore
          final ingredientRef =
              _firestore.collection('ingredients').doc(ingredientId);
          batch.update(ingredientRef, {'stock_amount': newStock});
        } else {
          debugPrint(
              '  - PERINGATAN: Ingredient dengan ID $ingredientId tidak ditemukan!');
        }
      }

      // Commit batch update
      debugPrint(
          'Melakukan commit batch update untuk ${ingredientUsage.length} bahan...');
      await batch.commit();
      debugPrint('Batch update berhasil dilakukan');

      // 7. Update stok semua menu berdasarkan ketersediaan bahan terbaru
      debugPrint(
          'Memulai update stok menu berdasarkan ketersediaan bahan terbaru...');
      await _updateAllMenuStocks();

      debugPrint('===== PENGURANGAN STOK BAHAN SELESAI =====');
    } catch (e) {
      debugPrint('===== ERROR PENGURANGAN STOK BAHAN =====');
      debugPrint('Error reducing ingredients stock: $e');
      throw Exception('Gagal mengurangi stok bahan: $e');
    }
  }

  Future<void> _updateAllMenuStocks() async {
    try {
      debugPrint('===== UPDATE STOK MENU DIMULAI =====');

      // 1. Ambil semua menu
      debugPrint('Mengambil data semua menu...');
      final menuQuery = await _firestore.collection('menus').get();
      final menuIds = menuQuery.docs.map((doc) => doc.id).toList();
      debugPrint('Total menu: ${menuIds.length}');

      // 2. Ambil semua ingredients dengan stok terbaru
      debugPrint('Mengambil data semua ingredients dengan stok terbaru...');
      final ingredientsQuery = await _firestore.collection('ingredients').get();
      final ingredients = ingredientsQuery.docs.map((doc) {
        final data = doc.data();
        final ingredient = IngredientEntity(
          id: doc.id,
          name: data['name'] ?? '',
          stockAmount: data['stock_amount'] ?? 0,
          imageUrl: data['image_url'] ?? '',
          createdAt:
              (data['created_at'] as Timestamp?)?.toDate() ?? DateTime.now(),
        );
        debugPrint(
            '  - Ingredient: ${ingredient.name} (ID: ${ingredient.id}) - Stok terbaru: ${ingredient.stockAmount}');
        return ingredient;
      }).toList();
      debugPrint('Total ingredients: ${ingredients.length}');

      // 3. Ambil semua requirements
      debugPrint('Mengambil data semua menu requirements...');
      final requirementsQuery =
          await _firestore.collection('menu_requirements').get();
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
      debugPrint('Total requirements: ${requirements.length}');

      // 4. Kelompokkan requirements berdasarkan menu_id
      final Map<String, List<MenuRequirementEntity>> menuRequirements = {};
      for (var req in requirements) {
        if (!menuRequirements.containsKey(req.menuId)) {
          menuRequirements[req.menuId] = [];
        }
        menuRequirements[req.menuId]!.add(req);
      }

      // Log detail menu requirements
      debugPrint('Detail menu requirements:');
      menuRequirements.forEach((menuId, reqs) {
        debugPrint('  - Menu ID: $menuId membutuhkan ${reqs.length} bahan');
        for (var req in reqs) {
          debugPrint(
              '    * ${req.ingredientName} (${req.ingredientId}): ${req.requiredAmount} unit');
        }
      });

      // 5. Hitung dan update stok untuk setiap menu
      final batch = _firestore.batch();
      debugPrint('Menghitung stok baru untuk setiap menu...');

      int totalMenuUpdated = 0;
      Map<String, Map<String, dynamic>> stockBeforeAfter = {};

      for (var menuId in menuIds) {
        final reqs = menuRequirements[menuId] ?? [];

        // Dapatkan detail menu saat ini
        final menuDoc = await _firestore.collection('menus').doc(menuId).get();
        final menuData = menuDoc.data() ?? {};
        final menuName = menuData['name'] ?? 'Unknown Menu';
        final currentStock = menuData['stock'] ?? 0;

        // Jika menu tidak memiliki requirements, set stok ke 0
        if (reqs.isEmpty) {
          debugPrint(
              '  - Menu $menuName (ID: $menuId): tidak memiliki requirements, set stok = 0');
          stockBeforeAfter[menuName] = {
            'before': currentStock,
            'after': 0,
            'requirements': 0
          };

          // Update stok menu di Firestore
          final menuRef = _firestore.collection('menus').doc(menuId);
          batch.update(menuRef, {'stock': 0});
          totalMenuUpdated++;
          continue;
        }

        // Hitung stok menu berdasarkan ketersediaan bahan
        debugPrint('  - Menghitung stok untuk menu: $menuName (ID: $menuId)');
        int calculatedStock = _calculateMenuStock(
          menuRequirements: reqs,
          availableIngredients: ingredients,
        );

        stockBeforeAfter[menuName] = {
          'before': currentStock,
          'after': calculatedStock,
          'requirements': reqs.length
        };

        debugPrint(
            '  - Menu: $menuName (ID: $menuId) - Stok lama: $currentStock, Stok baru: $calculatedStock');

        // Update stok menu di Firestore
        final menuRef = _firestore.collection('menus').doc(menuId);
        batch.update(menuRef, {'stock': calculatedStock});
        totalMenuUpdated++;
      }

      // Commit batch update
      debugPrint(
          'Melakukan commit batch update untuk $totalMenuUpdated menu...');
      await batch.commit();

      debugPrint('Ringkasan update stok menu:');
      stockBeforeAfter.forEach((menuName, info) {
        debugPrint(
            '  - $menuName: stok sebelum = ${info['before']}, stok setelah = ${info['after']}, requirements = ${info['requirements']}');
      });

      debugPrint('Batch update menu berhasil dilakukan');
      debugPrint('===== UPDATE STOK MENU SELESAI =====');
    } catch (e) {
      debugPrint('===== ERROR UPDATE STOK MENU =====');
      debugPrint('Error updating all menu stocks: $e');
      throw Exception('Gagal mengupdate stok menu: $e');
    }
  }

  int _calculateMenuStock({
    required List<MenuRequirementEntity> menuRequirements,
    required List<IngredientEntity> availableIngredients,
  }) {
    // Jika tidak ada requirements, stok = 0
    if (menuRequirements.isEmpty) {
      debugPrint('    _calculateMenuStock: Tidak ada requirements, stok = 0');
      return 0;
    }

    debugPrint(
        '    _calculateMenuStock: Menghitung stok berdasarkan ${menuRequirements.length} requirements');

    // Mapping ingredient untuk akses cepat
    final ingredientMap = {
      for (var ingredient in availableIngredients) ingredient.id: ingredient
    };

    // Hitung berapa banyak menu yang bisa dibuat dari setiap bahan
    List<int> possibleStocks = [];

    for (var requirement in menuRequirements) {
      final ingredient = ingredientMap[requirement.ingredientId];

      // Jika bahan tidak ditemukan atau stok bahan = 0, maka stok menu = 0
      if (ingredient == null) {
        debugPrint(
            '    _calculateMenuStock: Ingredient ${requirement.ingredientName} (${requirement.ingredientId}) tidak ditemukan, stok = 0');
        return 0;
      }

      if (ingredient.stockAmount <= 0) {
        debugPrint(
            '    _calculateMenuStock: Stok ${ingredient.name} = 0, stok menu = 0');
        return 0;
      }

      // Hitung berapa banyak menu yang bisa dibuat dari bahan ini
      final requiredAmount =
          requirement.requiredAmount > 0 ? requirement.requiredAmount : 1;
      final possibleStock = ingredient.stockAmount ~/ requiredAmount;

      debugPrint(
          '    _calculateMenuStock: ${ingredient.name} (ID: ${ingredient.id}) - stok ${ingredient.stockAmount} / kebutuhan $requiredAmount = $possibleStock menu');

      // Jika tidak bisa membuat menu dari bahan ini, stok menu = 0
      if (possibleStock <= 0) {
        debugPrint(
            '    _calculateMenuStock: Tidak bisa membuat menu dari ${ingredient.name}, stok = 0');
        return 0;
      }

      possibleStocks.add(possibleStock);
    }

    // Stok menu adalah minimum dari semua kemungkinan stok
    if (possibleStocks.isEmpty) {
      debugPrint(
          '    _calculateMenuStock: Tidak ada stok yang bisa dihitung, stok = 0');
      return 0;
    }

    final result =
        possibleStocks.reduce((min, stock) => stock < min ? stock : min);
    debugPrint(
        '    _calculateMenuStock: Stok final = $result menu (dari kemungkinan: $possibleStocks)');
    return result;
  }
}
