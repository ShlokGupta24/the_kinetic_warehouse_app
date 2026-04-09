import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../domain/dashboard_stats.dart';

part 'dashboard_repository.g.dart';

// ---------------------------------------------------------------------------
// Firestore instance – kept alive so it's never re-created
// ---------------------------------------------------------------------------
@Riverpod(keepAlive: true)
FirebaseFirestore firestore(Ref ref) {
  return FirebaseFirestore.instance;
}

// ---------------------------------------------------------------------------
// Stream: All Products – keepAlive so auto-dispose loop can't happen
// ---------------------------------------------------------------------------
@Riverpod(keepAlive: true)
Stream<QuerySnapshot<Map<String, dynamic>>> productsStream(Ref ref) {
  final db = ref.watch(firestoreProvider);
  return db.collection('products').snapshots();
}

// ---------------------------------------------------------------------------
// Stream: Recent Activity (latest 10 transactions)
// ---------------------------------------------------------------------------
@Riverpod(keepAlive: true)
Stream<QuerySnapshot<Map<String, dynamic>>> recentActivityStream(Ref ref) {
  final db = ref.watch(firestoreProvider);
  return db
      .collection('transactions')
      .orderBy('timestamp', descending: true)
      .limit(10)
      .snapshots();
}

// ---------------------------------------------------------------------------
// Stream: Today's Sales – use LOCAL timezone midnight, not UTC
// ---------------------------------------------------------------------------
@Riverpod(keepAlive: true)
Stream<QuerySnapshot<Map<String, dynamic>>> todaySalesStream(Ref ref) {
  final db = ref.watch(firestoreProvider);
  final now = DateTime.now();
  // Local midnight → avoids IST/UTC mismatch losing today's data
  final todayStart = Timestamp.fromDate(DateTime(now.year, now.month, now.day));

  return db
      .collection('transactions')
      .where('timestamp', isGreaterThanOrEqualTo: todayStart)
      .snapshots();
}

// ---------------------------------------------------------------------------
// Stream: Last Year Same-Day Sales
// ---------------------------------------------------------------------------
@Riverpod(keepAlive: true)
Stream<QuerySnapshot<Map<String, dynamic>>> lySalesStream(Ref ref) {
  final db = ref.watch(firestoreProvider);
  final now = DateTime.now();
  final lyStart = Timestamp.fromDate(DateTime(now.year - 1, now.month, now.day));
  final lyEnd = Timestamp.fromDate(
    DateTime(now.year - 1, now.month, now.day, 23, 59, 59),
  );

  return db
      .collection('transactions')
      .where('timestamp', isGreaterThanOrEqualTo: lyStart)
      .where('timestamp', isLessThanOrEqualTo: lyEnd)
      .snapshots();
}

// ---------------------------------------------------------------------------
// Aggregator – instantly returns DashboardStats.empty while streams load,
// then reacts to every snapshot update in real-time.
// ---------------------------------------------------------------------------
@Riverpod(keepAlive: true)
DashboardStats dashboardStats(Ref ref) {
  final productsSnap = ref.watch(productsStreamProvider).value;
  final activitySnap = ref.watch(recentActivityStreamProvider).value;
  final todaySalesSnap = ref.watch(todaySalesStreamProvider).value;
  final lySalesSnap = ref.watch(lySalesStreamProvider).value;

  // Return empty stats immediately so the UI renders instantly.
  // Each field will update as streams emit.
  if (productsSnap == null &&
      activitySnap == null &&
      todaySalesSnap == null &&
      lySalesSnap == null) {
    return DashboardStats.empty;
  }

  int lowStock = 0;
  double totalValue = 0;

  for (final doc in (productsSnap?.docs ?? [])) {
    final data = doc.data();
    final qty = (data['qty'] as num?)?.toInt() ?? 0;
    final price = (data['price'] as num?)?.toDouble() ?? 0;
    final threshold = (data['lowStockThreshold'] as num?)?.toInt() ?? 10;

    totalValue += qty * price;
    if (qty <= threshold) lowStock++;
  }

  double todaySalesTotal = 0;
  for (final doc in (todaySalesSnap?.docs ?? [])) {
    final data = doc.data();
    if (data['type'] == 'sale') {
      todaySalesTotal += (data['amount'] as num?)?.toDouble() ?? 0;
    }
  }

  double lyTotal = 0;
  for (final doc in (lySalesSnap?.docs ?? [])) {
    final data = doc.data();
    if (data['type'] == 'sale') {
      lyTotal += (data['amount'] as num?)?.toDouble() ?? 0;
    }
  }

  final activityItems = (activitySnap?.docs ?? [])
      .map((doc) => ActivityItem.fromFirestore(doc))
      .toList();

  return DashboardStats(
    totalProducts: productsSnap?.docs.length ?? 0,
    lowStockCount: lowStock,
    totalInventoryValue: totalValue,
    todaySales: todaySalesTotal,
    lastYearTodaySales: lyTotal,
    recentActivity: activityItems,
  );
}
