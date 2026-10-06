import 'package:lms/core/network/api_client.dart';
import 'package:lms/features/shared/universities/data/models/university_model.dart';

class UniversitiesRemoteDataSource {
  UniversitiesRemoteDataSource({required this.apiClient});

  final ApiClient apiClient;

  Future<List<UniversityModel>> getUniversities() async {
    final data = await apiClient.getList('/public/universities');
    return data
        .whereType<Map<String, dynamic>>()
        .map(UniversityModel.fromJson)
        .toList();
  }
}
