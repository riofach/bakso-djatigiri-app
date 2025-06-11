// Repository interface untuk History
import 'package:cloud_firestore/cloud_firestore.dart';
import '../entities/transaction.dart' as entity;
import '../entities/transaction_item.dart';

abstract class HistoryRepository {
  // Mendapatkan daftar transaksi dengan urutan timestamp terbaru
  Future<List<entity.Transaction>> getTransactions();

  // Mendapatkan detail item dari suatu transaksi
  Future<List<TransactionItem>> getTransactionItems(String transactionId);

  // Mendapatkan stream transaksi untuk pembaruan realtime
  Stream<List<entity.Transaction>> watchTransactions();

  // Stream spesifik untuk transaksi tertentu dan item-itemnya
  Stream<DocumentSnapshot> watchTransaction(String transactionId);
}
