import 'dart:async';
import '../models/models.dart';
import 'tts_service.dart';

/// Represents the current state of the timer.
enum TimerState {
  idle,
  running,
  paused,
  completed,
}

/// A message triggered at a specific time.
class TriggeredMessage {
  final int second;
  final String message;
  final DateTime timestamp;

  TriggeredMessage({
    required this.second,
    required this.message,
    required this.timestamp,
  });
}

/// The core timer engine that manages time tracking and event triggering.
/// 
/// Features:
/// - Precise second-by-second tracking
/// - Exact-time event triggering
/// - Interval-based repeat rule triggering
/// - Duplicate trigger prevention
/// - Independent of UI
class TimerEngineService {
  final TtsService _ttsService;
  
  // Timer state
  TimerState _state = TimerState.idle;
  TimerPlan? _currentPlan;
  int _elapsedSeconds = 0;
  Timer? _timer;
  
  // Duplicate prevention - tracks which seconds have been processed
  final Set<int> _triggeredSeconds = {};
  
  // Event log for debugging and display
  final List<TriggeredMessage> _messageLog = [];
  
  // Callbacks for UI updates
  void Function(int elapsedSeconds)? onTick;
  void Function(TimerState state)? onStateChanged;
  void Function(String message, int second)? onMessageTriggered;
  void Function()? onCompleted;

  TimerEngineService({required TtsService ttsService}) : _ttsService = ttsService;

  /// Gets the current timer state.
  TimerState get state => _state;

  /// Gets the currently loaded plan.
  TimerPlan? get currentPlan => _currentPlan;

  /// Gets the elapsed time in seconds.
  int get elapsedSeconds => _elapsedSeconds;

  /// Gets the formatted elapsed time as HH:MM:SS.
  String get formattedElapsedTime {
    final hours = _elapsedSeconds ~/ 3600;
    final minutes = (_elapsedSeconds % 3600) ~/ 60;
    final seconds = _elapsedSeconds % 60;
    
    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:'
             '${minutes.toString().padLeft(2, '0')}:'
             '${seconds.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:'
           '${seconds.toString().padLeft(2, '0')}';
  }

  /// Gets the remaining time in seconds (if duration is set).
  int? get remainingSeconds {
    if (_currentPlan?.totalDurationSeconds == null) return null;
    return _currentPlan!.totalDurationSeconds! - _elapsedSeconds;
  }

  /// Gets the formatted remaining time as HH:MM:SS.
  String? get formattedRemainingTime {
    final remaining = remainingSeconds;
    if (remaining == null) return null;
    
    final hours = remaining ~/ 3600;
    final minutes = (remaining % 3600) ~/ 60;
    final seconds = remaining % 60;
    
    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:'
             '${minutes.toString().padLeft(2, '0')}:'
             '${seconds.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:'
           '${seconds.toString().padLeft(2, '0')}';
  }

  /// Gets the progress as a value between 0.0 and 1.0.
  double get progress {
    if (_currentPlan?.totalDurationSeconds == null || 
        _currentPlan!.totalDurationSeconds == 0) {
      return 0.0;
    }
    return (_elapsedSeconds / _currentPlan!.totalDurationSeconds!).clamp(0.0, 1.0);
  }

  /// Gets the message log.
  List<TriggeredMessage> get messageLog => List.unmodifiable(_messageLog);

  /// Loads a timer plan for execution.
  void loadPlan(TimerPlan plan) {
    if (_state == TimerState.running) {
      stop();
    }
    
    _currentPlan = plan;
    _elapsedSeconds = 0;
    _triggeredSeconds.clear();
    _messageLog.clear();
    _setState(TimerState.idle);
    
    print('[TimerEngine] Loaded plan: ${plan.name}');
  }

  /// Starts or resumes the timer.
  void start() {
    if (_currentPlan == null) {
      print('[TimerEngine] No plan loaded');
      return;
    }
    
    if (_state == TimerState.running) return;
    
    _setState(TimerState.running);
    _startTimer();
    
    print('[TimerEngine] Started');
  }

  /// Pauses the timer.
  void pause() {
    if (_state != TimerState.running) return;
    
    _timer?.cancel();
    _timer = null;
    _setState(TimerState.paused);
    
    print('[TimerEngine] Paused at $formattedElapsedTime');
  }

  /// Resumes the timer from a paused state.
  void resume() {
    if (_state != TimerState.paused) return;
    
    _setState(TimerState.running);
    _startTimer();
    
    print('[TimerEngine] Resumed');
  }

  /// Stops and resets the timer.
  void stop() {
    _timer?.cancel();
    _timer = null;
    _elapsedSeconds = 0;
    _triggeredSeconds.clear();
    _messageLog.clear();
    _setState(TimerState.idle);
    _ttsService.stop();
    
    print('[TimerEngine] Stopped');
  }

  /// Resets the timer to the beginning without unloading the plan.
  void reset() {
    final wasPaused = _state == TimerState.paused;
    stop();
    if (wasPaused) {
      _setState(TimerState.idle);
    }
    
    print('[TimerEngine] Reset');
  }

  /// Starts the internal timer.
  void _startTimer() {
    // Process immediate triggers at second 0 if just starting
    if (_elapsedSeconds == 0 && !_triggeredSeconds.contains(0)) {
      _processSecond(0);
    }
    
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _elapsedSeconds++;
      onTick?.call(_elapsedSeconds);
      
      _processSecond(_elapsedSeconds);
      
      // Check for completion
      if (_currentPlan?.totalDurationSeconds != null &&
          _elapsedSeconds >= _currentPlan!.totalDurationSeconds!) {
        _complete();
      }
    });
  }

  /// Processes all triggers for a given second.
  void _processSecond(int second) {
    // Prevent duplicate processing of the same second
    if (_triggeredSeconds.contains(second)) {
      return;
    }
    _triggeredSeconds.add(second);
    
    // Use a Set to deduplicate identical messages at the same second
    final uniqueMessages = <String>{};
    
    // Check exact-time events (priority - added first)
    for (final event in _currentPlan!.enabledEvents) {
      if (event.triggerAtSecond == second) {
        uniqueMessages.add(event.spokenMessage);
      }
    }
    
    // Check repeat rules
    for (final rule in _currentPlan!.enabledRepeatRules) {
      if (rule.shouldTriggerAt(second)) {
        uniqueMessages.add(rule.spokenMessage);
      }
    }
    
    // If there are messages, combine and speak once
    if (uniqueMessages.isNotEmpty) {
      // Combine multiple messages with a pause between them
      final combinedMessage = uniqueMessages.join('. ');
      _triggerMessage(combinedMessage, second);
    }
  }

  /// Triggers a voice message.
  Future<void> _triggerMessage(String message, int second) async {
    _messageLog.add(TriggeredMessage(
      second: second,
      message: message,
      timestamp: DateTime.now(),
    ));
    
    onMessageTriggered?.call(message, second);
    
    print('[TimerEngine] @${_formatSecond(second)}: "$message"');
    
    // Speak the message
    await _ttsService.speak(message);
  }

  /// Completes the timer.
  void _complete() {
    _timer?.cancel();
    _timer = null;
    _setState(TimerState.completed);
    onCompleted?.call();
    
    print('[TimerEngine] Completed at $formattedElapsedTime');
  }

  /// Updates the state and notifies listeners.
  void _setState(TimerState newState) {
    _state = newState;
    onStateChanged?.call(newState);
  }

  /// Formats seconds as MM:SS.
  String _formatSecond(int totalSeconds) {
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:'
           '${seconds.toString().padLeft(2, '0')}';
  }

  /// Disposes of the timer resources.
  void dispose() {
    _timer?.cancel();
    _timer = null;
  }
}
