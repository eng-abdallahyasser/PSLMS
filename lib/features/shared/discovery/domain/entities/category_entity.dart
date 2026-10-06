import 'package:equatable/equatable.dart';

class CategoryEntity extends Equatable {
  const CategoryEntity({
    required this.id,
    required this.name,
    this.nameAr,
    this.slug,
  });

  final String id;
  final String name;
  final String? nameAr;
  final String? slug;

  @override
  List<Object?> get props => [id, name, nameAr, slug];
}
