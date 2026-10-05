import 'package:heroman/feature/domain/entities/mechanic.dart';

abstract class MechanicRepository {
  Future<Mechanic?> getMechanicById(String id);
  Future<void> createMechanic(Mechanic mechanic);
}
