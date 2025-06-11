// Implementasi history repository berdasarkan data source
// ignore_for_file: unused_import
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/transaction.dart' as entity;
import '../../domain/entities/transaction_item.dart';
import '../../domain/repositories/history_repository.dart';
import '../datasources/history_data_source.dart';
import '../models/transaction_model.dart';

class HistoryRepositoryImpl implements HistoryRepository {
  final HistoryDataSource dataSource;

  HistoryRepositoryImpl(this.dataSource);

  @override
  Future<List<entity.Transaction>> getTransactions() async {
    return await dataSource.getTransactions();
  }

  @override
  Future<List<TransactionItem>> getTransactionItems(
      String transactionId) async {
    return await dataSource.getTransactionItems(transactionId);
  }

  @override
  Stream<List<entity.Transaction>> watchTransactions() {
    return dataSource.watchTransactions();
  }

  @override
  Stream<DocumentSnapshot> watchTransaction(String transactionId) {
    return dataSource.watchTransaction(transactionId);
  }
}
