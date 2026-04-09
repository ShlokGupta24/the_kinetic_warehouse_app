import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// State providers for active filters
final searchQueryProvider = StateProvider<String>((ref) => '');
final categoryFilterProvider = StateProvider<String?>((ref) => null);
final stockStatusFilterProvider = StateProvider<String?>((ref) => null);

// Base stream containing all products
final allProductsStreamProvider = StreamProvider<QuerySnapshot<Map<String, dynamic>>>((ref) {
  return FirebaseFirestore.instance.collection('products').snapshots();
});

// The filtered products provider
final filteredProductsProvider = Provider<AsyncValue<List<Map<String, dynamic>>>>((ref) {
  final productsAsync = ref.watch(allProductsStreamProvider);
  final searchQuery = ref.watch(searchQueryProvider).toLowerCase();
  final category = ref.watch(categoryFilterProvider);
  final stockStatus = ref.watch(stockStatusFilterProvider);

  return productsAsync.whenData((snapshot) {
    var docs = snapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id; // Map the doc ID
      return data;
    }).toList();

    // 1. Text Search filtering
    if (searchQuery.isNotEmpty) {
      docs = docs.where((doc) {
        final name = (doc['name'] as String?)?.toLowerCase() ?? '';
        final sku = (doc['sku'] as String?)?.toLowerCase() ?? '';
        return name.contains(searchQuery) || sku.contains(searchQuery);
      }).toList();
    }

    // 2. Category filtering
    if (category != null && category != 'All Items') {
      docs = docs.where((doc) {
        final docCategory = doc['category'] as String?;
        return docCategory == category;
      }).toList();
    }

    // 3. Stock Status filtering
    if (stockStatus != null && stockStatus != 'All') {
      docs = docs.where((doc) {
        final qty = (doc['qty'] as num?)?.toInt() ?? 0;
        final threshold = (doc['lowStockThreshold'] as num?)?.toInt() ?? 10;
        
        if (stockStatus == 'Low Stock') {
          return qty <= threshold;
        } else if (stockStatus == 'In Stock') {
          return qty > threshold;
        }
        return true;
      }).toList();
    }

    return docs;
  });
});
