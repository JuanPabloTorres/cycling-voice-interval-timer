import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/providers.dart';
import '../models/models.dart';
import '../ui/ui.dart';
import 'plan_editor_screen.dart';
import 'run_timer_screen.dart';
import 'voice_settings_screen.dart';

/// Screen displaying the list of all timer plans.
class PlansScreen extends StatefulWidget {
  const PlansScreen({super.key});

  @override
  State<PlansScreen> createState() => _PlansScreenState();
}

class _PlansScreenState extends State<PlansScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TimerProvider>().initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('RidePulse'),
        actions: [
          IconActionButton(
            icon: Icons.volume_up,
            tooltip: 'Probar voz',
            color: Theme.of(context).colorScheme.primary,
            backgroundColor: Colors.transparent,
            onPressed: () => context.read<TimerProvider>().testVoice(),
          ),
          IconActionButton(
            icon: Icons.settings_voice,
            tooltip: 'Ajustes de voz',
            color: Theme.of(context).colorScheme.primary,
            backgroundColor: Colors.transparent,
            onPressed: () => Navigator.push(
              context,
              AppPageRoute(child: const VoiceSettingsScreen()),
            ),
          ),
          const SizedBox(width: AppDimens.sm),
        ],
      ),
      body: Consumer<TimerProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return _buildLoadingState();
          }

          if (provider.error != null) {
            return _buildErrorState(provider);
          }

          if (provider.plans.isEmpty) {
            return _buildEmptyState();
          }

          return _buildPlansList(provider);
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _navigateToEditor(context, null),
        icon: const Icon(Icons.add),
        label: const Text('Nuevo Plan'),
      ),
    );
  }

  Widget _buildLoadingState() {
    return ListView.builder(
      padding: const EdgeInsets.all(AppDimens.md),
      itemCount: 3,
      itemBuilder: (context, index) {
        return const Padding(
          padding: EdgeInsets.only(bottom: AppDimens.md),
          child: SkeletonCard(),
        );
      },
    );
  }

  Widget _buildErrorState(TimerProvider provider) {
    return EmptyStateView(
      icon: Icons.error_outline,
      title: 'Error al cargar',
      subtitle: provider.error,
      action: PrimaryButton(
        label: 'Reintentar',
        icon: Icons.refresh,
        fullWidth: false,
        onPressed: () => provider.loadPlans(),
      ),
    );
  }

  Widget _buildEmptyState() {
    return EmptyStateView(
      icon: Icons.timer_outlined,
      title: 'Sin planes',
      subtitle: 'Crea tu primer plan de entrenamiento con avisos de voz',
      action: PrimaryButton(
        label: 'Crear Plan',
        icon: Icons.add,
        fullWidth: false,
        onPressed: () => _navigateToEditor(context, null),
      ),
    );
  }

  Widget _buildPlansList(TimerProvider provider) {
    return RefreshIndicator(
      onRefresh: () => provider.loadPlans(),
      child: ListView.builder(
        padding: const EdgeInsets.all(AppDimens.md),
        itemCount: provider.plans.length,
        itemBuilder: (context, index) {
          final plan = provider.plans[index];
          return _PlanCard(
            plan: plan,
            onTap: () => _navigateToRun(context, plan),
            onEdit: () => _navigateToEditor(context, plan),
            onDelete: () => _confirmDelete(context, provider, plan),
          );
        },
      ),
    );
  }

  void _navigateToEditor(BuildContext context, TimerPlan? plan) {
    Navigator.push(
      context,
      AppPageRoute(page: PlanEditorScreen(plan: plan)),
    );
  }

  void _navigateToRun(BuildContext context, TimerPlan plan) {
    Navigator.push(
      context,
      AppPageRoute(page: RunTimerScreen(plan: plan)),
    );
  }

  void _confirmDelete(BuildContext context, TimerProvider provider, TimerPlan plan) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar plan'),
        content: Text('¿Eliminar "${plan.name}"?\n\nEsta acción no se puede deshacer.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              provider.deletePlan(plan.id);
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }
}

/// Card widget for displaying a single plan.
class _PlanCard extends StatefulWidget {
  final TimerPlan plan;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _PlanCard({
    required this.plan,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  State<_PlanCard> createState() => _PlanCardState();
}

class _PlanCardState extends State<_PlanCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AppDurations.instant,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.98).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimens.md),
      child: GestureDetector(
        onTapDown: (_) => _controller.forward(),
        onTapUp: (_) => _controller.reverse(),
        onTapCancel: () => _controller.reverse(),
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: Card(
            child: InkWell(
              onTap: widget.onTap,
              borderRadius: BorderRadius.circular(AppDimens.radiusMd),
              child: Padding(
                padding: const EdgeInsets.all(AppDimens.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(AppDimens.radiusSm),
                          ),
                          child: const Icon(
                            Icons.timer,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(width: AppDimens.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.plan.name,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              if (widget.plan.description?.isNotEmpty ?? false)
                                Text(
                                  widget.plan.description!,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                            ],
                          ),
                        ),
                        PopupMenuButton<String>(
                          icon: Icon(
                            Icons.more_vert,
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                          ),
                          onSelected: (value) {
                            if (value == 'edit') widget.onEdit();
                            if (value == 'delete') widget.onDelete();
                          },
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: 'edit',
                              child: Row(
                                children: [
                                  Icon(Icons.edit_outlined),
                                  SizedBox(width: AppDimens.sm),
                                  Text('Editar'),
                                ],
                              ),
                            ),
                            PopupMenuItem(
                              value: 'delete',
                              child: Row(
                                children: [
                                  Icon(Icons.delete_outline, color: AppColors.error),
                                  const SizedBox(width: AppDimens.sm),
                                  Text('Eliminar', style: TextStyle(color: AppColors.error)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: AppDimens.md),
                    
                    // Info chips
                    Wrap(
                      spacing: AppDimens.sm,
                      runSpacing: AppDimens.sm,
                      children: [
                        InfoChip(
                          icon: Icons.schedule,
                          label: widget.plan.formattedDuration,
                        ),
                        InfoChip(
                          icon: Icons.notifications_active_outlined,
                          label: '${widget.plan.events.length} eventos',
                        ),
                        InfoChip(
                          icon: Icons.repeat,
                          label: '${widget.plan.repeatRules.length} intervalos',
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: AppDimens.md),
                    
                    // Play button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: widget.onTap,
                        icon: const Icon(Icons.play_arrow),
                        label: const Text('Iniciar'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
