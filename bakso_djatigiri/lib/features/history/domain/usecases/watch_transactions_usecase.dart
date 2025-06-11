// UseCase untuk memantau daftar transaksi secara realtime
import '../entities/transaction.dart';
import '../repositories/history_repository.dart';

class WatchTransactionsUseCase {
  final HistoryRepository repository;

  WatchTransactionsUseCase(this.repository);

  Stream<List<Transaction>> call() {
    return repository.watchTransactions();
  }
}
