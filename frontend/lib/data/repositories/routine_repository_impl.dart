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
      ApiConstants.routines,
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
    final response = await _remote.get<Map<String, dynamic>>(
      '${ApiConstants.routineById}/$id',
      fromJson: (json) => json as Map<String, dynamic>,
    );
    if (response.isSuccess && response.data != null) {
      return RoutineModel.fromJson(response.data!);
    }
    throw ApiException(message: response.message ?? 'Routine not found');
  }

  @override
  Future<Routine> completeStep(String routineId, String stepId) async {
    final response = await _remote.post<Map<String, dynamic>>(
      ApiConstants.completeRoutineStep,
      data: {'routine_id': routineId, 'step_id': stepId},
      fromJson: (json) => json as Map<String, dynamic>,
    );
    if (response.isSuccess && response.data != null) {
      return RoutineModel.fromJson(response.data!);
    }
    throw ApiException(message: response.message ?? 'Failed to complete step');
  }

  @override
  Future<void> completeRoutine(String routineId) async {
    await _remote.post(
      '${ApiConstants.routines}/$routineId/complete',
    );
  }
}

