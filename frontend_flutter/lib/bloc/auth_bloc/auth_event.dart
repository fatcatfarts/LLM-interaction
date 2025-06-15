part of 'auth_bloc.dart';
//triggering events that change state


abstract class AuthEvent extends Equatable {
  const AuthEvent();
  @override
  List<Object?> get props => [];
}

class AuthSignupRequested extends AuthEvent {
  final String email;
  final String password;
  final String? username;

  const AuthSignupRequested({required this.email, required this.password, this.username});
  @override
  List<Object?> get props => [email, password, username];
}

class AuthLoginRequested extends AuthEvent {
  final String email;
  final String password;

  const AuthLoginRequested({required this.email, required this.password});
  @override
  List<Object?> get props => [email, password];
}

class AuthLogoutRequested extends AuthEvent {}