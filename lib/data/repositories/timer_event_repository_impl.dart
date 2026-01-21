import '../interfaces/repository_interfaces.dart';
import '../db/sqlite_database_provider.dart';
import '../../models/timer_event.dart';

/// SQLite implementation of [ITimerEventRepository].
/// 
/// Follows Single Responsibility Principle - only handles TimerEvent persistence.
class TimerEventRepositoryImpl implements ITimerEventRepository {
  final IDatabaseProvider _dbProvider;

  TimerEventRepositoryImpl({required IDatabaseProvider dbProvider})
      : _dbProvider = dbProvider;

  @override
  Future<String> insert(TimerEvent entity) async {
    await _dbProvider.insert(
      SqliteDatabaseProvider.tableTimerEvents,
      entity.toMap(),
    );
    return entity.id;
  }

  @override
  Future<int> update(TimerEvent entity) async {
    return await _dbProvider.update(
      SqliteDatabaseProvider.tableTimerEvents,
      entity.toMap(),
      where: 'id = ?',
      whereArgs: [entity.id],
    );
  }

  @override
  Future<int> delete(String id) async {
    return await _dbProvider.delete(
      SqliteDatabaseProvider.tableTimerEvents,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  @override
  Future<TimerEvent?> getById(String id) async {
    final results = await _dbProvider.query(
      SqliteDatabaseProvider.tableTimerEvents,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (results.isEmpty) return null;
    return TimerEvent.fromMap(results.first);
  }

  @override
  Future<List<TimerEvent>> getAll() async {
    final results = await _dbProvider.query(
      SqliteDatabaseProvider.tableTimerEvents,
      orderBy: 'trigger_at_second ASC',
    );
    return results.map((map) => TimerEvent.fromMap(map)).toList();
  }

  @override
  Future<int> count() async {
    final result = await _dbProvider.rawQuery(
      'SELECT COUNT(*) FROM ${SqliteDatabaseProvider.tableTimerEvents}',
    );
    return result.first.values.first as int? ?? 0;
  }

  @override
  Future<List<TimerEvent>> getByPlanId(String planId) async {
    final results = await _dbProvider.query(
      SqliteDatabaseProvider.tableTimerEvents,
      where: 'plan_id = ?',
      whereArgs: [planId],
      orderBy: 'trigger_at_second ASC',
    );
    return results.map((map) => TimerEvent.fromMap(map)).toList();
  }

  @override
  Future<void> insertAll(List<TimerEvent> events) async {
    for (final event in events) {
      await insert(event);
    }
  }

  @override
  Future<void> replaceAllForPlan(String planId, List<TimerEvent> events) async {
    // Delete existing events for this plan
    await _dbProvider.delete(
      SqliteDatabaseProvider.tableTimerEvents,
      where: 'plan_id = ?',
      whereArgs: [planId],
    );
    
    // Insert new events
    await insertAll(events);
  }

  @override
  Future<List<TimerEvent>> getByTriggerSecond(String planId, int second) async {
    final results = await _dbProvider.query(
      SqliteDatabaseProvider.tableTimerEvents,
      where: 'plan_id = ? AND trigger_at_second = ?',
      whereArgs: [planId, second],
    );
    return results.map((map) => TimerEvent.fromMap(map)).toList();
  }
}
