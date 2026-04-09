import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../dashboard/data/dashboard_repository.dart';

part 'ledger_repository.g.dart';

class LedgerRepository {
  final FirebaseFirestore _db;

  LedgerRepository(this._db);

  /// Records a transaction and automatically updates the product stock
  Future<void> recordTransaction({
    required String productId,
    required String productSku,
    required String productName,
    required int qty,
    required bool isPurchase,
    required String staffName,
  }) async {
    final productRef = _db.collection('products').doc(productId);
    final transactionRef = _db.collection('transactions').doc();

    await _db.runTransaction((transaction) async {
      final productDoc = await transaction.get(productRef);
      if (!productDoc.exists) {
        throw Exception("Product does not exist!");
      }

      final currentQty = (productDoc.data()?['qty'] as num?)?.toInt() ?? 0;
      final newQty = isPurchase ? currentQty + qty : currentQty - qty;

      // Ensure we don't end up with negative stock for sales
      if (!isPurchase && newQty < 0) {
        throw Exception("Insufficient stock!");
      }

      // Update product quantity
      transaction.update(productRef, {'qty': newQty});

      // Insert transaction record
      transaction.set(transactionRef, {
        'type': isPurchase ? 'purchase' : 'sale',
        'title': productName,
        'subtitle': 'Staff: \$staffName',
        'productSku': productSku,
        'qty': qty,
        'timestamp': FieldValue.serverTimestamp(),
      });
    });
  }

  /// Get all transactions with limit
  Stream<QuerySnapshot<Map<String, dynamic>>> getTransactions({int limit = 50}) {
    return _db
        .collection('transactions')
        .orderBy('timestamp', descending: true)
        .limit(limit)
        .snapshots();
  }
}

@riverpod
LedgerRepository ledgerRepository(Ref ref) {
  return LedgerRepository(ref.watch(firestoreProvider));
}
