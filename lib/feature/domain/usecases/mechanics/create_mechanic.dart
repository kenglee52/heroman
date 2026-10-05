import 'package:heroman/feature/domain/entities/mechanic.dart';
import 'package:heroman/feature/domain/repositories/mechanic_repository.dart';

class CreateMechanic {
  final MechanicRepository repository;
  CreateMechanic(this.repository);
  Future<void> call(Mechanic mechanic) {
    return repository.createMechanic(mechanic);
  }
}
