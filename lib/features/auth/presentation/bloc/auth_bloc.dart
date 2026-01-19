import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/sign_in_usecase.dart'; // Import NoParams from domain
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final SignInUseCase signInUseCase;
  final SignUpUseCase signUpUseCase;
  final SignInWithGoogleUseCase signInWithGoogleUseCase;
  final SignInWithFacebookUseCase signInWithFacebookUseCase;
  final SignOutUseCase signOutUseCase;
  final GetCurrentUserUseCase getCurrentUserUseCase;

  AuthBloc({
    required this.signInUseCase,
    required this.signUpUseCase,
    required this.signInWithGoogleUseCase,
    required this.signInWithFacebookUseCase,
    required this.signOutUseCase,
    required this.getCurrentUserUseCase,
  }) : super(AuthInitial()) {
    on<SignInWithEmailEvent>(_onSignInWithEmail);
    on<SignUpWithEmailEvent>(_onSignUpWithEmail);
    on<SignInWithGoogleEvent>(_onSignInWithGoogle);
    on<SignInWithFacebookEvent>(_onSignInWithFacebook);
    on<SignOutEvent>(_onSignOut);
    on<CheckAuthStatusEvent>(_onCheckAuthStatus);
  }

  Future<void> _onSignInWithEmail(
      SignInWithEmailEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());

    final result = await signInUseCase(
      SignInParams(email: event.email, password: event.password),
    );

    result.fold(
          (failure) => emit(AuthError(failure.message)),
          (user) => emit(
        AuthAuthenticated(
          userId: user.uid,
          email: user.email,
          displayName: user.displayName,
        ),
      ),
    );
  }

  Future<void> _onSignUpWithEmail(
      SignUpWithEmailEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());

    final result = await signUpUseCase(
      SignUpParams(
        name: event.name,
        email: event.email,
        password: event.password,
      ),
    );

    result.fold(
          (failure) => emit(AuthError(failure.message)),
          (user) => emit(
        AuthAuthenticated(
          userId: user.uid,
          email: user.email,
          displayName: user.displayName,
        ),
      ),
    );
  }

  Future<void> _onSignInWithGoogle(
      SignInWithGoogleEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());

    final result = await signInWithGoogleUseCase(NoParams());

    result.fold(
          (failure) => emit(AuthError(failure.message)),
          (user) => emit(
        AuthAuthenticated(
          userId: user.uid,
          email: user.email,
          displayName: user.displayName,
        ),
      ),
    );
  }

  Future<void> _onSignInWithFacebook(
      SignInWithFacebookEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());

    final result = await signInWithFacebookUseCase(NoParams());

    result.fold(
          (failure) => emit(AuthError(failure.message)),
          (user) => emit(
        AuthAuthenticated(
          userId: user.uid,
          email: user.email,
          displayName: user.displayName,
        ),
      ),
    );
  }

  Future<void> _onSignOut(
      SignOutEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());

    final result = await signOutUseCase(NoParams());

    result.fold(
          (failure) => emit(AuthError(failure.message)),
          (_) => emit(AuthUnauthenticated()),
    );
  }

  Future<void> _onCheckAuthStatus(
      CheckAuthStatusEvent event, Emitter<AuthState> emit) async {
    final result = await getCurrentUserUseCase(NoParams());

    result.fold(
          (_) => emit(AuthUnauthenticated()),
          (user) {
        if (user != null) {
          emit(
            AuthAuthenticated(
              userId: user.uid,
              email: user.email,
              displayName: user.displayName,
            ),
          );
        } else {
          emit(AuthUnauthenticated());
        }
      },
    );
  }
}
