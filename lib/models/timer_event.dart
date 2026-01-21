/// Represents a single voice instruction triggered at an exact time.
///
/// A [TimerEvent] fires when the elapsed seconds exactly match [triggerAtSecond].
class TimerEvent {
  /// Unique identifier for this event.
  final String id;

  /// The ID of the parent [TimerPlan] this event belongs to.
  final String planId;

  /// The exact second at which this event should trigger.
  /// For example, 1200 means the event fires at minute 20.
  final int triggerAtSecond;

  /// The message to be spoken via Text-to-Speech.
  final String spokenMessage;

  /// Whether this event is active and should trigger during timer execution.
  final bool isEnabled;

  /// Display order within the plan's event list.
  final int sortOrder;

  const TimerEvent({
    required this.id,
    required this.planId,
    required this.triggerAtSecond,
    required this.spokenMessage,
    this.isEnabled = true,
    this.sortOrder = 0,
  });

  /// Creates a copy of this event with the given fields replaced.
  TimerEvent copyWith({
    String? id,
    String? planId,
    int? triggerAtSecond,
    String? spokenMessage,
    bool? isEnabled,
    int? sortOrder,
  }) {
    return TimerEvent(
      id: id ?? this.id,
      planId: planId ?? this.planId,
      triggerAtSecond: triggerAtSecond ?? this.triggerAtSecond,
      spokenMessage: spokenMessage ?? this.spokenMessage,
      isEnabled: isEnabled ?? this.isEnabled,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }

  /// Converts this event to a map for SQLite storage.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'plan_id': planId,
      'trigger_at_second': triggerAtSecond,
      'spoken_message': spokenMessage,
      'is_enabled': isEnabled ? 1 : 0,
      'sort_order': sortOrder,
    };
  }

  /// Creates a [TimerEvent] from a SQLite map.
  factory TimerEvent.fromMap(Map<String, dynamic> map) {
    return TimerEvent(
      id: map['id'] as String,
      planId: map['plan_id'] as String,
      triggerAtSecond: map['trigger_at_second'] as int,
      spokenMessage: map['spoken_message'] as String,
      isEnabled: (map['is_enabled'] as int) == 1,
      sortOrder: map['sort_order'] as int? ?? 0,
    );
  }

  /// Returns a human-readable time format (MM:SS) for display.
  String get formattedTime {
    final minutes = triggerAtSecond ~/ 60;
    final seconds = triggerAtSecond % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  String toString() {
    return 'TimerEvent(id: $id, at: $formattedTime, message: "$spokenMessage", enabled: $isEnabled)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TimerEvent &&
        other.id == id &&
        other.planId == planId &&
        other.triggerAtSecond == triggerAtSecond &&
        other.spokenMessage == spokenMessage &&
        other.isEnabled == isEnabled &&
        other.sortOrder == sortOrder;
  }

  @override
  int get hashCode {
    return Object.hash(id, planId, triggerAtSecond, spokenMessage, isEnabled, sortOrder);
  }
}
