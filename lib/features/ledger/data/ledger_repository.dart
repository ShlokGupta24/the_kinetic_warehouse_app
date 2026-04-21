import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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

    // Force a token refresh to ensure valid credentials before the transaction
    try {
      await FirebaseAuth.instance.currentUser?.getIdToken(true);
    } catch (_) {}

    final productDoc = await productRef.get();
    if (!productDoc.exists) {
      throw Exception("Product does not exist!");
    }

    final data = productDoc.data()!;
    final currentQty = (data['qty'] as num?)?.toInt() ?? 0;
    final newQty = isPurchase ? currentQty + qty : currentQty - qty;
    final costPrice = (data['costPrice'] as num?)?.toDouble() ?? 0.0;
    final sellingPrice = (data['price'] as num?)?.toDouble() ?? 0.0;

    // Ensure we don't end up with negative stock for sales
    if (!isPurchase && newQty < 0) {
      throw Exception("Insufficient stock!");
    }

    // Calculate amount and profit
    final amount = isPurchase ? costPrice * qty : sellingPrice * qty;
    final profit = isPurchase ? 0.0 : (sellingPrice - costPrice) * qty;

    final batch = _db.batch();
    // Update product quantity
    batch.update(productRef, {'qty': newQty});

    // Insert transaction record
    batch.set(transactionRef, {
      'type': isPurchase ? 'purchase' : 'sale',
      'title': productName,
      'subtitle': 'Staff: $staffName',
      'productSku': productSku,
      'qty': qty,
      'amount': amount,
      'profit': profit,
      'timestamp': FieldValue.serverTimestamp(),
    });

    await batch.commit();
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
