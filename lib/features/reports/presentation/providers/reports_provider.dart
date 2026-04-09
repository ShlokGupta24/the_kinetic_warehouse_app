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

class SalesChartData {
  final List<double> weeklySales; // Mon-Sun (length 7)
  final List<double> monthlySales; // Weeks W1,W2,W3,W4,W5
  
  SalesChartData({required this.weeklySales, required this.monthlySales});
  
  double get maxWeekly => weeklySales.fold(0, (a, b) => a > b ? a : b);
  double get maxMonthly => monthlySales.fold(0, (a, b) => a > b ? a : b);
}

final salesChartDataProvider = Provider.autoDispose<AsyncValue<SalesChartData>>((ref) {
  final transactionsAsync = ref.watch(allTransactionsProvider);
  return transactionsAsync.whenData((transactions) {
    final List<double> weeklySales = List.filled(7, 0.0);
    final List<double> monthlySales = List.filled(5, 0.0);
    
    final now = DateTime.now();
    // Start of current week (Monday)
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final startOfMon = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);
    
    // Start of current month
    final startOfMonth = DateTime(now.year, now.month, 1);
    
    for (var tx in transactions) {
      if (tx['type'] == 'sale' || tx['type'] == 'outbound') {
        final amount = (tx['amount'] as num?)?.toDouble() ?? 0.0;
        final timestamp = (tx['timestamp'] as dynamic)?.toDate();
        if (timestamp == null) continue;
        
        // Weekly mapping
        if (timestamp.isAfter(startOfMon.subtract(const Duration(seconds: 1)))) {
           final dayIndex = timestamp.weekday - 1; // 0 for Mon
           if (dayIndex >= 0 && dayIndex < 7) {
              weeklySales[dayIndex] += amount;
           }
        }
        
        // Monthly mapping
        if (timestamp.isAfter(startOfMonth.subtract(const Duration(seconds: 1)))) {
          final dayOfMonth = timestamp.day;
          // Approximate weeks: 1-7=W1, 8-14=W2...
          final weekIndex = (dayOfMonth - 1) ~/ 7;
          if (weekIndex >= 0 && weekIndex < 5) {
             monthlySales[weekIndex] += amount;
          }
        }
      }
    }
    
    return SalesChartData(weeklySales: weeklySales, monthlySales: monthlySales);
  });
});
