import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lms/core/widgets/app_widgets.dart';
import 'package:lms/features/auth/domain/entities/user_entity.dart';
import 'package:lms/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:lms/features/shared/notifications/presentation/cubit/notification_cubit.dart';
import 'package:lms/features/instructor/courses/dashboard/domain/entities/dashboard_stats_entity.dart';
import 'package:lms/features/instructor/courses/dashboard/presentation/cubit/dashboard_cubit.dart';
import 'package:lms/features/instructor/storage/domain/entities/storage_entities.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  @override
  void initState() {
    super.initState();
    context.read<DashboardCubit>().getStats(_currentRole());
    context.read<NotificationCubit>().getNotifications();
  }

  UserRole _currentRole() {
    final authState = context.read<AuthCubit>().state;
    if (authState is AuthAuthenticated) return authState.user.role;
    if (authState is AuthMobileOtpVerified) return authState.user.role;
    return UserRole.learner;
  }

  UserEntity? _currentUser() {
    final authState = context.read<AuthCubit>().state;
    if (authState is AuthAuthenticated) return authState.user;
    if (authState is AuthMobileOtpVerified) return authState.user;
    return null;
  }

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  String _formatMinutes(int minutes) {
    if (minutes < 60) return '$minutes min';
    final h = minutes ~/ 60;
    final m = minutes % 60;
    return m == 0 ? '$h h' : '$h h $m min';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          'Home',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: const Color(0xFF1565C0),
        foregroundColor: Colors.white,
        actions: [
          BlocBuilder<NotificationCubit, NotificationState>(
            builder: (context, notifState) {
              final unreadCount = notifState is NotificationsLoaded
                  ? notifState.notifications.where((n) => !n.isRead).length
                  : 0;
              return IconButton(
                icon: Badge(
                  isLabelVisible: unreadCount > 0,
                  label: Text('$unreadCount'),
                  child: const Icon(Icons.notifications_outlined),
                ),
                onPressed: () => context.push('/notifications'),
                tooltip: 'Notifications',
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () => context.push('/profile'),
            tooltip: 'Profile',
          ),
        ],
      ),
      body: BlocBuilder<DashboardCubit, DashboardState>(
        builder: (context, state) {
          return switch (state) {
            DashboardInitial() => const SizedBox.shrink(),
            DashboardLoading() => const AppLoadingWidget(),
            DashboardLoaded(:final stats, :final revenue) =>
              _buildDashboard(stats, revenue),
            DashboardError(:final message) => Center(
                child: AppErrorWidget(
                  message: message,
                  onRetry: () =>
                      context.read<DashboardCubit>().getStats(_currentRole()),
                ),
              ),
          };
        },
      ),
    );
  }

  // ----- Dashboard body -----

  Widget _buildDashboard(DashboardStatsEntity stats, RevenueSummary? revenue) {
    final role = _currentRole();
    final isEmptyStats = stats.enrolledCourses == 0;

    return RefreshIndicator(
      onRefresh: () =>
          context.read<DashboardCubit>().getStats(_currentRole(), silent: true),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildWelcomeHeader(),
          const SizedBox(height: 20),
          if (isEmptyStats) ...[
            _buildEmptyStateCta(role),
            const SizedBox(height: 20),
          ],
          _buildStatGrid(stats, revenue, role),
          if (role == UserRole.learner) ...[
            const SizedBox(height: 20),
            _buildProgressCard(stats),
          ],
          if (revenue != null) ...[
            const SizedBox(height: 20),
            _buildRevenueCard(revenue),
          ],
          const SizedBox(height: 24),
          Text(
            'Quick Actions',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 12),
          _buildQuickActions(role),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildWelcomeHeader() {
    final user = _currentUser();
    final name = (user?.firstName.isNotEmpty ?? false)
        ? user!.firstName
        : '';
    final subtitle = _currentRole() == UserRole.instructor
        ? "Here's how your courses are doing"
        : 'Continue your learning journey';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1565C0), Color(0xFF42A5F5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1565C0).withAlpha(51),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name.isEmpty ? _greeting() : '${_greeting()}, $name',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.white.withAlpha(179),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: () => context.push('/profile'),
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: AppAvatar(
                imageUrl: user?.avatarUrl,
                initials: (user?.firstName.isNotEmpty ?? false)
                    ? user!.firstName[0].toUpperCase()
                    : 'U',
                radius: 26,
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF1565C0),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyStateCta(UserRole role) {
    final isLearner = role == UserRole.learner;
    final title =
        isLearner ? 'Start your learning journey' : 'Create your first course';
    final message = isLearner
        ? 'Browse the catalog and enroll in your first course — it takes a minute.'
        : 'Upload content, set a price and reach students on Manara.';
    final cta = isLearner ? 'Browse courses' : 'Go to My Courses';

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: const BoxDecoration(
                color: Color(0xFFE3F2FD),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isLearner ? Icons.explore : Icons.add_photo_alternate_outlined,
                size: 32,
                color: const Color(0xFF1565C0),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Colors.grey[600]),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => context.push('/courses'),
                icon: const Icon(Icons.arrow_forward, size: 18),
                label: Text(cta),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatGrid(
    DashboardStatsEntity stats,
    RevenueSummary? revenue,
    UserRole role,
  ) {
    final isLearner = role == UserRole.learner;
    final cards = <Widget>[
      _buildStatCard(
        label: isLearner ? 'Enrolled' : 'Total Courses',
        value: '${stats.enrolledCourses}',
        icon: Icons.menu_book,
        color: const Color(0xFF1565C0),
        bgColor: const Color(0xFFE3F2FD),
        onTap: () => context.push(isLearner ? '/my-courses' : '/courses'),
      ),
      _buildStatCard(
        label: isLearner ? 'Completed' : 'Total Lessons',
        value: isLearner
            ? '${stats.completedCourses}'
            : '${stats.totalLessonsCompleted}',
        icon: Icons.check_circle,
        color: const Color(0xFF2E7D32),
        bgColor: const Color(0xFFE8F5E9),
      ),
      _buildStatCard(
        label: isLearner ? 'Lessons Done' : 'Content Length',
        value: isLearner
            ? '${stats.totalLessonsCompleted}'
            : _formatMinutes(stats.totalMinutesLearned),
        icon: Icons.play_circle_filled,
        color: const Color(0xFFE65100),
        bgColor: const Color(0xFFFFF3E0),
      ),
      if (isLearner)
        _buildStatCard(
          label: 'Time Learned',
          value: _formatMinutes(stats.totalMinutesLearned),
          icon: Icons.access_time,
          color: const Color(0xFF6A1B9A),
          bgColor: const Color(0xFFF3E5F5),
        )
      else
        _buildStatCard(
          label: 'Sales',
          value: revenue != null ? '${revenue.totalSales}' : '—',
          icon: Icons.sell_outlined,
          color: const Color(0xFF00695C),
          bgColor: const Color(0xFFE0F2F1),
        ),
    ];

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.35,
      children: cards,
    );
  }

  Widget _buildProgressCard(DashboardStatsEntity stats) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE3F2FD),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.trending_up,
                    color: Color(0xFF1565C0),
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Overall Progress',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: stats.overallProgress / 100,
                minHeight: 12,
                backgroundColor: const Color(0xFFE0E0E0),
                valueColor: const AlwaysStoppedAnimation<Color>(
                  Color(0xFF1565C0),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${stats.overallProgress.toStringAsFixed(0)}% Complete',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF1565C0),
                  ),
                ),
                Text(
                  '${stats.completedCourses}/${stats.enrolledCourses} courses',
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRevenueCard(RevenueSummary revenue) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E9),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.payments_outlined,
                    color: Color(0xFF2E7D32),
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Revenue',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () => context.push('/instructor/storage'),
                  child: const Text('Details'),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              '${revenue.netRevenue.toStringAsFixed(2)} ${revenue.currency}',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: const Color(0xFF2E7D32),
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              'Net revenue after commission',
              style: TextStyle(fontSize: 12.5, color: Colors.grey[600]),
            ),
            const SizedBox(height: 16),
            _revenueRow('Gross revenue',
                '${revenue.grossRevenue.toStringAsFixed(2)} ${revenue.currency}'),
            _revenueRow(
              'Platform commission',
              '-${revenue.totalCommission.toStringAsFixed(2)} ${revenue.currency}',
              muted: true,
            ),
            _revenueRow('Sales', '${revenue.totalSales}'),
          ],
        ),
      ),
    );
  }

  Widget _revenueRow(String label, String value, {bool muted = false}) {
    final style = Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: muted ? Colors.grey[600] : null,
        );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [Text(label, style: style), Text(value, style: style)],
      ),
    );
  }

  Widget _buildQuickActions(UserRole role) {
    final actions = role == UserRole.instructor
        ? const [
            (Icons.menu_book, 'My Courses', Color(0xFF1565C0), '/courses'),
            (
              Icons.storage,
              'Storage & Billing',
              Color(0xFF6A1B9A),
              '/instructor/storage'
            ),
            (
              Icons.notifications_outlined,
              'Notifications',
              Color(0xFFE65100),
              '/notifications'
            ),
            (Icons.person_outline, 'Profile', Color(0xFF00695C), '/profile'),
          ]
        : const [
            (Icons.menu_book, 'My Courses', Color(0xFF1565C0), '/my-courses'),
            (
              Icons.search,
              'Find Instructors',
              Color(0xFFE65100),
              '/search-instructors'
            ),
            (Icons.school, 'Browse Courses', Color(0xFF00695C), '/courses'),
            (
              Icons.notifications_outlined,
              'Notifications',
              Color(0xFF6A1B9A),
              '/notifications'
            ),
          ];

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.9,
      children: [
        for (final (icon, label, color, route) in actions)
          _buildActionCard(
            icon: icon,
            label: label,
            color: color,
            onTap: () => context.push(route),
          ),
      ],
    );
  }

  Widget _buildStatCard({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
    required Color bgColor,
    VoidCallback? onTap,
  }) {
    final content = Padding(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 6),
          Flexible(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: color,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );

    if (onTap == null) {
      return Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: content,
      );
    }
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(onTap: onTap, child: content),
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 14),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withAlpha(26),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
              Icon(Icons.chevron_right, size: 18, color: Colors.grey[400]),
            ],
          ),
        ),
      ),
    );
  }
}
