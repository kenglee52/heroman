import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:heroman/feature/domain/entities/mechanic.dart';
import 'package:heroman/feature/domain/usecases/mechanics/create_mechanic.dart';
import 'package:heroman/feature/domain/usecases/mechanics/get_mechanic_by_id.dart';


abstract class MechanicEvent {}

class CreateMechanicEvent extends MechanicEvent {
  final Mechanic mechanic;

  CreateMechanicEvent({
    required this.mechanic,
  });
}

class LoadMechanicById extends MechanicEvent {
  final String id;

  LoadMechanicById({
    required this.id,
  });
}


abstract class MechanicState {}

class MechanicInitial extends MechanicState {}

class MechanicLoading extends MechanicState {}

class MechanicCreated extends MechanicState {}

class MechanicLoaded extends MechanicState {
  final Mechanic? mechanic;

  MechanicLoaded({
    required this.mechanic,
  });
}

class MechanicError extends MechanicState {
  final String message;

  MechanicError({
    required this.message,
  });
}


class MechanicBloc extends Bloc<MechanicEvent, MechanicState> {
  final CreateMechanic createMechanicUsecase;
  final GetMechanicById getMechanicByIdUsecase;

  MechanicBloc({
    required this.createMechanicUsecase,
    required this.getMechanicByIdUsecase,
  }) : super(MechanicInitial()) {
    on<CreateMechanicEvent>(_createMechanic);
    on<LoadMechanicById>(_loadMechanicById);
  }

  Future<void> _createMechanic(
    CreateMechanicEvent event,
    Emitter<MechanicState> emit,
  ) async {
    emit(MechanicLoading());

    try {
      await createMechanicUsecase(event.mechanic);

      emit(MechanicCreated());
    } catch (e) {
      emit(
        MechanicError(
          message: e.toString(),
        ),
      );
    }
  }

  Future<void> _loadMechanicById(
    LoadMechanicById event,
    Emitter<MechanicState> emit,
  ) async {
    emit(MechanicLoading());

    try {
      final mechanic = await getMechanicByIdUsecase(event.id);

      emit(
        MechanicLoaded(
          mechanic: mechanic,
        ),
      );
    } catch (e) {
      emit(
        MechanicError(
          message: e.toString(),
        ),
      );
    }
  }
}