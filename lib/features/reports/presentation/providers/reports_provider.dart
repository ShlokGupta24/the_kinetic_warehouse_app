import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../ledger/data/ledger_repository.dart';
import '../../../products/presentation/providers/product_filter_provider.dart';

final allTransactionsProvider = StreamProvider.autoDispose<List<Map<String, dynamic>>>((ref) {
  final repo = ref.watch(ledgerRepositoryProvider);
  // We fetch a larger limit for reports, e.g., 500
  return repo.getTransactions(limit: 500).map((snapshot) {
    return snapshot.docs.map((doc) => doc.data()).toList();
  });
});

// A provider that aggregates sales by product to find Top Sellers
final topSellingProductsProvider = Provider.autoDispose<AsyncValue<List<Map<String, dynamic>>>>((ref) {
  final transactionsAsync = ref.watch(allTransactionsProvider);
  
  return transactionsAsync.whenData((transactions) {
    final Map<String, Map<String, dynamic>> salesVolume = {};

    for (var tx in transactions) {
      final type = (tx['type'] as String?)?.toLowerCase() ?? 'purchase';
      // Only count 'sale' or 'outbound'
      if (type == 'sale' || type == 'outbound') {
        final sku = tx['productSku'] as String? ?? 'Unknown';
        final name = tx['title'] as String? ?? 'Unknown Product';
        final qty = (tx['qty'] as num?)?.toInt() ?? 0;
        
        if (salesVolume.containsKey(sku)) {
          salesVolume[sku]!['qty'] += qty;
        } else {
          salesVolume[sku] = {
            'sku': sku,
            'name': name,
            'qty': qty,
          };
        }
      }
    }

    final topSellers = salesVolume.values.toList()
      ..sort((a, b) => (b['qty'] as int).compareTo(a['qty'] as int));

    return topSellers.take(3).toList();
  });
});

// A provider that filters products with qty <= lowStockThreshold
final lowStockProductsProvider = Provider.autoDispose<AsyncValue<List<Map<String, dynamic>>>>((ref) {
  final productsAsync = ref.watch(allProductsStreamProvider);

  return productsAsync.whenData((snapshot) {
    return snapshot.docs
        .map((d) {
          final data = d.data();
          data['id'] = d.id;
          return data;
        })
        .where((p) {
          final qty = (p['qty'] as num?)?.toInt() ?? 0;
          final threshold = (p['lowStockThreshold'] as num?)?.toInt() ?? 10;
          return qty <= threshold;
        })
        .toList();
  });
});
