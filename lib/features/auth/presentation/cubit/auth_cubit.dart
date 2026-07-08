import 'dart:developer';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lms/core/errors/failures.dart';
import 'package:lms/features/auth/data/models/device_info_model.dart';
import 'package:lms/features/auth/domain/entities/user_entity.dart';
import 'package:lms/features/auth/domain/usecases/complete_registration_usecase.dart';
import 'package:lms/features/auth/domain/usecases/facebook_sign_in_usecase.dart';
import 'package:lms/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:lms/features/auth/domain/usecases/google_sign_in_usecase.dart';
import 'package:lms/features/auth/domain/usecases/login_usecase.dart';
import 'package:lms/features/auth/domain/usecases/logout_usecase.dart';
import 'package:lms/features/auth/domain/usecases/register_usecase.dart';
import 'package:lms/features/auth/domain/usecases/send_otp_usecase.dart';
import 'package:lms/features/auth/domain/usecases/verify_email_usecase.dart';

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

class AuthOtpSent extends AuthState {
  final String email;

  const AuthOtpSent(this.email);

  @override
  List<Object?> get props => [email];
}

class AuthEmailVerified extends AuthState {
  final String email;

  const AuthEmailVerified(this.email);

  @override
  List<Object?> get props => [email];
}

class AuthEmailNotVerified extends AuthState {
  final String email;
  final String message;

  const AuthEmailNotVerified({required this.email, required this.message});

  @override
  List<Object?> get props => [email, message];
}

class AuthRegistrationCompleted extends AuthState {
  const AuthRegistrationCompleted();
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
  final String client;
  final String? deviceToken;
  final DeviceInfo? deviceInfo;

  const LoginEvent({
    required this.email,
    required this.password,
    this.client = 'mobile',
    this.deviceToken,
    this.deviceInfo,
  });

  @override
  List<Object?> get props => [email, password, client, deviceToken, deviceInfo];
}

class RegisterEvent extends AuthEvent {
  final String firstName;
  final String lastName;
  final String email;
  final String mobileNumber;
  final String password;
  final String role;
  final String? client;

  const RegisterEvent({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.mobileNumber,
    required this.password,
    this.role = 'learner',
    this.client,
  });

  @override
  List<Object?> get props => [firstName, lastName, email, mobileNumber, password, role, client];
}

class LogoutEvent extends AuthEvent {
  const LogoutEvent();
}

class CheckAuthEvent extends AuthEvent {
  const CheckAuthEvent();
}

class SendOtpEvent extends AuthEvent {
  final String email;

  const SendOtpEvent({required this.email});

  @override
  List<Object?> get props => [email];
}

class VerifyEmailEvent extends AuthEvent {
  final String email;
  final String otp;

  const VerifyEmailEvent({required this.email, required this.otp});

  @override
  List<Object?> get props => [email, otp];
}

class CompleteRegistrationEvent extends AuthEvent {
  final String tempToken;
  final String? role;
  final String? client;

  const CompleteRegistrationEvent({
    required this.tempToken,
    this.role,
    this.client,
  });

  @override
  List<Object?> get props => [tempToken, role, client];
}

class GoogleSignInEvent extends AuthEvent {
  final String role;
  final String client;

  const GoogleSignInEvent({
    this.role = 'learner',
    this.client = 'mobile',
  });

  @override
  List<Object?> get props => [role, client];
}

class FacebookSignInEvent extends AuthEvent {
  final String role;
  final String client;

  const FacebookSignInEvent({
    this.role = 'learner',
    this.client = 'mobile',
  });

  @override
  List<Object?> get props => [role, client];
}

// ----- Cubit -----

class AuthCubit extends Cubit<AuthState> {
  final LoginUseCase loginUseCase;
  final RegisterUseCase registerUseCase;
  final LogoutUseCase logoutUseCase;
  final GetCurrentUserUseCase getCurrentUserUseCase;
  final SendOtpUseCase sendOtpUseCase;
  final VerifyEmailUseCase verifyEmailUseCase;
  final CompleteRegistrationUseCase completeRegistrationUseCase;
  final GoogleSignInUseCase googleSignInUseCase;
  final FacebookSignInUseCase facebookSignInUseCase;

  AuthCubit({
    required this.loginUseCase,
    required this.registerUseCase,
    required this.logoutUseCase,
    required this.getCurrentUserUseCase,
    required this.sendOtpUseCase,
    required this.verifyEmailUseCase,
    required this.completeRegistrationUseCase,
    required this.googleSignInUseCase,
    required this.facebookSignInUseCase,
  }) : super(const AuthInitial());

  Future<void> login({required String email, required String password}) async {
    emit(const AuthLoading());
    log('[DEBUG] Cubit login: calling loginUseCase');
    final result = await loginUseCase(
      LoginParams(email: email, password: password),
    );
    log('[DEBUG] Cubit login: result received, fold called');
    result.fold(
      (failure) {
        log('[DEBUG] Cubit login: failure branch type=${failure.runtimeType} message=${failure.message} errorCode=${failure is AuthFailure ? failure.errorCode : 'N/A'}');
        if (failure is AuthFailure && failure.errorCode == 'VERIFY_EMAIL') {
          log('[DEBUG] Cubit login: emitting AuthEmailNotVerified email=$email');
          emit(AuthEmailNotVerified(email: email, message: failure.message));
        } else {
          log('[DEBUG] Cubit login: emitting AuthError');
          emit(AuthError(_mapFailureToMessage(failure)));
        }
      },
      (user) {
        log('[DEBUG] Cubit login: success branch, emitting AuthAuthenticated');
        emit(AuthAuthenticated(user));
      },
    );
  }

  Future<void> register({
    required String firstName,
    required String lastName,
    required String email,
    required String mobileNumber,
    required String password,
    required String role,
  }) async {
    emit(const AuthLoading());
    final result = await registerUseCase(
      RegisterParams(
        firstName: firstName,
        lastName: lastName,
        email: email,
        mobileNumber: mobileNumber,
        password: password,
        role: role,
      ),
    );
    result.fold(
      (failure) => emit(AuthError(_mapFailureToMessage(failure))),
      (_) => emit(AuthOtpSent(email)),
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
    emit(const AuthLoading());
    final result = await getCurrentUserUseCase();
    result.fold(
      (failure) => emit(const AuthUnauthenticated()),
      (user) => emit(AuthAuthenticated(user)),
    );
  }

  Future<void> sendOtp({required String email}) async {
    emit(const AuthLoading());
    final result = await sendOtpUseCase(SendOtpParams(email: email));
    result.fold(
      (failure) => emit(AuthError(_mapFailureToMessage(failure))),
      (_) => emit(AuthOtpSent(email)),
    );
  }

  Future<void> verifyEmail({required String email, required String otp}) async {
    emit(const AuthLoading());
    final result = await verifyEmailUseCase(
      VerifyEmailParams(email: email, otp: otp),
    );
    result.fold(
      (failure) => emit(AuthError(_mapFailureToMessage(failure))),
      (_) => emit(AuthEmailVerified(email)),
    );
  }

  Future<void> completeRegistration({
    required String tempToken,
    String? role,
    String? client,
  }) async {
    emit(const AuthLoading());
    final result = await completeRegistrationUseCase(
      CompleteRegistrationParams(
        tempToken: tempToken,
        role: role,
        client: client,
      ),
    );
    result.fold(
      (failure) => emit(AuthError(_mapFailureToMessage(failure))),
      (_) => emit(const AuthRegistrationCompleted()),
    );
  }

  Future<void> signInWithGoogle({
    String role = 'learner',
    String client = 'mobile',
  }) async {
    emit(const AuthLoading());
    final result = await googleSignInUseCase(
      GoogleSignInParams(role: role, client: client),
    );
    result.fold(
      (failure) => emit(AuthError(_mapFailureToMessage(failure))),
      (user) => emit(AuthAuthenticated(user)),
    );
  }

  Future<void> signInWithFacebook({
    String role = 'learner',
    String client = 'mobile',
  }) async {
    emit(const AuthLoading());
    final result = await facebookSignInUseCase(
      FacebookSignInParams(role: role, client: client),
    );
    result.fold(
      (failure) => emit(AuthError(_mapFailureToMessage(failure))),
      (user) => emit(AuthAuthenticated(user)),
    );
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
