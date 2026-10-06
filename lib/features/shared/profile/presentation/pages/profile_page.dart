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
import 'package:lms/features/shared/universities/data/datasources/universities_remote_datasource.dart';
import 'package:lms/features/shared/universities/data/models/university_model.dart';
import 'package:lms/injection_container.dart';

const _monthNames = [
  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
];

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  List<UniversityModel> _universities = [];

  @override
  void initState() {
    super.initState();
    context.read<ProfileCubit>().getProfile();
    _loadUniversities();
  }

  Future<void> _loadUniversities() async {
    try {
      final list = await sl<UniversitiesRemoteDataSource>().getUniversities();
      if (mounted) setState(() => _universities = list);
    } catch (_) {
      // University names fall back to raw id — non-blocking.
    }
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
        actions: [
          BlocBuilder<ProfileCubit, ProfileState>(
            builder: (context, state) {
              final saving = state is ProfileLoaded && state.saving;
              return saving
                  ? const Padding(
                      padding: EdgeInsets.only(right: 16),
                      child: SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      ),
                    )
                  : const SizedBox.shrink();
            },
          ),
        ],
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
        child: BlocListener<ProfileCubit, ProfileState>(
          listener: (context, state) {
            if (state case ProfileLoaded(
              notice: final notice?,
              noticeIsError: final isError,
            ) when notice.isNotEmpty) {
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(
                  SnackBar(
                    content: Text(notice),
                    backgroundColor: isError ? Colors.red : Colors.green,
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
      ),
    );
  }

  // ----- Sections -----

  Widget _buildProfile(ProfileEntity profile) {
    return RefreshIndicator(
      onRefresh: () => context.read<ProfileCubit>().refresh(),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildHeader(profile),
          if (!profile.isActive) ...[
            const SizedBox(height: 12),
            _buildInactiveBanner(),
          ],
          const SizedBox(height: 20),
          _sectionTitle('Verification'),
          _buildVerificationCard(profile),
          if (_hasAcademicData(profile)) ...[
            const SizedBox(height: 20),
            _sectionTitle('Academic Information'),
            _buildAcademicCard(profile),
          ],
          const SizedBox(height: 20),
          _sectionTitle('Storage'),
          _buildStorageCard(profile),
          const SizedBox(height: 20),
          _sectionTitle('Preferences'),
          _buildPreferences(profile),
          const SizedBox(height: 20),
          _sectionTitle('Account'),
          _buildMenuItem(
            icon: Icons.person_outline,
            title: 'Edit Profile',
            subtitle: 'Name, phone, faculty, university',
            onTap: () => _showEditProfileDialog(context, profile),
          ),
          _buildMenuItem(
            icon: Icons.notifications_outlined,
            title: 'Notifications',
            onTap: () => context.push('/notifications'),
          ),
          _buildMenuItem(
            icon: Icons.info_outline,
            title: 'About',
            onTap: _showAboutDialog,
          ),
          const SizedBox(height: 24),
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
      ),
    );
  }

  Widget _buildHeader(ProfileEntity profile) {
    final avatarUrl = profile.avatarUrl;
    final roleLabel = profile.role.value.isEmpty
        ? profile.role.value
        : profile.role.value[0].toUpperCase() + profile.role.value.substring(1);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1565C0), Color(0xFF42A5F5)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1565C0).withValues(alpha: 0.3),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          GestureDetector(
            onTap: _pickAndUploadAvatar,
            child: Stack(
              alignment: Alignment.bottomRight,
              children: [
                AppAvatar(
                  imageUrl: avatarUrl,
                  initials:
                      profile.initials.isNotEmpty ? profile.initials : 'U',
                  radius: 46,
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF1565C0),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFF1565C0), width: 2),
                  ),
                  padding: const EdgeInsets.all(6),
                  child: const Icon(
                    Icons.photo_camera,
                    size: 16,
                    color: Color(0xFF1565C0),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Text(
            profile.fullName,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: Text(
                  profile.email,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Icon(
                profile.isEmailVerified ? Icons.verified : Icons.pending,
                size: 16,
                color: profile.isEmailVerified
                    ? Colors.lightGreenAccent
                    : Colors.amberAccent,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Chip(
                label: Text(
                  roleLabel,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF1565C0),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                backgroundColor: Colors.white.withValues(alpha: 0.2),
                side: BorderSide.none,
                visualDensity: VisualDensity.compact,
                padding: const EdgeInsets.symmetric(horizontal: 6),
              ),
              if (profile.createdAt != null) ...[
                const SizedBox(width: 8),
                Text(
                  'Joined ${_formatDate(profile.createdAt!)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInactiveBanner() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.amber.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.amber.shade400),
      ),
      child: Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: Colors.amber.shade800),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              'This account is inactive. Please contact support.',
              style: TextStyle(fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVerificationCard(ProfileEntity profile) {
    return Card(
      margin: EdgeInsets.zero,
      child: Column(
        children: [
          _infoRow(
            icon: Icons.mail_outline,
            label: 'Email',
            value: profile.email,
            trailing: _verifyChip(ok: profile.isEmailVerified),
          ),
          const Divider(height: 1, indent: 16, endIndent: 16),
          _infoRow(
            icon: Icons.phone_outlined,
            label: 'Phone number',
            value: (profile.mobileNumber?.isNotEmpty ?? false)
                ? profile.mobileNumber!
                : 'Not added',
            trailing: (profile.mobileNumber?.isNotEmpty ?? false)
                ? _verifyChip(ok: profile.isMobileVerified)
                : null,
          ),
          const Divider(height: 1, indent: 16, endIndent: 16),
          _infoRow(
            icon: Icons.badge_outlined,
            label: 'Account type',
            value: profile.role.value.isEmpty
                ? profile.role.value
                : profile.role.value[0].toUpperCase() +
                    profile.role.value.substring(1),
          ),
        ],
      ),
    );
  }

  bool _hasAcademicData(ProfileEntity profile) =>
      profile.universityId?.isNotEmpty == true ||
      profile.faculty?.isNotEmpty == true ||
      profile.department?.isNotEmpty == true ||
      profile.year?.isNotEmpty == true;

  Widget _buildAcademicCard(ProfileEntity profile) {
    return Card(
      margin: EdgeInsets.zero,
      child: Column(
        children: [
          if (profile.universityId?.isNotEmpty == true)
            _infoRow(
              icon: Icons.school_outlined,
              label: 'University',
              value: _universityName(profile) ?? '—',
            ),
          if (profile.faculty?.isNotEmpty == true) ...[
            const Divider(height: 1, indent: 16, endIndent: 16),
            _infoRow(
              icon: Icons.account_balance_outlined,
              label: 'Faculty',
              value: profile.faculty!,
            ),
          ],
          if (profile.department?.isNotEmpty == true) ...[
            const Divider(height: 1, indent: 16, endIndent: 16),
            _infoRow(
              icon: Icons.menu_book_outlined,
              label: 'Department',
              value: profile.department!,
            ),
          ],
          if (profile.year?.isNotEmpty == true) ...[
            const Divider(height: 1, indent: 16, endIndent: 16),
            _infoRow(
              icon: Icons.calendar_today_outlined,
              label: 'Year',
              value: profile.year!,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStorageCard(ProfileEntity profile) {
    return Card(
      margin: EdgeInsets.zero,
      child: _infoRow(
        icon: Icons.pie_chart_outline,
        label: 'Storage quota',
        value: profile.storageQuotaLabel,
        trailing: const Icon(Icons.cloud_outlined, size: 20, color: Colors.grey),
      ),
    );
  }

  Widget _buildPreferences(ProfileEntity profile) {
    return Column(
      children: [
        Card(
          margin: const EdgeInsets.only(bottom: 8),
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
        Card(
          margin: EdgeInsets.zero,
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
      ],
    );
  }

  // ----- Shared bits -----

  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: Theme.of(
          context,
        ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _infoRow({
    required IconData icon,
    required String label,
    required String value,
    Widget? trailing,
  }) {
    return ListTile(
      dense: true,
      leading: Icon(icon, size: 22, color: Colors.grey[700]),
      title: Text(
        label,
        style: TextStyle(fontSize: 12.5, color: Colors.grey[600]),
      ),
      subtitle: Text(
        value,
        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
      ),
      trailing: trailing,
    );
  }

  Widget _verifyChip({required bool ok}) {
    final color = ok ? Colors.green : Colors.orange;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            ok ? Icons.check_circle : Icons.error_outline,
            size: 14,
            color: color.shade700,
          ),
          const SizedBox(width: 4),
          Text(
            ok ? 'Verified' : 'Not verified',
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              color: color.shade700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        subtitle: subtitle != null
            ? Text(subtitle, style: const TextStyle(fontSize: 12.5))
            : null,
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

  String _formatDate(DateTime date) {
    final d = date.toLocal();
    return '${_monthNames[d.month - 1]} ${d.year}';
  }

  String? _universityName(ProfileEntity profile) {
    final id = profile.universityId;
    if (id == null || id.isEmpty) return null;
    UniversityModel? match;
    for (final u in _universities) {
      if (u.id == id) {
        match = u;
        break;
      }
    }
    if (match == null) return id;
    return profile.lang == 'ar'
        ? (match.nameAr?.isNotEmpty == true ? match.nameAr! : match.name)
        : match.name;
  }

  // ----- Actions -----

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
    final formKey = GlobalKey<FormState>();
    final firstNameController = TextEditingController(text: profile.firstName);
    final lastNameController = TextEditingController(text: profile.lastName);
    final mobileController =
        TextEditingController(text: profile.mobileNumber ?? '');
    final facultyController = TextEditingController(text: profile.faculty ?? '');
    final departmentController =
        TextEditingController(text: profile.department ?? '');
    final yearController = TextEditingController(text: profile.year ?? '');
    String? universityId = profile.universityId;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit Profile'),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AppTextField(
                    label: 'First Name',
                    controller: firstNameController,
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? 'Required'
                        : null,
                  ),
                  const SizedBox(height: 12),
                  AppTextField(
                    label: 'Last Name',
                    controller: lastNameController,
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? 'Required'
                        : null,
                  ),
                  const SizedBox(height: 12),
                  AppTextField(
                    label: 'Phone Number',
                    controller: mobileController,
                    keyboardType: TextInputType.phone,
                    prefixIcon: const Icon(Icons.phone_outlined),
                  ),
                  if (_universities.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: _universities.any((u) => u.id == universityId)
                          ? universityId
                          : null,
                      decoration: const InputDecoration(
                        labelText: 'University',
                        prefixIcon: Icon(Icons.school_outlined),
                      ),
                      items: _universities
                          .map(
                            (u) => DropdownMenuItem(
                              value: u.id,
                              child: Text(
                                u.name,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (value) => universityId = value,
                    ),
                  ],
                  const SizedBox(height: 12),
                  AppTextField(
                    label: 'Faculty',
                    controller: facultyController,
                    prefixIcon: const Icon(Icons.account_balance_outlined),
                  ),
                  const SizedBox(height: 12),
                  AppTextField(
                    label: 'Department',
                    controller: departmentController,
                    prefixIcon: const Icon(Icons.menu_book_outlined),
                  ),
                  const SizedBox(height: 12),
                  AppTextField(
                    label: 'Year',
                    controller: yearController,
                    prefixIcon: const Icon(Icons.calendar_today_outlined),
                  ),
                ],
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (!(formKey.currentState?.validate() ?? false)) return;
              context.read<ProfileCubit>().updateProfile(
                firstName: firstNameController.text.trim(),
                lastName: lastNameController.text.trim(),
                mobileNumber: mobileController.text.trim(),
                universityId: universityId,
                faculty: facultyController.text.trim(),
                department: departmentController.text.trim(),
                year: yearController.text.trim(),
              );
              Navigator.of(ctx).pop();
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (ctx) => FutureBuilder<PackageInfo>(
        future: PackageInfo.fromPlatform(),
        builder: (context, snapshot) {
          final info = snapshot.data;
          return AlertDialog(
            title: const Text('About'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Manara LMS',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                if (info != null)
                  Text(
                    'Version ${info.version}'
                    '${info.buildNumber.isNotEmpty ? ' (${info.buildNumber})' : ''}',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                const SizedBox(height: 4),
                Text(
                  'Your learning platform.',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('Close'),
              ),
            ],
          );
        },
      ),
    );
  }
}
