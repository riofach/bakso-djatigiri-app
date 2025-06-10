// Implementasi repository untuk cashier (data layer)
import 'package:injectable/injectable.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/repositories/cashier_repository.dart';
import '../models/transaction_item_model.dart';
import '../datasources/cashier_data_source.dart';

@Injectable(as: CashierRepository)
class CashierRepositoryImpl implements CashierRepository {
  final CashierDataSource _dataSource;

  CashierRepositoryImpl(this._dataSource);

  @override
  Future<void> checkout({
    required String userId,
    required String cashierName,
    required int totalPrice,
    required int payment,
    required List<TransactionItemModel> items,
  }) async {
    return await _dataSource.createTransaction(
      userId: userId,
      cashierName: cashierName,
      totalPrice: totalPrice,
      payment: payment,
      items: items,
    );
  }

  @override
  Future<void> reduceIngredientsStock({
    required List<TransactionItemModel> items,
  }) async {
    return await _dataSource.reduceIngredientsStock(items: items);
  }
}
