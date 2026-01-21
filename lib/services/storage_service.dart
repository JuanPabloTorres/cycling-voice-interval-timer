import 'package:uuid/uuid.dart';
import '../data/interfaces/repository_interfaces.dart';
import '../data/services/data_service_factory.dart';
import '../models/models.dart';

/// Service wrapper for data persistence operations.
/// 
/// Provides a simplified interface to the IDataService for use
/// in the application layer.
/// 
/// Follows Dependency Inversion Principle - depends on IDataService abstraction.
/// Uses DataServiceFactory to get platform-appropriate implementation:
/// - Native (Android/iOS/Desktop): SQLite persistent storage
/// - Web: In-memory storage (session only)
class StorageService {
  IDataService? _dataService;
  final Uuid _uuid = const Uuid();
  bool _isInitialized = false;

  StorageService();

  /// Initializes the storage service with platform-appropriate persistence.
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    _dataService = await DataServiceFactory.create();
    _isInitialized = true;
    print('[StorageService] Initialized');
  }

  Future<void> _ensureInitialized() async {
    if (!_isInitialized) {
      await initialize();
    }
  }

  // ============================================================
  // Plan Operations
  // ============================================================

  /// Gets all plans with their events and rules.
  Future<List<TimerPlan>> getAllPlans() async {
    await _ensureInitialized();
    return await _dataService!.getAllPlansWithDetails();
  }

  /// Gets a single plan by ID with all details.
  Future<TimerPlan?> getPlan(String planId) async {
    await _ensureInitialized();
    return await _dataService!.getPlanWithDetails(planId);
  }

  /// Creates a new plan.
  Future<String> createPlan(TimerPlan plan) async {
    await _ensureInitialized();
    return await _dataService!.createPlan(plan);
  }

  /// Updates an existing plan.
  Future<void> updatePlan(TimerPlan plan) async {
    await _ensureInitialized();
    await _dataService!.updatePlanWithDetails(plan);
  }

  /// Deletes a plan.
  Future<void> deletePlan(String planId) async {
    await _ensureInitialized();
    await _dataService!.deletePlan(planId);
  }

  // ============================================================
  // Utility Methods
  // ============================================================

  /// Generates a new unique ID.
  String generateId() {
    return _dataService?.generateId() ?? _uuid.v4();
  }

  /// Creates demo plans for first-time users.
  Future<void> createDemoPlansIfEmpty() async {
    await _ensureInitialized();
    
    final plans = await getAllPlans();
    if (plans.isEmpty) {
      await _dataService!.createDemoPlan();
      print('[StorageService] Created demo plans');
    }
  }

  /// Gets database statistics.
  Future<Map<String, int>> getStats() async {
    await _ensureInitialized();
    return await _dataService!.getStatistics();
  }

  /// Closes the storage connection.
  Future<void> close() async {
    if (_dataService != null) {
      await _dataService!.close();
      _dataService = null;
      _isInitialized = false;
    }
  }
}

