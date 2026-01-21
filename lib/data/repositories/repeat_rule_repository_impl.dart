import '../interfaces/repository_interfaces.dart';
import '../db/sqlite_database_provider.dart';
import '../../models/repeat_rule.dart';

/// SQLite implementation of [IRepeatRuleRepository].
/// 
/// Follows Single Responsibility Principle - only handles RepeatRule persistence.
class RepeatRuleRepositoryImpl implements IRepeatRuleRepository {
  final IDatabaseProvider _dbProvider;

  RepeatRuleRepositoryImpl({required IDatabaseProvider dbProvider})
      : _dbProvider = dbProvider;

  @override
  Future<String> insert(RepeatRule entity) async {
    await _dbProvider.insert(
      SqliteDatabaseProvider.tableRepeatRules,
      entity.toMap(),
    );
    return entity.id;
  }

  @override
  Future<int> update(RepeatRule entity) async {
    return await _dbProvider.update(
      SqliteDatabaseProvider.tableRepeatRules,
      entity.toMap(),
      where: 'id = ?',
      whereArgs: [entity.id],
    );
  }

  @override
  Future<int> delete(String id) async {
    return await _dbProvider.delete(
      SqliteDatabaseProvider.tableRepeatRules,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  @override
  Future<RepeatRule?> getById(String id) async {
    final results = await _dbProvider.query(
      SqliteDatabaseProvider.tableRepeatRules,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (results.isEmpty) return null;
    return RepeatRule.fromMap(results.first);
  }

  @override
  Future<List<RepeatRule>> getAll() async {
    final results = await _dbProvider.query(
      SqliteDatabaseProvider.tableRepeatRules,
      orderBy: 'start_at_second ASC',
    );
    return results.map((map) => RepeatRule.fromMap(map)).toList();
  }

  @override
  Future<int> count() async {
    final result = await _dbProvider.rawQuery(
      'SELECT COUNT(*) FROM ${SqliteDatabaseProvider.tableRepeatRules}',
    );
    return result.first.values.first as int? ?? 0;
  }

  @override
  Future<List<RepeatRule>> getByPlanId(String planId) async {
    final results = await _dbProvider.query(
      SqliteDatabaseProvider.tableRepeatRules,
      where: 'plan_id = ?',
      whereArgs: [planId],
      orderBy: 'start_at_second ASC',
    );
    return results.map((map) => RepeatRule.fromMap(map)).toList();
  }

  @override
  Future<void> insertAll(List<RepeatRule> rules) async {
    for (final rule in rules) {
      await insert(rule);
    }
  }

  @override
  Future<void> replaceAllForPlan(String planId, List<RepeatRule> rules) async {
    // Delete existing rules for this plan
    await _dbProvider.delete(
      SqliteDatabaseProvider.tableRepeatRules,
      where: 'plan_id = ?',
      whereArgs: [planId],
    );
    
    // Insert new rules
    await insertAll(rules);
  }
}
