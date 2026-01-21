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
      appBar: AppBar(
        title: Text(isEditing ? 'Editar Plan' : 'Nuevo Plan'),
        actions: [
          TextButton.icon(
            onPressed: _savePlan,
            icon: const Icon(Icons.check),
            label: const Text('Guardar'),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.primary,
            ),
          ),
          const SizedBox(width: AppDimens.sm),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppDimens.md),
          children: [
            // Plan info section
            SectionCard(
              title: 'Información',
              icon: Icons.info_outline,
              child: Column(
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Nombre del plan',
                      hintText: 'Ej: Entrenamiento de intervalos',
                      prefixIcon: Icon(Icons.label_outline),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'El nombre es requerido';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppDimens.md),
                  TextFormField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Descripción (opcional)',
                      hintText: 'Describe tu plan de entrenamiento',
                      prefixIcon: Icon(Icons.description_outlined),
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: AppDimens.md),
                  TextFormField(
                    initialValue: _durationMinutes?.toString(),
                    decoration: const InputDecoration(
                      labelText: 'Duración total',
                      hintText: 'Dejar vacío para sin límite',
                      prefixIcon: Icon(Icons.timer_outlined),
                      suffixText: 'min',
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
              title: 'Eventos Exactos',
              subtitle: 'Avisos en tiempos específicos',
              icon: Icons.notifications_active_outlined,
              onAdd: _addEvent,
            ),
            const SizedBox(height: AppDimens.sm),
            if (_events.isEmpty)
              _buildEmptySection('Sin eventos configurados')
            else
              ..._events.asMap().entries.map((entry) => 
                _buildEventTile(entry.key, entry.value)
              ),
            
            const SizedBox(height: AppDimens.lg),

            // Repeat rules section
            _buildSectionHeader(
              context,
              title: 'Intervalos',
              subtitle: 'Avisos repetidos periódicamente',
              icon: Icons.repeat,
              onAdd: _addRepeatRule,
            ),
            const SizedBox(height: AppDimens.sm),
            if (_repeatRules.isEmpty)
              _buildEmptySection('Sin intervalos configurados')
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
    final theme = Theme.of(context);
    
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.secondary.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(AppDimens.radiusSm),
          ),
          child: Icon(icon, color: AppColors.secondary, size: 20),
        ),
        const SizedBox(width: AppDimens.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                subtitle,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        ),
        IconActionButton(
          icon: Icons.add,
          onPressed: onAdd,
          color: AppColors.primary,
          tooltip: 'Agregar',
        ),
      ],
    );
  }

  Widget _buildEmptySection(String text) {
    return Container(
      padding: const EdgeInsets.all(AppDimens.lg),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(AppDimens.radiusMd),
        border: Border.all(
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1),
          style: BorderStyle.solid,
        ),
      ),
      child: Center(
        child: Text(
          text,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
            fontStyle: FontStyle.italic,
          ),
        ),
      ),
    );
  }

  Widget _buildEventTile(int index, TimerEvent event) {
    final theme = Theme.of(context);
    
    return Card(
      margin: const EdgeInsets.only(bottom: AppDimens.sm),
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
        ),
        subtitle: Text(
          'A los ${event.formattedTime}',
          style: theme.textTheme.bodySmall,
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              onPressed: () => _editEvent(index),
              tooltip: 'Editar',
            ),
            IconButton(
              icon: Icon(Icons.delete_outline, color: AppColors.error),
              onPressed: () => _deleteEvent(index),
              tooltip: 'Eliminar',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRepeatRuleTile(int index, RepeatRule rule) {
    final theme = Theme.of(context);
    
    return Card(
      margin: const EdgeInsets.only(bottom: AppDimens.sm),
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
        ),
        subtitle: Text(
          rule.description,
          style: theme.textTheme.bodySmall,
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              onPressed: () => _editRepeatRule(index),
              tooltip: 'Editar',
            ),
            IconButton(
              icon: Icon(Icons.delete_outline, color: AppColors.error),
              onPressed: () => _deleteRepeatRule(index),
              tooltip: 'Eliminar',
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
        title: Text(index == null ? 'Nuevo Evento' : 'Editar Evento'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: minutesController,
                      decoration: const InputDecoration(
                        labelText: 'Min',
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: AppDimens.sm),
                    child: Text(':', style: TextStyle(fontSize: 24)),
                  ),
                  Expanded(
                    child: TextField(
                      controller: secondsController,
                      decoration: const InputDecoration(
                        labelText: 'Seg',
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppDimens.md),
              TextField(
                controller: messageController,
                decoration: const InputDecoration(
                  labelText: 'Mensaje a decir',
                  hintText: 'Ej: ¡Aumenta la intensidad!',
                ),
                maxLines: 2,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              final minutes = int.tryParse(minutesController.text) ?? 0;
              final seconds = int.tryParse(secondsController.text) ?? 0;
              final message = messageController.text.trim();

              if (message.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('El mensaje es requerido')),
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
            child: const Text('Guardar'),
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
        title: Text(index == null ? 'Nuevo Intervalo' : 'Editar Intervalo'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: startMinutesController,
                decoration: const InputDecoration(
                  labelText: 'Empezar en minuto',
                  suffixText: 'min',
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: AppDimens.md),
              TextField(
                controller: intervalMinutesController,
                decoration: const InputDecoration(
                  labelText: 'Repetir cada',
                  suffixText: 'min',
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: AppDimens.md),
              TextField(
                controller: endMinutesController,
                decoration: const InputDecoration(
                  labelText: 'Terminar en minuto (opcional)',
                  hintText: 'Vacío = sin límite',
                  suffixText: 'min',
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: AppDimens.md),
              TextField(
                controller: messageController,
                decoration: const InputDecoration(
                  labelText: 'Mensaje a decir',
                  hintText: 'Ej: Recuerda hidratarte',
                ),
                maxLines: 2,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              final startMinutes = int.tryParse(startMinutesController.text) ?? 0;
              final intervalMinutes = int.tryParse(intervalMinutesController.text) ?? 0;
              final endMinutes = int.tryParse(endMinutesController.text);
              final message = messageController.text.trim();

              if (intervalMinutes <= 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('El intervalo debe ser mayor a 0')),
                );
                return;
              }

              if (message.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('El mensaje es requerido')),
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
            child: const Text('Guardar'),
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
        content: Text(isEditing ? 'Plan actualizado' : 'Plan creado'),
        backgroundColor: AppColors.success,
      ),
    );
  }
}
