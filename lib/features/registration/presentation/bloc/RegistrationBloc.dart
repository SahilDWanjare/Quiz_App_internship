import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:test_app_project/features/registration/domain/usecases/SubmitRegistrationUseCase.dart';
import 'RegistrationEvent.dart';
import 'RegistrationState.dart';

class RegistrationBloc extends Bloc<RegistrationEvent, RegistrationState> {
  final SubmitRegistrationUseCase submitRegistrationUseCase;

  RegistrationBloc({
    required this.submitRegistrationUseCase,
  }) : super(RegistrationInitial()) {
    on<SubmitRegistrationEvent>(_onSubmitRegistration);
  }

  Future<void> _onSubmitRegistration(
      SubmitRegistrationEvent event,
      Emitter<RegistrationState> emit,
      ) async {
    print('========================================');
    print('REGISTRATION BLOC:  Received SubmitRegistrationEvent');
    print('REGISTRATION BLOC:  userId = "${event. userId}"');
    print('REGISTRATION BLOC: userId length = ${event. userId.length}');
    print('REGISTRATION BLOC: userId isEmpty = ${event. userId.isEmpty}');
    print('REGISTRATION BLOC: name = "${event.name}"');
    print('REGISTRATION BLOC: mobileNo = "${event.mobileNo}"');
    print('REGISTRATION BLOC: companyName = "${event.companyName}"');
    print('REGISTRATION BLOC: designation = "${event.designation}"');
    print('REGISTRATION BLOC:  address = "${event. address}"');
    print('REGISTRATION BLOC: gender = "${event.gender}"');
    print('========================================');

    // Validate userId before proceeding
    if (event.userId.isEmpty) {
      print('REGISTRATION BLOC: ✗ ERROR - userId is empty!');
      emit(const RegistrationError('User ID is missing.  Please sign in again.'));
      return;
    }

    emit(RegistrationLoading());
    print('REGISTRATION BLOC:  Emitted RegistrationLoading state');

    try {
      final result = await submitRegistrationUseCase.call(
        RegistrationParams(
          userId:  event.userId,
          name: event. name,
          mobileNo: event. mobileNo,
          companyName:  event.companyName,
          designation:  event.designation,
          address: event. address,
          gender: event.gender,
        ),
      );

      result.fold(
            (failure) {
          print('REGISTRATION BLOC:  ✗ Registration FAILED: ${failure.message}');
          emit(RegistrationError(failure.message));
        },
            (_) {
          print('REGISTRATION BLOC: ✓ Registration SUCCESS');
          emit(RegistrationSuccess());
        },
      );
    } catch (e, stackTrace) {
      print('REGISTRATION BLOC: ✗ EXCEPTION:  $e');
      print('REGISTRATION BLOC: StackTrace: $stackTrace');
      emit(RegistrationError('An unexpected error occurred:  $e'));
    }
  }
}