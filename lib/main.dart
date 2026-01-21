import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

import 'core/di/injection_container.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/bloc/auth_event.dart';
import 'features/auth/presentation/bloc/auth_state.dart';
import 'features/registration/presentation/bloc/RegistrationBloc.dart';
import 'features/splash/presentation/pages/SplashScreen.dart';
import 'features/splash/presentation/pages/SignInScreen.dart';
import 'features/splash/presentation/pages/home_screen_full.dart';
import 'features/subscription/presentation/bloc/subscription_bloc.dart';
import 'features/assessment/presentation/bloc/quiz_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  print('🚀 Initializing Firebase...');
  await Firebase. initializeApp();
  print('✓ Firebase initialized successfully');

  // Initialize Stripe (set your publishable key)
  Stripe.publishableKey = 'YOUR_STRIPE_PUBLISHABLE_KEY';
  print('✓ Stripe initialized');

  // Initialize Dependencies
  await initializeDependencies();
  print('✓ Dependencies initialized');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key?  key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => sl<AuthBloc>().. add(CheckAuthStatusEvent()),
        ),
        BlocProvider(
          create: (_) => sl<RegistrationBloc>(),
        ),
        BlocProvider(
          create: (_) => sl<SubscriptionBloc>(),
        ),
        BlocProvider(
          create: (_) => sl<QuizBloc>(),
        ),
      ],
      child:  MaterialApp(
        title: 'Summit',
        debugShowCheckedModeBanner:  false,
        theme: AppTheme.lightTheme,
        home: const AuthWrapper(),
      ),
    );
  }
}

/// AuthWrapper listens to auth state changes and navigates accordingly
class AuthWrapper extends StatefulWidget {
  const AuthWrapper({Key? key}) : super(key: key);

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _showSplash = true;

  @override
  void initState() {
    super.initState();
    // Show splash for 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _showSplash = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_showSplash) {
      return const SplashScreen();
    }

    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        // Handle any auth state changes that need snackbars or other feedback
        if (state is AuthError) {
          ScaffoldMessenger. of(context).showSnackBar(
            SnackBar(
              content:  Text(state.message),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      builder: (context, state) {
        if (state is AuthLoading || state is AuthInitial) {
          return const Scaffold(
            body:  Center(
              child: CircularProgressIndicator(
                color: Color(0xFFD4AF37),
              ),
            ),
          );
        }

        if (state is AuthAuthenticated) {
          return const HomeScreen();
        }

        return const SignInScreen();
      },
    );
  }
}