import 'package:heroman/feature/domain/entities/mechanic.dart';
import 'package:heroman/feature/domain/repositories/mechanic_repository.dart';

class GetMechanicById {
  final MechanicRepository repository;
  GetMechanicById(this.repository);

  Future<Mechanic?> call(String id) {
    return repository.getMechanicById(id);
  }
}
