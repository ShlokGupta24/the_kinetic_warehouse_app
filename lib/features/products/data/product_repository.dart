import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

// Import the shared firestoreProvider from the dashboard repository
// to avoid duplicate provider definitions (which cause runtime conflicts).
import '../../dashboard/data/dashboard_repository.dart';

part 'product_repository.g.dart';

class ProductRepository {
  final FirebaseFirestore _db;

  ProductRepository(this._db);

  Future<void> addProduct({
    required String name,
    required String category,
    required String sku,
    required int initialQty,
    required String unit,
    required double costPrice,
    required double sellingPrice,
    String? imageUrl,
  }) async {
    final docRef = _db.collection('products').doc();

    // Build both write futures upfront
    final productWrite = docRef.set({
      'name': name,
      'category': category,
      'sku': sku,
      'qty': initialQty,
      'unit': unit,
      'costPrice': costPrice,
      'price': sellingPrice,
      'imageUrl': imageUrl,
      'lowStockThreshold': 10,
      'createdAt': FieldValue.serverTimestamp(),
    });

    if (initialQty > 0) {
      // Run both writes IN PARALLEL for maximum speed
      final transactionWrite = _db.collection('transactions').add({
        'type': 'restock',
        'title': name,
        'subtitle': 'Staff: ${FirebaseAuth.instance.currentUser?.displayName ?? FirebaseAuth.instance.currentUser?.email ?? 'Admin'}',
        'productSku': sku,
        'qty': initialQty,
        'amount': costPrice * initialQty,
        'timestamp': FieldValue.serverTimestamp(),
        'imageUrl': imageUrl,
      });

      await Future.wait([productWrite, transactionWrite]);
    } else {
      await productWrite;
    }
  }

  Future<void> editProduct({
    required String productId,
    required Map<String, dynamic> data,
    required int? oldQty,
    required int? newQty,
    required String? sku,
    required String? name,
    required String? imageUrl,
  }) async {
    final docRef = _db.collection('products').doc(productId);
    
    // Build both write futures upfront
    final productWrite = docRef.update(data);

    if (oldQty != null && newQty != null && oldQty != newQty) {
      int diff = newQty - oldQty;
      final transactionWrite = _db.collection('transactions').add({
        'type': diff > 0 ? 'restock' : 'adjustment',
        'title': name,
        'subtitle': 'Staff: ${FirebaseAuth.instance.currentUser?.displayName ?? FirebaseAuth.instance.currentUser?.email ?? 'Admin'} - ${diff > 0 ? 'Manual Restock' : 'Manual Adjustment'}',
        'productSku': sku,
        'qty': diff.abs(),
        'amount': 0, // Since it's an adjustment, no direct amount value unless derived 
        'timestamp': FieldValue.serverTimestamp(),
        'imageUrl': imageUrl,
      });

      await Future.wait([productWrite, transactionWrite]);
    } else {
      await productWrite;
    }
  }
  Future<void> deleteProduct(String productId, String sku) async {
    final batch = _db.batch();

    // Delete the product document
    batch.delete(_db.collection('products').doc(productId));

    // Find and delete all related transactions
    final transactionsSnapshot = await _db
        .collection('transactions')
        .where('productSku', isEqualTo: sku)
        .get();

    for (var doc in transactionsSnapshot.docs) {
      batch.delete(doc.reference);
    }

    await batch.commit();
  }
}

@riverpod
ProductRepository productRepository(Ref ref) {
  return ProductRepository(ref.watch(firestoreProvider));
}
