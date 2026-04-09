import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../products/presentation/providers/product_filter_provider.dart';
import '../../data/dashboard_repository.dart';
import '../../domain/dashboard_stats.dart';

final _rupeeFmt = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);
final _rupeeFmtDec = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 2);

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  @override
  Widget build(BuildContext context) {
    // dashboardStatsProvider now always returns a non-null DashboardStats
    // (empty while streams load, real data once they emit)
    final stats = ref.watch(dashboardStatsProvider);

    // Watch the activity stream directly for fastest live updates
    final activityAsync = ref.watch(recentActivityStreamProvider);
    final activities = activityAsync.value?.docs
            .map((doc) => ActivityItem.fromFirestore(doc))
            .toList() ??
        stats.recentActivity;

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
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: EdgeInsets.fromLTRB(20.w, 100.h, 20.w, 120.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              SizedBox(height: 28.h),
              _buildBentoGrid(stats),
              SizedBox(height: 28.h),
              if (stats.lowStockCount > 0) ...[
                _buildCriticalAlert(stats),
                SizedBox(height: 36.h),
              ],
              _buildQuickActions(),
              SizedBox(height: 28.h),
              _buildRecentActivity(activities, activityAsync.isLoading),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        Text(
          'Warehouse Overview',
          style: TextStyle(
            fontSize: 28.sp,
            fontWeight: FontWeight.w900,
            color: AppColors.onSurface,
            letterSpacing: -0.5,
            height: 1.1,
          ),
        ),
      ],
    );
  }

  Widget _buildBentoGrid(DashboardStats stats) {
    return Column(
      children: [
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: Container(
                  padding: EdgeInsets.all(18.r),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(24.r),
                  ),
                  child: Stack(
                    clipBehavior: Clip.hardEdge,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'TOTAL\nPRODUCTS',
                            style: TextStyle(
                              color: Colors.grey.shade400,
                              fontWeight: FontWeight.w600,
                              fontSize: 11.sp,
                              letterSpacing: 1,
                              height: 1.3,
                            ),
                          ),
                          SizedBox(height: 12.h),
                          Text(
                            NumberFormat.decimalPattern().format(stats.totalProducts),
                            style: TextStyle(
                              color: AppColors.primary,
                              fontSize: 30.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 60.h),
                        ],
                      ),
                      Positioned(
                        right: -8,
                        bottom: -8,
                        child: Opacity(
                          opacity: 0.07,
                          child: Icon(LucideIcons.package, size: 70.sp, color: AppColors.primary),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(width: 14.w),
              Expanded(
                child: Container(
                  padding: EdgeInsets.all(18.r),
                  decoration: BoxDecoration(
                    color: AppColors.secondaryContainer.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(24.r),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'TOTAL UNITS SOLD',
                        style: TextStyle(
                          color: AppColors.secondary,
                          fontWeight: FontWeight.w600,
                          fontSize: 11.sp,
                          letterSpacing: 1,
                        ),
                      ),
                      SizedBox(height: 12.h),
                      Text(
                        NumberFormat.decimalPattern().format(stats.totalUnitsSold),
                        style: TextStyle(
                          color: AppColors.secondary,
                          fontSize: 30.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        'ALL-TIME VOLUME',
                        style: TextStyle(
                          color: AppColors.secondary.withOpacity(0.7),
                          fontWeight: FontWeight.bold,
                          fontSize: 9.sp,
                          letterSpacing: 1,
                        ),
                      ),
                      SizedBox(height: 12.h),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 14.h),
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(22.r),
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(24.r),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'TOTAL INVENTORY VALUE',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.6),
                          fontWeight: FontWeight.w600,
                          fontSize: 11.sp,
                          letterSpacing: 1,
                        ),
                      ),
                      Text(
                        _rupeeFmt.format(stats.totalInventoryValue),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 30.sp,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: EdgeInsets.all(8.r),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Icon(Icons.payments_outlined, color: Colors.white, size: 22.sp),
                  ),
                ],
              ),
              SizedBox(height: 14.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'TODAY\'S SALES',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.6),
                          fontWeight: FontWeight.bold,
                          fontSize: 10.sp,
                          letterSpacing: 1.5,
                        ),
                      ),
                      Text(
                        _rupeeFmtDec.format(stats.todaySales),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'PROFIT',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.6),
                          fontWeight: FontWeight.bold,
                          fontSize: 10.sp,
                          letterSpacing: 1.5,
                        ),
                      ),
                      Text(
                        _rupeeFmtDec.format(stats.todayProfit),
                        style: TextStyle(
                          color: const Color(0xFF69F0AE),
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCriticalAlert(DashboardStats stats) {
    return GestureDetector(
      onTap: () {
        ref.read(stockStatusFilterProvider.notifier).state = 'Low Stock';
        context.go('/products');
      },
      child: Container(
        padding: EdgeInsets.all(18.r),
        decoration: BoxDecoration(
          color: const Color(0xFF842225),
          borderRadius: BorderRadius.circular(20.r),
          border: const Border(left: BorderSide(color: Color(0xFFA43A3A), width: 4)),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(10.r),
              decoration: BoxDecoration(
                color: const Color(0xFFA43A3A).withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.warning_amber_rounded, color: const Color(0xFFA43A3A), size: 22.sp),
            ),
            SizedBox(width: 14.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Critical Inventory Alert',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14.sp),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    '${stats.lowStockCount} item${stats.lowStockCount == 1 ? '' : 's'} below safety threshold.',
                    style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12.sp),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.white.withOpacity(0.5), size: 22.sp),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 4.w, bottom: 14.h),
          child: Text(
            'QUICK ACTIONS',
            style: TextStyle(
              fontSize: 11.sp,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade400,
              letterSpacing: 2,
            ),
          ),
        ),
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () => context.push('/add-product'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 14.h),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
                  elevation: 0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_box_outlined, size: 18.sp),
                    SizedBox(width: 6.w),
                    Flexible(
                      child: Text(
                        'Add Product', 
                        style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.bold),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(width: 14.w),
            Expanded(
              child: ElevatedButton(
                onPressed: () => context.push('/add-transaction'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.secondary,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 14.h),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
                  elevation: 0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(LucideIcons.tag, size: 18.sp),
                    SizedBox(width: 6.w),
                    Flexible(
                      child: Text(
                        'Record Sale', 
                        style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.bold),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRecentActivity(List<ActivityItem> activities, bool isLoading) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 4.w, bottom: 20.h),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                children: [
                  Text(
                    'RECENT ACTIVITY',
                    style: TextStyle(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade400,
                      letterSpacing: 2,
                    ),
                  ),
                  if (isLoading) ...[
                    SizedBox(width: 8.w),
                    SizedBox(
                      width: 10.r,
                      height: 10.r,
                      child: CircularProgressIndicator(
                        strokeWidth: 1.5,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ],
              ),
              GestureDetector(
                onTap: () => context.go('/ledger'),
                child: Text(
                  'VIEW ALL',
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ],
          ),
        ),
        if (activities.isEmpty && !isLoading)
          _buildEmptyActivity()
        else if (activities.isEmpty && isLoading)
          const SizedBox.shrink()
        else
          ...activities.asMap().entries.map((entry) {
            final item = entry.value;
            final isLast = entry.key == activities.length - 1;
            return Column(
              children: [
                _buildActivityItem(item),
                if (!isLast) SizedBox(height: 10.h),
              ],
            );
          }),
      ],
    );
  }

  Widget _buildEmptyActivity() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(32.r),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Column(
        children: [
          Icon(LucideIcons.clipboardList, size: 40.sp, color: Colors.grey.shade300),
          SizedBox(height: 12.h),
          Text(
            'No activity yet',
            style: TextStyle(color: Colors.grey.shade400, fontSize: 14.sp, fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 4.h),
          Text(
            'Sales and restocks will appear here.',
            style: TextStyle(color: Colors.grey.shade400, fontSize: 12.sp),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityItem(ActivityItem item) {
    final isSale = item.type == 'sale';
    final valueText = isSale
        ? '+${_rupeeFmtDec.format(item.amount)}'
        : '+${NumberFormat.decimalPattern().format(item.qty)} units';
    final valueColor = isSale ? AppColors.primary : AppColors.secondary;

    return Container(
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(18.r),
      ),
      child: Row(
        children: [
          Container(
            width: 46.r,
            height: 46.r,
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(12.r),
              image: item.imageUrl != null && item.imageUrl!.isNotEmpty
                  ? DecorationImage(image: NetworkImage(item.imageUrl!), fit: BoxFit.cover)
                  : null,
            ),
            child: item.imageUrl == null || item.imageUrl!.isEmpty
                ? Icon(isSale ? LucideIcons.tag : LucideIcons.packagePlus,
                    size: 20.sp, color: valueColor)
                : null,
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        item.title,
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.bold,
                          color: AppColors.onSurface,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      item.timeAgo,
                      style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.w500, color: Colors.grey.shade400),
                    ),
                  ],
                ),
                SizedBox(height: 2.h),
                Text(
                  item.subtitle,
                  style: TextStyle(fontSize: 11.sp, color: Colors.grey.shade500),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          SizedBox(width: 12.w),
          Text(
            valueText,
            style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.bold, color: valueColor),
          ),
        ],
      ),
    );
  }

}
