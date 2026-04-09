import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/product_repository.dart';
import 'package:simple_barcode_scanner/simple_barcode_scanner.dart';

class EditProductScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic> product;

  const EditProductScreen({super.key, required this.product});

  @override
  ConsumerState<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends ConsumerState<EditProductScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _skuController;
  late TextEditingController _costController;
  late TextEditingController _priceController;
  late TextEditingController _qtyController;

  late String _selectedCategory;
  late String _selectedUnit;
  bool _isLoading = false;

  final List<String> _categories = [
    'Select Category',
    'Beverages',
    'Dry Goods',
    'Perishables',
    'Equipment'
  ];

  final List<String> _units = [
    'Piece (pc)',
    'Dozen (dz)',
    'Kilogram (kg)',
    'Liter (l)',
    'Box (bx)'
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.product['name']);
    _skuController = TextEditingController(text: widget.product['sku']);
    _costController = TextEditingController(text: widget.product['costPrice']?.toString() ?? '0');
    _priceController = TextEditingController(text: widget.product['price']?.toString() ?? '0');
    _qtyController = TextEditingController(text: widget.product['qty']?.toString() ?? '0');

    _selectedCategory = widget.product['category'] ?? 'Select Category';
    if (!_categories.contains(_selectedCategory)) {
      _selectedCategory = 'Select Category';
    }

    _selectedUnit = widget.product['unit'] ?? 'Piece (pc)';
    if (!_units.contains(_selectedUnit)) {
      _selectedUnit = 'Piece (pc)';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _skuController.dispose();
    _costController.dispose();
    _priceController.dispose();
    _qtyController.dispose();
    super.dispose();
  }

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (_selectedCategory == 'Select Category') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a category')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final docId = widget.product['id'] as String;
      final int oldQty = widget.product['qty'] ?? 0;
      final int newQty = int.tryParse(_qtyController.text) ?? 0;

      await ref.read(productRepositoryProvider).editProduct(
        productId: docId,
        oldQty: oldQty,
        newQty: newQty,
        sku: _skuController.text.trim(),
        name: _nameController.text.trim(),
        imageUrl: widget.product['imageUrl'] as String?,
        data: {
          'name': _nameController.text.trim(),
          'category': _selectedCategory,
          'sku': _skuController.text.trim(),
          'qty': newQty,
          'unit': _selectedUnit,
          'costPrice': double.tryParse(_costController.text) ?? 0,
          'price': double.tryParse(_priceController.text) ?? 0,
        },
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Product updated successfully')),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update product: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(64.h),
        child: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              color: Colors.white.withOpacity(0.7),
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              child: SafeArea(
                bottom: false,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        IconButton(
                          onPressed: () => context.pop(),
                          icon: Icon(Icons.arrow_back, color: AppColors.primary, size: 24.sp),
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            hoverColor: Colors.grey.shade100,
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          'Edit Product',
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                            color: AppColors.onSurface,
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
          padding: EdgeInsets.fromLTRB(20.w, 100.h, 20.w, 40.h),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildImageUpload(),
                SizedBox(height: 24.h),
                _buildCoreDetails(),
                SizedBox(height: 24.h),
                _buildPricingInventory(),
                SizedBox(height: 24.h),
                _buildActions(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImageUpload() {
    return Container(
      width: double.infinity,
      height: 180.h,
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(color: AppColors.outlineVariant.withOpacity(0.3), width: 2),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(24.r),
          onTap: () {}, // Add image picker later
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
               widget.product['imageUrl'] != null
                ? Expanded(
                    child: Padding(
                      padding: EdgeInsets.all(8.r),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16.r),
                        child: Image.network(widget.product['imageUrl'] as String, fit: BoxFit.cover, width: double.infinity),
                      ),
                    ),
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: EdgeInsets.all(16.r),
                        decoration: BoxDecoration(
                          color: AppColors.primaryContainer.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.add_a_photo, color: AppColors.primary, size: 32.sp),
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        'Change Product Image',
                        style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.onSurfaceVariant, fontSize: 13.sp),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        'Recommended: 1200 x 675 px',
                        style: TextStyle(color: AppColors.outline, fontSize: 11.sp),
                      ),
                    ],
                  ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCoreDetails() {
    return Container(
      padding: EdgeInsets.all(24.r),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0B1C30).withOpacity(0.02),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Core Details',
            style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w900, color: AppColors.onSurface, letterSpacing: -0.5),
          ),
          SizedBox(height: 20.h),
          _buildTextField(
            label: 'Product Name',
            controller: _nameController,
            hint: 'e.g. Organic Arabica Beans',
            validator: (v) => v == null || v.isEmpty ? 'Required' : null,
          ),
          SizedBox(height: 16.h),
          Row(
            children: [
              Expanded(
                child: _buildDropdown(
                  label: 'Category',
                  value: _selectedCategory,
                  items: _categories,
                  onChanged: (v) => setState(() => _selectedCategory = v!),
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: _buildScannerField(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPricingInventory() {
    return Container(
      padding: EdgeInsets.all(24.r),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0B1C30).withOpacity(0.02),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Stock & Pricing',
            style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w900, color: AppColors.onSurface, letterSpacing: -0.5),
          ),
          SizedBox(height: 20.h),
          _buildDropdown(
            label: 'Unit of Measure',
            value: _selectedUnit,
            items: _units,
            onChanged: (v) => setState(() => _selectedUnit = v!),
          ),
          SizedBox(height: 16.h),
          _buildTextField(
            label: 'Quantity in Stock',
            controller: _qtyController,
            hint: '0',
            validator: (v) => v == null || v.isEmpty ? 'Required' : null,
          ),
          SizedBox(height: 16.h),
          Row(
            children: [
              Expanded(
                child: _buildCurrencyField(
                  label: 'Cost Price',
                  controller: _costController,
                  validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                  isPrimary: false,
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: _buildCurrencyField(
                  label: 'Selling Price',
                  controller: _priceController,
                  validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                  isPrimary: true,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActions() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 56.h,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _saveProduct,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
              elevation: 4,
              shadowColor: AppColors.primary.withOpacity(0.4),
            ),
            child: _isLoading 
                ? const CircularProgressIndicator(color: Colors.white)
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.check_circle, size: 20.sp),
                      SizedBox(width: 8.w),
                      Text('Update Product', style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.bold)),
                    ],
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: EdgeInsets.only(left: 4.w, bottom: 8.h),
      child: Text(
        text.toUpperCase(),
        style: TextStyle(
          fontSize: 10.sp,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.5,
          color: AppColors.outline,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required String hint,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(label),
        TextFormField(
          controller: controller,
          validator: validator,
          style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500, color: AppColors.onSurface),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: AppColors.outlineVariant),
            filled: true,
            fillColor: AppColors.surfaceContainerHigh,
            contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r), borderSide: BorderSide.none),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
                                    borderSide: BorderSide(
                                      color: AppColors.primary.withOpacity(0.3),
                                      width: 2,
                                    ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown({
    required String label,
    required String value,
    required List<String> items,
    required void Function(String?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(label),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: items.contains(value) ? value : null,
              isExpanded: true,
              icon: Icon(Icons.expand_more, color: AppColors.outline, size: 20.sp),
              style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500, color: AppColors.onSurface),
              onChanged: onChanged,
              items: items.map((String item) {
                return DropdownMenuItem(value: item, child: Text(item));
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildScannerField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel('Barcode / SKU'),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _skuController,
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500, color: AppColors.onSurface),
                decoration: InputDecoration(
                  hintText: 'Scan or enter ID',
                  hintStyle: TextStyle(color: AppColors.outlineVariant),
                  filled: true,
                  fillColor: AppColors.surfaceContainerHigh,
                  contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r), borderSide: BorderSide.none),
                ),
              ),
            ),
            SizedBox(width: 8.w),
            Container(
              height: 48.h,
              width: 48.h,
              decoration: BoxDecoration(
                color: AppColors.secondaryContainer,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: IconButton(
                onPressed: () async {
                  var res = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SimpleBarcodeScannerPage(),
                    ),
                  );
                  if (res is String && res != '-1') {
                    setState(() {
                      _skuController.text = res;
                    });
                  }
                },
                icon: Icon(LucideIcons.scanLine, color: Colors.white, size: 20.sp),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCurrencyField({required String label, required TextEditingController controller, required String? Function(String?) validator, required bool isPrimary}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(label),
        TextFormField(
          controller: controller,
          validator: validator,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: isPrimary ? FontWeight.bold : FontWeight.w500,
            color: isPrimary ? AppColors.primary : AppColors.onSurface,
          ),
          decoration: InputDecoration(
            prefixIcon: Padding(
              padding: EdgeInsets.all(14.w),
              child: Text(
                '₹',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: isPrimary ? AppColors.primary : AppColors.outline,
                ),
              ),
            ),
            prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
            hintText: '0.00',
            hintStyle: TextStyle(color: AppColors.outlineVariant, fontWeight: FontWeight.normal),
            filled: true,
            fillColor: AppColors.surfaceContainerHigh,
            contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r), borderSide: BorderSide.none),
            focusedBorder: isPrimary
                ? OutlineInputBorder(borderRadius: BorderRadius.circular(12.r), borderSide: BorderSide(color: AppColors.primaryContainer.withOpacity(0.3), width: 2))
                : null,
          ),
        ),
      ],
    );
  }
}
