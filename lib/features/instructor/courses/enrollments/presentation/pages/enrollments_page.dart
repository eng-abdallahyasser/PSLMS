import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lms/core/widgets/app_widgets.dart';
import 'package:lms/features/shared/domain/entities/enrollment_entity.dart';
import 'package:lms/features/instructor/courses/enrollments/presentation/cubit/enrollment_cubit.dart';

class EnrollmentsPage extends StatefulWidget {

  const EnrollmentsPage({super.key, required this.courseId});
  final String courseId;

  @override
  State<EnrollmentsPage> createState() => _EnrollmentsPageState();
}

class _EnrollmentsPageState extends State<EnrollmentsPage> {
  @override
  void initState() {
    super.initState();
    context.read<EnrollmentCubit>().getEnrollments(widget.courseId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Enrollments'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add),
            tooltip: 'Invite Learner',
            onPressed: () => _showInviteDialog(context),
          ),
        ],
      ),
      body: BlocConsumer<EnrollmentCubit, EnrollmentState>(
        listener: (context, state) {
          if (state is EnrollmentActionSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
              ),
            );
            // Refresh list
            context.read<EnrollmentCubit>().getEnrollments(widget.courseId);
          }
          if (state is EnrollmentError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          return switch (state) {
            EnrollmentInitial() => const SizedBox.shrink(),
            EnrollmentLoading() => const AppLoadingWidget(message: 'Loading enrollments...'),
            EnrollmentLoaded(:final enrollments) =>
              _buildEnrollmentList(enrollments),
            EnrollmentActionSuccess() =>
              const AppLoadingWidget(message: 'Processing...'),
            EnrollmentError(:final message) => AppErrorWidget(
                message: message,
                onRetry: () =>
                    context.read<EnrollmentCubit>().getEnrollments(widget.courseId),
              ),
          };
        },
      ),
    );
  }

  Widget _buildEnrollmentList(List<EnrollmentEntity> enrollments) {
    if (enrollments.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.people_outline, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No enrollments yet',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              'Invite learners or wait for enrollment requests',
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        await context.read<EnrollmentCubit>().getEnrollments(widget.courseId);
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: enrollments.length,
        itemBuilder: (context, index) {
          final enrollment = enrollments[index];
          return _buildEnrollmentCard(enrollment);
        },
      ),
    );
  }

  Widget _buildEnrollmentCard(EnrollmentEntity enrollment) {
    final learnerName = enrollment.learnerFirstName ?? 'Unknown';
    final learnerEmail = enrollment.learnerEmail ?? 'No email';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  child: Text(
                    learnerName.isNotEmpty
                        ? learnerName[0].toUpperCase()
                        : '?',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        learnerName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        learnerEmail,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                _buildStatusChip(enrollment.status),
              ],
            ),
            if (enrollment.status == EnrollmentStatus.pending) ...[
              const Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton.icon(
                    onPressed: () {
                      context.read<EnrollmentCubit>().respondToEnrollment(
                            enrollment.id,
                            'REJECTED',
                          );
                    },
                    icon: const Icon(Icons.close, size: 18),
                    label: const Text('Reject'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: () {
                      context.read<EnrollmentCubit>().respondToEnrollment(
                            enrollment.id,
                            'APPROVED',
                          );
                    },
                    icon: const Icon(Icons.check, size: 18),
                    label: const Text('Approve'),
                  ),
                ],
              ),
            ],
            if (enrollment.status != EnrollmentStatus.pending) ...[
              const Divider(),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: () {
                    context.read<EnrollmentCubit>().removeEnrollment(
                          enrollment.id,
                        );
                  },
                  icon: const Icon(Icons.remove_circle_outline,
                      size: 18, color: Colors.red),
                  label: const Text(
                    'Remove',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(EnrollmentStatus status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _statusColor(status).withAlpha(26),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status.value,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: _statusColor(status),
        ),
      ),
    );
  }

  Color _statusColor(EnrollmentStatus status) {
    return switch (status) {
      EnrollmentStatus.pending => Colors.orange,
      EnrollmentStatus.approved => Colors.green,
      EnrollmentStatus.rejected => Colors.red,
    };
  }

  void _showInviteDialog(BuildContext context) {
    final emailController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Invite Learner'),
        content: AppTextField(
          label: 'Email address',
          hint: 'learner@example.com',
          controller: emailController,
          keyboardType: TextInputType.emailAddress,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final email = emailController.text.trim();
              if (email.isNotEmpty) {
                context.read<EnrollmentCubit>().inviteLearner(
                      widget.courseId,
                      email,
                    );
                Navigator.of(ctx).pop();
              }
            },
            child: const Text('Send Invite'),
          ),
        ],
      ),
    );
  }
}
