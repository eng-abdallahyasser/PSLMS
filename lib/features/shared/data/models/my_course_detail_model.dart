import 'package:lms/features/shared/data/models/content_model.dart';
import 'package:lms/features/shared/data/models/course_model.dart';
import 'package:lms/features/shared/domain/entities/my_course_detail_entity.dart';

class MyCourseDetailModel {

  const MyCourseDetailModel({
    required this.course,
    required this.contents,
  });

  factory MyCourseDetailModel.fromJson(Map<String, dynamic> json) {
    // Detail may be wrapped in a purchase record: `{...purchase, course: {...}}`.
    final nested = json['course'];
    final courseJson = nested is Map<String, dynamic> ? nested : json;
    return MyCourseDetailModel(
      course: CourseModel.fromJson(courseJson),
      contents: (json['contents'] as List<dynamic>? ??
              courseJson['contents'] as List<dynamic>?)
          ?.map((e) => ContentModel.fromJson(e as Map<String, dynamic>))
          .toList() ??
          [],
    );
  }
  final CourseModel course;
  final List<ContentModel> contents;

  MyCourseDetailEntity toEntity() {
    return MyCourseDetailEntity(
      course: course.toEntity(),
      contents: contents.map((c) => c.toEntity()).toList(),
    );
  }
}
