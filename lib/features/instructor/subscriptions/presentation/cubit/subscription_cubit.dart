import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lms/core/errors/failures.dart';
import 'package:lms/features/instructor/subscriptions/domain/entities/storage_addon_entity.dart';
import 'package:lms/features/instructor/subscriptions/domain/entities/subscription_entity.dart';
import 'package:lms/features/instructor/subscriptions/domain/entities/subscription_plan_entity.dart';
import 'package:lms/features/instructor/subscriptions/domain/usecases/get_subscription_usecase.dart';
import 'package:lms/features/instructor/subscriptions/domain/usecases/get_plans_usecase.dart';
import 'package:lms/features/instructor/subscriptions/domain/usecases/create_checkout_usecase.dart';
import 'package:lms/features/instructor/subscriptions/domain/usecases/create_portal_usecase.dart';
import 'package:lms/features/instructor/subscriptions/domain/usecases/choose_plan_usecase.dart';
import 'package:lms/features/instructor/subscriptions/domain/usecases/buy_storage_usecase.dart';
import 'package:lms/features/instructor/subscriptions/domain/usecases/get_storage_addons_usecase.dart';
import 'package:lms/features/instructor/subscriptions/domain/usecases/refresh_subscription_usecase.dart';
import 'package:lms/features/instructor/subscriptions/domain/usecases/cancel_subscription_usecase.dart';

// ----- States -----

sealed class SubscriptionState extends Equatable {
  const SubscriptionState();

  @override
  List<Object?> get props => [];
}

class SubscriptionInitial extends SubscriptionState {
  const SubscriptionInitial();
}

class SubscriptionLoading extends SubscriptionState {
  const SubscriptionLoading();
}

class SubscriptionLoaded extends SubscriptionState {

  const SubscriptionLoaded({
    required this.subscription,
    this.plans = const [],
    this.storageAddons = const [],
  });
  final SubscriptionEntity subscription;
  final List<SubscriptionPlanEntity> plans;
  final List<StorageAddonEntity> storageAddons;

  @override
  List<Object?> get props => [subscription, plans, storageAddons];
}

class SubscriptionCheckoutUrl extends SubscriptionState {

  const SubscriptionCheckoutUrl(this.url);
  final String url;

  @override
  List<Object?> get props => [url];
}

class SubscriptionPortalUrl extends SubscriptionState {

  const SubscriptionPortalUrl(this.url);
  final String url;

  @override
  List<Object?> get props => [url];
}

class SubscriptionActionSuccess extends SubscriptionState {

  const SubscriptionActionSuccess(this.message);
  final String message;

  @override
  List<Object?> get props => [message];
}

class SubscriptionError extends SubscriptionState {

  const SubscriptionError(this.message);
  final String message;

  @override
  List<Object?> get props => [message];
}

// ----- Cubit -----

class SubscriptionCubit extends Cubit<SubscriptionState> {

  SubscriptionCubit({
    required this.getSubscriptionUseCase,
    required this.getPlansUseCase,
    required this.createCheckoutUseCase,
    required this.createPortalUseCase,
    required this.choosePlanUseCase,
    required this.buyStorageUseCase,
    required this.getStorageAddonsUseCase,
    required this.refreshSubscriptionUseCase,
    required this.cancelSubscriptionUseCase,
  }) : super(const SubscriptionInitial());
  final GetSubscriptionUseCase getSubscriptionUseCase;
  final GetPlansUseCase getPlansUseCase;
  final CreateCheckoutUseCase createCheckoutUseCase;
  final CreatePortalUseCase createPortalUseCase;
  final ChoosePlanUseCase choosePlanUseCase;
  final BuyStorageUseCase buyStorageUseCase;
  final GetStorageAddonsUseCase getStorageAddonsUseCase;
  final RefreshSubscriptionUseCase refreshSubscriptionUseCase;
  final CancelSubscriptionUseCase cancelSubscriptionUseCase;

  Future<void> loadSubscriptionData() async {
    emit(const SubscriptionLoading());

    final subResult = await getSubscriptionUseCase();
    SubscriptionEntity? subscription;
    String? error;

    subResult.fold(
      (failure) => error = _mapFailure(failure),
      (data) => subscription = data,
    );

    if (subscription == null) {
      emit(SubscriptionError(error ?? 'Failed to load subscription data'));
      return;
    }

    final plansResult = await getPlansUseCase();
    List<SubscriptionPlanEntity> plans = [];
    plansResult.fold(
      (failure) => error = _mapFailure(failure),
      (data) => plans = data,
    );

    final storageResult = await getStorageAddonsUseCase();
    List<StorageAddonEntity> storageAddons = [];
    storageResult.fold(
      (failure) => error = _mapFailure(failure),
      (data) => storageAddons = data,
    );

    emit(SubscriptionLoaded(
      subscription: subscription!,
      plans: plans,
      storageAddons: storageAddons,
    ));
  }

  Future<void> createCheckout({required String planType}) async {
    emit(const SubscriptionLoading());
    final result = await createCheckoutUseCase(
      CreateCheckoutParams(planType: planType),
    );
    result.fold(
      (failure) => emit(SubscriptionError(_mapFailure(failure))),
      (url) => emit(SubscriptionCheckoutUrl(url)),
    );
  }

  Future<void> openPortal() async {
    emit(const SubscriptionLoading());
    final result = await createPortalUseCase();
    result.fold(
      (failure) => emit(SubscriptionError(_mapFailure(failure))),
      (url) => emit(SubscriptionPortalUrl(url)),
    );
  }

  Future<void> choosePlan({required String planType}) async {
    emit(const SubscriptionLoading());
    final result = await choosePlanUseCase(
      ChoosePlanParams(planType: planType),
    );
    result.fold(
      (failure) => emit(SubscriptionError(_mapFailure(failure))),
      (url) {
        if (url.isEmpty) {
          // Free plan applied immediately
          emit(const SubscriptionActionSuccess('Plan selected!'));
          loadSubscriptionData();
        } else {
          // Paid plan needs Stripe checkout
          emit(SubscriptionCheckoutUrl(url));
        }
      },
    );
  }

  Future<void> buyStorage() async {
    emit(const SubscriptionLoading());
    final result = await buyStorageUseCase();
    result.fold(
      (failure) => emit(SubscriptionError(_mapFailure(failure))),
      (url) => emit(SubscriptionCheckoutUrl(url)),
    );
  }

  Future<void> refreshSubscription() async {
    emit(const SubscriptionLoading());
    final result = await refreshSubscriptionUseCase();
    result.fold(
      (failure) => emit(SubscriptionError(_mapFailure(failure))),
      (subscription) {
        emit(const SubscriptionActionSuccess('Subscription refreshed!'));
        loadSubscriptionData();
      },
    );
  }

  Future<void> cancelSubscription() async {
    emit(const SubscriptionLoading());
    final result = await cancelSubscriptionUseCase();
    result.fold(
      (failure) => emit(SubscriptionError(_mapFailure(failure))),
      (_) {
        emit(const SubscriptionActionSuccess('Subscription cancelled'));
        loadSubscriptionData();
      },
    );
  }

  String _mapFailure(Failure failure) {
    return switch (failure) {
      ServerFailure f => f.message,
      NetworkFailure f => f.message,
      AuthFailure f => f.message,
      _ => 'An unexpected error occurred',
    };
  }
}
