import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../interfaces/repository_interfaces.dart';

/// SQLite implementation of [IDatabaseProvider].
/// 
/// Uses sqflite package for native SQLite access on mobile/desktop platforms.
/// Implements singleton pattern for single database connection.
class SqliteDatabaseProvider implements IDatabaseProvider {
  static const String _databaseName = 'interval_voice_timer.db';
  static const int _databaseVersion = 1;

  // Table names
  static const String tableTimerPlans = 'timer_plans';
  static const String tableTimerEvents = 'timer_events';
  static const String tableRepeatRules = 'repeat_rules';

  Database? _database;
  bool _isInitialized = false;

  @override
  bool get isInitialized => _isInitialized;

  @override
  Future<void> initialize() async {
    if (_isInitialized) return;

    final Directory documentsDirectory = await getApplicationDocumentsDirectory();
    final String path = join(documentsDirectory.path, _databaseName);

    _database = await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
      onConfigure: _onConfigure,
    );

    _isInitialized = true;
    print('[SqliteDatabaseProvider] Database initialized at: $path');
  }

  Future<void> _onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  }

  Future<void> _onCreate(Database db, int version) async {
    // Create timer_plans table
    await db.execute('''
      CREATE TABLE $tableTimerPlans (
        id TEXT PRIMARY KEY NOT NULL,
        name TEXT NOT NULL,
        description TEXT,
        total_duration_seconds INTEGER,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    // Create timer_events table
    await db.execute('''
      CREATE TABLE $tableTimerEvents (
        id TEXT PRIMARY KEY NOT NULL,
        plan_id TEXT NOT NULL,
        trigger_at_second INTEGER NOT NULL,
        spoken_message TEXT NOT NULL,
        is_enabled INTEGER NOT NULL DEFAULT 1,
        sort_order INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY (plan_id) REFERENCES $tableTimerPlans (id) ON DELETE CASCADE
      )
    ''');

    // Create repeat_rules table
    await db.execute('''
      CREATE TABLE $tableRepeatRules (
        id TEXT PRIMARY KEY NOT NULL,
        plan_id TEXT NOT NULL,
        start_at_second INTEGER NOT NULL,
        repeat_every_seconds INTEGER NOT NULL,
        end_at_second INTEGER,
        spoken_message TEXT NOT NULL,
        is_enabled INTEGER NOT NULL DEFAULT 1,
        sort_order INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY (plan_id) REFERENCES $tableTimerPlans (id) ON DELETE CASCADE
      )
    ''');

    // Create indexes
    await db.execute('CREATE INDEX idx_events_plan_id ON $tableTimerEvents (plan_id)');
    await db.execute('CREATE INDEX idx_events_trigger ON $tableTimerEvents (trigger_at_second)');
    await db.execute('CREATE INDEX idx_rules_plan_id ON $tableRepeatRules (plan_id)');
    await db.execute('CREATE INDEX idx_plans_name ON $tableTimerPlans (name)');

    print('[SqliteDatabaseProvider] Database created with version $version');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    print('[SqliteDatabaseProvider] Upgrading from $oldVersion to $newVersion');
  }

  Future<Database> _getDb() async {
    if (!_isInitialized || _database == null) {
      await initialize();
    }
    return _database!;
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
    final db = await _getDb();
    return await db.query(
      table,
      columns: columns,
      where: where,
      whereArgs: whereArgs,
      orderBy: orderBy,
      limit: limit,
    );
  }

  @override
  Future<int> insert(String table, Map<String, dynamic> values) async {
    final db = await _getDb();
    await db.insert(table, values, conflictAlgorithm: ConflictAlgorithm.replace);
    return 1;
  }

  @override
  Future<int> update(
    String table,
    Map<String, dynamic> values, {
    String? where,
    List<Object?>? whereArgs,
  }) async {
    final db = await _getDb();
    return await db.update(table, values, where: where, whereArgs: whereArgs);
  }

  @override
  Future<int> delete(String table, {String? where, List<Object?>? whereArgs}) async {
    final db = await _getDb();
    return await db.delete(table, where: where, whereArgs: whereArgs);
  }

  @override
  Future<void> execute(String sql) async {
    final db = await _getDb();
    await db.execute(sql);
  }

  @override
  Future<List<Map<String, dynamic>>> rawQuery(String sql, [List<Object?>? arguments]) async {
    final db = await _getDb();
    return await db.rawQuery(sql, arguments);
  }

  @override
  Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
      _isInitialized = false;
    }
  }

  /// Deletes the database file (for testing/reset).
  Future<void> deleteDatabase() async {
    final Directory documentsDirectory = await getApplicationDocumentsDirectory();
    final String path = join(documentsDirectory.path, _databaseName);
    
    await close();
    
    final file = File(path);
    if (await file.exists()) {
      await file.delete();
      print('[SqliteDatabaseProvider] Database deleted');
    }
  }
}
