import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lms/core/widgets/app_widgets.dart';
import 'package:lms/features/shared/domain/entities/content_entity.dart';
import 'package:lms/features/learner/my_courses/content/presentation/cubit/learner_content_cubit.dart';

class MyCourseDetailPage extends StatefulWidget {

  const MyCourseDetailPage({super.key, required this.courseId});
  final String courseId;

  @override
  State<MyCourseDetailPage> createState() => _MyCourseDetailPageState();
}

class _MyCourseDetailPageState extends State<MyCourseDetailPage> {
  @override
  void initState() {
    super.initState();
    context.read<LearnerContentCubit>().getContents(widget.courseId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Course Content')),
      body: BlocBuilder<LearnerContentCubit, LearnerContentState>(
        builder: (context, state) {
          return switch (state) {
            LearnerContentInitial() => const SizedBox.shrink(),
            LearnerContentLoading() => const AppLoadingWidget(),
            LearnerContentLoaded(:final contents) => _buildList(contents),
            LearnerContentError(:final message) =>
              AppErrorWidget(message: message, onRetry: () => context.read<LearnerContentCubit>().getContents(widget.courseId)),
          _ => const SizedBox.shrink(),
          };
        },
      ),
    );
  }

  Widget _buildList(List<ContentEntity> contents) {
    if (contents.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.folder_open, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text('No content available yet', style: TextStyle(fontSize: 16, color: Colors.grey[600])),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),      itemCount: contents.length,
        itemBuilder: (context, index) {
        final item = contents[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: const Icon(Icons.play_circle, color: Colors.blue),
            title: Text(item.title),
            trailing: Icon(Icons.lock_open, size: 18, color: Colors.green[400]),
          ),
        );
      },
    );
  }
}
