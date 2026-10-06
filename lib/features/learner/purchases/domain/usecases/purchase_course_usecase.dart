import 'package:dartz/dartz.dart';
import 'package:lms/core/errors/failures.dart';
import 'package:lms/features/learner/purchases/domain/entities/purchase_result.dart';
import 'package:lms/features/learner/purchases/domain/repositories/purchase_repository.dart';

class PurchaseCourseUseCase {
  PurchaseCourseUseCase(this.repository);

  final PurchaseRepository repository;

  Future<Either<Failure, PurchaseResult>> call(String courseId) {
    return repository.purchaseCourse(courseId);
  }
}
