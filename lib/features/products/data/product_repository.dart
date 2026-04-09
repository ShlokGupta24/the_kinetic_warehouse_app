import 'package:cloud_firestore/cloud_firestore.dart';
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
        'subtitle': 'Initial Stock Added',
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
}

@riverpod
ProductRepository productRepository(Ref ref) {
  return ProductRepository(ref.watch(firestoreProvider));
}
