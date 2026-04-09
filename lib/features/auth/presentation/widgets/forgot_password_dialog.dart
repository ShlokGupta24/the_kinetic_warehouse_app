import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/auth_controller.dart';

class ForgotPasswordDialog extends ConsumerStatefulWidget {
  const ForgotPasswordDialog({super.key});

  @override
  ConsumerState<ForgotPasswordDialog> createState() => _ForgotPasswordDialogState();
}

class _ForgotPasswordDialogState extends ConsumerState<ForgotPasswordDialog> {
  final TextEditingController _emailController = TextEditingController();
  bool _isValid = false;

  @override
  void initState() {
    super.initState();
    _emailController.addListener(_validate);
  }

  void _validate() {
    final email = _emailController.text.trim();
    final isValid = RegExp(r"^[^@\s]+@[^@\s]+\.[^@\s]+").hasMatch(email);
    if (isValid != _isValid) {
      setState(() => _isValid = isValid);
    }
  }

  @override
  void dispose() {
    _emailController.removeListener(_validate);
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    return Dialog(
      insetPadding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
      backgroundColor: Colors.transparent,
      child: Stack(
        children: [
          // Glassmorphic backdrop
          Container(
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(20.r),
              border: Border.all(
                color: AppColors.outline.withOpacity(0.2),
                width: 1,
              ),
            ),
            padding: EdgeInsets.all(24.r),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Reset Password',
                  style: TextStyle(
                    fontSize: 22.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.onSurface,
                  ),
                ),
                SizedBox(height: 12.h),
                Text(
                  'Enter your email address and we\'ll send you a link to reset your password.',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
                SizedBox(height: 20.h),
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    hintText: 'you@example.com',
                    prefixIcon: Icon(
                      LucideIcons.mail,
                      color: AppColors.onSurfaceVariant,
                      size: 20.r,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    // Replaced removed surfaceContainerHighest with surfaceContainerHigh
                    fillColor: AppColors.surfaceContainerHigh.withOpacity(0.6),
                  ),
                ),
                SizedBox(height: 24.h),
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      // Replaced deprecated 'primary:' with 'backgroundColor:'
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                    ),
                    onPressed: _isValid && !authState.isLoading
                        ? () async {
                            final navigator = Navigator.of(context);
                            await ref
                                .read(authControllerProvider.notifier)
                                .resetPassword(_emailController.text.trim(), context);
                            navigator.pop();
                          }
                        : null,
                    child: authState.isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            'Send Reset',
                            style: TextStyle(
                              color: AppColors.onPrimary,
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
          // Close button
          Positioned(
            top: 8.r,
            right: 8.r,
            child: IconButton(
              icon: Icon(Icons.close, color: AppColors.onSurfaceVariant),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
        ],
      ),
    );
  }
}

// Helper to show the dialog
Future<void> showForgotPasswordDialog(BuildContext context) async {
  await showDialog(
    context: context,
    barrierDismissible: true,
    builder: (_) => const ForgotPasswordDialog(),
  );
}
