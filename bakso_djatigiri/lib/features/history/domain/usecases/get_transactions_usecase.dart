// UseCase untuk mendapatkan daftar transaksi
import '../entities/transaction.dart';
import '../repositories/history_repository.dart';

class GetTransactionsUseCase {
  final HistoryRepository repository;

  GetTransactionsUseCase(this.repository);

  Future<List<Transaction>> call() async {
    return await repository.getTransactions();
  }
}
