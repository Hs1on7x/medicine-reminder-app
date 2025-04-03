import '../models/pill.dart';
import 'pills_database.dart';

class Repository {
  final PillsDatabase _pillsDatabase = PillsDatabase.instance;

  Future<Pill> addPill(Pill pill) async {
    return await _pillsDatabase.create(pill);
  }

  Future<List<Pill>> getAllPills() async {
    return await _pillsDatabase.readAllPills();
  }

  Future<Pill> getPillById(int id) async {
    return await _pillsDatabase.readPill(id);
  }

  Future<int> updatePill(Pill pill) async {
    return await _pillsDatabase.update(pill);
  }

  Future<int> deletePill(int id) async {
    return await _pillsDatabase.delete(id);
  }
} 