import 'package:lms/features/shared/domain/entities/content_entity.dart';

class ContentModel extends ContentEntity {

  factory ContentModel.fromEntity(ContentEntity entity) {
    return ContentModel(
      id: entity.id,
      title: entity.title,
      description: entity.description,
      contentType: entity.contentType,
      size: entity.size,
      url: entity.url,
      courseId: entity.courseId,
      createdAt: entity.createdAt,
    );
  }
  const ContentModel({
    required super.id,
    required super.title,
    super.description,
    super.contentType,
    super.size,
    required super.url,
    super.courseId,
    super.createdAt,
  });

  factory ContentModel.fromJson(Map<String, dynamic> json) {
    return ContentModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      contentType: json['contentType'] != null
          ? ContentType.fromString(json['contentType'] as String)
          : ContentType.document,
      size: (json['size'] as num?)?.toInt() ?? 0,
      url: json['url'] as String,
      courseId: json['courseId'] as String? ?? json['course_id'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'contentType': contentType.value,
      'size': size,
      'url': url,
      'course_id': courseId,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  ContentEntity toEntity() {
    return ContentEntity(
      id: id,
      title: title,
      description: description,
      contentType: contentType,
      size: size,
      url: url,
      courseId: courseId,
      createdAt: createdAt,
    );
  }
}
