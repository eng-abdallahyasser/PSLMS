import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lms/core/theme/app_theme.dart';
import 'package:lms/injection_container.dart';
import 'package:lms/features/auth/domain/entities/user_entity.dart';
import 'package:lms/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:lms/features/auth/presentation/pages/login_page.dart';
import 'package:lms/features/auth/presentation/pages/register_page.dart';
import 'package:lms/features/auth/presentation/pages/verify_email_page.dart';
import 'package:lms/features/splash/presentation/pages/splash_page.dart';
import 'package:lms/features/courses/presentation/cubit/course_cubit.dart';
import 'package:lms/features/courses/presentation/pages/courses_page.dart';
import 'package:lms/features/contents/presentation/cubit/content_cubit.dart';
import 'package:lms/features/contents/presentation/pages/contents_page.dart';
import 'package:lms/features/enrollments/presentation/cubit/enrollment_cubit.dart';
import 'package:lms/features/enrollments/presentation/pages/enrollments_page.dart';
import 'package:lms/features/dashboard/presentation/cubit/dashboard_cubit.dart';
import 'package:lms/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:lms/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:lms/features/profile/presentation/pages/profile_page.dart';

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

        if (authState is AuthInitial || authState is AuthLoading) {
          return location == '/splash' ? null : '/splash';
        }

        if (authState is AuthAuthenticated) {
          if (location == '/splash' || location == '/login') {
            return authState.user.role == UserRole.instructor
                ? '/instructor/dashboard'
                : '/dashboard';
          }
          return null;
        }

        if (authState is AuthUnauthenticated) {
          final publicRoutes = ['/login', '/register', '/verify-email'];
          if (!publicRoutes.contains(location)) {
            return '/login';
          }
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
        BlocProvider(create: (_) => sl<ProfileCubit>()),
      ],
      child: BlocListener<AuthCubit, AuthState>(
        listener: (_, _) {
          _authRefreshNotifier.value = !_authRefreshNotifier.value;
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
