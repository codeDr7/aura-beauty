import '../entities/routine.dart';

abstract class RoutineRepository {
  Future<List<Routine>> getRoutines();
  Future<Routine> getRoutineById(String id);
  Future<Routine> completeStep(String routineId, String stepRowName);
  Future<void> completeRoutine(String routineId);
}
