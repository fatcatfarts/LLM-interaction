import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../data/models/user_model.dart';
import '../../data/repositories/auth_repository.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;
  User? _currentUser;

  User? get currentUser => _currentUser;

  AuthBloc({required this.authRepository}) : super(AuthInitial()) {
    on<AuthSignupRequested>(_onSignupRequested);
    on<AuthLoginRequested>(_onLoginRequested);
    on<AuthLogoutRequested>(_onLogoutRequested);
  }

  Future<void> _onSignupRequested(
      AuthSignupRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final user = await authRepository.signup(
        email: event.email,
        password: event.password,
        username: event.username,
      );
      _currentUser = user;
      emit(AuthAuthenticated(user));
    } catch (e) {
      emit(AuthFailure(e.toString().replaceFirst("Exception: ", "")));
      emit(AuthUnauthenticated());
    }
  }

  Future<void> _onLoginRequested(
      AuthLoginRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final user = await authRepository.login(
        email: event.email,
        password: event.password,
      );
      _currentUser = user;
      emit(AuthAuthenticated(user));
    } catch (e) {
      emit(AuthFailure(e.toString().replaceFirst("Exception: ", "")));
      emit(AuthUnauthenticated());
    }
  }

  void _onLogoutRequested(AuthLogoutRequested event, Emitter<AuthState> emit) {
    _currentUser = null;
    emit(AuthUnauthenticated());
  }
}