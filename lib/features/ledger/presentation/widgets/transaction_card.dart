import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_colors.dart';
import 'package:intl/intl.dart';

class TransactionCard extends StatelessWidget {
  final Map<String, dynamic> transaction;

  const TransactionCard({super.key, required this.transaction});

  @override
  Widget build(BuildContext context) {
    // Determine the type: purchase (inbound) vs sale (outbound)
    // Legacy might be 'restock', so we treat it as inbound
    final type = (transaction['type'] as String?)?.toLowerCase() ?? 'purchase';
    final isInbound = type == 'purchase' || type == 'restock' || type == 'inbound';
    
    final title = transaction['title'] as String? ?? 'Unknown Item';
    final subtitle = transaction['subtitle'] as String? ?? 'No details';
    final qty = (transaction['qty'] as num?)?.toInt() ?? 0;
    
    // Formatting timestamp
    String timeStr = 'Unknown';
    if (transaction['timestamp'] != null) {
      final dt = (transaction['timestamp']).toDate() as DateTime;
      timeStr = DateFormat('MMM d, HH:mm').format(dt);
    }

    final accentColor = isInbound ? AppColors.primary : AppColors.tertiary;
    final iconData = isInbound ? Icons.south_east_rounded : Icons.north_east_rounded;
    final typeLabel = isInbound ? 'INBOUND' : 'OUTBOUND';
    final prefix = isInbound ? '+' : '-';

    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0B1C30).withOpacity(0.02),
            blurRadius: 24,
            offset: const Offset(0, -8),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 56.w,
            height: 56.w,
            decoration: BoxDecoration(
              color: accentColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Icon(iconData, color: accentColor, size: 24.sp),
          ),
          SizedBox(width: 20.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.onSurface,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 6.h),
                Row(
                  children: [
                    Icon(Icons.person, size: 14.sp, color: AppColors.onSurfaceVariant),
                    SizedBox(width: 4.w),
                    Expanded(
                      child: Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.bold,
                          color: AppColors.onSurfaceVariant,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      width: 4.w,
                      height: 4.w,
                      margin: EdgeInsets.symmetric(horizontal: 8.w),
                      decoration: BoxDecoration(
                        color: AppColors.outlineVariant,
                        shape: BoxShape.circle,
                      ),
                    ),
                    Text(
                      timeStr,
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w500,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(width: 12.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$prefix$qty',
                style: TextStyle(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.w900,
                  color: accentColor,
                ),
              ),
              Container(
                margin: EdgeInsets.only(top: 4.h),
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: accentColor.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Text(
                  typeLabel,
                  style: TextStyle(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.5,
                    color: accentColor.withOpacity(0.8), // Used .tertiary safely.
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
