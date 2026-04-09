import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/theme/app_colors.dart';
import '../providers/product_filter_provider.dart';
import '../widgets/product_card.dart';
import 'package:simple_barcode_scanner/simple_barcode_scanner.dart';

class ProductListScreen extends ConsumerStatefulWidget {
  const ProductListScreen({super.key});

  @override
  ConsumerState<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends ConsumerState<ProductListScreen> {
  late TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final productsAsync = ref.watch(filteredProductsProvider);
    final currentCategory = ref.watch(categoryFilterProvider) ?? 'All Items';
    final currentStatus = ref.watch(stockStatusFilterProvider) ?? 'All';

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
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerHigh,
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: TextField(
                        controller: _searchController,
                        onChanged: (val) => ref.read(searchQueryProvider.notifier).state = val,
                        decoration: InputDecoration(
                          hintText: 'Search products...',
                          hintStyle: TextStyle(color: AppColors.outline.withOpacity(0.6)),
                          prefixIcon: Icon(Icons.search, color: AppColors.outline),
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          filled: false,
                          contentPadding: EdgeInsets.symmetric(vertical: 14.h),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Container(
                    width: 56.w,
                    height: 56.w,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(12.r),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.2),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: IconButton(
                      icon: Icon(Icons.qr_code_scanner, color: Colors.white, size: 24.sp),
                      onPressed: () async {
                        var res = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SimpleBarcodeScannerPage(),
                          ),
                        );
                        if (res is String && res != '-1') {
                          _searchController.text = res;
                          ref.read(searchQueryProvider.notifier).state = res;
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
            
            // Filters
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'CATEGORIES',
                    style: TextStyle(
                      fontSize: 10.sp,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                      color: AppColors.outline,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    child: Row(
                      children: [
                        _buildFilterChip('All Items', currentCategory, (v) => ref.read(categoryFilterProvider.notifier).state = v),
                        _buildFilterChip('Electronics', currentCategory, (v) => ref.read(categoryFilterProvider.notifier).state = v),
                        _buildFilterChip('Clothing', currentCategory, (v) => ref.read(categoryFilterProvider.notifier).state = v),
                        _buildFilterChip('Furniture', currentCategory, (v) => ref.read(categoryFilterProvider.notifier).state = v),
                        _buildFilterChip('Hardware', currentCategory, (v) => ref.read(categoryFilterProvider.notifier).state = v),
                      ],
                    ),
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    'STOCK STATUS',
                    style: TextStyle(
                      fontSize: 10.sp,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                      color: AppColors.outline,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Row(
                    children: [
                      _buildStatusChip('All', currentStatus, null, (v) => ref.read(stockStatusFilterProvider.notifier).state = v),
                      _buildStatusChip('Low Stock', currentStatus, AppColors.error, (v) => ref.read(stockStatusFilterProvider.notifier).state = v),
                      _buildStatusChip('In Stock', currentStatus, AppColors.primaryContainer, (v) => ref.read(stockStatusFilterProvider.notifier).state = v),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 16.h),

            // Product List
            Expanded(
              child: productsAsync.when(
                data: (products) {
                  if (products.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(LucideIcons.packageOpen, size: 64.sp, color: Colors.grey.shade300),
                          SizedBox(height: 16.h),
                          Text('No products found', style: TextStyle(color: Colors.grey.shade600)),
                        ],
                      ),
                    );
                  }
                  return ListView.builder(
                    padding: EdgeInsets.fromLTRB(24.w, 8.h, 24.w, 120.h),
                    physics: const BouncingScrollPhysics(),
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      final product = products[index];
                      return ProductCard(product: product);
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, stack) => Center(child: Text('Error: $err')),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, String currentVal, Function(String) onSelect) {
    final isSelected = currentVal == label;
    return GestureDetector(
      onTap: () => onSelect(label),
      child: Container(
        margin: EdgeInsets.only(right: 8.w),
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF4EDEA3) : AppColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
            color: isSelected ? const Color(0xFF005236) : AppColors.onSurfaceVariant,
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(String label, String currentVal, Color? dotColor, Function(String) onSelect) {
    final isSelected = currentVal == label;
    return GestureDetector(
      onTap: () => onSelect(label),
      child: Container(
        margin: EdgeInsets.only(right: 8.w),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.surfaceContainerHigh : Colors.white,
          border: Border.all(color: AppColors.outlineVariant.withOpacity(0.3)),
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (dotColor != null) ...[
              Container(
                width: 8.w,
                height: 8.w,
                decoration: BoxDecoration(
                  color: dotColor,
                  shape: BoxShape.circle,
                ),
              ),
              SizedBox(width: 6.w),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: AppColors.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
