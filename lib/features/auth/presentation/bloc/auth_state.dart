import 'package:equatable/equatable.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object? > get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthAuthenticated extends AuthState {
  final String userId;
  final String email;
  final String?  displayName;
  final bool isNewUser; // Track if this is a new signup

  const AuthAuthenticated({
    required this.userId,
    required this.email,
    this.displayName,
    this.isNewUser = false,
  });

  @override
  List<Object?> get props => [userId, email, displayName, isNewUser];
}

class AuthUnauthenticated extends AuthState {}

class AuthError extends AuthState {
  final String message;

  const AuthError(this.message);

  @override
  List<Object?> get props => [message];
}