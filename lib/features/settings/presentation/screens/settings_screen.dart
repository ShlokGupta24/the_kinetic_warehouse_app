import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/providers/auth_controller.dart';
import '../../../auth/domain/auth_repository.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _stockAlertsEnabled = true;
  bool _darkMode = false;

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authStateChangesProvider).value;

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
                        Icon(Icons.settings_outlined, color: AppColors.primary, size: 22.sp),
                        SizedBox(width: 8.w),
                        Text(
                          'PREFERENCES',
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
        padding: EdgeInsets.fromLTRB(24.w, 100.h, 24.w, 150.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Text(
              'Profile & Settings',
              style: TextStyle(
                fontSize: 32.sp,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.5,
                color: AppColors.onSurface,
              ),
            ),
            SizedBox(height: 32.h),

            // Profile Card
            _buildProfileCard(user),
            SizedBox(height: 24.h),

            // Business Info Section
            Text(
              'COMPANY INFO',
              style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold, letterSpacing: 1.5, color: AppColors.onSurfaceVariant),
            ),
            SizedBox(height: 12.h),
            _buildSettingsList([
              _SettingsTile(
                icon: LucideIcons.building,
                title: 'Business Details',
                subtitle: 'The Kinetic Warehouse LLC',
                onTap: () {},
              ),
              _SettingsTile(
                icon: LucideIcons.mapPin,
                title: 'Locations & Zones',
                subtitle: 'Manage warehouse sectors',
                onTap: () {},
              ),
              _SettingsTile(
                icon: LucideIcons.users,
                title: 'Team Directory',
                subtitle: 'Manage user access and roles',
                onTap: () => context.push('/users'),
                showForwardArrow: true,
              ),
            ]),
            SizedBox(height: 24.h),

            // Notifications
            Text(
              'PREFERENCES',
              style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold, letterSpacing: 1.5, color: AppColors.onSurfaceVariant),
            ),
            SizedBox(height: 12.h),
            _buildSettingsList([
              _SettingsSwitch(
                icon: LucideIcons.bellRing,
                title: 'Push Notifications',
                value: _notificationsEnabled,
                onChanged: (val) => setState(() => _notificationsEnabled = val),
              ),
              _SettingsSwitch(
                icon: LucideIcons.packageMinus,
                title: 'Low Stock Alerts',
                value: _stockAlertsEnabled,
                onChanged: (val) => setState(() => _stockAlertsEnabled = val),
              ),
              _SettingsSwitch(
                icon: LucideIcons.moon,
                title: 'Dark Mode',
                value: _darkMode,
                onChanged: (val) {
                  // Scaffold functionality for dark mode could be tied to Riverpod later
                  setState(() => _darkMode = val);
                },
              ),
            ]),
            SizedBox(height: 32.h),

            // Logout
            SizedBox(
              width: double.infinity,
              height: 56.h,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.error.withOpacity(0.1),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
                  elevation: 0,
                ),
                onPressed: () {
                  ref.read(authControllerProvider.notifier).signOut();
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(LucideIcons.logOut, color: AppColors.error, size: 20.sp),
                    SizedBox(width: 8.w),
                    Text('Logout', style: TextStyle(color: AppColors.error, fontSize: 16.sp, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileCard(dynamic user) {
    final email = user?.email ?? 'Unknown User';
    final name = email.split('@')[0].toUpperCase();

    return Container(
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0B1C30).withOpacity(0.04),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: AppColors.primaryContainer.withOpacity(0.15),
            radius: 32.r,
            child: Text(
              name.isNotEmpty ? name[0] : 'U',
              style: TextStyle(
                fontSize: 24.sp,
                fontWeight: FontWeight.w900,
                color: AppColors.primary,
              ),
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w900, color: AppColors.onSurface, letterSpacing: -0.5),
                ),
                SizedBox(height: 4.h),
                Text(
                  email,
                  style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w500, color: AppColors.onSurfaceVariant),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(9999.r),
            ),
            child: Text(
              'ACTIVE',
              style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.bold, letterSpacing: 1.0, color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsList(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0B1C30).withOpacity(0.04),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.zero,
        itemCount: children.length,
        separatorBuilder: (context, index) => Divider(height: 1, color: AppColors.outlineVariant.withOpacity(0.2), indent: 56.w, endIndent: 24.w),
        itemBuilder: (context, index) => children[index],
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool showForwardArrow;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.showForwardArrow = false,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 4.h),
      leading: Container(
        padding: EdgeInsets.all(10.r),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Icon(icon, size: 20.sp, color: AppColors.primary),
      ),
      title: Text(title, style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w900, color: AppColors.onSurface)),
      subtitle: Text(subtitle, style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w500, color: AppColors.onSurfaceVariant)),
      trailing: showForwardArrow ? Icon(Icons.chevron_right, color: AppColors.outline) : null,
      onTap: onTap,
    );
  }
}

class _SettingsSwitch extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SettingsSwitch({
    required this.icon,
    required this.title,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 4.h),
      leading: Container(
        padding: EdgeInsets.all(10.r),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Icon(icon, size: 20.sp, color: AppColors.primary),
      ),
      title: Text(title, style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w900, color: AppColors.onSurface)),
      trailing: Switch.adaptive(
        value: value,
        onChanged: onChanged,
        activeThumbColor: AppColors.primary,
        activeTrackColor: AppColors.primaryContainer.withOpacity(0.5),
      ),
    );
  }
}
