import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lms/core/errors/failures.dart';
import 'package:lms/features/instructor/storage/domain/entities/storage_entities.dart';
import 'package:lms/features/instructor/storage/domain/usecases/get_revenue_usecase.dart';
import 'package:lms/features/instructor/storage/domain/usecases/get_storage_plans_usecase.dart';
import 'package:lms/features/instructor/storage/domain/usecases/get_storage_usage_usecase.dart';
import 'package:lms/features/instructor/storage/domain/usecases/subscribe_storage_plan_usecase.dart';

sealed class StorageState extends Equatable {
  const StorageState();

  @override
  List<Object?> get props => [];
}

class StorageInitial extends StorageState {
  const StorageInitial();
}

class StorageLoading extends StorageState {
  const StorageLoading();
}

class StorageLoaded extends StorageState {
  const StorageLoaded({required this.usage, required this.plans, this.revenue});

  final StorageUsage usage;
  final List<StoragePlan> plans;
  final RevenueSummary? revenue;

  @override
  List<Object?> get props => [usage, plans, revenue];
}

class StorageSubscribeCheckout extends StorageState {
  const StorageSubscribeCheckout(this.checkoutUrl);

  final String checkoutUrl;

  @override
  List<Object?> get props => [checkoutUrl];
}

class StorageError extends StorageState {
  const StorageError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

class StorageCubit extends Cubit<StorageState> {
  StorageCubit({
    required this.getUsageUseCase,
    required this.getPlansUseCase,
    required this.subscribeUseCase,
    required this.getRevenueUseCase,
  }) : super(const StorageInitial());

  final GetStorageUsageUseCase getUsageUseCase;
  final GetStoragePlansUseCase getPlansUseCase;
  final SubscribeStoragePlanUseCase subscribeUseCase;
  final GetRevenueUseCase getRevenueUseCase;

  Future<void> load() async {
    emit(const StorageLoading());
    final usageEither = await getUsageUseCase();
    final plansEither = await getPlansUseCase();
    final revenueEither = await getRevenueUseCase();

    StorageUsage? usage;
    List<StoragePlan>? plans;
    RevenueSummary? revenue;
    Failure? failure;
    usageEither.fold((f) => failure ??= f, (v) => usage = v);
    plansEither.fold((f) => failure ??= f, (v) => plans = v);
    revenueEither.fold((f) => failure ??= f, (v) => revenue = v);

    if (failure != null) {
      emit(StorageError(_mapFailureToMessage(failure!)));
      return;
    }

    emit(
      StorageLoaded(
        usage: usage!,
        plans: plans!,
        revenue: revenue!._isEmpty ? null : revenue,
      ),
    );
  }

  Future<void> subscribe(String planId) async {
    final result = await subscribeUseCase(planId);
    result.fold(
      (failure) => emit(StorageError(_mapFailureToMessage(failure))),
      (subscribe) => emit(StorageSubscribeCheckout(subscribe.checkoutUrl)),
    );
  }

  void reset() => emit(const StorageInitial());

  String _mapFailureToMessage(Failure failure) {
    return switch (failure) {
      NetworkFailure f => f.message,
      ServerFailure f => f.message,
      AuthFailure f => f.message,
      _ => 'An unexpected error occurred',
    };
  }
}

extension on RevenueSummary {
  bool get _isEmpty =>
      totalSales == 0 &&
      grossRevenue == 0 &&
      totalCommission == 0 &&
      netRevenue == 0;
}
