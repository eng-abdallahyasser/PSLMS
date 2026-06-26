import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lms/core/widgets/app_widgets.dart';
import 'package:lms/features/dashboard/domain/entities/dashboard_stats_entity.dart';
import 'package:lms/features/dashboard/presentation/cubit/dashboard_cubit.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  @override
  void initState() {
    super.initState();
    context.read<DashboardCubit>().getStats();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DashboardCubit, DashboardState>(
      builder: (context, state) {
        return switch (state) {
          DashboardInitial() => const SizedBox.shrink(),
          DashboardLoading() => const AppLoadingWidget(),
          DashboardLoaded(:final stats) => _buildDashboard(stats),
          DashboardError(:final message) => AppErrorWidget(message: message),
        };
      },
    );
  }

  Widget _buildDashboard(DashboardStatsEntity stats) {
    return RefreshIndicator(
      onRefresh: () => context.read<DashboardCubit>().getStats(),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Dashboard',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          // Stats Grid
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.6,
            children: [
              _buildStatCard(
                'Enrolled',
                '${stats.enrolledCourses}',
                Icons.menu_book,
                Colors.blue,
              ),
              _buildStatCard(
                'Completed',
                '${stats.completedCourses}',
                Icons.check_circle,
                Colors.green,
              ),
              _buildStatCard(
                'Lessons Done',
                '${stats.totalLessonsCompleted}',
                Icons.play_circle,
                Colors.orange,
              ),
              _buildStatCard(
                'Minutes',
                '${stats.totalMinutesLearned}',
                Icons.access_time,
                Colors.purple,
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Overall Progress
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Overall Progress',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  LinearProgressIndicator(
                    value: stats.overallProgress / 100,
                    minHeight: 10,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${stats.overallProgress.toStringAsFixed(0)}% Complete',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
