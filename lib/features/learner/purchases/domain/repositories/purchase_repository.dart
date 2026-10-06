import 'package:dartz/dartz.dart';
import 'package:lms/core/errors/failures.dart';
import 'package:lms/features/learner/purchases/domain/entities/purchase_result.dart';

abstract class PurchaseRepository {
  Future<Either<Failure, PurchaseResult>> purchaseCourse(String courseId);
}
