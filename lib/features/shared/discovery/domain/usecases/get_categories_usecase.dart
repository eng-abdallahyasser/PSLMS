import 'package:dartz/dartz.dart';
import 'package:lms/core/errors/failures.dart';
import 'package:lms/features/shared/discovery/domain/entities/category_entity.dart';
import 'package:lms/features/shared/discovery/domain/repositories/discovery_repository.dart';

class GetCategoriesUseCase {
  GetCategoriesUseCase(this.repository);

  final DiscoveryRepository repository;

  Future<Either<Failure, List<CategoryEntity>>> call() {
    return repository.getCategories();
  }
}
