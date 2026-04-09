import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/theme/app_colors.dart';
import '../../data/users_repository.dart';

class UsersScreen extends ConsumerWidget {
  const UsersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usersAsync = ref.watch(allUsersStreamProvider);

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
                        Icon(LucideIcons.users, color: AppColors.primary, size: 22.sp),
                        SizedBox(width: 8.w),
                        Text(
                          'TEAM DIRECTORY',
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
                      icon: Icon(Icons.more_vert, color: AppColors.onSurfaceVariant),
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
              'User Management',
              style: TextStyle(
                fontSize: 32.sp,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.5,
                color: AppColors.onSurface,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              'Manage access and operational roles.',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: AppColors.onSurfaceVariant,
              ),
            ),
            SizedBox(height: 32.h),

            // Users List
            usersAsync.when(
              data: (snapshot) {
                final users = snapshot.docs;
                if (users.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: EdgeInsets.all(40.r),
                      child: Text('No users found.', style: TextStyle(color: AppColors.outline)),
                    ),
                  );
                }

                return ListView.separated(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: users.length,
                  separatorBuilder: (context, index) => SizedBox(height: 12.h),
                  itemBuilder: (context, index) {
                    final data = users[index].data();
                    final id = users[index].id;
                    return _UserCard(
                      id: id,
                      name: data['name'] as String? ?? 'Unknown User',
                      email: data['email'] as String? ?? 'No Email',
                      role: data['role'] as String? ?? 'Staff',
                      isActive: data['isActive'] as bool? ?? true,
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, st) => Center(child: Text('Failed to load users: $err')),
            ),
          ],
        ),
      ),
      floatingActionButton: Container(
        height: 56.h,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.r),
          gradient: LinearGradient(
            colors: [AppColors.primary, AppColors.primaryContainer],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.3),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: FloatingActionButton.extended(
          onPressed: () {
            // Placeholder: Show Add User Bottom Sheet or overlay Route
            _showAddUserDialog(context, ref);
          },
          backgroundColor: Colors.transparent,
          elevation: 0,
          highlightElevation: 0,
          icon: const Icon(LucideIcons.plus, color: Colors.white),
          label: Text('Add User', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14.sp)),
        ),
      ),
    );
  }

  void _showAddUserDialog(BuildContext context, WidgetRef ref) {
    String name = '';
    String email = '';
    String role = 'Staff';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
          child: Container(
            padding: EdgeInsets.all(24.r),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
            ),
            child: StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Add New User', style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.w900, color: AppColors.onSurface)),
                    SizedBox(height: 24.h),
                    TextField(
                      decoration: InputDecoration(
                        labelText: 'Full Name',
                        filled: true,
                        fillColor: AppColors.surfaceContainerHigh,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r), borderSide: BorderSide.none),
                      ),
                      onChanged: (val) => name = val,
                    ),
                    SizedBox(height: 16.h),
                    TextField(
                      decoration: InputDecoration(
                        labelText: 'Email Address',
                        filled: true,
                        fillColor: AppColors.surfaceContainerHigh,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r), borderSide: BorderSide.none),
                      ),
                      onChanged: (val) => email = val,
                    ),
                    SizedBox(height: 16.h),
                    DropdownButtonFormField<String>(
                      initialValue: role,
                      decoration: InputDecoration(
                        labelText: 'Access Role',
                        filled: true,
                        fillColor: AppColors.surfaceContainerHigh,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r), borderSide: BorderSide.none),
                      ),
                      items: ['Admin', 'Manager', 'Staff'].map((String val) {
                        return DropdownMenuItem(value: val, child: Text(val));
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setState(() => role = val);
                        }
                      },
                    ),
                    SizedBox(height: 32.h),
                    SizedBox(
                      width: double.infinity,
                      height: 56.h,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                        ),
                        onPressed: () {
                          if (name.isNotEmpty && email.isNotEmpty) {
                            ref.read(usersRepositoryProvider).addUser({
                              'name': name,
                              'email': email,
                              'role': role,
                              'isActive': true,
                            });
                            Navigator.pop(context);
                          }
                        },
                        child: Text('Create User', style: TextStyle(color: Colors.white, fontSize: 16.sp, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                );
              }
            ),
          ),
        );
      },
    );
  }
}

class _UserCard extends ConsumerWidget {
  final String id;
  final String name;
  final String email;
  final String role;
  final bool isActive;

  const _UserCard({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool isAdmin = role.toLowerCase() == 'admin';

    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0B1C30).withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: isAdmin ? AppColors.tertiary.withOpacity(0.1) : AppColors.primaryContainer.withOpacity(0.1),
            radius: 24.r,
            child: Text(
              name.isNotEmpty ? name[0].toUpperCase() : '?',
              style: TextStyle(
                fontWeight: FontWeight.w900,
                color: isAdmin ? AppColors.tertiary : AppColors.primary,
                fontSize: 18.sp,
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
                  style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w900, color: AppColors.onSurface, letterSpacing: -0.5),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 2.h),
                Text(
                  email,
                  style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w500, color: AppColors.onSurfaceVariant),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          SizedBox(width: 12.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: isAdmin ? AppColors.tertiary.withOpacity(0.1) : AppColors.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(9999.r),
                ),
                child: Text(
                  role.toUpperCase(),
                  style: TextStyle(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.0,
                    color: isAdmin ? AppColors.tertiary : AppColors.onSurfaceVariant,
                  ),
                ),
              ),
              SizedBox(height: 8.h),
              if (isAdmin)
                 IconButton(
                    icon: Icon(LucideIcons.shieldAlert, size: 16.sp, color: AppColors.tertiary),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () {},
                  )
              else
                  PopupMenuButton<String>(
                    icon: Icon(Icons.more_vert, size: 16.sp, color: AppColors.outline),
                    padding: EdgeInsets.zero,
                    itemBuilder: (context) => [
                      PopupMenuItem(value: 'promote', child: Text('Promote to Admin')),
                      PopupMenuItem(value: 'delete', child: Text('Remove User', style: TextStyle(color: AppColors.error))),
                    ],
                    onSelected: (val) {
                      if (val == 'promote') {
                        ref.read(usersRepositoryProvider).updateUserRole(id, 'Admin');
                      } else if (val == 'delete') {
                        ref.read(usersRepositoryProvider).deleteUser(id);
                      }
                    },
                  ),
            ],
          ),
        ],
      ),
    );
  }
}
