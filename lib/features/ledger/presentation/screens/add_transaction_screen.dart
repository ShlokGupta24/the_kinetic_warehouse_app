import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../products/presentation/providers/product_filter_provider.dart';
import '../../data/ledger_repository.dart';

class AddTransactionScreen extends ConsumerStatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  ConsumerState<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends ConsumerState<AddTransactionScreen> {
  final _qtyController = TextEditingController();
  Map<String, dynamic>? _selectedProduct;
  bool _isPurchase = true; // default to INBOUND
  bool _isLoading = false;

  @override
  void dispose() {
    _qtyController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (_selectedProduct == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a product first.')));
      return;
    }
    
    final qtyText = _qtyController.text;
    final qty = int.tryParse(qtyText);
    if (qty == null || qty <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter a valid quantity.')));
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final repo = ref.read(ledgerRepositoryProvider);
      
      // "Alex" is hardcoded locally as asked in ledger design logic until global auth state allows variable staffName.
      await repo.recordTransaction(
        productId: _selectedProduct!['id'] ?? _selectedProduct!['docId'], 
        productSku: _selectedProduct!['sku'] ?? 'N/A',
        productName: _selectedProduct!['name'] ?? 'Unknown Item',
        qty: qty,
        isPurchase: _isPurchase,
        staffName: 'Alex',
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Transaction recorded!')));
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final productsAsync = ref.watch(allProductsStreamProvider);

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: const Text('Record Transaction'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Transaction Type Toggle
            Text(
              'Transaction Type',
              style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: AppColors.onSurfaceVariant),
            ),
            SizedBox(height: 12.h),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _isPurchase = true),
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                      decoration: BoxDecoration(
                        color: _isPurchase ? AppColors.primary : AppColors.surfaceContainerLowest,
                        borderRadius: BorderRadius.circular(16.r),
                        border: Border.all(color: _isPurchase ? AppColors.primary : AppColors.outlineVariant),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        'Purchase (In)',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          color: _isPurchase ? Colors.white : AppColors.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _isPurchase = false),
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                      decoration: BoxDecoration(
                        color: !_isPurchase ? AppColors.tertiary : AppColors.surfaceContainerLowest,
                        borderRadius: BorderRadius.circular(16.r),
                        border: Border.all(color: !_isPurchase ? AppColors.tertiary : AppColors.outlineVariant),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        'Sale (Out)',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          color: !_isPurchase ? Colors.white : AppColors.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 32.h),

            // Select Product Autocomplete
            Text(
              'Select Product',
              style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: AppColors.onSurfaceVariant),
            ),
            SizedBox(height: 12.h),
            productsAsync.when(
              data: (snapshot) {
                final products = snapshot.docs.map((d) {
                  final data = d.data();
                  data['id'] = d.id;
                  return data;
                }).toList();

                return Autocomplete<Map<String, dynamic>>(
                  optionsBuilder: (TextEditingValue textEditingValue) {
                    if (textEditingValue.text.isEmpty) {
                      return const Iterable<Map<String, dynamic>>.empty();
                    }
                    return products.where((product) {
                      final name = (product['name'] as String?)?.toLowerCase() ?? '';
                      final sku = (product['sku'] as String?)?.toLowerCase() ?? '';
                      final q = textEditingValue.text.toLowerCase();
                      return name.contains(q) || sku.contains(q);
                    });
                  },
                  displayStringForOption: (option) => option['name'] ?? 'Unknown',
                  onSelected: (selection) {
                    setState(() {
                      _selectedProduct = selection;
                    });
                  },
                  fieldViewBuilder: (context, controller, focusNode, onEditingComplete) {
                    return TextField(
                      controller: controller,
                      focusNode: focusNode,
                      onEditingComplete: onEditingComplete,
                      decoration: InputDecoration(
                        hintText: 'Search by Name or SKU...',
                        filled: true,
                        fillColor: AppColors.surfaceContainerLowest,
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16.r),
                          borderSide: BorderSide(color: AppColors.outlineVariant),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16.r),
                          borderSide: BorderSide(color: AppColors.outlineVariant),
                        ),
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, st) => Text('Error loading products: \$e'),
            ),

            if (_selectedProduct != null) ...[
              SizedBox(height: 8.h),
              Text(
                "Current Stock: ${_selectedProduct!['qty'] ?? 0} ${_selectedProduct!['unit'] ?? ''}",
                style: TextStyle(fontSize: 12.sp, color: AppColors.secondary, fontWeight: FontWeight.bold),
              ),
            ],

            SizedBox(height: 32.h),

            // Enter Quantity
            Text(
              'Quantity',
              style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: AppColors.onSurfaceVariant),
            ),
            SizedBox(height: 12.h),
            TextField(
              controller: _qtyController,
              keyboardType: TextInputType.number,
              style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.bold),
              decoration: InputDecoration(
                hintText: '0',
                filled: true,
                fillColor: AppColors.surfaceContainerLowest,
                contentPadding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16.r),
                  borderSide: BorderSide.none,
                ),
              ),
            ),

            SizedBox(height: 60.h),

            // Submit Button
            SizedBox(
              width: double.infinity,
              height: 56.h,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  elevation: 0,
                ),
                child: _isLoading 
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                        'Record Transaction',
                        style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
