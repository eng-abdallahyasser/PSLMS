import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lms/core/widgets/app_widgets.dart';
import 'package:lms/features/instructor/courses/presentation/cubit/course_cubit.dart';
import 'package:lms/features/instructor/students/domain/entities/student_entity.dart';
import 'package:lms/features/instructor/students/presentation/cubit/student_cubit.dart';

class StudentsPage extends StatefulWidget {
  const StudentsPage({super.key});

  @override
  State<StudentsPage> createState() => _StudentsPageState();
}

class _StudentsPageState extends State<StudentsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    context.read<StudentCubit>().getStudents();
    context.read<StudentCubit>().getRequests();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Students'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add),
            tooltip: 'Invite Student',
            onPressed: () => _showInviteDialog(context),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white.withAlpha(170),
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal, fontSize: 15),
          tabs: const [
            Tab(text: 'Active'),
            Tab(text: 'Invited'),
            Tab(text: 'Requests'),
          ],
        ),
      ),
      body: BlocListener<StudentCubit, StudentState>(
        listener: (context, state) {
          if (state is StudentActionSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
              ),
            );
          }
          if (state is StudentError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildStudentTab(status: 'active'),
            _buildStudentTab(status: 'invited'),
            _buildRequestsTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildStudentTab({String? status}) {
    return BlocBuilder<StudentCubit, StudentState>(
      builder: (context, state) {
        return switch (state) {
          StudentInitial() => const SizedBox.shrink(),
          StudentLoading() => const AppLoadingWidget(),
          StudentsLoaded(:final students) => _buildStudentList(students, status),
          StudentActionSuccess() => const AppLoadingWidget(),
          StudentError(:final message) => AppErrorWidget(
              message: message,
              onRetry: () => context.read<StudentCubit>().getStudents(),
            ),
        };
      },
    );
  }

  Widget _buildRequestsTab() {
    return BlocBuilder<StudentCubit, StudentState>(
      builder: (context, state) {
        return switch (state) {
          StudentInitial() => const SizedBox.shrink(),
          StudentLoading() => const AppLoadingWidget(),
          StudentsLoaded(:final requests) => _buildRequestsList(requests),
          StudentActionSuccess() => const AppLoadingWidget(),
          StudentError(:final message) => AppErrorWidget(
              message: message,
              onRetry: () => context.read<StudentCubit>().getRequests(),
            ),
        };
      },
    );
  }

  Widget _buildStudentList(List<StudentEntity> students, String? status) {
    final filtered = students.where((s) {
      if (status == null) return true;
      return s.status.name == status;
    }).toList();

    if (filtered.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.people_outline, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text('No students found',
                style: TextStyle(fontSize: 16, color: Colors.grey[600])),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        await context.read<StudentCubit>().getStudents();
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: filtered.length,
        itemBuilder: (context, index) {
          final student = filtered[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.blue[100],
                child: Text(
                  student.fullName.isNotEmpty
                      ? student.fullName[0].toUpperCase()
                      : '?',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              title: Text(student.fullName),
              subtitle: student.email != null ? Text(student.email!) : null,
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.book, color: Colors.blue),
                    tooltip: 'Assign Courses',
                    onPressed: () => _showAssignCoursesDialog(context, student),
                  ),
                  IconButton(
                    icon: Icon(Icons.remove_circle_outline, color: Colors.red[400]),
                    tooltip: 'Remove',
                    onPressed: () => _confirmRemove(context, student),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildRequestsList(List<StudentEntity> requests) {
    if (requests.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.inbox_outlined, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text('No pending requests',
                style: TextStyle(fontSize: 16, color: Colors.grey[600])),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        await context.read<StudentCubit>().getRequests();
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: requests.length,
        itemBuilder: (context, index) {
          final request = requests[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.orange[100],
                child: Text(
                  request.fullName.isNotEmpty
                      ? request.fullName[0].toUpperCase()
                      : '?',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              title: Text(request.fullName),
              subtitle: request.email != null ? Text(request.email!) : null,
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.check_circle, color: Colors.green),
                    tooltip: 'Approve',
                    onPressed: () {
                      context.read<StudentCubit>().respondToRequest(
                            request.id,
                            'approve',
                          );
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.cancel, color: Colors.red),
                    tooltip: 'Decline',
                    onPressed: () {
                      context.read<StudentCubit>().respondToRequest(
                            request.id,
                            'decline',
                          );
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showInviteDialog(BuildContext context) {
    final emailController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Invite Student'),
        content: AppTextField(
          label: 'Email',
          hint: 'student@example.com',
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
                context.read<StudentCubit>().inviteStudent(email);
                Navigator.of(ctx).pop();
              }
            },
            child: const Text('Invite'),
          ),
        ],
      ),
    );
  }

  Future<void> _showAssignCoursesDialog(
      BuildContext context, StudentEntity student) async {
    // Load the instructor's courses
    context.read<CourseCubit>().getCourses();
    // Load current assignments
    final assignedIds =
        await context.read<StudentCubit>().getAssignments(student.id);

    if (!context.mounted) return;

    showDialog(
      context: context,
      builder: (ctx) => _AssignCoursesDialog(
        student: student,
        initiallyAssignedIds: assignedIds,
      ),
    );
  }

  void _confirmRemove(BuildContext context, StudentEntity student) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remove Student'),
        content: Text('Remove "${student.fullName}" from your students?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              context.read<StudentCubit>().removeStudent(student.id);
              Navigator.of(ctx).pop();
            },
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }
}

class _AssignCoursesDialog extends StatefulWidget {

  const _AssignCoursesDialog({
    required this.student,
    required this.initiallyAssignedIds,
  });
  final StudentEntity student;
  final List<String> initiallyAssignedIds;

  @override
  State<_AssignCoursesDialog> createState() => _AssignCoursesDialogState();
}

class _AssignCoursesDialogState extends State<_AssignCoursesDialog> {
  late Set<String> _selectedIds;

  @override
  void initState() {
    super.initState();
    _selectedIds = Set.from(widget.initiallyAssignedIds);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Assign Courses — ${widget.student.fullName}'),
      content: SizedBox(
        width: double.maxFinite,
        child: BlocBuilder<CourseCubit, CourseState>(
          builder: (context, state) {
            if (state is CourseLoading) {
              return const SizedBox(
                height: 200,
                child: Center(child: CircularProgressIndicator()),
              );
            }
            if (state is CourseLoaded) {
              final courses = state.courses;
              if (courses.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.all(32),
                  child: Center(
                    child: Text('No courses available.\nCreate some courses first.'),
                  ),
                );
              }
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Select courses to assign:'),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 300,
                    child: ListView(
                      children: courses.map((course) {
                        final isSelected = _selectedIds.contains(course.id);
                        return CheckboxListTile(
                          title: Text(course.title),
                          subtitle: Text(
                                  course.description,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                          value: isSelected,
                          onChanged: (checked) {
                            setState(() {
                              if (checked == true) {
                                _selectedIds.add(course.id);
                              } else {
                                _selectedIds.remove(course.id);
                              }
                            });
                          },
                        );
                      }).toList(),
                    ),
                  ),
                ],
              );
            }
            return const SizedBox(
              height: 200,
              child: Center(child: Text('Failed to load courses')),
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            context
                .read<StudentCubit>()
                .assignCourses(widget.student.id, _selectedIds.toList());
            Navigator.of(context).pop();
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}
