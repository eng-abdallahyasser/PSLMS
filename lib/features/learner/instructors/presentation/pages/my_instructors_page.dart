import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lms/core/widgets/app_widgets.dart';
import 'package:lms/features/learner/instructors/presentation/cubit/instructor_cubit.dart';

class MyInstructorsPage extends StatefulWidget {
  const MyInstructorsPage({super.key});

  @override
  State<MyInstructorsPage> createState() => _MyInstructorsPageState();
}

class _MyInstructorsPageState extends State<MyInstructorsPage> {
  @override
  void initState() {
    super.initState();
    context.read<InstructorCubit>().getMyInstructors();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Instructors')),
      body: BlocBuilder<InstructorCubit, InstructorState>(
        builder: (context, state) {
          return switch (state) {
            InstructorInitial() => const SizedBox.shrink(),
            MyInstructorsLoading() => const AppLoadingWidget(),
            MyInstructorsLoaded(:final instructors) => _buildList(instructors),
            MyInstructorsError(:final message) =>
              AppErrorWidget(message: message, onRetry: () => context.read<InstructorCubit>().getMyInstructors()),
            _ => const SizedBox.shrink(),
          };
        },
      ),
    );
  }

  Widget _buildList(List instructors) {
    if (instructors.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.people_outline, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text('No instructors yet', style: TextStyle(fontSize: 16, color: Colors.grey[600])),
            const SizedBox(height: 8),
            Text('Search for instructors and request to join', style: TextStyle(fontSize: 14, color: Colors.grey[500])),
          ],
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: () => context.read<InstructorCubit>().getMyInstructors(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: instructors.length,
        itemBuilder: (context, index) {
          final instructor = instructors[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.green[100],
                child: Text(instructor.fullName.isNotEmpty ? instructor.fullName[0].toUpperCase() : '?'),
              ),
              title: Text(instructor.fullName),
              subtitle: instructor.bio != null ? Text(instructor.bio!, maxLines: 1, overflow: TextOverflow.ellipsis) : null,
            ),
          );
        },
      ),
    );
  }
}
