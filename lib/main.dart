import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

import 'core/di/injection_container.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/registration/presentation/bloc/RegistrationBloc.dart';
import 'features/splash/presentation/pages/SplashScreen.dart';
import 'features/subscription/presentation/bloc/subscription_bloc.dart';
import 'features/assessment/presentation/bloc/quiz_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  print('🚀 Initializing Firebase...');
  await Firebase.initializeApp();
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
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => sl<AuthBloc>(),
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
      child: MaterialApp(
        title: 'Summit',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const SplashScreen(),
      ),
    );
  }
}