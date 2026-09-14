import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lms/core/theme/app_theme.dart';
import 'package:lms/core/widgets/app_widgets.dart';
import 'package:lms/features/learner/instructors/domain/entities/invitation_info_entity.dart';
import 'package:lms/features/learner/instructors/presentation/cubit/instructor_cubit.dart';

class InvitationPage extends StatefulWidget {
  const InvitationPage({super.key, required this.token});

  final String token;

  @override
  State<InvitationPage> createState() => _InvitationPageState();
}

class _InvitationPageState extends State<InvitationPage> {
  @override
  void initState() {
    super.initState();
    if (widget.token.isNotEmpty) {
      context.read<InstructorCubit>().getInvitationInfo(widget.token);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Invitation'),
        centerTitle: true,
      ),
      body: BlocBuilder<InstructorCubit, InstructorState>(
        builder: (context, state) {
          return switch (state) {
            InstructorInitial() => _buildMissingToken(),
            InvitationInfoLoading() =>
              const AppLoadingWidget(message: 'Loading invitation...'),
            InvitationInfoError(:final message) => AppErrorWidget(
                message: message,
                onRetry: () => context.read<InstructorCubit>()
                    .getInvitationInfo(widget.token),
              ),
            InvitationInfoLoaded(:final info) => _buildInfo(info),
            InstructorActionSuccess(:final message) => _buildSuccess(message),
            _ => const SizedBox.shrink(),
          };
        },
      ),
    );
  }

  Widget _buildInfo(InvitationInfoEntity info) {
    if (info.isExpired) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.timer_off,
                size: 64,
                color: AppTheme.warningColor.withAlpha(180),
              ),
              const SizedBox(height: 16),
              const Text(
                'This invitation has expired.',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Text(
                'Please ask the instructor to send a new invitation.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      );
    }
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  AppAvatar(
                    initials: _initials(info.instructorName),
                    radius: 32,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    info.instructorName,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (info.instructorEmail != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      info.instructorEmail!,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                  const SizedBox(height: 16),
                  Text(
                    '${info.instructorName} has invited you to become one of their students.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 15, height: 1.4),
                  ),
                  if (info.message != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      '"${info.message}"',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        fontStyle: FontStyle.italic,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          AppPrimaryButton(
            label: 'Accept Invitation',
            icon: Icons.check_circle_outline,
            onPressed: () =>
                context.read<InstructorCubit>().acceptInvitation(widget.token),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccess(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.check_circle,
              size: 72,
              color: AppTheme.successColor,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 24),
            AppPrimaryButton(
              label: 'Go to My Instructors',
              icon: Icons.school,
              onPressed: () => context.go('/my-instructors'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMissingToken() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.link_off, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            const Text(
              'Invalid invitation link',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              'This invitation link is missing its token.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  String _initials(String name) {
    final parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((p) => p.isNotEmpty)
        .toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }
}