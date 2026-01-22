import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/providers.dart';
import '../models/models.dart';
import '../ui/ui.dart';

/// Screen for creating and editing timer plans.
class PlanEditorScreen extends StatefulWidget {
  final TimerPlan? plan;

  const PlanEditorScreen({super.key, this.plan});

  @override
  State<PlanEditorScreen> createState() => _PlanEditorScreenState();
}

class _PlanEditorScreenState extends State<PlanEditorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  int? _durationMinutes;
  List<TimerEvent> _events = [];
  List<RepeatRule> _repeatRules = [];
  
  bool get isEditing => widget.plan != null;

  @override
  void initState() {
    super.initState();
    if (widget.plan != null) {
      _nameController.text = widget.plan!.name;
      _descriptionController.text = widget.plan!.description ?? '';
      _durationMinutes = widget.plan!.totalDurationSeconds != null 
          ? widget.plan!.totalDurationSeconds! ~/ 60 
          : null;
      _events = List.from(widget.plan!.events);
      _repeatRules = List.from(widget.plan!.repeatRules);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F8FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: AppColors.textPrimaryLight,
        iconTheme: const IconThemeData(color: AppColors.textPrimaryLight),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20, color: AppColors.textPrimaryLight),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          isEditing ? 'Edit Plan' : 'New Plan',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimaryLight,
          ),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: AppDimens.md),
            child: TextButton.icon(
              onPressed: _savePlan,
              icon: const Icon(Icons.check, size: 18, color: Colors.white),
              label: const Text('Save', style: TextStyle(color: Colors.white)),
              style: TextButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(horizontal: AppDimens.md),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppDimens.radiusMd),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppDimens.lg),
          children: [
            // Plan info section
            Container(
              padding: const EdgeInsets.all(AppDimens.lg),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppDimens.radiusLg),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(AppDimens.sm),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(AppDimens.radiusSm),
                        ),
                        child: Icon(Icons.info_outline, color: AppColors.primary, size: 20),
                      ),
                      const SizedBox(width: AppDimens.md),
                      const Text(
                        'Plan Information',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimaryLight,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppDimens.lg),
                  TextFormField(
                    controller: _nameController,
                    style: const TextStyle(color: AppColors.textPrimaryLight),
                    decoration: InputDecoration(
                      labelText: 'Plan name',
                      labelStyle: const TextStyle(color: AppColors.textSecondaryLight),
                      hintText: 'E.g.: Interval training',
                      hintStyle: TextStyle(color: AppColors.textSecondaryLight.withValues(alpha: 0.7)),
                      prefixIcon: const Icon(Icons.label_outline, color: AppColors.textSecondaryLight),
                      filled: true,
                      fillColor: const Color(0xFFF5F8FA),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppDimens.radiusMd),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppDimens.radiusMd),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppDimens.radiusMd),
                        borderSide: BorderSide(color: AppColors.primary, width: 2),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Name is required';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppDimens.md),
                  TextFormField(
                    controller: _descriptionController,
                    style: const TextStyle(color: AppColors.textPrimaryLight),
                    decoration: InputDecoration(
                      labelText: 'Description (optional)',
                      labelStyle: const TextStyle(color: AppColors.textSecondaryLight),
                      hintText: 'Describe your training plan',
                      hintStyle: TextStyle(color: AppColors.textSecondaryLight.withValues(alpha: 0.7)),
                      prefixIcon: const Icon(Icons.description_outlined, color: AppColors.textSecondaryLight),
                      filled: true,
                      fillColor: const Color(0xFFF5F8FA),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppDimens.radiusMd),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppDimens.radiusMd),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppDimens.radiusMd),
                        borderSide: BorderSide(color: AppColors.primary, width: 2),
                      ),
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: AppDimens.md),
                  TextFormField(
                    initialValue: _durationMinutes?.toString(),
                    style: const TextStyle(color: AppColors.textPrimaryLight),
                    decoration: InputDecoration(
                      labelText: 'Total duration',
                      labelStyle: const TextStyle(color: AppColors.textSecondaryLight),
                      hintText: 'Leave empty for no limit',
                      hintStyle: TextStyle(color: AppColors.textSecondaryLight.withValues(alpha: 0.7)),
                      prefixIcon: const Icon(Icons.timer_outlined, color: AppColors.textSecondaryLight),
                      suffixText: 'min',
                      suffixStyle: const TextStyle(color: AppColors.textSecondaryLight),
                      filled: true,
                      fillColor: const Color(0xFFF5F8FA),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppDimens.radiusMd),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppDimens.radiusMd),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppDimens.radiusMd),
                        borderSide: BorderSide(color: AppColors.primary, width: 2),
                      ),
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      setState(() {
                        _durationMinutes = int.tryParse(value);
                      });
                    },
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: AppDimens.lg),

            // Events section
            _buildSectionHeader(
              context,
              title: 'Exact Events',
              subtitle: 'Alerts at specific times',
              icon: Icons.notifications_active_outlined,
              onAdd: _addEvent,
            ),
            const SizedBox(height: AppDimens.sm),
            if (_events.isEmpty)
              _buildEmptySection('No events configured')
            else
              ..._events.asMap().entries.map((entry) => 
                _buildEventTile(entry.key, entry.value)
              ),
            
            const SizedBox(height: AppDimens.lg),

            // Repeat rules section
            _buildSectionHeader(
              context,
              title: 'Intervals',
              subtitle: 'Periodically repeated alerts',
              icon: Icons.repeat,
              onAdd: _addRepeatRule,
            ),
            const SizedBox(height: AppDimens.sm),
            if (_repeatRules.isEmpty)
              _buildEmptySection('No intervals configured')
            else
              ..._repeatRules.asMap().entries.map((entry) => 
                _buildRepeatRuleTile(entry.key, entry.value)
              ),
            
            const SizedBox(height: 100), // Space for keyboard
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onAdd,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppDimens.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDimens.radiusLg),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.secondary, AppColors.accent],
              ),
              borderRadius: BorderRadius.circular(AppDimens.radiusMd),
            ),
            child: Icon(icon, color: Colors.white, size: 22),
          ),
          const SizedBox(width: AppDimens.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimaryLight,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondaryLight,
                  ),
                ),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(AppDimens.radiusMd),
            ),
            child: IconButton(
              icon: const Icon(Icons.add, color: Colors.white, size: 20),
              onPressed: onAdd,
              tooltip: 'Add',
              constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptySection(String text) {
    return Container(
      padding: const EdgeInsets.all(AppDimens.xl),
      margin: const EdgeInsets.only(top: AppDimens.sm),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDimens.radiusMd),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.2),
          style: BorderStyle.solid,
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.inbox_outlined,
            size: 40,
            color: AppColors.textSecondaryLight,
          ),
          const SizedBox(height: AppDimens.sm),
          Text(
            text,
            style: TextStyle(
              color: AppColors.textSecondaryLight,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventTile(int index, TimerEvent event) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppDimens.sm),
      color: Colors.white,
      elevation: 1,
      shadowColor: Colors.black.withValues(alpha: 0.1),
      child: ListTile(
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: event.isEnabled 
                ? AppColors.primary.withValues(alpha: 0.15)
                : Colors.grey.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(AppDimens.radiusSm),
          ),
          child: Center(
            child: Text(
              event.formattedTime,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: event.isEnabled ? AppColors.primary : Colors.grey,
              ),
            ),
          ),
        ),
        title: Text(
          event.spokenMessage,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(color: AppColors.textPrimaryLight, fontWeight: FontWeight.w500),
        ),
        subtitle: Text(
          'At ${event.formattedTime}',
          style: const TextStyle(color: AppColors.textSecondaryLight, fontSize: 12),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit_outlined, color: AppColors.textSecondaryLight),
              onPressed: () => _editEvent(index),
              tooltip: 'Edit',
            ),
            IconButton(
              icon: Icon(Icons.delete_outline, color: AppColors.error),
              onPressed: () => _deleteEvent(index),
              tooltip: 'Delete',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRepeatRuleTile(int index, RepeatRule rule) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppDimens.sm),
      color: Colors.white,
      elevation: 1,
      shadowColor: Colors.black.withValues(alpha: 0.1),
      child: ListTile(
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: rule.isEnabled 
                ? AppColors.secondary.withValues(alpha: 0.15)
                : Colors.grey.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(AppDimens.radiusSm),
          ),
          child: Icon(
            Icons.repeat,
            color: rule.isEnabled ? AppColors.secondary : Colors.grey,
            size: 20,
          ),
        ),
        title: Text(
          rule.spokenMessage,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(color: AppColors.textPrimaryLight, fontWeight: FontWeight.w500),
        ),
        subtitle: Text(
          rule.description,
          style: const TextStyle(color: AppColors.textSecondaryLight, fontSize: 12),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit_outlined, color: AppColors.textSecondaryLight),
              onPressed: () => _editRepeatRule(index),
              tooltip: 'Edit',
            ),
            IconButton(
              icon: Icon(Icons.delete_outline, color: AppColors.error),
              onPressed: () => _deleteRepeatRule(index),
              tooltip: 'Delete',
            ),
          ],
        ),
      ),
    );
  }

  void _addEvent() => _showEventDialog(null, null);
  void _editEvent(int index) => _showEventDialog(index, _events[index]);
  void _deleteEvent(int index) => setState(() => _events.removeAt(index));

  void _addRepeatRule() => _showRepeatRuleDialog(null, null);
  void _editRepeatRule(int index) => _showRepeatRuleDialog(index, _repeatRules[index]);
  void _deleteRepeatRule(int index) => setState(() => _repeatRules.removeAt(index));

  void _showEventDialog(int? index, TimerEvent? event) {
    final minutesController = TextEditingController(
      text: event != null ? (event.triggerAtSecond ~/ 60).toString() : '',
    );
    final secondsController = TextEditingController(
      text: event != null ? (event.triggerAtSecond % 60).toString() : '0',
    );
    final messageController = TextEditingController(
      text: event?.spokenMessage ?? '',
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: Text(
          index == null ? 'New Event' : 'Edit Event',
          style: const TextStyle(color: AppColors.textPrimaryLight, fontWeight: FontWeight.w700),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: minutesController,
                      style: const TextStyle(color: AppColors.textPrimaryLight),
                      decoration: const InputDecoration(
                        labelText: 'Min',
                        labelStyle: TextStyle(color: AppColors.textSecondaryLight),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: AppDimens.sm),
                    child: Text(':', style: TextStyle(fontSize: 24, color: AppColors.textPrimaryLight)),
                  ),
                  Expanded(
                    child: TextField(
                      controller: secondsController,
                      style: const TextStyle(color: AppColors.textPrimaryLight),
                      decoration: const InputDecoration(
                        labelText: 'Sec',
                        labelStyle: TextStyle(color: AppColors.textSecondaryLight),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppDimens.md),
              TextField(
                controller: messageController,
                style: const TextStyle(color: AppColors.textPrimaryLight),
                decoration: const InputDecoration(
                  labelText: 'Message to speak',
                  labelStyle: TextStyle(color: AppColors.textSecondaryLight),
                  hintText: 'E.g.: Increase intensity!',
                  hintStyle: TextStyle(color: AppColors.textSecondaryLight),
                ),
                maxLines: 2,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: AppColors.textSecondaryLight)),
          ),
          ElevatedButton(
            onPressed: () {
              final minutes = int.tryParse(minutesController.text) ?? 0;
              final seconds = int.tryParse(secondsController.text) ?? 0;
              final message = messageController.text.trim();

              if (message.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Message is required')),
                );
                return;
              }

              final provider = context.read<TimerProvider>();
              final planId = widget.plan?.id ?? provider.generateId();
              
              final newEvent = TimerEvent(
                id: event?.id ?? provider.generateId(),
                planId: planId,
                triggerAtSecond: minutes * 60 + seconds,
                spokenMessage: message,
                isEnabled: true,
                sortOrder: index ?? _events.length,
              );

              setState(() {
                if (index != null) {
                  _events[index] = newEvent;
                } else {
                  _events.add(newEvent);
                }
                _events.sort((a, b) => a.triggerAtSecond.compareTo(b.triggerAtSecond));
              });

              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showRepeatRuleDialog(int? index, RepeatRule? rule) {
    final startMinutesController = TextEditingController(
      text: rule != null ? (rule.startAtSecond ~/ 60).toString() : '0',
    );
    final intervalMinutesController = TextEditingController(
      text: rule != null ? (rule.repeatEverySeconds ~/ 60).toString() : '5',
    );
    final endMinutesController = TextEditingController(
      text: rule?.endAtSecond != null ? (rule!.endAtSecond! ~/ 60).toString() : '',
    );
    final messageController = TextEditingController(
      text: rule?.spokenMessage ?? '',
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: Text(
          index == null ? 'New Interval' : 'Edit Interval',
          style: const TextStyle(color: AppColors.textPrimaryLight, fontWeight: FontWeight.w700),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: startMinutesController,
                style: const TextStyle(color: AppColors.textPrimaryLight),
                decoration: const InputDecoration(
                  labelText: 'Start at minute',
                  labelStyle: TextStyle(color: AppColors.textSecondaryLight),
                  suffixText: 'min',
                  suffixStyle: TextStyle(color: AppColors.textSecondaryLight),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: AppDimens.md),
              TextField(
                controller: intervalMinutesController,
                style: const TextStyle(color: AppColors.textPrimaryLight),
                decoration: const InputDecoration(
                  labelText: 'Repeat every',
                  labelStyle: TextStyle(color: AppColors.textSecondaryLight),
                  suffixText: 'min',
                  suffixStyle: TextStyle(color: AppColors.textSecondaryLight),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: AppDimens.md),
              TextField(
                controller: endMinutesController,
                style: const TextStyle(color: AppColors.textPrimaryLight),
                decoration: const InputDecoration(
                  labelText: 'End at minute (optional)',
                  labelStyle: TextStyle(color: AppColors.textSecondaryLight),
                  hintText: 'Empty = no limit',
                  hintStyle: TextStyle(color: AppColors.textSecondaryLight),
                  suffixText: 'min',
                  suffixStyle: TextStyle(color: AppColors.textSecondaryLight),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: AppDimens.md),
              TextField(
                controller: messageController,
                style: const TextStyle(color: AppColors.textPrimaryLight),
                decoration: const InputDecoration(
                  labelText: 'Message to speak',
                  labelStyle: TextStyle(color: AppColors.textSecondaryLight),
                  hintText: 'E.g.: Remember to hydrate',
                  hintStyle: TextStyle(color: AppColors.textSecondaryLight),
                ),
                maxLines: 2,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: AppColors.textSecondaryLight)),
          ),
          ElevatedButton(
            onPressed: () {
              final startMinutes = int.tryParse(startMinutesController.text) ?? 0;
              final intervalMinutes = int.tryParse(intervalMinutesController.text) ?? 0;
              final endMinutes = int.tryParse(endMinutesController.text);
              final message = messageController.text.trim();

              if (intervalMinutes <= 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Interval must be greater than 0')),
                );
                return;
              }

              if (message.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Message is required')),
                );
                return;
              }

              final provider = context.read<TimerProvider>();
              final planId = widget.plan?.id ?? provider.generateId();

              final newRule = RepeatRule(
                id: rule?.id ?? provider.generateId(),
                planId: planId,
                startAtSecond: startMinutes * 60,
                repeatEverySeconds: intervalMinutes * 60,
                endAtSecond: endMinutes != null ? endMinutes * 60 : null,
                spokenMessage: message,
                isEnabled: true,
                sortOrder: index ?? _repeatRules.length,
              );

              setState(() {
                if (index != null) {
                  _repeatRules[index] = newRule;
                } else {
                  _repeatRules.add(newRule);
                }
              });

              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _savePlan() {
    if (!_formKey.currentState!.validate()) return;

    final provider = context.read<TimerProvider>();
    final now = DateTime.now();
    final planId = widget.plan?.id ?? provider.generateId();

    final updatedEvents = _events.map((e) => e.copyWith(planId: planId)).toList();
    final updatedRules = _repeatRules.map((r) => r.copyWith(planId: planId)).toList();

    final plan = TimerPlan(
      id: planId,
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim().isEmpty 
          ? null 
          : _descriptionController.text.trim(),
      totalDurationSeconds: _durationMinutes != null ? _durationMinutes! * 60 : null,
      createdAt: widget.plan?.createdAt ?? now,
      updatedAt: now,
      events: updatedEvents,
      repeatRules: updatedRules,
    );

    if (isEditing) {
      provider.updatePlan(plan);
    } else {
      provider.createPlan(plan);
    }

    Navigator.pop(context);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(isEditing ? 'Plan updated' : 'Plan created'),
        backgroundColor: AppColors.success,
      ),
    );
  }
}
