import 'dart:async';

import 'package:get_it/get_it.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:lms/core/constants/app_constants.dart';
import 'package:lms/core/errors/failures.dart';
import 'package:lms/core/network/api_client.dart';
import 'package:lms/core/network/network_info.dart';
import 'package:lms/core/theme/theme_controller.dart';
import 'package:lms/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:lms/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:lms/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:lms/features/auth/domain/repositories/auth_repository.dart';
import 'package:lms/features/auth/data/services/social_auth_service.dart';
import 'package:lms/features/auth/domain/usecases/complete_registration_usecase.dart';
import 'package:lms/features/auth/domain/usecases/facebook_sign_in_usecase.dart';
import 'package:lms/features/auth/domain/usecases/forgot_password_usecase.dart';
import 'package:lms/features/auth/domain/usecases/reset_password_usecase.dart';
import 'package:lms/features/auth/domain/usecases/send_mobile_otp_usecase.dart';
import 'package:lms/features/auth/domain/usecases/verify_mobile_otp_usecase.dart';
import 'package:lms/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:lms/features/auth/domain/usecases/google_sign_in_usecase.dart';
import 'package:lms/features/auth/domain/usecases/login_usecase.dart';
import 'package:lms/features/auth/domain/usecases/logout_usecase.dart';
import 'package:lms/features/auth/domain/usecases/register_usecase.dart';
import 'package:lms/features/auth/domain/usecases/send_otp_usecase.dart';
import 'package:lms/features/auth/domain/usecases/verify_email_usecase.dart';
import 'package:lms/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:lms/features/instructor/courses/data/datasources/course_remote_datasource.dart';
import 'package:lms/features/instructor/courses/data/repositories/course_repository_impl.dart';
import 'package:lms/features/instructor/courses/domain/repositories/course_repository.dart';
import 'package:lms/features/instructor/courses/domain/usecases/create_course_usecase.dart';
import 'package:lms/features/instructor/courses/domain/usecases/delete_course_usecase.dart';
import 'package:lms/features/instructor/storage/data/datasources/storage_remote_datasource.dart';
import 'package:lms/features/instructor/storage/data/repositories/storage_repository_impl.dart';
import 'package:lms/features/instructor/storage/domain/repositories/storage_repository.dart';
import 'package:lms/features/instructor/storage/domain/usecases/get_revenue_usecase.dart';
import 'package:lms/features/instructor/storage/domain/usecases/get_storage_plans_usecase.dart';
import 'package:lms/features/instructor/storage/domain/usecases/get_storage_usage_usecase.dart';
import 'package:lms/features/instructor/storage/domain/usecases/subscribe_storage_plan_usecase.dart';
import 'package:lms/features/instructor/storage/presentation/cubit/storage_cubit.dart';
import 'package:lms/features/instructor/courses/domain/usecases/get_courses_usecase.dart';
import 'package:lms/features/instructor/courses/domain/usecases/update_course_usecase.dart';
import 'package:lms/features/instructor/courses/presentation/cubit/course_cubit.dart';
import 'package:lms/features/instructor/courses/content/data/datasources/content_remote_datasource.dart';
import 'package:lms/features/instructor/courses/content/data/repositories/content_repository_impl.dart';
import 'package:lms/features/instructor/courses/content/domain/repositories/content_repository.dart';
import 'package:lms/features/instructor/courses/content/domain/usecases/delete_content_usecase.dart';
import 'package:lms/features/instructor/courses/content/domain/usecases/get_course_contents_usecase.dart';
import 'package:lms/features/instructor/courses/content/domain/usecases/reorder_content_usecase.dart';
import 'package:lms/features/instructor/courses/content/domain/usecases/update_content_usecase.dart';
import 'package:lms/features/learner/my_courses/content/domain/usecases/get_my_content_detail_usecase.dart';
import 'package:lms/features/learner/my_courses/content/domain/usecases/get_my_course_contents_usecase.dart';
import 'package:lms/features/instructor/courses/content/domain/usecases/upload_content_usecase.dart';
import 'package:lms/features/instructor/courses/content/presentation/cubit/content_cubit.dart';
import 'package:lms/features/learner/my_courses/content/presentation/cubit/learner_content_cubit.dart';
import 'package:lms/features/instructor/courses/dashboard/data/datasources/dashboard_remote_datasource.dart';
import 'package:lms/features/instructor/courses/dashboard/data/repositories/dashboard_repository_impl.dart';
import 'package:lms/features/instructor/courses/dashboard/domain/repositories/dashboard_repository.dart';
import 'package:lms/features/instructor/courses/dashboard/domain/usecases/get_dashboard_stats_usecase.dart';
import 'package:lms/features/instructor/courses/dashboard/presentation/cubit/dashboard_cubit.dart';
import 'package:lms/features/learner/my_courses/data/datasources/my_courses_remote_datasource.dart';
import 'package:lms/features/learner/my_courses/data/repositories/my_courses_repository_impl.dart';
import 'package:lms/features/learner/my_courses/domain/repositories/my_courses_repository.dart';
import 'package:lms/features/learner/my_courses/domain/usecases/get_my_course_detail_usecase.dart';
import 'package:lms/features/learner/my_courses/domain/usecases/get_my_courses_usecase.dart';
import 'package:lms/features/learner/my_courses/presentation/cubit/my_courses_cubit.dart';
import 'package:lms/features/learner/instructors/data/datasources/instructor_remote_datasource.dart';
import 'package:lms/features/learner/instructors/data/repositories/instructor_repository_impl.dart';
import 'package:lms/features/learner/instructors/domain/repositories/instructor_repository.dart';
import 'package:lms/features/learner/instructors/domain/usecases/get_instructor_profile_usecase.dart';
import 'package:lms/features/learner/instructors/domain/usecases/search_instructors_usecase.dart';
import 'package:lms/features/learner/instructors/presentation/cubit/instructor_cubit.dart';
import 'package:lms/features/shared/discovery/data/datasources/discovery_remote_datasource.dart';
import 'package:lms/features/shared/discovery/data/repositories/discovery_repository_impl.dart';
import 'package:lms/features/shared/discovery/domain/repositories/discovery_repository.dart';
import 'package:lms/features/shared/discovery/domain/usecases/get_categories_usecase.dart';
import 'package:lms/features/shared/discovery/domain/usecases/get_public_courses_usecase.dart';
import 'package:lms/features/shared/discovery/domain/usecases/get_public_instructors_usecase.dart';
import 'package:lms/features/shared/notifications/data/datasources/notification_remote_datasource.dart';
import 'package:lms/features/shared/notifications/data/repositories/notification_repository_impl.dart';
import 'package:lms/features/shared/notifications/domain/repositories/notification_repository.dart';
import 'package:lms/features/shared/notifications/domain/usecases/get_notifications_usecase.dart';
import 'package:lms/features/shared/notifications/domain/usecases/mark_all_notifications_read_usecase.dart';
import 'package:lms/features/shared/notifications/domain/usecases/mark_notification_read_usecase.dart';
import 'package:lms/features/shared/notifications/presentation/cubit/notification_cubit.dart';
import 'package:lms/features/learner/purchases/data/datasources/purchase_remote_datasource.dart';
import 'package:lms/features/learner/purchases/data/repositories/purchase_repository_impl.dart';
import 'package:lms/features/learner/purchases/domain/repositories/purchase_repository.dart';
import 'package:lms/features/learner/purchases/domain/usecases/purchase_course_usecase.dart';
import 'package:lms/features/learner/purchases/presentation/cubit/purchase_cubit.dart';
import 'package:lms/features/shared/universities/data/datasources/universities_remote_datasource.dart';
import 'package:lms/features/shared/profile/data/datasources/profile_remote_datasource.dart';
import 'package:lms/features/shared/profile/data/repositories/profile_repository_impl.dart';
import 'package:lms/features/shared/profile/domain/repositories/profile_repository.dart';
import 'package:lms/features/shared/profile/domain/usecases/get_profile_usecase.dart';
import 'package:lms/features/shared/profile/domain/usecases/update_preferences_usecase.dart';
import 'package:lms/features/shared/profile/domain/usecases/update_profile_usecase.dart';
import 'package:lms/features/shared/profile/domain/usecases/upload_avatar_usecase.dart';
import 'package:lms/features/shared/profile/presentation/cubit/profile_cubit.dart';

final sl = GetIt.instance;

Future<void> initDependencies() async {
  // ===== Core =====

  // SharedPreferences
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton<SharedPreferences>(() => sharedPreferences);

  // Session expired notifier
  sl.registerLazySingleton<StreamController<void>>(
    () => StreamController<void>.broadcast(),
  );

  // API Client â€” token read dynamically from SharedPreferences
  sl.registerLazySingleton<ApiClient>(
    () {
      final client = ApiClient();
      client.setTokenProvider(
        () => sl<SharedPreferences>().getString(AppConstants.tokenKey),
      );
      client.onTokenRefresh = () async {
        final refreshToken =
            sl<SharedPreferences>().getString(AppConstants.refreshTokenKey);
        if (refreshToken == null || refreshToken.isEmpty) return null;
        final result = await sl<AuthRepository>().refreshToken(refreshToken);
        return result.fold((failure) {
          if (failure is AuthFailure &&
              (failure.statusCode == 401 || failure.statusCode == 403)) {
            sl<SharedPreferences>().remove(AppConstants.tokenKey);
            sl<SharedPreferences>().remove(AppConstants.refreshTokenKey);
            sl<SharedPreferences>().remove(AppConstants.userKey);
            sl<StreamController<void>>().add(null);
          }
          return null;
        }, (token) => token);
      };
      return client;
    },
  );

  // Network Info
  sl.registerLazySingleton<InternetConnectionChecker>(
    () => InternetConnectionChecker.createInstance(
      addresses: [
      AddressCheckOption(
        uri: Uri.parse(AppConstants.baseUrl),
      ),
    ],
    ),
  );
  sl.registerLazySingleton<NetworkInfo>(
    () => NetworkInfoImpl(sl<InternetConnectionChecker>()),
  );

  // ===== Shared: Universities =====
  sl.registerLazySingleton<UniversitiesRemoteDataSource>(
    () => UniversitiesRemoteDataSource(apiClient: sl<ApiClient>()),
  );

  // ===== Learner Purchases =====
  sl.registerLazySingleton<PurchaseRemoteDataSource>(
    () => PurchaseRemoteDataSourceImpl(apiClient: sl<ApiClient>()),
  );
  sl.registerLazySingleton<PurchaseRepository>(
    () => PurchaseRepositoryImpl(
      remoteDataSource: sl<PurchaseRemoteDataSource>(),
      networkInfo: sl<NetworkInfo>(),
    ),
  );
  sl.registerLazySingleton<PurchaseCourseUseCase>(
    () => PurchaseCourseUseCase(sl<PurchaseRepository>()),
  );
  sl.registerFactory<PurchaseCubit>(
    () => PurchaseCubit(purchaseCourseUseCase: sl<PurchaseCourseUseCase>()),
  );

  // ===== Auth Feature =====

  // Data sources
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(apiClient: sl<ApiClient>()),
  );
  sl.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(sharedPreferences: sl<SharedPreferences>()),
  );

  // Services
  sl.registerLazySingleton<SocialAuthService>(
    () => SocialAuthService(),
  );

  // Repository
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: sl<AuthRemoteDataSource>(),
      localDataSource: sl<AuthLocalDataSource>(),
      networkInfo: sl<NetworkInfo>(),
      socialAuthService: sl<SocialAuthService>(),
    ),
  );

  // Use cases
  sl.registerLazySingleton<LoginUseCase>(
    () => LoginUseCase(sl<AuthRepository>()),
  );
  sl.registerLazySingleton<RegisterUseCase>(
    () => RegisterUseCase(sl<AuthRepository>()),
  );
  sl.registerLazySingleton<LogoutUseCase>(
    () => LogoutUseCase(sl<AuthRepository>()),
  );
  sl.registerLazySingleton<SendMobileOtpUseCase>(
    () => SendMobileOtpUseCase(sl<AuthRepository>()),
  );
  sl.registerLazySingleton<VerifyMobileOtpUseCase>(
    () => VerifyMobileOtpUseCase(sl<AuthRepository>()),
  );
  sl.registerLazySingleton<SendOtpUseCase>(
    () => SendOtpUseCase(sl<AuthRepository>()),
  );
  sl.registerLazySingleton<VerifyEmailUseCase>(
    () => VerifyEmailUseCase(sl<AuthRepository>()),
  );
  sl.registerLazySingleton<CompleteRegistrationUseCase>(
    () => CompleteRegistrationUseCase(sl<AuthRepository>()),
  );
  sl.registerLazySingleton<GoogleSignInUseCase>(
    () => GoogleSignInUseCase(sl<AuthRepository>()),
  );
  sl.registerLazySingleton<FacebookSignInUseCase>(
    () => FacebookSignInUseCase(sl<AuthRepository>()),
  );
  sl.registerLazySingleton<ForgotPasswordUseCase>(
    () => ForgotPasswordUseCase(sl<AuthRepository>()),
  );
  sl.registerLazySingleton<ResetPasswordUseCase>(
    () => ResetPasswordUseCase(sl<AuthRepository>()),
  );
  sl.registerLazySingleton<GetCurrentUserUseCase>(
    () => GetCurrentUserUseCase(sl<AuthRepository>()),
  );

  // Cubit
  sl.registerFactory<AuthCubit>(
    () => AuthCubit(
      loginUseCase: sl<LoginUseCase>(),
      registerUseCase: sl<RegisterUseCase>(),
      logoutUseCase: sl<LogoutUseCase>(),
      getCurrentUserUseCase: sl<GetCurrentUserUseCase>(),
      sendOtpUseCase: sl<SendOtpUseCase>(),
      verifyEmailUseCase: sl<VerifyEmailUseCase>(),
      forgotPasswordUseCase: sl<ForgotPasswordUseCase>(),
      resetPasswordUseCase: sl<ResetPasswordUseCase>(),
      sendMobileOtpUseCase: sl<SendMobileOtpUseCase>(),
      verifyMobileOtpUseCase: sl<VerifyMobileOtpUseCase>(),
      completeRegistrationUseCase: sl<CompleteRegistrationUseCase>(),
      googleSignInUseCase: sl<GoogleSignInUseCase>(),
      facebookSignInUseCase: sl<FacebookSignInUseCase>(),
      sessionExpiredStream: sl<StreamController<void>>().stream,
    ),
  );

  // ===== Courses Feature =====

  // Data sources
  sl.registerLazySingleton<CourseRemoteDataSource>(
    () => CourseRemoteDataSourceImpl(apiClient: sl<ApiClient>()),
  );

  // Repository
  sl.registerLazySingleton<CourseRepository>(
    () => CourseRepositoryImpl(
      remoteDataSource: sl<CourseRemoteDataSource>(),
      networkInfo: sl<NetworkInfo>(),
    ),
  );

  // Use cases
  sl.registerLazySingleton<GetCoursesUseCase>(
    () => GetCoursesUseCase(sl<CourseRepository>()),
  );
  sl.registerLazySingleton<CreateCourseUseCase>(
    () => CreateCourseUseCase(sl<CourseRepository>()),
  );
  sl.registerLazySingleton<UpdateCourseUseCase>(
    () => UpdateCourseUseCase(sl<CourseRepository>()),
  );
  sl.registerLazySingleton<DeleteCourseUseCase>(
    () => DeleteCourseUseCase(sl<CourseRepository>()),
  );

  // Cubit
  sl.registerFactory<CourseCubit>(
    () => CourseCubit(
      getCoursesUseCase: sl<GetCoursesUseCase>(),
      createCourseUseCase: sl<CreateCourseUseCase>(),
      updateCourseUseCase: sl<UpdateCourseUseCase>(),
      deleteCourseUseCase: sl<DeleteCourseUseCase>(),
    ),
  );

  // ===== Contents Feature =====

  // Data source
  sl.registerLazySingleton<ContentRemoteDataSource>(
    () => ContentRemoteDataSourceImpl(apiClient: sl<ApiClient>()),
  );

  // Repository
  sl.registerLazySingleton<ContentRepository>(
    () => ContentRepositoryImpl(
      remoteDataSource: sl<ContentRemoteDataSource>(),
      networkInfo: sl<NetworkInfo>(),
    ),
  );

  // Use cases
  sl.registerLazySingleton<GetCourseContentsUseCase>(
    () => GetCourseContentsUseCase(sl<ContentRepository>()),
  );
  sl.registerLazySingleton<UploadContentUseCase>(
    () => UploadContentUseCase(sl<ContentRepository>()),
  );
  sl.registerLazySingleton<ReorderContentUseCase>(
    () => ReorderContentUseCase(sl<ContentRepository>()),
  );
  sl.registerLazySingleton<UpdateContentUseCase>(
    () => UpdateContentUseCase(sl<ContentRepository>()),
  );
  sl.registerLazySingleton<DeleteContentUseCase>(
    () => DeleteContentUseCase(sl<ContentRepository>()),
  );
  sl.registerLazySingleton<GetMyCourseContentsUseCase>(
    () => GetMyCourseContentsUseCase(sl<ContentRepository>()),
  );
  sl.registerLazySingleton<GetMyContentDetailUseCase>(
    () => GetMyContentDetailUseCase(sl<ContentRepository>()),
  );

  // Cubits
  sl.registerFactory<ContentCubit>(
    () => ContentCubit(
      getCourseContentsUseCase: sl<GetCourseContentsUseCase>(),
      uploadContentUseCase: sl<UploadContentUseCase>(),
      reorderContentUseCase: sl<ReorderContentUseCase>(),
      updateContentUseCase: sl<UpdateContentUseCase>(),
      deleteContentUseCase: sl<DeleteContentUseCase>(),
    ),
  );
  sl.registerFactory<LearnerContentCubit>(
    () => LearnerContentCubit(
      getMyCourseContentsUseCase: sl<GetMyCourseContentsUseCase>(),
      getMyContentDetailUseCase: sl<GetMyContentDetailUseCase>(),
    ),
  );

  // ===== My Courses Feature =====

  // Data source
  sl.registerLazySingleton<MyCoursesRemoteDataSource>(
    () => MyCoursesRemoteDataSourceImpl(apiClient: sl<ApiClient>()),
  );

  // Repository
  sl.registerLazySingleton<MyCoursesRepository>(
    () => MyCoursesRepositoryImpl(
      remoteDataSource: sl<MyCoursesRemoteDataSource>(),
      networkInfo: sl<NetworkInfo>(),
    ),
  );

  // Use cases
  sl.registerLazySingleton<GetMyCoursesUseCase>(
    () => GetMyCoursesUseCase(sl<MyCoursesRepository>()),
  );
  sl.registerLazySingleton<GetMyCourseDetailUseCase>(
    () => GetMyCourseDetailUseCase(sl<MyCoursesRepository>()),
  );

  // Cubits
  sl.registerFactory<MyCoursesCubit>(
    () => MyCoursesCubit(
      getMyCoursesUseCase: sl<GetMyCoursesUseCase>(),
      getMyCourseDetailUseCase: sl<GetMyCourseDetailUseCase>(),
    ),
  );

  // ===== Instructors Feature =====

  // Data source
  sl.registerLazySingleton<InstructorRemoteDataSource>(
    () => InstructorRemoteDataSourceImpl(apiClient: sl<ApiClient>()),
  );

  // Repository
  sl.registerLazySingleton<InstructorRepository>(
    () => InstructorRepositoryImpl(
      remoteDataSource: sl<InstructorRemoteDataSource>(),
      networkInfo: sl<NetworkInfo>(),
    ),
  );

  // Use cases
  sl.registerLazySingleton<SearchInstructorsUseCase>(
    () => SearchInstructorsUseCase(sl<InstructorRepository>()),
  );
  sl.registerLazySingleton<GetInstructorProfileUseCase>(
    () => GetInstructorProfileUseCase(sl<InstructorRepository>()),
  );

  // Cubit
  sl.registerFactory<InstructorCubit>(
    () => InstructorCubit(
      searchInstructorsUseCase: sl<SearchInstructorsUseCase>(),
      getInstructorProfileUseCase: sl<GetInstructorProfileUseCase>(),
    ),
  );

  // ===== Discovery Feature (public, no auth) =====

  // Data source
  sl.registerLazySingleton<DiscoveryRemoteDataSource>(
    () => DiscoveryRemoteDataSourceImpl(apiClient: sl<ApiClient>()),
  );

  // Repository
  sl.registerLazySingleton<DiscoveryRepository>(
    () => DiscoveryRepositoryImpl(
      remoteDataSource: sl<DiscoveryRemoteDataSource>(),
      networkInfo: sl<NetworkInfo>(),
    ),
  );

  // Use cases (registered for guest browsing / future onboarding UI)
  sl.registerLazySingleton<GetPublicCoursesUseCase>(
    () => GetPublicCoursesUseCase(sl<DiscoveryRepository>()),
  );
  sl.registerLazySingleton<GetPublicInstructorsUseCase>(
    () => GetPublicInstructorsUseCase(sl<DiscoveryRepository>()),
  );
  sl.registerLazySingleton<GetCategoriesUseCase>(
    () => GetCategoriesUseCase(sl<DiscoveryRepository>()),
  );

  // ===== Notifications Feature =====

  // Data source
  sl.registerLazySingleton<NotificationRemoteDataSource>(
    () => NotificationRemoteDataSourceImpl(apiClient: sl<ApiClient>()),
  );

  // Repository
  sl.registerLazySingleton<NotificationRepository>(
    () => NotificationRepositoryImpl(
      remoteDataSource: sl<NotificationRemoteDataSource>(),
      networkInfo: sl<NetworkInfo>(),
    ),
  );

  // Use cases
  sl.registerLazySingleton<GetNotificationsUseCase>(
    () => GetNotificationsUseCase(sl<NotificationRepository>()),
  );
  sl.registerLazySingleton<MarkNotificationReadUseCase>(
    () => MarkNotificationReadUseCase(sl<NotificationRepository>()),
  );
  sl.registerLazySingleton<MarkAllNotificationsReadUseCase>(
    () => MarkAllNotificationsReadUseCase(sl<NotificationRepository>()),
  );

  // Cubit
  sl.registerFactory<NotificationCubit>(
    () => NotificationCubit(
      getNotificationsUseCase: sl<GetNotificationsUseCase>(),
      markNotificationReadUseCase: sl<MarkNotificationReadUseCase>(),
      markAllNotificationsReadUseCase: sl<MarkAllNotificationsReadUseCase>(),
    ),
  );

  // ===== Storage Feature =====

  // Data source
  sl.registerLazySingleton<StorageRemoteDataSource>(
    () => StorageRemoteDataSourceImpl(apiClient: sl<ApiClient>()),
  );

  // Repository
  sl.registerLazySingleton<StorageRepository>(
    () => StorageRepositoryImpl(
      remoteDataSource: sl<StorageRemoteDataSource>(),
      networkInfo: sl<NetworkInfo>(),
    ),
  );

  // Use cases
  sl.registerLazySingleton<GetStorageUsageUseCase>(
    () => GetStorageUsageUseCase(sl<StorageRepository>()),
  );
  sl.registerLazySingleton<GetStoragePlansUseCase>(
    () => GetStoragePlansUseCase(sl<StorageRepository>()),
  );
  sl.registerLazySingleton<SubscribeStoragePlanUseCase>(
    () => SubscribeStoragePlanUseCase(sl<StorageRepository>()),
  );
  sl.registerLazySingleton<GetRevenueUseCase>(
    () => GetRevenueUseCase(sl<StorageRepository>()),
  );

  // Cubit
  sl.registerFactory<StorageCubit>(
    () => StorageCubit(
      getUsageUseCase: sl<GetStorageUsageUseCase>(),
      getPlansUseCase: sl<GetStoragePlansUseCase>(),
      subscribeUseCase: sl<SubscribeStoragePlanUseCase>(),
      getRevenueUseCase: sl<GetRevenueUseCase>(),
    ),
  );

  // ===== Dashboard Feature =====

  // Data source
  sl.registerLazySingleton<DashboardRemoteDataSource>(
    () => DashboardRemoteDataSourceImpl(apiClient: sl<ApiClient>()),
  );

  // Repository
  sl.registerLazySingleton<DashboardRepository>(
    () => DashboardRepositoryImpl(
      remoteDataSource: sl<DashboardRemoteDataSource>(),
      networkInfo: sl<NetworkInfo>(),
    ),
  );

  // Use case
  sl.registerLazySingleton<GetDashboardStatsUseCase>(
    () => GetDashboardStatsUseCase(sl<DashboardRepository>()),
  );

  // Cubit
  sl.registerFactory<DashboardCubit>(
    () => DashboardCubit(
      getDashboardStatsUseCase: sl<GetDashboardStatsUseCase>(),
      getRevenueUseCase: sl<GetRevenueUseCase>(),
    ),
  );

  // ===== Profile Feature =====

  // App-level theme/preferences sync
  sl.registerLazySingleton<ThemeController>(
    () => ThemeController(sl<SharedPreferences>()),
  );

  // Data source
  sl.registerLazySingleton<ProfileRemoteDataSource>(
    () => ProfileRemoteDataSourceImpl(apiClient: sl<ApiClient>()),
  );

  // Repository
  sl.registerLazySingleton<ProfileRepository>(
    () => ProfileRepositoryImpl(
      remoteDataSource: sl<ProfileRemoteDataSource>(),
      networkInfo: sl<NetworkInfo>(),
      themeController: sl<ThemeController>(),
    ),
  );

  // Use cases
  sl.registerLazySingleton<GetProfileUseCase>(
    () => GetProfileUseCase(sl<ProfileRepository>()),
  );
  sl.registerLazySingleton<UpdateProfileUseCase>(
    () => UpdateProfileUseCase(sl<ProfileRepository>()),
  );
  sl.registerLazySingleton<UpdatePreferencesUseCase>(
    () => UpdatePreferencesUseCase(sl<ProfileRepository>()),
  );
  sl.registerLazySingleton<UploadAvatarUseCase>(
    () => UploadAvatarUseCase(sl<ProfileRepository>()),
  );

  // Cubit
  sl.registerFactory<ProfileCubit>(
    () => ProfileCubit(
      getProfileUseCase: sl<GetProfileUseCase>(),
      updateProfileUseCase: sl<UpdateProfileUseCase>(),
      updatePreferencesUseCase: sl<UpdatePreferencesUseCase>(),
      uploadAvatarUseCase: sl<UploadAvatarUseCase>(),
    ),
  );
}
