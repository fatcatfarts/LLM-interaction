part of 'auth_bloc.dart';
// this file manages the state

abstract class AuthState extends Equatable {// equatable is a package to compare 2 quantities of the same class
  const AuthState();
  @override
  List<Object?> get props => []; // a getter that equatable wants us to override
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthAuthenticated extends AuthState {
  final User user;
  const AuthAuthenticated(this.user);
  @override
  List<Object?> get props => [user];
}

class AuthUnauthenticated extends AuthState {}

class AuthFailure extends AuthState {
  final String message;
  const AuthFailure(this.message);
  @override
  List<Object?> get props => [message];
}