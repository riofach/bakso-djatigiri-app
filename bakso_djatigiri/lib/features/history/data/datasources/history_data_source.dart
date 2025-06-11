// Data source untuk mengakses data history dari Firestore
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/transaction_model.dart';
import '../models/transaction_item_model.dart';

abstract class HistoryDataSource {
  Future<List<TransactionModel>> getTransactions();
  Future<List<TransactionItemModel>> getTransactionItems(String transactionId);
  Stream<List<TransactionModel>> watchTransactions();
  Stream<DocumentSnapshot> watchTransaction(String transactionId);
}

class HistoryDataSourceImpl implements HistoryDataSource {
  final FirebaseFirestore firestore;

  HistoryDataSourceImpl({required this.firestore});

  @override
  Future<List<TransactionModel>> getTransactions() async {
    try {
      final querySnapshot = await firestore
          .collection('transactions')
          .orderBy('timestamp', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => TransactionModel.fromSnapshot(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch transactions: $e');
    }
  }

  @override
  Future<List<TransactionItemModel>> getTransactionItems(
      String transactionId) async {
    try {
      final querySnapshot = await firestore
          .collection('transaction_items')
          .where('transaction_id', isEqualTo: transactionId)
          .get();

      return querySnapshot.docs
          .map((doc) => TransactionItemModel.fromSnapshot(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch transaction items: $e');
    }
  }

  @override
  Stream<List<TransactionModel>> watchTransactions() {
    return firestore
        .collection('transactions')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => TransactionModel.fromSnapshot(doc))
          .toList();
    });
  }

  @override
  Stream<DocumentSnapshot> watchTransaction(String transactionId) {
    return firestore.collection('transactions').doc(transactionId).snapshots();
  }
}
