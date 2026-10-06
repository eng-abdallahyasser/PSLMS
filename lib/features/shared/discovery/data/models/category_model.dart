import 'package:lms/features/shared/discovery/domain/entities/category_entity.dart';

class CategoryModel extends CategoryEntity {
  const CategoryModel({
    required super.id,
    required super.name,
    super.nameAr,
    super.slug,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? json['title'] as String? ?? '',
      nameAr: json['nameAr'] as String? ?? json['name_ar'] as String?,
      slug: json['slug'] as String?,
    );
  }

  CategoryEntity toEntity() {
    return CategoryEntity(id: id, name: name, nameAr: nameAr, slug: slug);
  }
}
