import 'package:heroman/feature/data/datasources/mechanic_remote_datasource.dart';
import 'package:heroman/feature/data/models/mechanic_model.dart';
import 'package:heroman/feature/domain/entities/mechanic.dart';
import 'package:heroman/feature/domain/repositories/mechanic_repository.dart';

class MechanicRepositoryImpl implements MechanicRepository {
  final MechanicRemoteDatasource remote;
  MechanicRepositoryImpl(this.remote);

  @override
  Future<void> createMechanic(Mechanic mechanic) {
    final model = MechanicModel.fromEntity(mechanic);
    return remote.createMechanic(model);
  }

  @override
  Future<Mechanic?> getMechanicById(String id) => remote.getMechanicById(id);
}
