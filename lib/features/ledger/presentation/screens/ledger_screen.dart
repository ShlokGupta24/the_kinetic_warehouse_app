import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/shared_bottom_nav_bar.dart';
import '../../data/ledger_repository.dart';
import '../widgets/transaction_card.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Providers for the ledger filters
final ledgerFilterProvider = StateProvider<String>((ref) => 'All');

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
    final transactionsAsync = ref.watch(ledgerTransactionsProvider);

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
            _buildStatsBento(),
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
                Icon(Icons.filter_list, color: AppColors.onSurfaceVariant, size: 20.sp),
              ],
            ),
            SizedBox(height: 16.h),

            // Feed Content
            transactionsAsync.when(
              data: (transactions) {
                // Filter locally
                final filtered = transactions.where((tx) {
                  final type = (tx['type'] as String?)?.toLowerCase() ?? 'purchase';
                  final isPur = type == 'purchase' || type == 'restock' || type == 'inbound';
                  if (filter == 'Purchases' && !isPur) return false;
                  if (filter == 'Sales' && isPur) return false;
                  return true;
                }).toList();

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
      floatingActionButton: Padding(
        padding: EdgeInsets.only(bottom: 90.h),
        child: FloatingActionButton(
          onPressed: () => context.push('/add-transaction'),
          backgroundColor: AppColors.primary,
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
      bottomNavigationBar: const SharedBottomNavBar(selectedIndex: 2),
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

  Widget _buildStatsBento() {
    return Column(
      children: [
        // Today Inflow
        Container(
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
                  Text('+842', style: TextStyle(fontSize: 32.sp, fontWeight: FontWeight.w900, color: AppColors.primary)),
                  SizedBox(width: 8.w),
                  Text('UNITS', style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold, color: AppColors.primaryContainer)),
                ],
              )
            ],
          ),
        ),
        SizedBox(height: 16.h),
        Row(
          children: [
            // Velocity
            Expanded(
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
                    Text('12.4%', style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.w900, color: AppColors.secondary)),
                  ],
                ),
              ),
            ),
            SizedBox(width: 16.h),
            // Active Staff
            Expanded(
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
                        Text('Alex +4', style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: AppColors.onSurface)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        )
      ],
    );
  }
}
