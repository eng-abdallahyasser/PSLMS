import 'package:equatable/equatable.dart';

enum ContentType {
  video,
  document,
  pdf;

  String get value {
    switch (this) {
      case ContentType.video:
        return 'VIDEO';
      case ContentType.document:
        return 'DOCUMENT';
      case ContentType.pdf:
        return 'PDF';
    }
  }

  static ContentType fromString(String value) {
    switch (value.toUpperCase()) {
      case 'VIDEO':
        return ContentType.video;
      case 'DOCUMENT':
        return ContentType.document;
      case 'PDF':
        return ContentType.pdf;
      default:
        return ContentType.document;
    }
  }
}

class ContentEntity extends Equatable {

  const ContentEntity({
    required this.id,
    required this.title,
    this.description,
    this.contentType = ContentType.document,
    this.size = 0,
    required this.url,
    this.courseId,
    this.createdAt,
  });
  final String id;
  final String title;
  final String? description;
  final ContentType contentType;
  final int size;
  final String url;
  final String? courseId;
  final DateTime? createdAt;

  /// Human-readable file size string (e.g. "1.5 MB", "240 KB").
  String get formattedSize {
    if (size < 1024) return '$size B';
    if (size < 1024 * 1024) return '${(size / 1024).toStringAsFixed(1)} KB';
    return '${(size / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        contentType,
        size,
        url,
        courseId,
        createdAt,
      ];
}
