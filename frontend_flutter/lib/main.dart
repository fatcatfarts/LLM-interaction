import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'bloc/auth_bloc/auth_bloc.dart';
import 'bloc/llm_bloc/llm_bloc.dart';
import 'data/repositories/auth_repository.dart';
import 'data/repositories/llm_repository.dart';
import 'presentation/ui/chat_page.dart';
import 'presentation/ui/login_page.dart';
import 'presentation/ui/signup_page.dart';
import 'routes/app_routes.dart';

void main() {
  // Initialize repositories (no DI, so we do it here or pass them down)
  final authRepository = AuthRepository();
  final llmRepository = LlmRepository();

  runApp(MyApp(authRepository: authRepository, llmRepository: llmRepository));
}

class MyApp extends StatelessWidget {
  final AuthRepository authRepository;
  final LlmRepository llmRepository;

  const MyApp({
    super.key,
    required this.authRepository,
    required this.llmRepository,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (context) => AuthBloc(authRepository: authRepository),
        ),
        BlocProvider<LlmBloc>(
          create: (context) => LlmBloc(
            llmRepository: llmRepository,
            authBloc: BlocProvider.of<AuthBloc>(context),
          ),
        ),
      ],
      child: MaterialApp(
        title: 'LLM Chat App',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
            primarySwatch: Colors.teal,
            visualDensity: VisualDensity.adaptivePlatformDensity,
            inputDecorationTheme: InputDecorationTheme(
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            )
        ),
        initialRoute: AppRoutes.login,
        routes: {
          AppRoutes.login: (context) => const LoginPage(),
          AppRoutes.signup: (context) => const SignupPage(),
          AppRoutes.chat: (context) => const ChatPage(),
        },
        builder: (context, child) {
          return BlocListener<AuthBloc, AuthState>(
            listener: (context, state) {
              final navigator = Navigator.of(context);
              if (state is AuthAuthenticated) {
                final currentRoute = ModalRoute.of(context)?.settings.name;
                if (currentRoute == AppRoutes.login || currentRoute == AppRoutes.signup) {
                  navigator.pushNamedAndRemoveUntil(AppRoutes.chat, (route) => false);
                }
              } else if (state is AuthUnauthenticated && state is! AuthInitial) {
                final currentRoute = ModalRoute.of(context)?.settings.name;
                if (currentRoute != AppRoutes.login && currentRoute != AppRoutes.signup) {
                  navigator.pushNamedAndRemoveUntil(AppRoutes.login, (route) => false);
                }
              }
            },
            child: child!,
          );
        },
      ),
    );
  }
}