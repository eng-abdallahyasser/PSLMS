import 'package:get_it/get_it.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:lms/core/constants/app_constants.dart';
import 'package:lms/core/network/api_client.dart';
import 'package:lms/core/network/network_info.dart';
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
import 'package:lms/features/instructor/students/data/datasources/student_remote_datasource.dart';
import 'package:lms/features/instructor/students/data/repositories/student_repository_impl.dart';
import 'package:lms/features/instructor/students/domain/repositories/student_repository.dart';
import 'package:lms/features/instructor/students/domain/usecases/invite_student_usecase.dart';
import 'package:lms/features/instructor/students/domain/usecases/list_students_usecase.dart';
import 'package:lms/features/instructor/students/domain/usecases/list_requests_usecase.dart';
import 'package:lms/features/instructor/students/domain/usecases/respond_to_request_usecase.dart';
import 'package:lms/features/instructor/students/domain/usecases/remove_student_usecase.dart';
import 'package:lms/features/instructor/students/domain/usecases/assign_courses_usecase.dart';
import 'package:lms/features/instructor/students/domain/usecases/get_assignments_usecase.dart';
import 'package:lms/features/instructor/students/presentation/cubit/student_cubit.dart';
import 'package:lms/features/instructor/subscriptions/data/datasources/subscription_remote_datasource.dart';
import 'package:lms/features/instructor/subscriptions/data/repositories/subscription_repository_impl.dart';
import 'package:lms/features/instructor/subscriptions/domain/repositories/subscription_repository.dart';
import 'package:lms/features/instructor/subscriptions/domain/usecases/cancel_subscription_usecase.dart';
import 'package:lms/features/instructor/subscriptions/domain/usecases/create_checkout_usecase.dart';
import 'package:lms/features/instructor/subscriptions/domain/usecases/create_portal_usecase.dart';
import 'package:lms/features/instructor/subscriptions/domain/usecases/choose_plan_usecase.dart';
import 'package:lms/features/instructor/subscriptions/domain/usecases/buy_storage_usecase.dart';
import 'package:lms/features/instructor/subscriptions/domain/usecases/get_plans_usecase.dart';
import 'package:lms/features/instructor/subscriptions/domain/usecases/get_storage_addons_usecase.dart';
import 'package:lms/features/instructor/subscriptions/domain/usecases/get_subscription_usecase.dart';
import 'package:lms/features/instructor/subscriptions/domain/usecases/refresh_subscription_usecase.dart';
import 'package:lms/features/instructor/subscriptions/presentation/cubit/subscription_cubit.dart';
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
import 'package:lms/features/instructor/courses/enrollments/data/datasources/enrollment_remote_datasource.dart';
import 'package:lms/features/instructor/courses/enrollments/data/repositories/enrollment_repository_impl.dart';
import 'package:lms/features/instructor/courses/enrollments/domain/repositories/enrollment_repository.dart';
import 'package:lms/features/learner/my_courses/enrollments/domain/usecases/enroll_in_course_usecase.dart';
import 'package:lms/features/instructor/courses/enrollments/domain/usecases/get_enrollments_usecase.dart';
import 'package:lms/features/learner/my_courses/domain/usecases/get_my_course_detail_usecase.dart';
import 'package:lms/features/learner/my_courses/domain/usecases/get_my_courses_usecase.dart';
import 'package:lms/features/instructor/courses/enrollments/domain/usecases/invite_learner_usecase.dart';
import 'package:lms/features/instructor/courses/enrollments/domain/usecases/remove_enrollment_usecase.dart';
import 'package:lms/features/instructor/courses/enrollments/domain/usecases/respond_to_enrollment_usecase.dart';
import 'package:lms/features/instructor/courses/enrollments/presentation/cubit/enrollment_cubit.dart';
import 'package:lms/features/learner/my_courses/presentation/cubit/my_courses_cubit.dart';
import 'package:lms/features/learner/instructors/data/datasources/instructor_remote_datasource.dart';
import 'package:lms/features/learner/instructors/data/repositories/instructor_repository_impl.dart';
import 'package:lms/features/learner/instructors/domain/repositories/instructor_repository.dart';
import 'package:lms/features/learner/instructors/domain/usecases/accept_invitation_usecase.dart';
import 'package:lms/features/learner/instructors/domain/usecases/get_instructor_courses_usecase.dart';
import 'package:lms/features/learner/instructors/domain/usecases/get_instructor_profile_usecase.dart';
import 'package:lms/features/learner/instructors/domain/usecases/get_invitation_info_usecase.dart';
import 'package:lms/features/learner/instructors/domain/usecases/get_my_instructors_usecase.dart';
import 'package:lms/features/learner/instructors/domain/usecases/request_to_join_usecase.dart';
import 'package:lms/features/learner/instructors/domain/usecases/search_instructors_usecase.dart';
import 'package:lms/features/learner/instructors/presentation/cubit/instructor_cubit.dart';
import 'package:lms/features/shared/notifications/data/datasources/notification_remote_datasource.dart';
import 'package:lms/features/shared/notifications/data/repositories/notification_repository_impl.dart';
import 'package:lms/features/shared/notifications/domain/repositories/notification_repository.dart';
import 'package:lms/features/shared/notifications/domain/usecases/get_notifications_usecase.dart';
import 'package:lms/features/shared/notifications/domain/usecases/mark_all_notifications_read_usecase.dart';
import 'package:lms/features/shared/notifications/domain/usecases/mark_notification_read_usecase.dart';
import 'package:lms/features/shared/notifications/presentation/cubit/notification_cubit.dart';
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

  // API Client — token read dynamically from SharedPreferences
  sl.registerLazySingleton<ApiClient>(
    () => ApiClient(
      tokenProvider: () => sl<SharedPreferences>().getString(AppConstants.tokenKey),
      onTokenRefresh: () async {
        final refreshToken =
            sl<SharedPreferences>().getString(AppConstants.refreshTokenKey);
        if (refreshToken == null || refreshToken.isEmpty) return null;
        final result = await sl<AuthRepository>().refreshToken(refreshToken);
        return result.fold((_) => null, (token) => token);
      },
    ),
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

  // ===== Enrollments Feature =====

  // Data source
  sl.registerLazySingleton<EnrollmentRemoteDataSource>(
    () => EnrollmentRemoteDataSourceImpl(apiClient: sl<ApiClient>()),
  );

  // Repository
  sl.registerLazySingleton<EnrollmentRepository>(
    () => EnrollmentRepositoryImpl(
      remoteDataSource: sl<EnrollmentRemoteDataSource>(),
      networkInfo: sl<NetworkInfo>(),
    ),
  );

  // Use cases
  sl.registerLazySingleton<EnrollInCourseUseCase>(
    () => EnrollInCourseUseCase(sl<EnrollmentRepository>()),
  );
  sl.registerLazySingleton<GetEnrollmentsUseCase>(
    () => GetEnrollmentsUseCase(sl<EnrollmentRepository>()),
  );
  sl.registerLazySingleton<GetMyCoursesUseCase>(
    () => GetMyCoursesUseCase(sl<EnrollmentRepository>()),
  );
  sl.registerLazySingleton<GetMyCourseDetailUseCase>(
    () => GetMyCourseDetailUseCase(sl<EnrollmentRepository>()),
  );
  sl.registerLazySingleton<RespondToEnrollmentUseCase>(
    () => RespondToEnrollmentUseCase(sl<EnrollmentRepository>()),
  );
  sl.registerLazySingleton<InviteLearnerUseCase>(
    () => InviteLearnerUseCase(sl<EnrollmentRepository>()),
  );
  sl.registerLazySingleton<RemoveEnrollmentUseCase>(
    () => RemoveEnrollmentUseCase(sl<EnrollmentRepository>()),
  );

  // Cubits
  sl.registerFactory<EnrollmentCubit>(
    () => EnrollmentCubit(
      enrollInCourseUseCase: sl<EnrollInCourseUseCase>(),
      getEnrollmentsUseCase: sl<GetEnrollmentsUseCase>(),
      respondToEnrollmentUseCase: sl<RespondToEnrollmentUseCase>(),
      inviteLearnerUseCase: sl<InviteLearnerUseCase>(),
      removeEnrollmentUseCase: sl<RemoveEnrollmentUseCase>(),
    ),
  );
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
  sl.registerLazySingleton<RequestToJoinUseCase>(
    () => RequestToJoinUseCase(sl<InstructorRepository>()),
  );
  sl.registerLazySingleton<GetMyInstructorsUseCase>(
    () => GetMyInstructorsUseCase(sl<InstructorRepository>()),
  );
  sl.registerLazySingleton<GetInstructorCoursesUseCase>(
    () => GetInstructorCoursesUseCase(sl<InstructorRepository>()),
  );
  sl.registerLazySingleton<GetInvitationInfoUseCase>(
    () => GetInvitationInfoUseCase(sl<InstructorRepository>()),
  );
  sl.registerLazySingleton<AcceptInvitationUseCase>(
    () => AcceptInvitationUseCase(sl<InstructorRepository>()),
  );

  // Cubit
  sl.registerFactory<InstructorCubit>(
    () => InstructorCubit(
      searchInstructorsUseCase: sl<SearchInstructorsUseCase>(),
      getInstructorProfileUseCase: sl<GetInstructorProfileUseCase>(),
      requestToJoinUseCase: sl<RequestToJoinUseCase>(),
      getMyInstructorsUseCase: sl<GetMyInstructorsUseCase>(),
      getInstructorCoursesUseCase: sl<GetInstructorCoursesUseCase>(),
      getInvitationInfoUseCase: sl<GetInvitationInfoUseCase>(),
      acceptInvitationUseCase: sl<AcceptInvitationUseCase>(),
    ),
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

  // ===== Subscriptions Feature =====

  // Data source
  sl.registerLazySingleton<SubscriptionRemoteDataSource>(
    () => SubscriptionRemoteDataSourceImpl(apiClient: sl<ApiClient>()),
  );

  // Repository
  sl.registerLazySingleton<SubscriptionRepository>(
    () => SubscriptionRepositoryImpl(
      remoteDataSource: sl<SubscriptionRemoteDataSource>(),
      networkInfo: sl<NetworkInfo>(),
    ),
  );

  // Use cases
  sl.registerLazySingleton<GetSubscriptionUseCase>(
    () => GetSubscriptionUseCase(sl<SubscriptionRepository>()),
  );
  sl.registerLazySingleton<GetPlansUseCase>(
    () => GetPlansUseCase(sl<SubscriptionRepository>()),
  );
  sl.registerLazySingleton<CreateCheckoutUseCase>(
    () => CreateCheckoutUseCase(sl<SubscriptionRepository>()),
  );
  sl.registerLazySingleton<CreatePortalUseCase>(
    () => CreatePortalUseCase(sl<SubscriptionRepository>()),
  );
  sl.registerLazySingleton<ChoosePlanUseCase>(
    () => ChoosePlanUseCase(sl<SubscriptionRepository>()),
  );
  sl.registerLazySingleton<BuyStorageUseCase>(
    () => BuyStorageUseCase(sl<SubscriptionRepository>()),
  );
  sl.registerLazySingleton<GetStorageAddonsUseCase>(
    () => GetStorageAddonsUseCase(sl<SubscriptionRepository>()),
  );
  sl.registerLazySingleton<RefreshSubscriptionUseCase>(
    () => RefreshSubscriptionUseCase(sl<SubscriptionRepository>()),
  );
  sl.registerLazySingleton<CancelSubscriptionUseCase>(
    () => CancelSubscriptionUseCase(sl<SubscriptionRepository>()),
  );

  // Cubit
  sl.registerFactory<SubscriptionCubit>(
    () => SubscriptionCubit(
      getSubscriptionUseCase: sl<GetSubscriptionUseCase>(),
      getPlansUseCase: sl<GetPlansUseCase>(),
      createCheckoutUseCase: sl<CreateCheckoutUseCase>(),
      createPortalUseCase: sl<CreatePortalUseCase>(),
      choosePlanUseCase: sl<ChoosePlanUseCase>(),
      buyStorageUseCase: sl<BuyStorageUseCase>(),
      getStorageAddonsUseCase: sl<GetStorageAddonsUseCase>(),
      refreshSubscriptionUseCase: sl<RefreshSubscriptionUseCase>(),
      cancelSubscriptionUseCase: sl<CancelSubscriptionUseCase>(),
    ),
  );

  // ===== Students Feature =====

  // Data source
  sl.registerLazySingleton<StudentRemoteDataSource>(
    () => StudentRemoteDataSourceImpl(apiClient: sl<ApiClient>()),
  );

  // Repository
  sl.registerLazySingleton<StudentRepository>(
    () => StudentRepositoryImpl(
      remoteDataSource: sl<StudentRemoteDataSource>(),
      networkInfo: sl<NetworkInfo>(),
    ),
  );

  // Use cases
  sl.registerLazySingleton<InviteStudentUseCase>(
    () => InviteStudentUseCase(sl<StudentRepository>()),
  );
  sl.registerLazySingleton<ListStudentsUseCase>(
    () => ListStudentsUseCase(sl<StudentRepository>()),
  );
  sl.registerLazySingleton<ListRequestsUseCase>(
    () => ListRequestsUseCase(sl<StudentRepository>()),
  );
  sl.registerLazySingleton<RespondToRequestUseCase>(
    () => RespondToRequestUseCase(sl<StudentRepository>()),
  );
  sl.registerLazySingleton<RemoveStudentUseCase>(
    () => RemoveStudentUseCase(sl<StudentRepository>()),
  );
  sl.registerLazySingleton<AssignCoursesUseCase>(
    () => AssignCoursesUseCase(sl<StudentRepository>()),
  );
  sl.registerLazySingleton<GetAssignmentsUseCase>(
    () => GetAssignmentsUseCase(sl<StudentRepository>()),
  );

  // Cubit
  sl.registerFactory<StudentCubit>(
    () => StudentCubit(
      inviteStudentUseCase: sl<InviteStudentUseCase>(),
      listStudentsUseCase: sl<ListStudentsUseCase>(),
      listRequestsUseCase: sl<ListRequestsUseCase>(),
      respondToRequestUseCase: sl<RespondToRequestUseCase>(),
      removeStudentUseCase: sl<RemoveStudentUseCase>(),
      assignCoursesUseCase: sl<AssignCoursesUseCase>(),
      getAssignmentsUseCase: sl<GetAssignmentsUseCase>(),
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
    ),
  );

  // ===== Profile Feature =====

  // Data source
  sl.registerLazySingleton<ProfileRemoteDataSource>(
    () => ProfileRemoteDataSourceImpl(apiClient: sl<ApiClient>()),
  );

  // Repository
  sl.registerLazySingleton<ProfileRepository>(
    () => ProfileRepositoryImpl(
      remoteDataSource: sl<ProfileRemoteDataSource>(),
      networkInfo: sl<NetworkInfo>(),
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
