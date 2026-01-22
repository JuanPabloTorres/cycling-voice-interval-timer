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
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFF0F8FC),
              Color(0xFFE8F4F8),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Custom App Bar with gradient accent
              _buildAppBar(context),
              
              // Content
              Expanded(
                child: Consumer<TimerProvider>(
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
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _navigateToEditor(context, null),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('New Plan', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
        backgroundColor: AppColors.primary,
        elevation: 4,
        highlightElevation: 8,
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 400;
    
    return Container(
      padding: EdgeInsets.fromLTRB(
        isSmallScreen ? AppDimens.md : AppDimens.lg,
        AppDimens.sm,
        AppDimens.sm,
        AppDimens.sm,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
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
          // Logo/Title with app icon
          Flexible(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: isSmallScreen ? 40 : 48,
                  height: isSmallScreen ? 40 : 48,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(isSmallScreen ? 12 : 14),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(isSmallScreen ? 12 : 14),
                    child: Image.asset(
                      'assets/icon/ridepulse3.png',
                      fit: BoxFit.cover,
                      filterQuality: FilterQuality.high,
                      cacheWidth: 144,
                      cacheHeight: 144,
                    ),
                  ),
                ),
                SizedBox(width: isSmallScreen ? AppDimens.sm : AppDimens.md),
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'RidePulse',
                        style: TextStyle(
                          fontSize: isSmallScreen ? 20 : 24,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimaryLight,
                          letterSpacing: -0.5,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (!isSmallScreen)
                        Text(
                          'Interval Training',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textSecondaryLight,
                            letterSpacing: 0.5,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppDimens.sm),
          // Action buttons with styled containers
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: isSmallScreen ? 2 : AppDimens.xs,
              vertical: AppDimens.xs,
            ),
            decoration: BoxDecoration(
              color: AppColors.secondary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppDimens.radiusMd),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.volume_up_rounded, size: isSmallScreen ? 20 : 22),
                  color: AppColors.secondary,
                  onPressed: () => context.read<TimerProvider>().testVoice(),
                  tooltip: 'Test voice',
                  padding: EdgeInsets.all(isSmallScreen ? 8 : 10),
                  constraints: BoxConstraints(
                    minWidth: isSmallScreen ? 36 : 40,
                    minHeight: isSmallScreen ? 36 : 40,
                  ),
                ),
                Container(
                  height: 24,
                  width: 1,
                  color: AppColors.secondary.withValues(alpha: 0.3),
                ),
                IconButton(
                  icon: Icon(Icons.settings_voice_rounded, size: isSmallScreen ? 20 : 22),
                  color: AppColors.secondary,
                  onPressed: () => Navigator.push(
                    context,
                    AppPageRoute(page: const VoiceSettingsScreen()),
                  ),
                  tooltip: 'Voice settings',
                  padding: EdgeInsets.all(isSmallScreen ? 8 : 10),
                  constraints: BoxConstraints(
                    minWidth: isSmallScreen ? 36 : 40,
                    minHeight: isSmallScreen ? 36 : 40,
                  ),
                ),
              ],
            ),
          ),
        ],
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
      title: 'Error loading',
      subtitle: provider.error,
      action: PrimaryButton(
        label: 'Retry',
        icon: Icons.refresh,
        fullWidth: false,
        onPressed: () => provider.loadPlans(),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimens.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Cycling illustration
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.gradientStart.withValues(alpha: 0.2),
                    AppColors.gradientEnd.withValues(alpha: 0.2),
                  ],
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.directions_bike,
                size: 60,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: AppDimens.lg),
            const Text(
              'Start your training!',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimaryLight,
              ),
            ),
            const SizedBox(height: AppDimens.sm),
            Text(
              'Create your first interval plan\nwith customized voice alerts',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: AppColors.textSecondaryLight,
                height: 1.5,
              ),
            ),
            const SizedBox(height: AppDimens.xl),
            GradientButton(
              text: 'Create Plan',
              icon: Icons.add,
              width: 180,
              onPressed: () => _navigateToEditor(context, null),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlansList(TimerProvider provider) {
    return RefreshIndicator(
      onRefresh: () => provider.loadPlans(),
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Responsive grid: 2 columns on mobile, more on larger screens
          final crossAxisCount = constraints.maxWidth > 900 
              ? 4 
              : constraints.maxWidth > 600 
                  ? 3 
                  : 2;
          
          // Better aspect ratio for mobile to prevent overflow
          final aspectRatio = constraints.maxWidth < 400 
              ? 0.75 
              : constraints.maxWidth < 600
                  ? 0.80
                  : 0.85;
          
          final padding = constraints.maxWidth < 400 
              ? AppDimens.sm 
              : AppDimens.md;
          
          return GridView.builder(
            padding: EdgeInsets.all(padding),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: padding,
              mainAxisSpacing: padding,
              childAspectRatio: aspectRatio,
            ),
            itemCount: provider.plans.length,
            itemBuilder: (context, index) {
              final plan = provider.plans[index];
              return _PlanGridCard(
                plan: plan,
                onTap: () => _navigateToRun(context, plan),
                onEdit: () => _navigateToEditor(context, plan),
                onDelete: () => _confirmDelete(context, provider, plan),
              );
            },
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
        title: const Text('Delete plan'),
        content: Text('Delete "${plan.name}"?\n\nThis action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              provider.deletePlan(plan.id);
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

/// Grid card widget for displaying a single plan in grid layout.
class _PlanGridCard extends StatefulWidget {
  final TimerPlan plan;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _PlanGridCard({
    required this.plan,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  State<_PlanGridCard> createState() => _PlanGridCardState();
}

class _PlanGridCardState extends State<_PlanGridCard>
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
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.96).animate(
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
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 400;
    
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) => _controller.reverse(),
      onTapCancel: () => _controller.reverse(),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppDimens.radiusLg),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: widget.onTap,
              borderRadius: BorderRadius.circular(AppDimens.radiusLg),
              child: Padding(
                padding: EdgeInsets.all(isSmallScreen ? AppDimens.sm : AppDimens.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header with icon and menu
                    Row(
                      children: [
                        Container(
                          width: isSmallScreen ? 36 : 44,
                          height: isSmallScreen ? 36 : 44,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [AppColors.secondary, AppColors.accent],
                            ),
                            borderRadius: BorderRadius.circular(isSmallScreen ? 10 : 12),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.secondary.withValues(alpha: 0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.directions_bike,
                            color: Colors.white,
                            size: isSmallScreen ? 18 : 22,
                          ),
                        ),
                        const Spacer(),
                        PopupMenuButton<String>(
                          icon: Icon(
                            Icons.more_horiz,
                            color: AppColors.textSecondaryLight,
                            size: isSmallScreen ? 18 : 20,
                          ),
                          padding: EdgeInsets.zero,
                          onSelected: (value) {
                            if (value == 'edit') widget.onEdit();
                            if (value == 'delete') widget.onDelete();
                          },
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: 'edit',
                              child: Row(
                                children: [
                                  Icon(Icons.edit_outlined, color: AppColors.secondary, size: 18),
                                  SizedBox(width: AppDimens.sm),
                                  Text('Edit'),
                                ],
                              ),
                            ),
                            PopupMenuItem(
                              value: 'delete',
                              child: Row(
                                children: [
                                  Icon(Icons.delete_outline, color: AppColors.error, size: 18),
                                  const SizedBox(width: AppDimens.sm),
                                  Text('Delete', style: TextStyle(color: AppColors.error)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    
                    SizedBox(height: isSmallScreen ? AppDimens.sm : AppDimens.md),
                    
                    // Title
                    Text(
                      widget.plan.name,
                      style: TextStyle(
                        fontSize: isSmallScreen ? 14 : 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimaryLight,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    
                    if (widget.plan.description?.isNotEmpty ?? false) ...[
                      const SizedBox(height: 4),
                      Text(
                        widget.plan.description!,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondaryLight,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    
                    const Spacer(),
                    
                    // Stats row
                    Row(
                      children: [
                        _buildStat(Icons.schedule, widget.plan.formattedDuration, isSmallScreen),
                        SizedBox(width: isSmallScreen ? AppDimens.sm : AppDimens.md),
                        _buildStat(Icons.repeat, '${widget.plan.repeatRules.length}', isSmallScreen),
                      ],
                    ),
                    
                    SizedBox(height: isSmallScreen ? 6 : AppDimens.sm),
                    
                    // Play button
                    SizedBox(
                      width: double.infinity,
                      height: isSmallScreen ? 36 : 40,
                      child: ElevatedButton(
                        onPressed: widget.onTap,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 8 : 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppDimens.radiusMd),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.play_arrow, size: isSmallScreen ? 18 : 20),
                            const SizedBox(width: 4),
                            Text(
                              'Start',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: isSmallScreen ? 13 : 14,
                              ),
                            ),
                          ],
                        ),
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

  Widget _buildStat(IconData icon, String value, bool isSmallScreen) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: isSmallScreen ? 12 : 14, color: AppColors.textSecondaryLight),
        const SizedBox(width: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: isSmallScreen ? 11 : 12,
            color: AppColors.textSecondaryLight,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

/// Card widget for displaying a single plan (list view - legacy).
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
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppDimens.radiusLg),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: InkWell(
              onTap: widget.onTap,
              borderRadius: BorderRadius.circular(AppDimens.radiusLg),
              child: Padding(
                padding: const EdgeInsets.all(AppDimens.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [AppColors.secondary, AppColors.accent],
                            ),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(
                            Icons.directions_bike,
                            color: Colors.white,
                            size: 26,
                          ),
                        ),
                        const SizedBox(width: AppDimens.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.plan.name,
                                style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimaryLight,
                                ),
                              ),
                              if (widget.plan.description?.isNotEmpty ?? false)
                                Text(
                                  widget.plan.description!,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: AppColors.textSecondaryLight,
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
                            color: AppColors.textSecondaryLight,
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
                                  Icon(Icons.edit_outlined, color: AppColors.secondary),
                                  SizedBox(width: AppDimens.sm),
                                  Text('Edit'),
                                ],
                              ),
                            ),
                            PopupMenuItem(
                              value: 'delete',
                              child: Row(
                                children: [
                                  Icon(Icons.delete_outline, color: AppColors.error),
                                  const SizedBox(width: AppDimens.sm),
                                  Text('Delete', style: TextStyle(color: AppColors.error)),
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
                          label: '${widget.plan.events.length} events',
                        ),
                        InfoChip(
                          icon: Icons.repeat,
                          label: '${widget.plan.repeatRules.length} intervals',
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
                        label: const Text('Start'),
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
