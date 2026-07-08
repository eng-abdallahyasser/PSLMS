import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lms/core/widgets/app_bottom_nav.dart';
import 'package:lms/core/widgets/app_widgets.dart';
import 'package:lms/features/auth/domain/entities/user_entity.dart';
import 'package:lms/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:lms/features/shared/domain/entities/course_entity.dart';
import 'package:lms/features/instructor/courses/presentation/cubit/course_cubit.dart';
import 'package:lms/features/instructor/courses/presentation/widgets/course_card.dart';

class CoursesPage extends StatefulWidget {
  const CoursesPage({super.key});

  @override
  State<CoursesPage> createState() => _CoursesPageState();
}

class _CoursesPageState extends State<CoursesPage> {
  final _scrollController = ScrollController();

  UserRole _currentRole() {
    final authState = context.read<AuthCubit>().state;
    if (authState is AuthAuthenticated) return authState.user.role;
    return UserRole.learner;
  }

  @override
  void initState() {
    super.initState();
    context.read<CourseCubit>().getCourses(role: _currentRole());
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<CourseCubit>().loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          'Courses',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: const Color(0xFF1565C0),
        foregroundColor: Colors.white,
      ),
      body: BlocBuilder<CourseCubit, CourseState>(
        builder: (context, state) {
          return switch (state) {
            CourseInitial() => const SizedBox.shrink(),
            CourseLoading() => const AppLoadingWidget(message: 'Loading courses...'),
            CourseLoaded(:final courses, :final hasReachedMax) =>
              _buildCourseList(courses, hasReachedMax),
            CourseError(:final message) => Center(
                child: AppErrorWidget(
                  message: message,
                  onRetry: () => context.read<CourseCubit>().getCourses(),
                ),
              ),
          };
        },
      ),
      bottomNavigationBar: AppBottomNav(
        currentIndex: 1,
        role: _currentRole(),
        onTap: (index) {
          switch (index) {
            case 0:
              context.pop();
              break;
            case 1:
              break;
            case 2:
              context.push('/profile');
              break;
          }
        },
      ),
    );
  }

  Widget _buildCourseList(List<CourseEntity> courses, bool hasReachedMax) {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: courses.length + (hasReachedMax ? 0 : 1),
      itemBuilder: (context, index) {
        if (index >= courses.length) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        return CourseCard(course: courses[index]);
      },
    );
  }
}
