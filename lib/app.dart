import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lms/core/theme/app_theme.dart';
import 'package:lms/injection_container.dart';
import 'package:lms/features/auth/domain/entities/user_entity.dart';
import 'package:lms/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:lms/features/auth/presentation/pages/login_page.dart';
import 'package:lms/features/auth/presentation/pages/mobile_otp_page.dart';
import 'package:lms/features/auth/presentation/pages/register_page.dart';
import 'package:lms/features/auth/presentation/pages/forgot_password_page.dart';
import 'package:lms/features/auth/presentation/pages/reset_password_page.dart';
import 'package:lms/features/auth/presentation/pages/verify_email_page.dart';
import 'package:lms/features/shared/splash/presentation/pages/splash_page.dart';
import 'package:lms/features/instructor/courses/presentation/cubit/course_cubit.dart';
import 'package:lms/features/instructor/courses/presentation/pages/courses_page.dart';
import 'package:lms/features/instructor/courses/content/presentation/cubit/content_cubit.dart';
import 'package:lms/features/instructor/courses/content/presentation/pages/contents_page.dart';
import 'package:lms/features/instructor/courses/enrollments/presentation/cubit/enrollment_cubit.dart';
import 'package:lms/features/instructor/courses/enrollments/presentation/pages/enrollments_page.dart';
import 'package:lms/features/instructor/courses/dashboard/presentation/cubit/dashboard_cubit.dart';
import 'package:lms/features/instructor/courses/dashboard/presentation/pages/dashboard_page.dart';
import 'package:lms/features/instructor/students/presentation/cubit/student_cubit.dart';
import 'package:lms/features/instructor/students/presentation/pages/students_page.dart';
import 'package:lms/features/instructor/subscriptions/presentation/cubit/subscription_cubit.dart';
import 'package:lms/features/instructor/subscriptions/presentation/pages/subscription_page.dart';
import 'package:lms/features/shared/profile/presentation/cubit/profile_cubit.dart';
import 'package:lms/features/shared/profile/presentation/pages/profile_page.dart';
import 'package:lms/features/shared/notifications/presentation/cubit/notification_cubit.dart';
import 'package:lms/features/shared/notifications/presentation/pages/notifications_page.dart';
import 'package:lms/features/learner/my_courses/presentation/cubit/my_courses_cubit.dart';
import 'package:lms/features/learner/my_courses/presentation/pages/my_courses_page.dart';
import 'package:lms/features/learner/my_courses/presentation/pages/my_course_detail_page.dart';
import 'package:lms/features/learner/my_courses/content/presentation/cubit/learner_content_cubit.dart';
import 'package:lms/features/learner/instructors/presentation/cubit/instructor_cubit.dart';
import 'package:lms/features/learner/instructors/presentation/pages/search_instructors_page.dart';
import 'package:lms/features/learner/instructors/presentation/pages/instructor_profile_page.dart';
import 'package:lms/features/learner/instructors/presentation/pages/my_instructors_page.dart';

String _courseIdFromState(GoRouterState state) {
  return state.pathParameters['courseId'] ?? '';
}

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  late final GoRouter _router;
  late final ValueNotifier<bool> _authRefreshNotifier;

  @override
  void initState() {
    super.initState();
    _authRefreshNotifier = ValueNotifier(false);
    _router = GoRouter(
      initialLocation: '/splash',
      refreshListenable: _authRefreshNotifier,
      redirect: (context, state) {
        final authState = context.read<AuthCubit>().state;
        final location = state.matchedLocation;
        final isAuthPage = ['/splash', '/login', '/register', '/verify-email', '/forgot-password', '/reset-password', '/mobile-otp'].contains(location);

        // ====== Auth checking / splash ======
        if (authState is AuthInitial || authState is AuthLoading) {
          if (!isAuthPage) return '/splash';
          return null;
        }

        // ====== Registration OTP flow ======
        if (authState is AuthOtpSent) {
          if (location == '/verify-email') return null;
          return '/verify-email';
        }

        if (authState is AuthEmailVerified) {
          if (location == '/login') return null;
          return '/login';
        }

        // ====== Login with unverified email ======
        if (authState is AuthEmailNotVerified) {
          if (location == '/verify-email') return null;
          return '/verify-email';
        }

        // ====== Authenticated ======
        if (authState is AuthAuthenticated) {
          final isInstructor = authState.user.role == UserRole.instructor;

          // Redirect off auth pages to role-based dashboard
          if (isAuthPage) {
            return isInstructor ? '/instructor/dashboard' : '/dashboard';
          }

          // Guard instructor-only routes from learners
          if (!isInstructor &&
              (location.startsWith('/courses') && location != '/courses' ||
                  location.startsWith('/instructor/'))) {
            return '/dashboard';
          }

          return null;
        }

        // ====== Unauthenticated ======
        final publicRoutes = ['/login', '/register', '/verify-email', '/forgot-password', '/reset-password', '/mobile-otp'];
        if (!publicRoutes.contains(location)) {
          return '/login';
        }

        return null;
      },
      routes: [
        GoRoute(
          path: '/splash',
          name: 'splash',
          builder: (context, state) => const SplashPage(),
        ),
        GoRoute(
          path: '/login',
          name: 'login',
          builder: (context, state) => const LoginPage(),
        ),
        GoRoute(
          path: '/register',
          name: 'register',
          builder: (context, state) => const RegisterPage(),
        ),
        GoRoute(
          path: '/verify-email',
          name: 'verifyEmail',
          builder: (context, state) => const VerifyEmailPage(),
        ),
        GoRoute(
          path: '/forgot-password',
          name: 'forgotPassword',
          builder: (context, state) => const ForgotPasswordPage(),
        ),
        GoRoute(
          path: '/reset-password',
          name: 'resetPassword',
          builder: (context, state) => const ResetPasswordPage(),
        ),
        GoRoute(
          path: '/mobile-otp',
          name: 'mobileOtp',
          builder: (context, state) => const MobileOtpPage(),
        ),
        GoRoute(
          path: '/dashboard',
          name: 'dashboard',
          builder: (context, state) => const DashboardPage(),
        ),
        GoRoute(
          path: '/courses',
          name: 'courses',
          builder: (context, state) => const CoursesPage(),
        ),
        GoRoute(
          path: '/courses/:courseId/contents',
          name: 'contents',
          builder: (context, state) => ContentsPage(
            courseId: _courseIdFromState(state),
          ),
        ),
        GoRoute(
          path: '/courses/:courseId/enrollments',
          name: 'enrollments',
          builder: (context, state) => EnrollmentsPage(
            courseId: _courseIdFromState(state),
          ),
        ),
        GoRoute(
          path: '/instructor/dashboard',
          name: 'instructorDashboard',
          builder: (context, state) => const DashboardPage(),
        ),
        GoRoute(
          path: '/instructor/students',
          name: 'instructorStudents',
          builder: (context, state) => const StudentsPage(),
        ),
        GoRoute(
          path: '/instructor/subscription',
          name: 'instructorSubscription',
          builder: (context, state) => const SubscriptionPage(),
        ),
        GoRoute(
          path: '/my-courses',
          name: 'myCourses',
          builder: (context, state) => const MyCoursesPage(),
        ),
        GoRoute(
          path: '/my-courses/:courseId',
          name: 'myCourseDetail',
          builder: (context, state) => MyCourseDetailPage(
            courseId: state.pathParameters['courseId'] ?? '',
          ),
        ),
        GoRoute(
          path: '/search-instructors',
          name: 'searchInstructors',
          builder: (context, state) => const SearchInstructorsPage(),
        ),
        GoRoute(
          path: '/instructors/:id',
          name: 'instructorProfile',
          builder: (context, state) => InstructorProfilePage(
            instructorId: state.pathParameters['id'] ?? '',
          ),
        ),
        GoRoute(
          path: '/my-instructors',
          name: 'myInstructors',
          builder: (context, state) => const MyInstructorsPage(),
        ),
        GoRoute(
          path: '/notifications',
          name: 'notifications',
          builder: (context, state) => const NotificationsPage(),
        ),
        GoRoute(
          path: '/profile',
          name: 'profile',
          builder: (context, state) => const ProfilePage(),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _authRefreshNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => sl<AuthCubit>()..checkAuth()),
        BlocProvider(create: (_) => sl<CourseCubit>()),
        BlocProvider(create: (_) => sl<DashboardCubit>()),
        BlocProvider(create: (_) => sl<ContentCubit>()),
        BlocProvider(create: (_) => sl<EnrollmentCubit>()),
        BlocProvider(create: (_) => sl<StudentCubit>()),
        BlocProvider(create: (_) => sl<SubscriptionCubit>()),
        BlocProvider(create: (_) => sl<ProfileCubit>()),
        BlocProvider(create: (_) => sl<MyCoursesCubit>()),
        BlocProvider(create: (_) => sl<LearnerContentCubit>()),
        BlocProvider(create: (_) => sl<InstructorCubit>()),
        BlocProvider(create: (_) => sl<NotificationCubit>()),
      ],
      child: BlocListener<AuthCubit, AuthState>(
        listener: (context, state) {
          _authRefreshNotifier.value = !_authRefreshNotifier.value;
          if (state is AuthEmailNotVerified) {
            _router.go('/verify-email', extra: state.email);
          }
        },
        child: MaterialApp.router(
          title: 'LMS',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          routerConfig: _router,
        ),
      ),
    );
  }
}
