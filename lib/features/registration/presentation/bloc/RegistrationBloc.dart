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
    print('DEBUG REG BLOC: Received SubmitRegistrationEvent');
    print('DEBUG REG BLOC: Event userId: "${event.userId}"');
    print('DEBUG REG BLOC: Event userId length: ${event.userId.length}');
    print('DEBUG REG BLOC: Event userId isEmpty: ${event.userId.isEmpty}');
    print('DEBUG REG BLOC: Event name: ${event.name}');
    print('DEBUG REG BLOC: Event mobile: ${event.mobileNo}');
    print('========================================');

    emit(RegistrationLoading());

    final result = await submitRegistrationUseCase.call(
      RegistrationParams(
        userId: event.userId,
        name: event.name,
        mobileNo: event.mobileNo,
        companyName: event.companyName,
        designation: event.designation,
        address: event.address,
        gender: event.gender,
      ),
    );

    result.fold(
          (failure) {
        print('DEBUG REG BLOC: Registration FAILED: ${failure.message}');
        emit(RegistrationError(failure.message));
      },
          (_) {
        print('DEBUG REG BLOC: Registration SUCCESS');
        emit(RegistrationSuccess());
      },
    );
  }
}