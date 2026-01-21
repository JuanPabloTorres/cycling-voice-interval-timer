/// Abstract interfaces for Repository Pattern following SOLID principles.
/// 
/// These interfaces allow for:
/// - Dependency Inversion: Depend on abstractions, not implementations
/// - Open/Closed: Extend behavior without modifying existing code
/// - Liskov Substitution: SQLite, Memory, or Web implementations are interchangeable
library;

import '../../models/models.dart';

/// Generic repository interface for CRUD operations.
/// 
/// [T] is the entity type, [ID] is the identifier type.
abstract class IRepository<T, ID> {
  /// Inserts a new entity.
  Future<ID> insert(T entity);
  
  /// Updates an existing entity.
  Future<int> update(T entity);
  
  /// Deletes an entity by its identifier.
  Future<int> delete(ID id);
  
  /// Retrieves an entity by its identifier.
  Future<T?> getById(ID id);
  
  /// Retrieves all entities.
  Future<List<T>> getAll();
  
  /// Returns the total count of entities.
  Future<int> count();
}

/// Interface for TimerPlan repository operations.
abstract class ITimerPlanRepository extends IRepository<TimerPlan, String> {
  /// Retrieves all plans ordered by most recently updated.
  Future<List<TimerPlan>> getAllByRecent();
}

/// Interface for TimerEvent repository operations.
abstract class ITimerEventRepository extends IRepository<TimerEvent, String> {
  /// Retrieves all events for a specific plan.
  Future<List<TimerEvent>> getByPlanId(String planId);
  
  /// Inserts multiple events at once.
  Future<void> insertAll(List<TimerEvent> events);
  
  /// Deletes all events for a plan and inserts new ones.
  Future<void> replaceAllForPlan(String planId, List<TimerEvent> events);
  
  /// Retrieves events that trigger at a specific second.
  Future<List<TimerEvent>> getByTriggerSecond(String planId, int second);
}

/// Interface for RepeatRule repository operations.
abstract class IRepeatRuleRepository extends IRepository<RepeatRule, String> {
  /// Retrieves all rules for a specific plan.
  Future<List<RepeatRule>> getByPlanId(String planId);
  
  /// Inserts multiple rules at once.
  Future<void> insertAll(List<RepeatRule> rules);
  
  /// Deletes all rules for a plan and inserts new ones.
  Future<void> replaceAllForPlan(String planId, List<RepeatRule> rules);
}

/// Interface for the complete data service.
/// 
/// Aggregates repository operations and provides high-level data access.
abstract class IDataService {
  /// Retrieves a plan with all its events and rules.
  Future<TimerPlan?> getPlanWithDetails(String planId);
  
  /// Retrieves all plans with their events and rules.
  Future<List<TimerPlan>> getAllPlansWithDetails();
  
  /// Creates a new plan with its events and rules.
  Future<String> createPlan(TimerPlan plan);
  
  /// Updates a plan and replaces all its events and rules.
  Future<void> updatePlanWithDetails(TimerPlan plan);
  
  /// Deletes a plan (cascades to events and rules).
  Future<void> deletePlan(String planId);
  
  /// Generates a new unique identifier.
  String generateId();
  
  /// Returns database statistics.
  Future<Map<String, int>> getStatistics();
  
  /// Creates demo data for first-time users.
  Future<void> createDemoPlan();
  
  /// Closes any open connections.
  Future<void> close();
}

/// Interface for database provider abstraction.
/// 
/// Allows switching between SQLite, in-memory, or web storage.
abstract class IDatabaseProvider {
  /// Initializes the database connection.
  Future<void> initialize();
  
  /// Executes a raw query.
  Future<List<Map<String, dynamic>>> query(
    String table, {
    List<String>? columns,
    String? where,
    List<Object?>? whereArgs,
    String? orderBy,
    int? limit,
  });
  
  /// Inserts a row into a table.
  Future<int> insert(String table, Map<String, dynamic> values);
  
  /// Updates rows in a table.
  Future<int> update(
    String table,
    Map<String, dynamic> values, {
    String? where,
    List<Object?>? whereArgs,
  });
  
  /// Deletes rows from a table.
  Future<int> delete(String table, {String? where, List<Object?>? whereArgs});
  
  /// Executes a raw SQL statement.
  Future<void> execute(String sql);
  
  /// Executes a raw query and returns results.
  Future<List<Map<String, dynamic>>> rawQuery(String sql, [List<Object?>? arguments]);
  
  /// Closes the database connection.
  Future<void> close();
  
  /// Whether the database is initialized.
  bool get isInitialized;
}
