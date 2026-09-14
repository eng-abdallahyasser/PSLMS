import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:lms/core/widgets/app_widgets.dart';
import 'package:lms/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:lms/features/shared/profile/domain/entities/profile_entity.dart';
import 'package:lms/features/shared/profile/presentation/cubit/profile_cubit.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  void initState() {
    super.initState();
    context.read<ProfileCubit>().getProfile();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          'Profile',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: const Color(0xFF1565C0),
        foregroundColor: Colors.white,
      ),
      body: BlocListener<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthUnauthenticated) {
            context.go('/login');
          }
          if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: BlocBuilder<ProfileCubit, ProfileState>(
          builder: (context, state) {
            return switch (state) {
              ProfileInitial() => const SizedBox.shrink(),
              ProfileLoading() => const AppLoadingWidget(),
              ProfileLoaded(:final profile) => _buildProfile(profile),
              ProfileError(:final message) => AppErrorWidget(
                message: message,
                onRetry: () => context.read<ProfileCubit>().getProfile(),
              ),
            };
          },
        ),
      ),
    );
  }

  Widget _buildProfile(ProfileEntity profile) {
    final avatarUrl = profile.avatarUrl;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const SizedBox(height: 24),
        // Avatar
        Center(
          child: GestureDetector(
            onTap: _pickAndUploadAvatar,
            child: Stack(
              alignment: Alignment.bottomRight,
              children: [
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.15),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: AppAvatar(
                    imageUrl: avatarUrl,
                    initials: profile.initials.isNotEmpty
                        ? profile.initials
                        : 'U',
                    radius: 50,
                    backgroundColor:
                        Theme.of(context).colorScheme.primaryContainer,
                    foregroundColor: Theme.of(context).colorScheme.primary,
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  padding: const EdgeInsets.all(6),
                  child: const Icon(
                    Icons.photo_camera,
                    size: 16,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Full Name
        Center(
          child: Text(
            profile.fullName,
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 4),
        // Email
        Center(
          child: Text(
            profile.email,
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
        ),
        const SizedBox(height: 4),
        // Role badge
        Center(
          child: Chip(
            label: Text(
              profile.role.value,
              style: const TextStyle(fontSize: 12),
            ),
            visualDensity: VisualDensity.compact,
          ),
        ),
        const SizedBox(height: 32),
        // Preferences Section
        Text(
          'Preferences',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        // Language Toggle
        Card(
          child: ListTile(
            leading: const Icon(Icons.language),
            title: const Text('Language'),
            subtitle: Text(profile.lang == 'ar' ? 'العربية' : 'English'),
            trailing: SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'en', label: Text('EN')),
                ButtonSegment(value: 'ar', label: Text('AR')),
              ],
              selected: {profile.lang},
              onSelectionChanged: (selected) {
                context.read<ProfileCubit>().updatePreferences(
                  lang: selected.first,
                );
              },
            ),
          ),
        ),
        // Theme Toggle
        Card(
          child: ListTile(
            leading: const Icon(Icons.dark_mode),
            title: const Text('Theme'),
            subtitle: Text(profile.mode == 'dark' ? 'Dark Mode' : 'Light Mode'),
            trailing: Switch(
              value: profile.mode == 'dark',
              onChanged: (value) {
                context.read<ProfileCubit>().updatePreferences(
                  mode: value ? 'dark' : 'light',
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 24),
        // Menu Items
        Text(
          'Account',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        _buildMenuItem(
          icon: Icons.person_outline,
          title: 'Edit Profile',
          onTap: () {
            _showEditProfileDialog(context, profile);
          },
        ),
        _buildMenuItem(
          icon: Icons.notifications_outlined,
          title: 'Notifications',
          onTap: () {},
        ),
        _buildMenuItem(
          icon: Icons.help_outline,
          title: 'Help & Support',
          onTap: () {},
        ),
        _buildMenuItem(icon: Icons.info_outline, title: 'About', onTap: () {}),
        const SizedBox(height: 24),
        // Logout
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => context.read<AuthCubit>().logout(),
            icon: const Icon(Icons.logout, color: Colors.red),
            label: const Text('Logout', style: TextStyle(color: Colors.red)),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Colors.red),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
        _buildVersionFooter(),
      ],
    );
  }

  Future<void> _pickAndUploadAvatar() async {
    if (kIsWeb) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Avatar upload is not supported on web yet'),
        ),
      );
      return;
    }
    final file = await FilePicker.pickFile(
      type: FileType.image,
    );
    final path = file?.path;
    if (path == null) return; // User cancelled
    if (!mounted) return;
    await context.read<ProfileCubit>().uploadAvatar(path);
  }

  void _showEditProfileDialog(BuildContext context, ProfileEntity profile) {
    final firstNameController = TextEditingController(text: profile.firstName);
    final lastNameController = TextEditingController(text: profile.lastName);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit Profile'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppTextField(
              label: 'First Name',
              controller: firstNameController,
            ),
            const SizedBox(height: 12),
            AppTextField(
              label: 'Last Name',
              controller: lastNameController,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<ProfileCubit>().updateProfile(
                firstName: firstNameController.text.trim(),
                lastName: lastNameController.text.trim(),
              );
              Navigator.of(ctx).pop();
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }

  Widget _buildVersionFooter() {
    return FutureBuilder<PackageInfo>(
      future: PackageInfo.fromPlatform(),
      builder: (context, snapshot) {
        final version = snapshot.data?.version ?? '';
        final build = snapshot.data?.buildNumber ?? '';
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Text(
            'v$version${build.isNotEmpty ? '+$build' : ''}',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[400], fontSize: 12),
          ),
        );
      },
    );
  }
}
