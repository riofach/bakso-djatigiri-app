// UseCase untuk mendapatkan detail item transaksi
import '../entities/transaction_item.dart';
import '../repositories/history_repository.dart';

class GetTransactionItemsUseCase {
  final HistoryRepository repository;

  GetTransactionItemsUseCase(this.repository);

  Future<List<TransactionItem>> call(String transactionId) async {
    return await repository.getTransactionItems(transactionId);
  }
}
