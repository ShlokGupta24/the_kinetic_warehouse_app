import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/product_repository.dart';

class ProductCard extends ConsumerWidget {
  final Map<String, dynamic> product;

  const ProductCard({super.key, required this.product});

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Product?'),
        content: const Text(
          'This will permanently delete the product and all associated transactions. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => context.pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => context.pop(true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
         await ref.read(productRepositoryProvider).deleteProduct(
           product['id'] as String,
           product['sku'] as String? ?? '',
         );
         if (context.mounted) {
           ScaffoldMessenger.of(context).showSnackBar(
             const SnackBar(content: Text('Product deleted successfully')),
           );
         }
      } catch (e) {
         if (context.mounted) {
           ScaffoldMessenger.of(context).showSnackBar(
             SnackBar(content: Text('Failed to delete product: $e')),
           );
         }
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final name = product['name'] as String? ?? 'Unknown Product';
    final category = product['category'] as String? ?? 'General';
    final qty = (product['qty'] as num?)?.toInt() ?? 0;
    final unit = product['unit'] as String? ?? 'units';
    final sku = product['sku'] as String? ?? 'No SKU';
    final imageUrl = product['imageUrl'] as String?;
    final threshold = (product['lowStockThreshold'] as num?)?.toInt() ?? 10;
    final isLowStock = qty <= threshold;

    return GestureDetector(
      onTap: () {
        context.push('/edit-product', extra: product);
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        padding: EdgeInsets.all(16.r),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: AppColors.secondary.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 80.w,
              height: 80.w,
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(12.r),
                image: imageUrl != null && imageUrl.isNotEmpty
                    ? DecorationImage(
                        image: NetworkImage(imageUrl),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: imageUrl == null || imageUrl.isEmpty
                  ? Icon(Icons.image_not_supported, color: AppColors.outlineVariant)
                  : null,
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        category.toUpperCase(),
                        style: TextStyle(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.0,
                          color: AppColors.secondary,
                        ),
                      ),
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                            decoration: BoxDecoration(
                              color: isLowStock ? const Color(0xFFFEF2F2) : const Color(0xFFECFDF5),
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            child: Text(
                              isLowStock ? 'LOW STOCK' : 'IN STOCK',
                              style: TextStyle(
                                fontSize: 10.sp,
                                fontWeight: FontWeight.bold,
                                letterSpacing: -0.5,
                                color: isLowStock ? AppColors.error : AppColors.primary,
                              ),
                            ),
                          ),
                          SizedBox(width: 4.w),
                          PopupMenuButton<String>(
                            onSelected: (value) {
                              if (value == 'edit') {
                                context.push('/edit-product', extra: product);
                              } else if (value == 'delete') {
                                _confirmDelete(context, ref);
                              }
                            },
                            icon: const Icon(Icons.more_vert, size: 20),
                            padding: EdgeInsets.zero,
                            itemBuilder: (context) => [
                              const PopupMenuItem(
                                value: 'edit',
                                child: Text('Edit'),
                              ),
                              PopupMenuItem(
                                value: 'delete',
                                child: Text('Delete', style: TextStyle(color: AppColors.error)),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                  Text(
                    name,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.onSurface,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 8.h),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'SKU: $sku',
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w500,
                          color: AppColors.outline,
                        ),
                      ),
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: '$qty ',
                              style: TextStyle(
                                fontSize: 20.sp,
                                fontWeight: FontWeight.w900,
                                color: isLowStock ? AppColors.error : AppColors.primary,
                              ),
                            ),
                            TextSpan(
                              text: unit.toUpperCase(),
                              style: TextStyle(
                                fontSize: 10.sp,
                                fontWeight: FontWeight.bold,
                                color: (isLowStock ? AppColors.error : AppColors.primary).withOpacity(0.7),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
