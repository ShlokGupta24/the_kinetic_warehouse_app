import 'package:cloud_firestore/cloud_firestore.dart';

/// Represents a single item in the recent activity feed.
class ActivityItem {
  final String id;
  final String title;
  final String subtitle;
  final String type; // 'sale' | 'restock'
  final double amount; // rupees for sales, qty for restock
  final int qty;
  final DateTime timestamp;
  final String? imageUrl;

  const ActivityItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.type,
    required this.amount,
    required this.qty,
    required this.timestamp,
    this.imageUrl,
  });

  factory ActivityItem.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return ActivityItem(
      id: doc.id,
      title: data['title'] as String? ?? '',
      subtitle: data['subtitle'] as String? ?? '',
      type: data['type'] as String? ?? 'sale',
      amount: (data['amount'] as num?)?.toDouble() ?? 0,
      qty: (data['qty'] as num?)?.toInt() ?? 0,
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      imageUrl: data['imageUrl'] as String?,
    );
  }

  String get timeAgo {
    final diff = DateTime.now().difference(timestamp);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}

/// Aggregated stats for the dashboard.
class DashboardStats {
  final int totalProducts;
  final int lowStockCount;
  final int totalUnitsSold;
  final double totalInventoryValue; // in ₹
  final double todaySales; // in ₹
  final double todayProfit; // in ₹
  final double lastYearTodaySales; // for % comparison
  final List<ActivityItem> recentActivity;

  const DashboardStats({
    required this.totalProducts,
    required this.lowStockCount,
    required this.totalUnitsSold,
    required this.totalInventoryValue,
    required this.todaySales,
    required this.todayProfit,
    required this.lastYearTodaySales,
    required this.recentActivity,
  });

  /// Percentage change vs last year (same day).
  double get salesChangePercent {
    if (lastYearTodaySales == 0) return 0;
    return ((todaySales - lastYearTodaySales) / lastYearTodaySales) * 100;
  }

  static const DashboardStats empty = DashboardStats(
    totalProducts: 0,
    lowStockCount: 0,
    totalUnitsSold: 0,
    totalInventoryValue: 0,
    todaySales: 0,
    todayProfit: 0,
    lastYearTodaySales: 0,
    recentActivity: [],
  );
}
