import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/shared_bottom_nav_bar.dart';
import '../providers/reports_provider.dart';

class ReportsScreen extends ConsumerStatefulWidget {
  const ReportsScreen({super.key});

  @override
  ConsumerState<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends ConsumerState<ReportsScreen> {
  // Chart toggle states
  bool isWeekly = true;

  @override
  Widget build(BuildContext context) {
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
        padding: EdgeInsets.fromLTRB(24.w, 100.h, 24.w, 150.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Text(
              'Visual Analytics',
              style: TextStyle(
                fontSize: 32.sp,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.5,
                color: AppColors.onSurface,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              'Real-time data insights',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: AppColors.onSurfaceVariant,
              ),
            ),
            SizedBox(height: 24.h),

            // KPI Bento
            _buildKPIBento(),
            SizedBox(height: 24.h),

            // Sales Trend
            _buildSalesTrendLineChart(),
            SizedBox(height: 24.h),

            // Top Sellers
            _buildTopSellingList(ref),
            SizedBox(height: 24.h),

            // Low Stock Warning List
            _buildLowStockList(ref),
            SizedBox(height: 40.h),

            // Export Button
            SizedBox(
              width: double.infinity,
              height: 56.h,
              child: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Exporting report...')));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
                  elevation: 0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.file_download),
                    SizedBox(width: 8.w),
                    Text('Export Report (PDF/Excel)', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
            SizedBox(height: 12.h),
            Center(
              child: Text(
                'GENERATED ACCORDING TO LIVE FIREBASE FEED',
                style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.bold, color: AppColors.onSurfaceVariant.withOpacity(0.5), letterSpacing: 1.5),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const SharedBottomNavBar(selectedIndex: 3),
    );
  }

  Widget _buildKPIBento() {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: EdgeInsets.all(20.r),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20.r),
              boxShadow: [
                BoxShadow(color: const Color(0xFF0B1C30).withOpacity(0.04), blurRadius: 24, offset: const Offset(0, 8)),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'INVENTORY TURNOVER',
                  style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.bold, letterSpacing: 1.5, color: AppColors.onSurfaceVariant.withOpacity(0.6)),
                ),
                SizedBox(height: 8.h),
                Text('8.4x', style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.w900, color: AppColors.primary, letterSpacing: -0.5)),
                SizedBox(height: 16.h),
                Row(
                  children: [
                    Icon(Icons.trending_up, size: 14.sp, color: AppColors.primary),
                    SizedBox(width: 4.w),
                    Text('12.5%', style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold, color: AppColors.primary)),
                  ],
                ),
              ],
            ),
          ),
        ),
        SizedBox(width: 16.w),
        Expanded(
          child: Container(
            padding: EdgeInsets.all(20.r),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20.r),
              boxShadow: [
                BoxShadow(color: const Color(0xFF0B1C30).withOpacity(0.04), blurRadius: 24, offset: const Offset(0, 8)),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'PROFIT MARGIN',
                  style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.bold, letterSpacing: 1.5, color: AppColors.onSurfaceVariant.withOpacity(0.6)),
                ),
                SizedBox(height: 8.h),
                Text('24.2%', style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.w900, color: AppColors.secondary, letterSpacing: -0.5)),
                SizedBox(height: 16.h),
                Row(
                  children: [
                    Icon(Icons.remove, size: 14.sp, color: AppColors.secondary),
                    SizedBox(width: 4.w),
                    Text('Stable', style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold, color: AppColors.secondary)),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSalesTrendLineChart() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'SALES TRENDS',
              style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold, letterSpacing: 1.5, color: AppColors.onSurfaceVariant),
            ),
            Container(
              padding: EdgeInsets.all(4.r),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => setState(() => isWeekly = true),
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: isWeekly ? Colors.white : Colors.transparent,
                        borderRadius: BorderRadius.circular(16.r),
                        boxShadow: isWeekly ? [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4)] : [],
                      ),
                      child: Text('Weekly', style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.bold, color: isWeekly ? AppColors.primary : AppColors.onSurfaceVariant)),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => setState(() => isWeekly = false),
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: !isWeekly ? Colors.white : Colors.transparent,
                        borderRadius: BorderRadius.circular(16.r),
                        boxShadow: !isWeekly ? [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4)] : [],
                      ),
                      child: Text('Monthly', style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.bold, color: !isWeekly ? AppColors.primary : AppColors.onSurfaceVariant)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        Container(
          height: 220.h,
          padding: EdgeInsets.fromLTRB(16.w, 24.h, 16.w, 12.h),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24.r),
            boxShadow: [
              BoxShadow(color: const Color(0xFF0B1C30).withOpacity(0.04), blurRadius: 24, offset: const Offset(0, 8)),
            ],
          ),
          child: LineChart(
            LineChartData(
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: 1,
                getDrawingHorizontalLine: (value) {
                  return FlLine(color: AppColors.outlineVariant.withOpacity(0.3), strokeWidth: 1);
                },
              ),
              titlesData: FlTitlesData(
                show: true,
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 22,
                    interval: 1,
                    getTitlesWidget: (value, meta) {
                      final style = TextStyle(color: AppColors.onSurfaceVariant.withOpacity(0.5), fontWeight: FontWeight.bold, fontSize: 10.sp);
                      Widget text;
                      if (isWeekly) {
                        switch (value.toInt()) {
                          case 0: text = Text('MON', style: style); break;
                          case 1: text = Text('TUE', style: style); break;
                          case 2: text = Text('WED', style: style); break;
                          case 3: text = Text('THU', style: style); break;
                          case 4: text = Text('FRI', style: style); break;
                          case 5: text = Text('SAT', style: style); break;
                          case 6: text = Text('SUN', style: style); break;
                          default: text = const Text(''); break;
                        }
                      } else {
                        switch (value.toInt()) {
                          case 0: text = Text('W1', style: style); break;
                          case 2: text = Text('W2', style: style); break;
                          case 4: text = Text('W3', style: style); break;
                          case 6: text = Text('W4', style: style); break;
                          default: text = const Text(''); break;
                        }
                      }
                      return SideTitleWidget(meta: meta, child: text);
                    },
                  ),
                ),
              ),
              borderData: FlBorderData(show: false),
              minX: 0,
              maxX: 6,
              minY: 0,
              maxY: 5,
              lineBarsData: [
                LineChartBarData(
                  spots: isWeekly ? const [
                    FlSpot(0, 1),
                    FlSpot(1, 1.5),
                    FlSpot(2, 1.4),
                    FlSpot(3, 3.4),
                    FlSpot(4, 2),
                    FlSpot(5, 2.2),
                    FlSpot(6, 1.8),
                  ] : const [
                    FlSpot(0, 2),
                    FlSpot(2, 1.5),
                    FlSpot(4, 4),
                    FlSpot(6, 3.2),
                  ],
                  isCurved: true,
                  color: AppColors.primary,
                  barWidth: 4,
                  isStrokeCapRound: true,
                  dotData: const FlDotData(show: false),
                  belowBarData: BarAreaData(
                    show: true,
                    color: AppColors.primaryContainer.withOpacity(0.15),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTopSellingList(WidgetRef ref) {
    final topAsync = ref.watch(topSellingProductsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'TOP SELLING PRODUCTS',
          style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold, letterSpacing: 1.5, color: AppColors.onSurfaceVariant),
        ),
        SizedBox(height: 12.h),
        Container(
          padding: EdgeInsets.all(24.r),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24.r),
            boxShadow: [
              BoxShadow(color: const Color(0xFF0B1C30).withOpacity(0.04), blurRadius: 24, offset: const Offset(0, 8)),
            ],
          ),
          child: topAsync.when(
            data: (topProducts) {
              if (topProducts.isEmpty) {
                return Padding(
                  padding: EdgeInsets.symmetric(vertical: 20.h),
                  child: Center(child: Text('No sales recorded yet.', style: TextStyle(color: AppColors.outline))),
                );
              }

              final highestQty = topProducts.fold(1, (max, item) {
                final qty = item['qty'] as int;
                return qty > max ? qty : max;
              });

              return Column(
                children: topProducts.map((p) {
                  final name = p['name'] as String;
                  final qty = p['qty'] as int;
                  final perc = qty / highestQty;

                  return Padding(
                    padding: EdgeInsets.only(bottom: 16.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(child: Text(name, style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold, color: AppColors.onSurface), maxLines: 1, overflow: TextOverflow.ellipsis)),
                            Text('$qty units', style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold, color: AppColors.primary)),
                          ],
                        ),
                        SizedBox(height: 8.h),
                        Container(
                          height: 10.h,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainerLow,
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: FractionallySizedBox(
                            alignment: Alignment.centerLeft,
                            widthFactor: perc,
                            child: Container(
                              decoration: BoxDecoration(
                                color: AppColors.primaryContainer,
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, st) => Text('Error: $err'),
          ),
        ),
      ],
    );
  }

  Widget _buildLowStockList(WidgetRef ref) {
    final lowStockAsync = ref.watch(lowStockProductsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'LOW STOCK WARNINGS',
          style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold, letterSpacing: 1.5, color: AppColors.error),
        ),
        SizedBox(height: 12.h),
        Container(
          padding: EdgeInsets.all(24.r),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24.r),
            border: Border.all(color: AppColors.error.withOpacity(0.2)),
            boxShadow: [
              BoxShadow(color: const Color(0xFF0B1C30).withOpacity(0.04), blurRadius: 24, offset: const Offset(0, 8)),
            ],
          ),
          child: lowStockAsync.when(
            data: (lowStockItems) {
              if (lowStockItems.isEmpty) {
                return Padding(
                  padding: EdgeInsets.symmetric(vertical: 20.h),
                  child: Center(child: Text('All stock levels look healthy.', style: TextStyle(color: AppColors.outline))),
                );
              }

              return Column(
                children: lowStockItems.take(5).map((p) {
                  final name = p['name'] as String? ?? 'Unknown Item';
                  final qty = p['qty'] as num? ?? 0;
                  final unit = p['unit'] as String? ?? '';

                  return Padding(
                    padding: EdgeInsets.only(bottom: 12.h),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.warning_amber_rounded, size: 16.sp, color: AppColors.error),
                            SizedBox(width: 8.w),
                            SizedBox(
                              width: 150.w,
                              child: Text(
                                name, 
                                style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold, color: AppColors.onSurface),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        Text('$qty $unit', style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w900, color: AppColors.error)),
                      ],
                    ),
                  );
                }).toList(),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, st) => Text('Error: $err'),
          ),
        ),
      ],
    );
  }
}
