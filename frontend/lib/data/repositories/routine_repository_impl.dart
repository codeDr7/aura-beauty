import '../../core/constants/api_constants.dart';
import '../../domain/entities/routine.dart';
import '../../domain/repositories/routine_repository.dart';
import '../../core/network/api_exceptions.dart';
import '../datasources/remote_data_source.dart';
import '../models/routine_model.dart';

class RoutineRepositoryImpl implements RoutineRepository {
  final RemoteDataSource _remote;

  RoutineRepositoryImpl(this._remote);

  @override
  Future<List<Routine>> getRoutines() async {
    final response = await _remote.get<List<dynamic>>(
      ApiConstants.getRoutines,
      fromJson: (json) => json as List<dynamic>,
    );
    if (response.isSuccess && response.data != null) {
      return response.data!
          .map((e) => RoutineModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    throw ApiException(message: response.message ?? 'Failed to load routines');
  }

  @override
  Future<Routine> getRoutineById(String id) async {
    throw ApiException(message: 'Use getRoutines instead');
  }

  @override
  Future<Routine> completeStep(String routineId, String stepRowName) async {
    final response = await _remote.post<Map<String, dynamic>>(
      ApiConstants.completeStep,
      data: {'routine_id': routineId, 'step_row_name': stepRowName},
      fromJson: (json) => json as Map<String, dynamic>,
    );
    if (response.isSuccess && response.data != null) {
      return RoutineModel.fromJson(response.data!);
    }
    throw ApiException(message: response.message ?? 'Failed to complete step');
  }

  @override
  Future<void> completeRoutine(String routineId) async {
    throw ApiException(message: 'Complete steps individually');
  }
}
