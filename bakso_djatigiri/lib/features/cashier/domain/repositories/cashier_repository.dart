// Repository abstrak untuk cashier (domain layer)
import '../../data/models/transaction_item_model.dart';

abstract class CashierRepository {
  /// Melakukan checkout/pemesanan
  Future<void> checkout({
    required String userId,
    required String cashierName,
    required int totalPrice,
    required int payment,
    required List<TransactionItemModel> items,
  });

  /// Mengurangi stok bahan setelah transaksi
  Future<void> reduceIngredientsStock({
    required List<TransactionItemModel> items,
  });
}
