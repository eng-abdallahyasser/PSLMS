import 'package:flutter/material.dart';
import 'package:lms/core/theme/app_theme.dart';
import 'package:lms/features/shared/domain/entities/course_entity.dart';

class CourseCard extends StatelessWidget {
  final CourseEntity course;

  const CourseCard({super.key, required this.course});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          // TODO: Navigate to course detail
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: course.thumbnailUrl != null
                  ? Image.network(
                      course.thumbnailUrl!,
                      height: 160,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => _buildPlaceholder(),
                    )
                  : _buildPlaceholder(),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Difficulty Badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _difficultyColor.withAlpha(26),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      course.difficulty.toUpperCase(),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: _difficultyColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Title
                  Text(
                    course.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  // Instructor
                  if (course.instructor != null)
                    Text(
                      course.instructor!.fullName,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  const SizedBox(height: 12),
                  // Stats Row
                  Row(
                    children: [
                      _buildStat(
                        Icons.menu_book,
                        '${course.lessonCount} lessons',
                      ),
                      const SizedBox(width: 16),
                      _buildStat(
                        Icons.access_time,
                        '${course.durationMinutes} min',
                      ),
                      if (course.isEnrolled) ...[
                        const Spacer(),
                        _buildStat(
                          Icons.check_circle,
                          '${course.progress.toStringAsFixed(0)}%',
                          color: AppTheme.successColor,
                        ),
                      ],
                    ],
                  ),
                  // Progress Bar
                  if (course.isEnrolled && course.progress > 0) ...[
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: course.progress / 100,
                        backgroundColor: Colors.grey[200],
                        color: AppTheme.primaryColor,
                        minHeight: 6,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      height: 160,
      color: Colors.grey[200],
      child: Center(
        child: Icon(
          Icons.school,
          size: 48,
          color: Colors.grey[400],
        ),
      ),
    );
  }

  Widget _buildStat(IconData icon, String label, {Color? color}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: color ?? Colors.grey[600]),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: color ?? Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Color get _difficultyColor {
    return switch (course.difficulty.toLowerCase()) {
      'beginner' => AppTheme.successColor,
      'intermediate' => AppTheme.warningColor,
      'advanced' => AppTheme.errorColor,
      _ => AppTheme.textSecondary,
    };
  }
}
