import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:lms/core/widgets/app_widgets.dart';
import 'package:lms/features/learner/instructors/domain/entities/instructor_profile_entity.dart';
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
      body: BlocConsumer<InstructorCubit, InstructorState>(
        listener: (context, state) {
          switch (state) {
            case InstructorProfileLoaded(:final joinMessage, :final isJoinRequestInProgress)
                when joinMessage != null && !isJoinRequestInProgress:
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(
                  SnackBar(content: Text(joinMessage), backgroundColor: joinMessage == 'Join request sent!' ? Colors.green : Colors.red),
                );
            case InstructorActionSuccess(:final message):
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(
                  SnackBar(content: Text(message), backgroundColor: Colors.green),
                );
            case InstructorActionError(:final message):
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(
                  SnackBar(content: Text(message), backgroundColor: Colors.red),
                );
            default:
              break;
          }
        },
        builder: (context, state) {
          return switch (state) {
            InstructorInitial() => const SizedBox.shrink(),
            InstructorProfileLoading() => const AppLoadingWidget(),
            InstructorProfileLoaded(:final instructor, :final isJoinRequestInProgress) =>
              _buildProfile(instructor, isJoining: isJoinRequestInProgress),
            InstructorProfileError(:final message) =>
              AppErrorWidget(message: message, onRetry: () => context.read<InstructorCubit>().getInstructorProfile(widget.instructorId)),
            _ => const SizedBox.shrink(),
          };
        },
      ),
    );
  }

  Widget _buildProfile(InstructorProfileEntity profile, {required bool isJoining}) {
    final theme = Theme.of(context);

    return RefreshIndicator(
      onRefresh: () => context.read<InstructorCubit>().getInstructorProfile(widget.instructorId),
      child: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          // Avatar & Name Section
          Center(
            child: CircleAvatar(
              radius: 50,
              backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
              child: Text(
                profile.fullName.isNotEmpty ? profile.fullName[0].toUpperCase() : '?',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: theme.colorScheme.primary),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: Text(
              profile.fullName,
              style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          if (profile.bio != null) ...[
            const SizedBox(height: 8),
            Center(
              child: Text(
                profile.bio!,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[600], fontSize: 15),
              ),
            ),
          ],
          const SizedBox(height: 24),

          // Contact Info Card
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: Colors.grey.shade200),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                children: [
                  if (profile.email != null)
                    _infoRow(Icons.email_outlined, 'Email', profile.email!),
                  if (profile.email != null && profile.mobileNumber != null)
                    const Divider(height: 1),
                  if (profile.mobileNumber != null)
                    _infoRow(Icons.phone_outlined, 'Phone', profile.mobileNumber!),
                  if (profile.mobileNumber != null && profile.createdAt != null)
                    const Divider(height: 1),
                  if (profile.createdAt != null)
                    _infoRow(
                      Icons.calendar_today_outlined,
                      'Joined',
                      DateFormat('MMM d, yyyy').format(profile.createdAt!),
                    ),
                ],
              ),
            ),
          ),

          // Stats Row
          if (profile.courseCount != null || profile.studentCount != null) ...[
            const SizedBox(height: 16),
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: Colors.grey.shade200),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    if (profile.courseCount != null)
                      Expanded(child: _statTile(Icons.menu_book_rounded, '${profile.courseCount}', 'Courses')),
                    if (profile.courseCount != null && profile.studentCount != null)
                      SizedBox(
                        height: 40,
                        child: VerticalDivider(width: 1, color: Colors.grey.shade300),
                      ),
                    if (profile.studentCount != null)
                      Expanded(child: _statTile(Icons.people_outline, '${profile.studentCount}', 'Students')),
                  ],
                ),
              ),
            ),
          ],

          const SizedBox(height: 32),

          // Join Button
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: isJoining
                  ? null
                  : () => context.read<InstructorCubit>().requestToJoin(widget.instructorId),
              icon: isJoining
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.person_add),
              label: Text(isJoining ? 'Sending Request...' : 'Request to Join'),
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[500]),
      ),
              const SizedBox(height: 2),
              Text(value, style: const TextStyle(fontSize: 15)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statTile(IconData icon, String value, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        children: [
          Icon(icon, size: 24, color: Colors.grey[600]),
          const SizedBox(height: 6),
          Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          Text(label, style: TextStyle(fontSize: 13, color: Colors.grey[500]),
        ),
        ],
      ),
    );
  }
}
