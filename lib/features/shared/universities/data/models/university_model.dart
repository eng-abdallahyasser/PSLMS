class UniversityModel {
  final String id;
  final String name;
  final String? nameAr;
  final List<FacultyModel> faculties;

  const UniversityModel({
    required this.id,
    required this.name,
    this.nameAr,
    this.faculties = const [],
  });

  factory UniversityModel.fromJson(Map<String, dynamic> json) {
    final facultiesJson = json['faculties'] as List<dynamic>? ?? const [];
    return UniversityModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      nameAr: json['nameAr'] as String?,
      faculties: facultiesJson
          .whereType<Map<String, dynamic>>()
          .map(FacultyModel.fromJson)
          .toList(),
    );
  }
}

class FacultyModel {
  final String name;
  final String? nameAr;
  final List<DepartmentModel> departments;
  final List<YearModel> years;

  const FacultyModel({
    required this.name,
    this.nameAr,
    this.departments = const [],
    this.years = const [],
  });

  factory FacultyModel.fromJson(Map<String, dynamic> json) {
    final departmentsJson = json['departments'] as List<dynamic>? ?? const [];
    final yearsJson = json['years'] as List<dynamic>? ?? const [];
    return FacultyModel(
      name: json['name'] as String? ?? '',
      nameAr: json['nameAr'] as String?,
      departments: departmentsJson
          .whereType<Map<String, dynamic>>()
          .map(DepartmentModel.fromJson)
          .toList(),
      years: yearsJson
          .whereType<Map<String, dynamic>>()
          .map(YearModel.fromJson)
          .toList(),
    );
  }
}

class DepartmentModel {
  final String name;
  final String? nameAr;

  const DepartmentModel({required this.name, this.nameAr});

  factory DepartmentModel.fromJson(Map<String, dynamic> json) {
    return DepartmentModel(
      name: json['name'] as String? ?? '',
      nameAr: json['nameAr'] as String?,
    );
  }
}

class YearModel {
  final String name;
  final String? nameAr;

  const YearModel({required this.name, this.nameAr});

  factory YearModel.fromJson(Map<String, dynamic> json) {
    return YearModel(
      name: json['name'] as String? ?? '',
      nameAr: json['nameAr'] as String?,
    );
  }
}
