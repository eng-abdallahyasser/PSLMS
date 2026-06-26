import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lms/core/widgets/app_widgets.dart';
import 'package:lms/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:lms/features/profile/domain/entities/profile_entity.dart';
import 'package:lms/features/profile/presentation/cubit/profile_cubit.dart';

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
    return BlocListener<AuthCubit, AuthState>(
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
          child: CircleAvatar(
            radius: 50,
            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
            child: avatarUrl != null
                ? ClipOval(
                    child: Image.network(
                      avatarUrl,
                      fit: BoxFit.cover,
                      width: 100,
                      height: 100,
                    ),
                  )
                : Text(
                    profile.initials.isNotEmpty ? profile.initials : 'U',
                    style: TextStyle(
                      fontSize: 40,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 16),
        // Full Name
        Center(
          child: Text(
            profile.fullName,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
        const SizedBox(height: 4),
        // Email
        Center(
          child: Text(
            profile.email,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
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
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
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
                context
                    .read<ProfileCubit>()
                    .updatePreferences(lang: selected.first);
              },
            ),
          ),
        ),
        // Theme Toggle
        Card(
          child: ListTile(
            leading: const Icon(Icons.dark_mode),
            title: const Text('Theme'),
            subtitle: Text(
              profile.mode == 'dark' ? 'Dark Mode' : 'Light Mode',
            ),
            trailing: Switch(
              value: profile.mode == 'dark',
              onChanged: (value) {
                context
                    .read<ProfileCubit>()
                    .updatePreferences(mode: value ? 'dark' : 'light');
              },
            ),
          ),
        ),
        const SizedBox(height: 24),
        // Menu Items
        Text(
          'Account',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
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
        _buildMenuItem(
          icon: Icons.info_outline,
          title: 'About',
          onTap: () {},
        ),
        const SizedBox(height: 24),
        // Logout
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => context.read<AuthCubit>().logout(),
            icon: const Icon(Icons.logout, color: Colors.red),
            label: const Text(
              'Logout',
              style: TextStyle(color: Colors.red),
            ),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Colors.red),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
      ],
    );
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
            TextField(
              controller: firstNameController,
              decoration: const InputDecoration(
                labelText: 'First Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: lastNameController,
              decoration: const InputDecoration(
                labelText: 'Last Name',
                border: OutlineInputBorder(),
              ),
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
}
