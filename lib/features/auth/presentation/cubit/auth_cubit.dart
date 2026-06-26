import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lms/core/errors/failures.dart';
import 'package:lms/features/auth/domain/entities/user_entity.dart';
import 'package:lms/features/auth/domain/usecases/login_usecase.dart';
import 'package:lms/features/auth/domain/usecases/logout_usecase.dart';
import 'package:lms/features/auth/domain/usecases/register_usecase.dart';

// ----- States -----

sealed class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

class AuthAuthenticated extends AuthState {
  final UserEntity user;

  const AuthAuthenticated(this.user);

  @override
  List<Object?> get props => [user];
}

class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

class AuthError extends AuthState {
  final String message;

  const AuthError(this.message);

  @override
  List<Object?> get props => [message];
}

// ----- Events -----

sealed class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class LoginEvent extends AuthEvent {
  final String email;
  final String password;

  const LoginEvent({required this.email, required this.password});

  @override
  List<Object?> get props => [email, password];
}

class RegisterEvent extends AuthEvent {
  final String firstName;
  final String lastName;
  final String email;
  final String password;
  final String role;

  const RegisterEvent({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.password,
    this.role = 'learner',
  });

  @override
  List<Object?> get props => [firstName, lastName, email, password, role];
}

class LogoutEvent extends AuthEvent {
  const LogoutEvent();
}

class CheckAuthEvent extends AuthEvent {
  const CheckAuthEvent();
}

// ----- Cubit -----

class AuthCubit extends Cubit<AuthState> {
  final LoginUseCase loginUseCase;
  final RegisterUseCase registerUseCase;
  final LogoutUseCase logoutUseCase;

  AuthCubit({
    required this.loginUseCase,
    required this.registerUseCase,
    required this.logoutUseCase,
  }) : super(const AuthInitial());

  Future<void> login({required String email, required String password}) async {
    emit(const AuthLoading());
    final result = await loginUseCase(
      LoginParams(email: email, password: password),
    );
    result.fold(
      (failure) => emit(AuthError(_mapFailureToMessage(failure))),
      (user) => emit(AuthAuthenticated(user)),
    );
  }

  Future<void> register({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required String role,
  }) async {
    emit(const AuthLoading());
    final result = await registerUseCase(
      RegisterParams(
        firstName: firstName,
        lastName: lastName,
        email: email,
        password: password,
        role: role,
      ),
    );
    result.fold(
      (failure) => emit(AuthError(_mapFailureToMessage(failure))),
      (_) => emit(const AuthUnauthenticated()),
    );
  }

  Future<void> logout() async {
    emit(const AuthLoading());
    final result = await logoutUseCase();
    result.fold(
      (failure) => emit(AuthError(_mapFailureToMessage(failure))),
      (_) => emit(const AuthUnauthenticated()),
    );
  }

  Future<void> checkAuth() async {
    // Check if stored token exists; if not, user is unauthenticated.
    // Full token validation (GET /users/me) will be handled by ProfileCubit.
    emit(const AuthUnauthenticated());
  }

  String _mapFailureToMessage(Failure failure) {
    if (failure is ServerFailure) return failure.message;
    if (failure is NetworkFailure) return failure.message;
    if (failure is AuthFailure) return failure.message;
    if (failure is CacheFailure) return failure.message;
    if (failure is ValidationFailure) return failure.message;
    return failure.message;
  }
}
