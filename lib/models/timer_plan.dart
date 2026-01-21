import 'timer_event.dart';
import 'repeat_rule.dart';

/// Represents a complete timer plan with events and repeat rules.
///
/// A [TimerPlan] is a reusable configuration that contains:
/// - Exact-time events ([TimerEvent]) that fire at specific seconds
/// - Interval-based rules ([RepeatRule]) that fire repeatedly
class TimerPlan {
  /// Unique identifier for this plan.
  final String id;

  /// User-friendly name for this plan.
  final String name;

  /// Optional description of this plan's purpose.
  final String? description;

  /// Total duration of this plan in seconds.
  /// If null, the timer runs indefinitely until stopped.
  final int? totalDurationSeconds;

  /// Timestamp when this plan was created.
  final DateTime createdAt;

  /// Timestamp when this plan was last modified.
  final DateTime updatedAt;

  /// List of exact-time events for this plan.
  /// These are loaded separately from the database.
  final List<TimerEvent> events;

  /// List of interval-based repeat rules for this plan.
  /// These are loaded separately from the database.
  final List<RepeatRule> repeatRules;

  const TimerPlan({
    required this.id,
    required this.name,
    this.description,
    this.totalDurationSeconds,
    required this.createdAt,
    required this.updatedAt,
    this.events = const [],
    this.repeatRules = const [],
  });

  /// Creates a copy of this plan with the given fields replaced.
  TimerPlan copyWith({
    String? id,
    String? name,
    String? description,
    bool clearDescription = false,
    int? totalDurationSeconds,
    bool clearDuration = false,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<TimerEvent>? events,
    List<RepeatRule>? repeatRules,
  }) {
    return TimerPlan(
      id: id ?? this.id,
      name: name ?? this.name,
      description: clearDescription ? null : (description ?? this.description),
      totalDurationSeconds: clearDuration ? null : (totalDurationSeconds ?? this.totalDurationSeconds),
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      events: events ?? this.events,
      repeatRules: repeatRules ?? this.repeatRules,
    );
  }

  /// Converts this plan to a map for SQLite storage.
  /// Note: events and repeatRules are stored in separate tables.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'total_duration_seconds': totalDurationSeconds,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Creates a [TimerPlan] from a SQLite map.
  /// Note: events and repeatRules must be loaded separately.
  factory TimerPlan.fromMap(Map<String, dynamic> map) {
    return TimerPlan(
      id: map['id'] as String,
      name: map['name'] as String,
      description: map['description'] as String?,
      totalDurationSeconds: map['total_duration_seconds'] as int?,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
      events: const [],
      repeatRules: const [],
    );
  }

  /// Returns the formatted duration as HH:MM:SS or "No limit".
  String get formattedDuration {
    if (totalDurationSeconds == null) return 'Sin límite';

    final hours = totalDurationSeconds! ~/ 3600;
    final minutes = (totalDurationSeconds! % 3600) ~/ 60;
    final seconds = totalDurationSeconds! % 60;

    if (hours > 0) {
      return '${hours}h ${minutes.toString().padLeft(2, '0')}m';
    }
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  /// Returns the total number of configured triggers (events + rules).
  int get totalTriggerCount => events.length + repeatRules.length;

  /// Returns only enabled events.
  List<TimerEvent> get enabledEvents => events.where((e) => e.isEnabled).toList();

  /// Returns only enabled repeat rules.
  List<RepeatRule> get enabledRepeatRules => repeatRules.where((r) => r.isEnabled).toList();

  @override
  String toString() {
    return 'TimerPlan(id: $id, name: "$name", duration: $formattedDuration, events: ${events.length}, rules: ${repeatRules.length})';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TimerPlan &&
        other.id == id &&
        other.name == name &&
        other.description == description &&
        other.totalDurationSeconds == totalDurationSeconds;
  }

  @override
  int get hashCode {
    return Object.hash(id, name, description, totalDurationSeconds);
  }
}
