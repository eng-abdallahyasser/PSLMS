import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lms/core/widgets/app_bottom_nav.dart';
import 'package:lms/core/widgets/app_widgets.dart';
import 'package:lms/features/auth/domain/entities/user_entity.dart';
import 'package:lms/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:lms/features/instructor/courses/dashboard/domain/entities/dashboard_stats_entity.dart';
import 'package:lms/features/instructor/courses/dashboard/presentation/cubit/dashboard_cubit.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  @override
  void initState() {
    super.initState();
    final role = _currentRole();
    context.read<DashboardCubit>().getStats(role);
  }

  UserRole _currentRole() {
    final authState = context.read<AuthCubit>().state;
    if (authState is AuthAuthenticated) return authState.user.role;
    return UserRole.learner;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          'Dashboard',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: const Color(0xFF1565C0),
        foregroundColor: Colors.white,
        actions: [
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
            DashboardLoaded(:final stats) => _buildDashboard(stats),
            DashboardError(:final message) => Center(
                child: AppErrorWidget(
                  message: message,
                  onRetry: () => context.read<DashboardCubit>().getStats(_currentRole()),
                ),
              ),
          };
        },
      ),
      bottomNavigationBar: AppBottomNav(
        currentIndex: 0,
        role: _currentRole(),
        onTap: (index) {
          switch (index) {
            case 0:
              break;
            case 1:
              context.push('/courses');
              break;
            case 2:
              context.push('/profile');
              break;
          }
        },
      ),
    );
  }

  Widget _buildDashboard(DashboardStatsEntity stats) {
    return RefreshIndicator(
      onRefresh: () => context.read<DashboardCubit>().getStats(_currentRole()),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Welcome message
          Container(
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(30),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.school,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Welcome Back!',
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall
                            ?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Continue your learning journey',
                  style: TextStyle(
                    color: Colors.white.withAlpha(179),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // Stats Grid
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.4,
            children: [
              _buildStatCard(
                label: 'Enrolled',
                value: '${stats.enrolledCourses}',
                icon: Icons.menu_book,
                color: const Color(0xFF1565C0),
                bgColor: const Color(0xFFE3F2FD),
              ),
              _buildStatCard(
                label: 'Completed',
                value: '${stats.completedCourses}',
                icon: Icons.check_circle,
                color: const Color(0xFF2E7D32),
                bgColor: const Color(0xFFE8F5E9),
              ),
              _buildStatCard(
                label: 'Lessons Done',
                value: '${stats.totalLessonsCompleted}',
                icon: Icons.play_circle_filled,
                color: const Color(0xFFE65100),
                bgColor: const Color(0xFFFFF3E0),
              ),
              _buildStatCard(
                label: 'Minutes Learned',
                value: '${stats.totalMinutesLearned}',
                icon: Icons.access_time,
                color: const Color(0xFF6A1B9A),
                bgColor: const Color(0xFFF3E5F5),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Overall Progress
          Card(
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
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
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
          ),
          const SizedBox(height: 24),
          // Quick Actions
          Text(
            'Quick Actions',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 12),
          if (_currentRole() == UserRole.instructor) ...[
            Row(
              children: [
                Expanded(
                  child: _buildActionCard(
                    icon: Icons.menu_book,
                    label: 'My Courses',
                    color: const Color(0xFF1565C0),
                    onTap: () => context.push('/courses'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildActionCard(
                    icon: Icons.people,
                    label: 'Students',
                    color: const Color(0xFF2E7D32),
                    onTap: () => context.push('/instructor/students'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildActionCard(
                    icon: Icons.card_membership,
                    label: 'Subscription',
                    color: const Color(0xFF6A1B9A),
                    onTap: () => context.push('/instructor/subscription'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildActionCard(
                    icon: Icons.person,
                    label: 'My Profile',
                    color: const Color(0xFFE65100),
                    onTap: () => context.push('/profile'),
                  ),
                ),
              ],
            ),
          ] else ...[
            Row(
              children: [
                Expanded(
                  child: _buildActionCard(
                    icon: Icons.menu_book,
                    label: 'My Courses',
                    color: const Color(0xFF1565C0),
                    onTap: () => context.push('/my-courses'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildActionCard(
                    icon: Icons.people,
                    label: 'My Instructors',
                    color: const Color(0xFF2E7D32),
                    onTap: () => context.push('/my-instructors'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildActionCard(
                    icon: Icons.search,
                    label: 'Find Instructors',
                    color: const Color(0xFFE65100),
                    onTap: () => context.push('/search-instructors'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildActionCard(
                    icon: Icons.notifications,
                    label: 'Notifications',
                    color: const Color(0xFF6A1B9A),
                    onTap: () => context.push('/notifications'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildActionCard(
                    icon: Icons.school,
                    label: 'Browse All',
                    color: const Color(0xFF00695C),
                    onTap: () => context.push('/courses'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildActionCard(
                    icon: Icons.person,
                    label: 'My Profile',
                    color: const Color(0xFF6A1B9A),
                    onTap: () => context.push('/profile'),
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
    required Color bgColor,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
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
      ),
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
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withAlpha(26),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(height: 10),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
