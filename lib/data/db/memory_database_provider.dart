import '../interfaces/repository_interfaces.dart';

/// In-memory implementation of [IDatabaseProvider].
/// 
/// Used for web platform or testing where SQLite is not available.
/// Data persists only during the app session.
class MemoryDatabaseProvider implements IDatabaseProvider {
  final Map<String, List<Map<String, dynamic>>> _tables = {};
  bool _isInitialized = false;

  // Table names (same as SQLite for consistency)
  static const String tableTimerPlans = 'timer_plans';
  static const String tableTimerEvents = 'timer_events';
  static const String tableRepeatRules = 'repeat_rules';

  @override
  bool get isInitialized => _isInitialized;

  @override
  Future<void> initialize() async {
    if (_isInitialized) return;

    _tables[tableTimerPlans] = [];
    _tables[tableTimerEvents] = [];
    _tables[tableRepeatRules] = [];

    _isInitialized = true;
    print('[MemoryDatabaseProvider] In-memory database initialized');
  }

  @override
  Future<List<Map<String, dynamic>>> query(
    String table, {
    List<String>? columns,
    String? where,
    List<Object?>? whereArgs,
    String? orderBy,
    int? limit,
  }) async {
    await _ensureInitialized();
    
    var results = List<Map<String, dynamic>>.from(_tables[table] ?? []);
    
    // Apply WHERE clause
    if (where != null && whereArgs != null) {
      results = _applyWhere(results, where, whereArgs);
    }
    
    // Apply ORDER BY
    if (orderBy != null) {
      results = _applyOrderBy(results, orderBy);
    }
    
    // Apply LIMIT
    if (limit != null && results.length > limit) {
      results = results.take(limit).toList();
    }
    
    // Apply column selection
    if (columns != null) {
      results = results.map((row) {
        return Map.fromEntries(
          row.entries.where((e) => columns.contains(e.key)),
        );
      }).toList();
    }
    
    return results;
  }

  @override
  Future<int> insert(String table, Map<String, dynamic> values) async {
    await _ensureInitialized();
    
    final tableData = _tables[table];
    if (tableData == null) return 0;
    
    // Check for existing record with same ID (replace)
    final id = values['id'];
    if (id != null) {
      tableData.removeWhere((row) => row['id'] == id);
    }
    
    tableData.add(Map<String, dynamic>.from(values));
    return 1;
  }

  @override
  Future<int> update(
    String table,
    Map<String, dynamic> values, {
    String? where,
    List<Object?>? whereArgs,
  }) async {
    await _ensureInitialized();
    
    final tableData = _tables[table];
    if (tableData == null) return 0;
    
    int updatedCount = 0;
    
    for (int i = 0; i < tableData.length; i++) {
      if (_matchesWhere(tableData[i], where, whereArgs)) {
        tableData[i] = {...tableData[i], ...values};
        updatedCount++;
      }
    }
    
    return updatedCount;
  }

  @override
  Future<int> delete(String table, {String? where, List<Object?>? whereArgs}) async {
    await _ensureInitialized();
    
    final tableData = _tables[table];
    if (tableData == null) return 0;
    
    final initialLength = tableData.length;
    
    if (where == null) {
      tableData.clear();
    } else {
      tableData.removeWhere((row) => _matchesWhere(row, where, whereArgs));
    }
    
    final deletedCount = initialLength - tableData.length;
    
    // Cascade delete for foreign keys
    if (table == tableTimerPlans && deletedCount > 0) {
      await _cascadeDelete(whereArgs);
    }
    
    return deletedCount;
  }

  @override
  Future<void> execute(String sql) async {
    // No-op for memory database
  }

  @override
  Future<List<Map<String, dynamic>>> rawQuery(String sql, [List<Object?>? arguments]) async {
    await _ensureInitialized();
    
    // Handle COUNT queries
    if (sql.toUpperCase().contains('SELECT COUNT(*)')) {
      final tableMatch = RegExp(r'FROM\s+(\w+)', caseSensitive: false).firstMatch(sql);
      if (tableMatch != null) {
        final table = tableMatch.group(1);
        final count = _tables[table]?.length ?? 0;
        return [{'COUNT(*)': count}];
      }
    }
    
    return [];
  }

  @override
  Future<void> close() async {
    _tables.clear();
    _isInitialized = false;
  }

  Future<void> _ensureInitialized() async {
    if (!_isInitialized) {
      await initialize();
    }
  }

  List<Map<String, dynamic>> _applyWhere(
    List<Map<String, dynamic>> data,
    String where,
    List<Object?> whereArgs,
  ) {
    return data.where((row) => _matchesWhere(row, where, whereArgs)).toList();
  }

  bool _matchesWhere(Map<String, dynamic> row, String? where, List<Object?>? whereArgs) {
    if (where == null || whereArgs == null) return true;
    
    // Parse simple WHERE clauses like "id = ?" or "plan_id = ?"
    final match = RegExp(r'(\w+)\s*=\s*\?').firstMatch(where);
    if (match != null && whereArgs.isNotEmpty) {
      final column = match.group(1);
      final value = whereArgs.first;
      return row[column] == value;
    }
    
    return true;
  }

  List<Map<String, dynamic>> _applyOrderBy(
    List<Map<String, dynamic>> data,
    String orderBy,
  ) {
    final parts = orderBy.split(' ');
    final column = parts.first;
    final descending = parts.length > 1 && parts[1].toUpperCase() == 'DESC';
    
    final sorted = List<Map<String, dynamic>>.from(data);
    sorted.sort((a, b) {
      final aVal = a[column];
      final bVal = b[column];
      
      if (aVal == null && bVal == null) return 0;
      if (aVal == null) return descending ? -1 : 1;
      if (bVal == null) return descending ? 1 : -1;
      
      int result;
      if (aVal is Comparable) {
        result = aVal.compareTo(bVal);
      } else {
        result = aVal.toString().compareTo(bVal.toString());
      }
      
      return descending ? -result : result;
    });
    
    return sorted;
  }

  Future<void> _cascadeDelete(List<Object?>? whereArgs) async {
    if (whereArgs == null || whereArgs.isEmpty) return;
    
    final planId = whereArgs.first;
    
    _tables[tableTimerEvents]?.removeWhere((row) => row['plan_id'] == planId);
    _tables[tableRepeatRules]?.removeWhere((row) => row['plan_id'] == planId);
  }

  /// Clears all data (for testing).
  void clear() {
    for (final table in _tables.values) {
      table.clear();
    }
  }
}
