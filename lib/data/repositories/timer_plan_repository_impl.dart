import '../interfaces/repository_interfaces.dart';
import '../db/sqlite_database_provider.dart';
import '../../models/timer_plan.dart';

/// SQLite implementation of [ITimerPlanRepository].
/// 
/// Follows Single Responsibility Principle - only handles TimerPlan persistence.
class TimerPlanRepositoryImpl implements ITimerPlanRepository {
  final IDatabaseProvider _dbProvider;

  TimerPlanRepositoryImpl({required IDatabaseProvider dbProvider})
      : _dbProvider = dbProvider;

  @override
  Future<String> insert(TimerPlan plan) async {
    await _dbProvider.insert(
      SqliteDatabaseProvider.tableTimerPlans,
      plan.toMap(),
    );
    print('[TimerPlanRepository] Inserted plan: ${plan.name} (${plan.id})');
    return plan.id;
  }

  @override
  Future<int> update(TimerPlan plan) async {
    final updatedPlan = plan.copyWith(updatedAt: DateTime.now());
    final result = await _dbProvider.update(
      SqliteDatabaseProvider.tableTimerPlans,
      updatedPlan.toMap(),
      where: 'id = ?',
      whereArgs: [plan.id],
    );
    print('[TimerPlanRepository] Updated plan: ${plan.name} (${plan.id})');
    return result;
  }

  @override
  Future<int> delete(String id) async {
    final result = await _dbProvider.delete(
      SqliteDatabaseProvider.tableTimerPlans,
      where: 'id = ?',
      whereArgs: [id],
    );
    print('[TimerPlanRepository] Deleted plan: $id');
    return result;
  }

  @override
  Future<TimerPlan?> getById(String id) async {
    final results = await _dbProvider.query(
      SqliteDatabaseProvider.tableTimerPlans,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (results.isEmpty) return null;
    return TimerPlan.fromMap(results.first);
  }

  @override
  Future<List<TimerPlan>> getAll() async {
    final results = await _dbProvider.query(
      SqliteDatabaseProvider.tableTimerPlans,
      orderBy: 'name ASC',
    );
    return results.map((map) => TimerPlan.fromMap(map)).toList();
  }

  @override
  Future<List<TimerPlan>> getAllByRecent() async {
    final results = await _dbProvider.query(
      SqliteDatabaseProvider.tableTimerPlans,
      orderBy: 'updated_at DESC',
    );
    return results.map((map) => TimerPlan.fromMap(map)).toList();
  }

  @override
  Future<int> count() async {
    final result = await _dbProvider.rawQuery(
      'SELECT COUNT(*) FROM ${SqliteDatabaseProvider.tableTimerPlans}',
    );
    return result.first.values.first as int? ?? 0;
  }
}
