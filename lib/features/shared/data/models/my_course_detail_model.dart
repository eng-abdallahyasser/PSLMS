import 'package:lms/features/shared/data/models/content_model.dart';
import 'package:lms/features/shared/data/models/course_model.dart';
import 'package:lms/features/shared/domain/entities/my_course_detail_entity.dart';

class MyCourseDetailModel {
  final CourseModel course;
  final List<ContentModel> contents;

  const MyCourseDetailModel({
    required this.course,
    required this.contents,
  });

  factory MyCourseDetailModel.fromJson(Map<String, dynamic> json) {
    return MyCourseDetailModel(
      course: CourseModel.fromJson(json),
      contents: (json['contents'] as List<dynamic>?)
              ?.map((e) => ContentModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  MyCourseDetailEntity toEntity() {
    return MyCourseDetailEntity(
      course: course.toEntity(),
      contents: contents.map((c) => c.toEntity()).toList(),
    );
  }
}
