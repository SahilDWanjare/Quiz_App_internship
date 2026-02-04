import 'package:get_it/get_it.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';

// Auth imports
import '../../features/assessment/data/repository/assessment_repository.dart';
import '../../features/auth/data/datasources/auth_remote_data_source.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/sign_in_usecase.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';

// Registration imports
import '../../features/registration/domain/repository/RegistrationRepository.dart';
import '../../features/registration/domain/usecases/SubmitRegistrationUseCase.dart';
import '../../features/registration/presentation/bloc/RegistrationBloc.dart';
import '../../features/registration/data/repositories/registration_repository_impl.dart';
import '../../features/registration/data/datasources/firestore_service.dart';

// Subscription imports
import '../../features/subscription/data/repository/subscription_repository.dart';
import '../../features/subscription/presentation/bloc/subscription_bloc.dart';
import '../../features/subscription/data/services/payment_service.dart';

// Assessment imports
import '../../features/assessment/presentation/bloc/quiz_bloc.dart';

final sl = GetIt.instance;

Future<void> initializeDependencies() async {
  // ==================== EXTERNAL ====================
  sl.registerLazySingleton(() => FirebaseAuth.instance);
  sl.registerLazySingleton(() => FirebaseFirestore.instance);
  sl.registerLazySingleton(() => GoogleSignIn());
  sl.registerLazySingleton(() => FacebookAuth.instance);

  // ==================== DATA SOURCES ====================
  sl.registerLazySingleton<FirebaseAuthService>(
        () => FirebaseAuthServiceImpl(
      firebaseAuth: sl(),
      googleSignIn: sl(),
      facebookAuth: sl(),
    ),
  );

  sl.registerLazySingleton<FirestoreService>(
        () => FirestoreServiceImpl(firestore: sl()),
  );

  // ==================== REPOSITORIES ====================

  // Auth Repository
  sl.registerLazySingleton<AuthRepository>(
        () => AuthRepositoryImpl(firebaseAuthService: sl()),
  );

  // Registration Repository
  sl.registerLazySingleton<RegistrationRepository>(
        () => RegistrationRepositoryImpl(firestoreService: sl()),
  );

  // Subscription Repository
  sl.registerLazySingleton<SubscriptionRepository>(
        () => SubscriptionRepository(firestore: sl()),
  );

  // Assessment Repository
  sl.registerLazySingleton<AssessmentRepository>(
        () => AssessmentRepository(firestore: sl()),
  );

  // ==================== PAYMENT SERVICES ====================
  sl.registerLazySingleton<RazorpayService>(() => RazorpayService());
  sl.registerLazySingleton<StripeService>(() => StripeService());
  sl.registerLazySingleton<LocationService>(() => LocationService());

  // ==================== USE CASES ====================

  // Auth Use Cases
  sl.registerLazySingleton(() => SignInUseCase(sl()));
  sl.registerLazySingleton(() => SignUpUseCase(sl()));
  sl.registerLazySingleton(() => SignInWithGoogleUseCase(sl()));
  sl.registerLazySingleton(() => SignInWithFacebookUseCase(sl()));
  sl.registerLazySingleton(() => SignOutUseCase(sl()));
  sl.registerLazySingleton(() => GetCurrentUserUseCase(sl()));

  // Registration Use Cases
  sl.registerLazySingleton(() => SubmitRegistrationUseCase(sl()));

  // ==================== BLOCS ====================

  // Auth Bloc
  sl.registerFactory(
        () => AuthBloc(
      signInUseCase: sl(),
      signUpUseCase: sl(),
      signInWithGoogleUseCase: sl(),
      signInWithFacebookUseCase: sl(),
      signOutUseCase: sl(),
      getCurrentUserUseCase: sl(),
    ),
  );

  // Registration Bloc
  sl.registerFactory(
        () => RegistrationBloc(
      submitRegistrationUseCase: sl(),
    ),
  );

  // Subscription Bloc
  sl.registerFactory(
        () => SubscriptionBloc(
      subscriptionRepository: sl(),
      razorpayService: sl(),
      stripeService: sl(),
      locationService: sl(),
    ),
  );

  // Quiz Bloc
  sl.registerFactory(
        () => QuizBloc(
      assessmentRepository: sl(),
    ),
  );
}
