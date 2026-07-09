import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lms/core/widgets/app_widgets.dart';
import 'package:lms/features/learner/my_courses/presentation/cubit/my_courses_cubit.dart';

class MyCoursesPage extends StatefulWidget {
  const MyCoursesPage({super.key});

  @override
  State<MyCoursesPage> createState() => _MyCoursesPageState();
}

class _MyCoursesPageState extends State<MyCoursesPage> {
  @override
  void initState() {
    super.initState();
    context.read<MyCoursesCubit>().getMyCourses();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Courses')),
      body: BlocBuilder<MyCoursesCubit, MyCoursesState>(
        builder: (context, state) {
          return switch (state) {
            MyCoursesInitial() => const SizedBox.shrink(),
            MyCoursesLoading() => const AppLoadingWidget(),
            MyCoursesLoaded(:final courses) => _buildList(courses),
            MyCoursesError(:final message) =>
              AppErrorWidget(message: message, onRetry: () => context.read<MyCoursesCubit>().getMyCourses()),
          _ => const SizedBox.shrink(),
          };
        },
      ),
    );
  }

  Widget _buildList(List courses) {
    if (courses.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.menu_book, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text('No enrolled courses yet', style: TextStyle(fontSize: 16, color: Colors.grey[600])),
          ],
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: () => context.read<MyCoursesCubit>().getMyCourses(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: courses.length,
        itemBuilder: (context, index) {
          final course = courses[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.blue[100],
                child: const Icon(Icons.school, color: Colors.blue),
              ),
              title: Text(course.title),
              subtitle: course.description != null
                  ? Text(course.description!, maxLines: 1, overflow: TextOverflow.ellipsis)
                  : null,
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push('/my-courses/${course.id}'),
            ),
          );
        },
      ),
    );
  }
}
