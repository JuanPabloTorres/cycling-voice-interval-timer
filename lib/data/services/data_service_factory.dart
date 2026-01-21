import 'package:flutter/foundation.dart' show kIsWeb;
import '../interfaces/repository_interfaces.dart';
import '../db/sqlite_database_provider.dart';
import '../db/web_database_provider.dart';
import '../services/data_service_impl.dart';

/// Factory for creating platform-appropriate data service instances.
/// 
/// Follows Open/Closed Principle - extend by adding new providers without modifying existing code.
/// Follows Dependency Inversion Principle - returns abstractions, not concrete implementations.
class DataServiceFactory {
  /// Creates the appropriate [IDataService] based on the current platform.
  /// 
  /// - On mobile/desktop: Uses SQLite for persistent storage
  /// - On web: Uses SharedPreferences for persistent storage
  static Future<IDataService> create() async {
    final IDatabaseProvider provider;
    
    if (kIsWeb) {
      provider = WebDatabaseProvider();
      print('[DataServiceFactory] Using WebDatabaseProvider for web platform');
    } else {
      provider = SqliteDatabaseProvider();
      print('[DataServiceFactory] Using SqliteDatabaseProvider for native platform');
    }
    
    final dataService = DataServiceImpl(dbProvider: provider);
    await dataService.initialize();
    
    return dataService;
  }
  
  /// Creates a data service with SQLite storage (native platforms only).
  static Future<IDataService> createSqlite() async {
    if (kIsWeb) {
      throw UnsupportedError('SQLite is not supported on web platform');
    }
    
    final provider = SqliteDatabaseProvider();
    final dataService = DataServiceImpl(dbProvider: provider);
    await dataService.initialize();
    
    return dataService;
  }
  
  /// Creates a data service with in-memory/web storage (for testing or web).
  static Future<IDataService> createMemory() async {
    final provider = WebDatabaseProvider();
    final dataService = DataServiceImpl(dbProvider: provider);
    await dataService.initialize();
    
    return dataService;
  }
  
  /// Creates a data service with a custom database provider.
  /// 
  /// Useful for dependency injection and testing.
  static Future<IDataService> createWithProvider(IDatabaseProvider provider) async {
    final dataService = DataServiceImpl(dbProvider: provider);
    await dataService.initialize();
    
    return dataService;
  }
}
