import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Section card with optional header and content.
class SectionCard extends StatelessWidget {
  final String? title;
  final String? subtitle;
  final IconData? icon;
  final Widget? trailing;
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;

  const SectionCard({
    super.key,
    this.title,
    this.subtitle,
    this.icon,
    this.trailing,
    required this.child,
    this.padding,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasHeader = title != null || icon != null;
    
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimens.radiusMd),
        child: Padding(
          padding: padding ?? const EdgeInsets.all(AppDimens.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (hasHeader) ...[
                Row(
                  children: [
                    if (icon != null) ...[
                      Icon(icon, color: theme.colorScheme.primary, size: AppDimens.iconMd),
                      const SizedBox(width: AppDimens.sm),
                    ],
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (title != null)
                            Text(
                              title!,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          if (subtitle != null)
                            Text(
                              subtitle!,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                              ),
                            ),
                        ],
                      ),
                    ),
                    if (trailing != null) trailing!,
                  ],
                ),
                const SizedBox(height: AppDimens.md),
              ],
              child,
            ],
          ),
        ),
      ),
    );
  }
}

/// Large time display for timer screen.
class TimeDisplay extends StatelessWidget {
  final String time;
  final String? label;
  final bool isLarge;
  final Color? color;

  const TimeDisplay({
    super.key,
    required this.time,
    this.label,
    this.isLarge = true,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = color ?? Colors.white;
    
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null)
          Text(
            label!,
            style: TextStyle(
              fontSize: 14,
              color: textColor.withValues(alpha: 0.6),
              fontWeight: FontWeight.w500,
            ),
          ),
        Text(
          time,
          style: TextStyle(
            fontSize: isLarge ? 80 : 24,
            fontWeight: FontWeight.w700,
            color: textColor,
            fontFamily: 'monospace',
            letterSpacing: isLarge ? 4 : 2,
            height: 1.0,
          ),
        ),
      ],
    );
  }
}

/// Status badge for timer state.
class StatusBadge extends StatelessWidget {
  final String text;
  final IconData icon;
  final Color color;
  final bool isAnimated;

  const StatusBadge({
    super.key,
    required this.text,
    required this.icon,
    required this.color,
    this.isAnimated = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppDimens.md, vertical: AppDimens.sm),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(AppDimens.radiusFull),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isAnimated)
            _PulsingDot(color: color)
          else
            Icon(icon, color: color, size: AppDimens.iconSm),
          const SizedBox(width: AppDimens.sm),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

class _PulsingDot extends StatefulWidget {
  final Color color;

  const _PulsingDot({required this.color});

  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _animation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: widget.color.withValues(alpha: _animation.value),
          ),
        );
      },
    );
  }
}

/// Empty state with icon and message.
class EmptyStateView extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? action;

  const EmptyStateView({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimens.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: theme.colorScheme.primary.withValues(alpha: 0.1),
              ),
              child: Icon(
                icon,
                size: 40,
                color: theme.colorScheme.primary.withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(height: AppDimens.lg),
            Text(
              title,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            if (subtitle != null) ...[
              const SizedBox(height: AppDimens.sm),
              Text(
                subtitle!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (action != null) ...[
              const SizedBox(height: AppDimens.lg),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}

/// Shimmer loading placeholder.
class ShimmerLoading extends StatefulWidget {
  final double width;
  final double height;
  final BorderRadius? borderRadius;

  const ShimmerLoading({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius,
  });

  @override
  State<ShimmerLoading> createState() => _ShimmerLoadingState();
}

class _ShimmerLoadingState extends State<ShimmerLoading>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _animation = Tween<double>(begin: -2, end: 2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.linear),
    );
    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: widget.borderRadius ?? BorderRadius.circular(AppDimens.radiusSm),
            gradient: LinearGradient(
              begin: Alignment(_animation.value - 1, 0),
              end: Alignment(_animation.value, 0),
              colors: isDark
                  ? [
                      Colors.white10,
                      Colors.white24,
                      Colors.white10,
                    ]
                  : [
                      Colors.grey[300]!,
                      Colors.grey[100]!,
                      Colors.grey[300]!,
                    ],
            ),
          ),
        );
      },
    );
  }
}

/// Skeleton card for loading state.
class SkeletonCard extends StatelessWidget {
  const SkeletonCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppDimens.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const ShimmerLoading(width: 150, height: 20),
                const Spacer(),
                ShimmerLoading(
                  width: 32,
                  height: 32,
                  borderRadius: BorderRadius.circular(AppDimens.radiusFull),
                ),
              ],
            ),
            const SizedBox(height: AppDimens.md),
            const ShimmerLoading(width: double.infinity, height: 14),
            const SizedBox(height: AppDimens.sm),
            const ShimmerLoading(width: 200, height: 14),
            const SizedBox(height: AppDimens.md),
            const Row(
              children: [
                ShimmerLoading(width: 80, height: 24),
                SizedBox(width: AppDimens.sm),
                ShimmerLoading(width: 80, height: 24),
                SizedBox(width: AppDimens.sm),
                ShimmerLoading(width: 80, height: 24),
              ],
            ),
            const SizedBox(height: AppDimens.md),
            const ShimmerLoading(width: double.infinity, height: 48),
          ],
        ),
      ),
    );
  }
}

/// Info chip for displaying metadata.
class InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;

  const InfoChip({
    super.key,
    required this.icon,
    required this.label,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final chipColor = color ?? theme.colorScheme.onSurface.withValues(alpha: 0.6);
    
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimens.sm,
        vertical: AppDimens.xs,
      ),
      decoration: BoxDecoration(
        color: chipColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppDimens.radiusSm),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: chipColor),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: chipColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

/// Progress bar with animated bicycle icon completing a route.
class TimerProgressBar extends StatefulWidget {
  final double progress;
  final Color? color;
  final bool showPercentage;

  const TimerProgressBar({
    super.key,
    required this.progress,
    this.color,
    this.showPercentage = true,
  });

  @override
  State<TimerProgressBar> createState() => _TimerProgressBarState();
}

class _TimerProgressBarState extends State<TimerProgressBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _pedalController;

  @override
  void initState() {
    super.initState();
    _pedalController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    if (widget.progress > 0 && widget.progress < 1) {
      _pedalController.repeat();
    }
  }

  @override
  void didUpdateWidget(TimerProgressBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.progress > 0 && widget.progress < 1) {
      if (!_pedalController.isAnimating) {
        _pedalController.repeat();
      }
    } else {
      _pedalController.stop();
    }
  }

  @override
  void dispose() {
    _pedalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final progressColor = widget.color ?? AppColors.primary;
    
    return Column(
      children: [
        SizedBox(
          height: 40,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final trackWidth = constraints.maxWidth;
              final bikePosition = (trackWidth - 32) * widget.progress;
              
              return Stack(
                clipBehavior: Clip.none,
                children: [
                  // Track background
                  Positioned(
                    left: 0,
                    right: 0,
                    top: 18,
                    child: Container(
                      height: 6,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                  
                  // Progress track
                  Positioned(
                    left: 0,
                    top: 18,
                    child: TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0, end: widget.progress),
                      duration: AppDurations.normal,
                      builder: (context, value, child) {
                        return Container(
                          width: trackWidth * value,
                          height: 6,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                progressColor.withValues(alpha: 0.6),
                                progressColor,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(3),
                            boxShadow: [
                              BoxShadow(
                                color: progressColor.withValues(alpha: 0.4),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  
                  // Start flag
                  Positioned(
                    left: 0,
                    top: 6,
                    child: Icon(
                      Icons.flag_outlined,
                      size: 16,
                      color: Colors.white.withValues(alpha: 0.3),
                    ),
                  ),
                  
                  // Finish flag
                  Positioned(
                    right: 0,
                    top: 6,
                    child: Icon(
                      widget.progress >= 1.0 
                          ? Icons.emoji_events 
                          : Icons.flag,
                      size: 16,
                      color: widget.progress >= 1.0 
                          ? Colors.amber 
                          : Colors.white.withValues(alpha: 0.3),
                    ),
                  ),
                  
                  // Animated bicycle
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: bikePosition),
                    duration: AppDurations.normal,
                    builder: (context, position, child) {
                      return Positioned(
                        left: position,
                        top: 0,
                        child: AnimatedBuilder(
                          animation: _pedalController,
                          builder: (context, child) {
                            return Transform.rotate(
                              angle: _pedalController.value * 0.1 - 0.05,
                              child: Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: progressColor,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: progressColor.withValues(alpha: 0.5),
                                      blurRadius: 12,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.directions_bike,
                                  color: Colors.white,
                                  size: 18,
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                ],
              );
            },
          ),
        ),
        if (widget.showPercentage) ...[
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.speed,
                size: 14,
                color: Colors.white.withValues(alpha: 0.5),
              ),
              const SizedBox(width: 4),
              Text(
                '${(widget.progress * 100).toInt()}% completado',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.6),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
