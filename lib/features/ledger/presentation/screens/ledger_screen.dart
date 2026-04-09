import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/ledger_repository.dart';
import '../widgets/transaction_card.dart';
import '../../../users/data/users_repository.dart';

// Providers for the ledger filters
final ledgerFilterProvider = StateProvider<String>((ref) => 'All');
final ledgerSortOrderProvider = StateProvider<bool>((ref) => true); // true = newest first, false = oldest first

final ledgerTransactionsProvider = StreamProvider.autoDispose<List<Map<String, dynamic>>>((ref) {
  final repo = ref.watch(ledgerRepositoryProvider);
  return repo.getTransactions().map((snapshot) {
    return snapshot.docs.map((doc) => doc.data()).toList();
  });
});

class LedgerScreen extends ConsumerWidget {
  const LedgerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(ledgerFilterProvider);
    final sortDesc = ref.watch(ledgerSortOrderProvider);
    final transactionsAsync = ref.watch(ledgerTransactionsProvider);
    final usersAsync = ref.watch(allUsersStreamProvider);

    return Scaffold(
      backgroundColor: AppColors.surface,
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(72.h),
        child: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              color: Colors.white.withOpacity(0.7),
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
              child: SafeArea(
                bottom: false,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(LucideIcons.store, color: AppColors.primary, size: 22.sp),
                        SizedBox(width: 8.w),
                        Text(
                          'THE KINETIC WAREHOUSE',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w900,
                            color: AppColors.primary,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: Icon(Icons.cloud_off, color: Colors.grey.shade400),
                      onPressed: () {},
                      constraints: const BoxConstraints(),
                      padding: EdgeInsets.zero,
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.fromLTRB(24.w, 100.h, 24.w, 120.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Ledger Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Ledger',
                        style: TextStyle(
                          fontSize: 32.sp,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.5,
                          color: AppColors.onSurface,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        'Real-time inventory flow and transaction history.',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 24.h),

            // Tab Filters
            Container(
              padding: EdgeInsets.all(4.r),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildTab(context, ref, 'All', filter),
                  _buildTab(context, ref, 'Purchases', filter),
                  _buildTab(context, ref, 'Sales', filter),
                ],
              ),
            ),
            SizedBox(height: 32.h),

            // Bento Grid Stats
            _buildStatsBento(context, ref, transactionsAsync.valueOrNull ?? [], usersAsync.valueOrNull?.docs.length ?? 0),
            SizedBox(height: 32.h),

            // Transaction Feed header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'RECENT TRANSACTIONS',
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20.r))),
                      builder: (bottomSheetContext) => SafeArea(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ListTile(
                              leading: const Icon(Icons.arrow_downward),
                              title: const Text('Newest First'),
                              trailing: sortDesc ? const Icon(Icons.check, color: AppColors.primary) : null,
                              onTap: () {
                                ref.read(ledgerSortOrderProvider.notifier).state = true;
                                Navigator.pop(bottomSheetContext);
                              },
                            ),
                            ListTile(
                              leading: const Icon(Icons.arrow_upward),
                              title: const Text('Oldest First'),
                              trailing: !sortDesc ? const Icon(Icons.check, color: AppColors.primary) : null,
                              onTap: () {
                                ref.read(ledgerSortOrderProvider.notifier).state = false;
                                Navigator.pop(bottomSheetContext);
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  child: Icon(Icons.filter_list, color: AppColors.onSurfaceVariant, size: 20.sp),
                ),
              ],
            ),
            SizedBox(height: 16.h),

            // Feed Content
            transactionsAsync.when(
              data: (transactions) {
                // Filter locally
                var filtered = transactions.where((tx) {
                  final type = (tx['type'] as String?)?.toLowerCase() ?? 'purchase';
                  final isPur = type == 'purchase' || type == 'restock' || type == 'inbound';
                  if (filter == 'Purchases' && !isPur) return false;
                  if (filter == 'Sales' && isPur) return false;
                  return true;
                }).toList();

                // Sort locally
                filtered.sort((a, b) {
                  final tA = a['timestamp'];
                  final tB = b['timestamp'];
                  if (tA == null || tB == null) return 0;
                  final dtA = tA.toDate() as DateTime;
                  final dtB = tB.toDate() as DateTime;
                  return sortDesc ? dtB.compareTo(dtA) : dtA.compareTo(dtB);
                });

                if (filtered.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 40.h),
                      child: Text('No transactions found', style: TextStyle(color: Colors.grey.shade500)),
                    ),
                  );
                }

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: EdgeInsets.zero,
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    return TransactionCard(transaction: filtered[index]);
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Error: $err')),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTab(BuildContext context, WidgetRef ref, String title, String activeFilter) {
    final isActive = title == activeFilter;
    return GestureDetector(
      onTap: () => ref.read(ledgerFilterProvider.notifier).state = title,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: isActive ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(8.r),
          boxShadow: isActive
              ? [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 4, offset: const Offset(0, 2))]
              : [],
        ),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: isActive ? FontWeight.bold : FontWeight.w600,
            color: isActive ? AppColors.onPrimaryContainer : AppColors.onSurfaceVariant,
          ),
        ),
      ),
    );
  }

  Widget _buildStatsBento(BuildContext context, WidgetRef ref, List<Map<String, dynamic>> transactions, int totalStaff) {
    // Calculate Today's Inflow
    int sumInflow = 0;
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);

    int totalOutbound = 0;
    int totalInbound = 0;

    for (var tx in transactions) {
      final type = (tx['type'] as String?)?.toLowerCase() ?? 'purchase';
      final isInbound = type == 'purchase' || type == 'restock' || type == 'inbound';
      final qty = (tx['qty'] as num?)?.toInt() ?? 0;
      
      if (isInbound) {
        totalInbound += qty;
        
        final t = tx['timestamp'];
        if (t != null) {
          final dt = t.toDate() as DateTime;
          if (dt.isAfter(startOfDay) || dt.isAtSameMomentAs(startOfDay)) {
            sumInflow += qty;
          }
        }
      } else {
        totalOutbound += qty;
      }
    }

    // Calculate Stock Turnover
    double turnover = 0;
    if (totalInbound > 0) {
       turnover = (totalOutbound / totalInbound) * 100;
    }

    return Column(
      children: [
        // Today Inflow
        GestureDetector(
          onTap: () => _showTodayInflowDetails(context),
          child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(24.r),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24.r),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0B1C30).withOpacity(0.04),
                blurRadius: 24,
                offset: const Offset(0, -8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Today's Inflow",
                style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500, color: AppColors.onSurfaceVariant),
              ),
              SizedBox(height: 4.h),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text('+$sumInflow', style: TextStyle(fontSize: 32.sp, fontWeight: FontWeight.w900, color: AppColors.primary)),
                  SizedBox(width: 8.w),
                  Text('UNITS', style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold, color: AppColors.primaryContainer)),
                ],
              )
            ],
          ),
        ),
        ),
        SizedBox(height: 16.h),
        Row(
          children: [
            // Velocity
            Expanded(
              child: GestureDetector(
                onTap: () => _showStockTurnoverDetails(context),
                child: Container(
                padding: EdgeInsets.all(24.r),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24.r),
                  border: Border(left: BorderSide(color: AppColors.secondary, width: 4.w)),
                  boxShadow: [
                    BoxShadow(color: const Color(0xFF0B1C30).withOpacity(0.04), blurRadius: 24, offset: const Offset(0, -8)),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Stock Turnover', style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500, color: AppColors.onSurfaceVariant)),
                    SizedBox(height: 4.h),
                    Text('${turnover.toStringAsFixed(1)}%', style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.w900, color: AppColors.secondary)),
                  ],
                ),
              ),
              ),
            ),
            SizedBox(width: 16.h),
            // Active Staff
            Expanded(
              child: GestureDetector(
                onTap: () => _showActiveStaffDetails(context, ref),
                child: Container(
                padding: EdgeInsets.all(24.r),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24.r),
                  boxShadow: [
                    BoxShadow(color: const Color(0xFF0B1C30).withOpacity(0.04), blurRadius: 24, offset: const Offset(0, -8)),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Active Staff', style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500, color: AppColors.onSurfaceVariant)),
                    SizedBox(height: 4.h),
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 12.r,
                          backgroundColor: AppColors.primary,
                          child: Icon(Icons.person, size: 16.sp, color: Colors.white),
                        ),
                        SizedBox(width: 8.w),
                        Text('$totalStaff Users', style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: AppColors.onSurface)),
                      ],
                    ),
                  ],
                ),
              ),
              ),
            ),
          ],
        )
      ],
    );
  }

  void _showTodayInflowDetails(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => _buildDetailCard(
        title: "Today's Inflow",
        icon: Icons.south_east_rounded,
        iconColor: AppColors.primary,
        description: "Tracks incoming inventory volume (purchases and restocks) recorded since 12:00 AM today.",
        formula: "Sum of Qty of transactions where type is purchase, restock, or inbound AND date = today",
        businessTip: "Use this metric to ensure daily deliveries meet operational requirements. If this number is lower than outbound velocity, you may face stock shortages soon.",
      ),
    );
  }

  void _showStockTurnoverDetails(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => _buildDetailCard(
        title: "Stock Turnover",
        icon: Icons.sync,
        iconColor: AppColors.secondary,
        description: "Measures overall inventory throughput efficiency by comparing historical stock leaving the warehouse versus stock entering it.",
        formula: "(Total Units Sold / Total Units Received) x 100",
        businessTip: "A high turnover percentage suggests strong demand and efficient stock movement. A low number indicates overstocking or obsolete inventory holding capital hostage.",
      ),
    );
  }

  void _showActiveStaffDetails(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        final usersAsync = ref.watch(allUsersStreamProvider);
        return Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.95),
            borderRadius: BorderRadius.vertical(top: Radius.circular(32.r)),
          ),
          padding: EdgeInsets.all(32.r),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: AppColors.primary.withOpacity(0.1),
                      child: Icon(Icons.people, color: AppColors.primary, size: 24.sp),
                    ),
                    SizedBox(width: 16.w),
                    Text(
                      "Active Staff",
                      style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.bold, color: AppColors.onSurface),
                    ),
                  ],
                ),
                SizedBox(height: 24.h),
                usersAsync.when(
                  data: (data) {
                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: data.docs.length,
                      itemBuilder: (context, index) {
                        final user = data.docs[index].data();
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: CircleAvatar(
                            backgroundColor: AppColors.primaryContainer,
                            child: Text(
                              user['name']?.toString().substring(0, 1).toUpperCase() ?? 'U',
                              style: TextStyle(color: AppColors.onPrimaryContainer, fontWeight: FontWeight.bold),
                            ),
                          ),
                          title: Text(user['name'] ?? 'Unknown User', style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text(user['email'] ?? 'No email'),
                          trailing: Container(
                            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                            decoration: BoxDecoration(
                              color: AppColors.secondaryContainer,
                              borderRadius: BorderRadius.circular(16.r),
                            ),
                            child: const Text('Active', style: TextStyle(color: AppColors.secondary, fontWeight: FontWeight.bold, fontSize: 12)),
                          ),
                        );
                      },
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (e, s) => Text('Error loading staff: $e'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailCard({
    required String title,
    required IconData icon,
    required Color iconColor,
    required String description,
    required String formula,
    required String businessTip,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95), // Slight glassmorphism
        borderRadius: BorderRadius.vertical(top: Radius.circular(32.r)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 40,
            offset: const Offset(0, -10),
          )
        ],
      ),
      padding: EdgeInsets.all(32.r),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: iconColor.withOpacity(0.1),
                  child: Icon(icon, color: iconColor, size: 24.sp),
                ),
                SizedBox(width: 16.w),
                Text(
                  title,
                  style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.bold, color: AppColors.onSurface),
                ),
              ],
            ),
            SizedBox(height: 24.h),
            Text(
              "What it means",
              style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w900, color: AppColors.onSurfaceVariant, letterSpacing: 1),
            ),
            SizedBox(height: 8.h),
            Text(description, style: TextStyle(fontSize: 16.sp, color: AppColors.onSurface, height: 1.5)),
            SizedBox(height: 24.h),
            
            Container(
              padding: EdgeInsets.all(16.r),
              decoration: BoxDecoration(color: AppColors.surfaceVariant.withOpacity(0.5), borderRadius: BorderRadius.circular(16.r)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   Text(
                    "Calculation",
                    style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w900, color: AppColors.onSurfaceVariant, letterSpacing: 1),
                  ),
                  SizedBox(height: 8.h),
                  Text(formula, style: TextStyle(fontFamily: 'monospace', fontSize: 13.sp, color: AppColors.onSurfaceVariant)),
                ],
              ),
            ),

            SizedBox(height: 24.h),
            Text(
              "Business Application",
              style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w900, color: AppColors.onSurfaceVariant, letterSpacing: 1),
            ),
            SizedBox(height: 8.h),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.lightbulb, color: AppColors.tertiary, size: 20.sp),
                SizedBox(width: 12.w),
                Expanded(child: Text(businessTip, style: TextStyle(fontSize: 14.sp, color: AppColors.onSurface, height: 1.5))),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
