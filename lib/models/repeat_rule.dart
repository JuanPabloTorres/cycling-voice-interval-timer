/// Represents a repeating voice instruction triggered at regular intervals.
///
/// A [RepeatRule] fires when:
/// - elapsed >= [startAtSecond]
/// - (elapsed - startAtSecond) % [repeatEverySeconds] == 0
/// - elapsed <= [endAtSecond] (if specified)
class RepeatRule {
  /// Unique identifier for this rule.
  final String id;

  /// The ID of the parent [TimerPlan] this rule belongs to.
  final String planId;

  /// The second at which this rule starts firing.
  final int startAtSecond;

  /// The interval in seconds between each trigger.
  /// For example, 300 means every 5 minutes.
  final int repeatEverySeconds;

  /// The second at which this rule stops firing (inclusive).
  /// If null, the rule continues until the timer ends.
  final int? endAtSecond;

  /// The message to be spoken via Text-to-Speech on each trigger.
  final String spokenMessage;

  /// Whether this rule is active and should trigger during timer execution.
  final bool isEnabled;

  /// Display order within the plan's repeat rules list.
  final int sortOrder;

  const RepeatRule({
    required this.id,
    required this.planId,
    required this.startAtSecond,
    required this.repeatEverySeconds,
    this.endAtSecond,
    required this.spokenMessage,
    this.isEnabled = true,
    this.sortOrder = 0,
  });

  /// Creates a copy of this rule with the given fields replaced.
  RepeatRule copyWith({
    String? id,
    String? planId,
    int? startAtSecond,
    int? repeatEverySeconds,
    int? endAtSecond,
    bool clearEndAtSecond = false,
    String? spokenMessage,
    bool? isEnabled,
    int? sortOrder,
  }) {
    return RepeatRule(
      id: id ?? this.id,
      planId: planId ?? this.planId,
      startAtSecond: startAtSecond ?? this.startAtSecond,
      repeatEverySeconds: repeatEverySeconds ?? this.repeatEverySeconds,
      endAtSecond: clearEndAtSecond ? null : (endAtSecond ?? this.endAtSecond),
      spokenMessage: spokenMessage ?? this.spokenMessage,
      isEnabled: isEnabled ?? this.isEnabled,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }

  /// Converts this rule to a map for SQLite storage.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'plan_id': planId,
      'start_at_second': startAtSecond,
      'repeat_every_seconds': repeatEverySeconds,
      'end_at_second': endAtSecond,
      'spoken_message': spokenMessage,
      'is_enabled': isEnabled ? 1 : 0,
      'sort_order': sortOrder,
    };
  }

  /// Creates a [RepeatRule] from a SQLite map.
  factory RepeatRule.fromMap(Map<String, dynamic> map) {
    return RepeatRule(
      id: map['id'] as String,
      planId: map['plan_id'] as String,
      startAtSecond: map['start_at_second'] as int,
      repeatEverySeconds: map['repeat_every_seconds'] as int,
      endAtSecond: map['end_at_second'] as int?,
      spokenMessage: map['spoken_message'] as String,
      isEnabled: (map['is_enabled'] as int) == 1,
      sortOrder: map['sort_order'] as int? ?? 0,
    );
  }

  /// Checks if this rule should fire at the given elapsed second.
  bool shouldTriggerAt(int elapsedSeconds) {
    if (!isEnabled) return false;
    if (elapsedSeconds < startAtSecond) return false;
    if (endAtSecond != null && elapsedSeconds > endAtSecond!) return false;

    final secondsSinceStart = elapsedSeconds - startAtSecond;
    return secondsSinceStart % repeatEverySeconds == 0;
  }

  /// Returns a human-readable description of this rule.
  String get description {
    final startFormatted = _formatSeconds(startAtSecond);
    final intervalFormatted = _formatInterval(repeatEverySeconds);
    final endFormatted = endAtSecond != null ? _formatSeconds(endAtSecond!) : 'fin';
    return 'Cada $intervalFormatted desde $startFormatted hasta $endFormatted';
  }

  String _formatSeconds(int totalSeconds) {
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  String _formatInterval(int totalSeconds) {
    if (totalSeconds >= 60 && totalSeconds % 60 == 0) {
      final minutes = totalSeconds ~/ 60;
      return '$minutes min';
    }
    return '$totalSeconds seg';
  }

  @override
  String toString() {
    return 'RepeatRule(id: $id, every: ${repeatEverySeconds}s, start: $startAtSecond, end: $endAtSecond, message: "$spokenMessage", enabled: $isEnabled)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RepeatRule &&
        other.id == id &&
        other.planId == planId &&
        other.startAtSecond == startAtSecond &&
        other.repeatEverySeconds == repeatEverySeconds &&
        other.endAtSecond == endAtSecond &&
        other.spokenMessage == spokenMessage &&
        other.isEnabled == isEnabled &&
        other.sortOrder == sortOrder;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      planId,
      startAtSecond,
      repeatEverySeconds,
      endAtSecond,
      spokenMessage,
      isEnabled,
      sortOrder,
    );
  }
}
