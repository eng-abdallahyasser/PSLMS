import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lms/core/widgets/app_widgets.dart';
import 'package:lms/features/learner/instructors/presentation/cubit/instructor_cubit.dart';

class InstructorProfilePage extends StatefulWidget {
  final String instructorId;

  const InstructorProfilePage({super.key, required this.instructorId});

  @override
  State<InstructorProfilePage> createState() => _InstructorProfilePageState();
}

class _InstructorProfilePageState extends State<InstructorProfilePage> {
  @override
  void initState() {
    super.initState();
    context.read<InstructorCubit>().getInstructorProfile(widget.instructorId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Instructor Profile')),
      body: BlocBuilder<InstructorCubit, InstructorState>(
        builder: (context, state) {
          return switch (state) {
            InstructorInitial() => const SizedBox.shrink(),
            InstructorProfileLoading() => const AppLoadingWidget(),
            InstructorProfileLoaded(:final instructor) => _buildProfile(instructor),
            InstructorProfileError(:final message) =>
              AppErrorWidget(message: message, onRetry: () => context.read<InstructorCubit>().getInstructorProfile(widget.instructorId)),
            _ => const SizedBox.shrink(),
          };
        },
      ),
    );
  }

  Widget _buildProfile(dynamic profile) {
    return RefreshIndicator(
      onRefresh: () => context.read<InstructorCubit>().getInstructorProfile(widget.instructorId),
      child: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Center(
            child: CircleAvatar(
              radius: 50,
              backgroundColor: Colors.blue[100],
              child: Text(
                profile.fullName.isNotEmpty ? profile.fullName[0].toUpperCase() : '?',
                style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: Text(profile.fullName, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
          ),
          if (profile.bio != null) ...[
            const SizedBox(height: 8),
            Center(child: Text(profile.bio!, textAlign: TextAlign.center, style: TextStyle(color: Colors.grey[600]))),
          ],
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                context.read<InstructorCubit>().requestToJoin(widget.instructorId);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Join request sent!'), backgroundColor: Colors.green),
                );
              },
              icon: const Icon(Icons.person_add),
              label: const Text('Request to Join'),
            ),
          ),
        ],
      ),
    );
  }
}
