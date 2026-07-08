import 'package:equatable/equatable.dart';
import 'package:lms/features/shared/domain/entities/content_entity.dart';
import 'package:lms/features/shared/domain/entities/course_entity.dart';

class MyCourseDetailEntity extends Equatable {
  final CourseEntity course;
  final List<ContentEntity> contents;

  const MyCourseDetailEntity({
    required this.course,
    required this.contents,
  });

  @override
  List<Object?> get props => [course, contents];
}
