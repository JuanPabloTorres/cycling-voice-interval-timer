import 'package:flutter/foundation.dart';
import '../models/models.dart';
import '../services/services.dart';

/// Main provider for managing timer state and operations.
///
/// Provides reactive state management for:
/// - List of plans
/// - Current plan editing/execution
/// - Timer engine state
class TimerProvider extends ChangeNotifier {
  final StorageService _storageService;
  final TtsService _ttsService;
  final NotificationService _notificationService;
  late final TimerEngineService _timerEngine;

  // Plans state
  List<TimerPlan> _plans = [];
  bool _isLoading = false;
  String? _error;

  // Current plan for editing/running
  TimerPlan? _currentPlan;

  // Message log from timer execution
  final List<TriggeredMessage> _recentMessages = [];

  TimerProvider({
    StorageService? storageService,
    TtsService? ttsService,
    NotificationService? notificationService,
  })  : _storageService = storageService ?? StorageService(),
        _ttsService = ttsService ?? TtsService(),
        _notificationService = notificationService ?? NotificationService() {
    _timerEngine = TimerEngineService(ttsService: _ttsService);
    _setupTimerCallbacks();
    _notificationService.initialize();
  }

  // ============================================================
  // Getters
  // ============================================================

  List<TimerPlan> get plans => List.unmodifiable(_plans);
  bool get isLoading => _isLoading;
  String? get error => _error;
  TimerPlan? get currentPlan => _currentPlan;
  
  TimerEngineService get timerEngine => _timerEngine;
  TtsService get ttsService => _ttsService;
  
  TimerState get timerState => _timerEngine.state;
  int get elapsedSeconds => _timerEngine.elapsedSeconds;
  String get formattedElapsedTime => _timerEngine.formattedElapsedTime;
  String? get formattedRemainingTime => _timerEngine.formattedRemainingTime;
  double get progress => _timerEngine.progress;
  
  List<TriggeredMessage> get recentMessages => List.unmodifiable(_recentMessages);

  // ============================================================
  // Initialization
  // ============================================================

  /// Initializes the provider by loading plans and setting up TTS.
  Future<void> initialize() async {
    _setLoading(true);
    _error = null;

    try {
      await _ttsService.initialize();
      await _storageService.createDemoPlansIfEmpty();
      await loadPlans();
    } catch (e) {
      _error = 'Error al inicializar: $e';
      print('[TimerProvider] Initialization error: $e');
    } finally {
      _setLoading(false);
    }
  }

  // ============================================================
  // Plan Management
  // ============================================================

  /// Loads all plans from storage.
  Future<void> loadPlans() async {
    _setLoading(true);
    _error = null;

    try {
      _plans = await _storageService.getAllPlans();
      print('[TimerProvider] Loaded ${_plans.length} plans');
    } catch (e) {
      _error = 'Error al cargar planes: $e';
      print('[TimerProvider] Load error: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Creates a new plan.
  Future<void> createPlan(TimerPlan plan) async {
    try {
      await _storageService.createPlan(plan);
      await loadPlans();
      print('[TimerProvider] Created plan: ${plan.name}');
    } catch (e) {
      _error = 'Error al crear plan: $e';
      print('[TimerProvider] Create error: $e');
      notifyListeners();
    }
  }

  /// Updates an existing plan.
  Future<void> updatePlan(TimerPlan plan) async {
    try {
      await _storageService.updatePlan(plan);
      await loadPlans();
      
      // Update current plan if it's the one being edited
      if (_currentPlan?.id == plan.id) {
        _currentPlan = plan;
      }
      
      print('[TimerProvider] Updated plan: ${plan.name}');
    } catch (e) {
      _error = 'Error al actualizar plan: $e';
      print('[TimerProvider] Update error: $e');
      notifyListeners();
    }
  }

  /// Deletes a plan.
  Future<void> deletePlan(String planId) async {
    try {
      await _storageService.deletePlan(planId);
      
      if (_currentPlan?.id == planId) {
        _currentPlan = null;
      }
      
      await loadPlans();
      print('[TimerProvider] Deleted plan: $planId');
    } catch (e) {
      _error = 'Error deleting plan: $e';
      print('[TimerProvider] Delete error: $e');
      notifyListeners();
    }
  }

  /// Sets the current plan for editing or execution.
  void setCurrentPlan(TimerPlan? plan) {
    _currentPlan = plan;
    notifyListeners();
  }

  /// Loads a plan by ID and sets it as current.
  Future<void> loadPlan(String planId) async {
    try {
      _currentPlan = await _storageService.getPlan(planId);
      notifyListeners();
    } catch (e) {
      _error = 'Error al cargar plan: $e';
      print('[TimerProvider] Load plan error: $e');
      notifyListeners();
    }
  }

  /// Generates a new unique ID.
  String generateId() => _storageService.generateId();

  // ============================================================
  // Timer Control
  // ============================================================

  /// Loads a plan into the timer engine for execution.
  void loadPlanForExecution(TimerPlan plan) {
    _currentPlan = plan;
    _recentMessages.clear();
    _timerEngine.loadPlan(plan);
    notifyListeners();
  }

  /// Starts the timer.
  void startTimer() {
    _timerEngine.start();
  }

  /// Pauses the timer.
  void pauseTimer() {
    _timerEngine.pause();
  }

  /// Resumes the timer.
  void resumeTimer() {
    _timerEngine.resume();
  }

  /// Stops and resets the timer.
  void stopTimer() {
    _timerEngine.stop();
    _recentMessages.clear();
    _notificationService.cancelTimerNotification();
    notifyListeners();
  }

  /// Resets the timer to the beginning.
  void resetTimer() {
    _timerEngine.reset();
    _recentMessages.clear();
    notifyListeners();
  }

  // ============================================================
  // TTS Control
  // ============================================================

  /// Tests the TTS voice.
  Future<void> testVoice() async {
    await _ttsService.testVoice();
  }

  /// Sets the TTS volume.
  Future<void> setVolume(double volume) async {
    await _ttsService.setVolume(volume);
    notifyListeners();
  }

  /// Sets the TTS speech rate.
  Future<void> setSpeechRate(double rate) async {
    await _ttsService.setSpeechRate(rate);
    notifyListeners();
  }

  /// Sets the TTS pitch.
  Future<void> setPitch(double pitch) async {
    await _ttsService.setPitch(pitch);
    notifyListeners();
  }

  // ============================================================
  // Private Helpers
  // ============================================================

  void _setupTimerCallbacks() {
    _timerEngine.onTick = (elapsed) {
      _updateNotification();
      notifyListeners();
    };

    _timerEngine.onStateChanged = (state) {
      _updateNotification();
      notifyListeners();
    };

    _timerEngine.onMessageTriggered = (message, second) {
      _recentMessages.insert(0, TriggeredMessage(
        second: second,
        message: message,
        timestamp: DateTime.now(),
      ));
      
      // Keep only last 10 messages
      if (_recentMessages.length > 10) {
        _recentMessages.removeLast();
      }
      
      notifyListeners();
    };

    _timerEngine.onCompleted = () {
      _notificationService.cancelTimerNotification();
      notifyListeners();
    };
  }

  void _updateNotification() {
    if (_currentPlan != null && 
        (_timerState == TimerState.running || _timerState == TimerState.paused)) {
      _notificationService.showTimerNotification(
        planName: _currentPlan!.name,
        elapsedTime: formattedElapsedTime,
        remainingTime: formattedRemainingTime,
        isRunning: _timerState == TimerState.running,
      );
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  @override
  void dispose() {
    _timerEngine.dispose();
    _ttsService.dispose();
    _storageService.close();
    _notificationService.cancelAll();
    super.dispose();
  }
}
