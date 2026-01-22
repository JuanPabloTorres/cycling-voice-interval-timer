import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import '../providers/providers.dart';
import '../models/models.dart';
import '../services/services.dart';
import '../ui/ui.dart';

/// Screen for executing a timer plan with voice announcements.
/// 
/// Designed for maximum visibility while cycling:
/// - Large timer display readable at arm's length
/// - High contrast dark background
/// - Large touch targets for controls
/// - Subtle animations for running state
class RunTimerScreen extends StatefulWidget {
  final TimerPlan plan;

  const RunTimerScreen({super.key, required this.plan});

  @override
  State<RunTimerScreen> createState() => _RunTimerScreenState();
}

class _RunTimerScreenState extends State<RunTimerScreen>
    with TickerProviderStateMixin {
  bool _audioUnlocked = false;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    
    // Pulse animation for running state
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _pulseAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    
    // Enable wakelock (skip on web)
    if (!kIsWeb) {
      WakelockPlus.enable();
    }
    
    // Load plan into timer engine
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TimerProvider>().loadPlanForExecution(widget.plan);
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    if (!kIsWeb) {
      WakelockPlus.disable();
    }
    super.dispose();
  }

  void _updatePulseAnimation(TimerState state) {
    if (state == TimerState.running && !_pulseController.isAnimating) {
      _pulseController.repeat(reverse: true);
    } else if (state != TimerState.running && _pulseController.isAnimating) {
      _pulseController.stop();
      _pulseController.value = 0;
    }
  }

  Future<void> _unlockAudio(TimerProvider provider) async {
    await provider.testVoice();
    setState(() => _audioUnlocked = true);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          context.read<TimerProvider>().stopTimer();
        }
      },
      child: Scaffold(
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
          centerTitle: true,
          title: Text(
            widget.plan.name,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 20,
              color: AppColors.textPrimaryLight,
            ),
          ),
          actions: [
            Consumer<TimerProvider>(
              builder: (context, provider, child) {
                return IconActionButton(
                  icon: Icons.volume_up,
                  color: provider.ttsService.volume > 0 
                      ? AppColors.primary 
                      : Colors.grey,
                  backgroundColor: Colors.white10,
                  onPressed: () => _showVolumeDialog(context, provider),
                  tooltip: 'Volumen',
                );
              },
            ),
            const SizedBox(width: AppDimens.sm),
          ],
        ),
        body: Consumer<TimerProvider>(
          builder: (context, provider, child) {
            _updatePulseAnimation(provider.timerState);
            
            return SafeArea(
              child: Column(
                children: [
                  // Main timer display
                  Expanded(
                    flex: 4,
                    child: _buildTimerDisplay(context, provider),
                  ),
                  
                  // Progress bar
                  if (widget.plan.totalDurationSeconds != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: AppDimens.xl),
                      child: TimerProgressBar(
                        progress: provider.progress,
                        color: _getStateColor(provider.timerState),
                      ),
                    ),
                  
                  // Message log
                  Expanded(
                    flex: 2,
                    child: _buildMessageLog(provider),
                  ),
                  
                  // Control buttons
                  _buildControls(context, provider),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildTimerDisplay(BuildContext context, TimerProvider provider) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Web audio unlock button
          if (kIsWeb && !_audioUnlocked && provider.timerState == TimerState.idle)
            Padding(
              padding: const EdgeInsets.only(bottom: AppDimens.xl),
              child: SecondaryButton(
                label: 'Activar Voz',
                icon: Icons.volume_up,
                color: AppColors.warning,
                onPressed: () => _unlockAudio(provider),
              ),
            ),
          
          // Elapsed time with glow effect when running
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Container(
                padding: const EdgeInsets.all(AppDimens.lg),
                decoration: provider.timerState == TimerState.running
                    ? BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.play.withValues(
                              alpha: 0.2 + (_pulseAnimation.value * 0.15),
                            ),
                            blurRadius: 40 + (_pulseAnimation.value * 20),
                            spreadRadius: 10 + (_pulseAnimation.value * 10),
                          ),
                        ],
                      )
                    : null,
                child: TimeDisplay(
                  time: provider.formattedElapsedTime,
                  isLarge: true,
                ),
              );
            },
          ),
          
          // Remaining time
          if (provider.formattedRemainingTime != null) ...[
            const SizedBox(height: AppDimens.sm),
            Text(
              'Remaining: ${provider.formattedRemainingTime}',
              style: TextStyle(
                fontSize: 18,
                color: Colors.white.withValues(alpha: 0.5),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
          
          // Status badge
          const SizedBox(height: AppDimens.lg),
          _buildStatusBadge(provider.timerState),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(TimerState state) {
    final (text, icon, color, animated) = switch (state) {
      TimerState.idle => ('Ready to start', Icons.hourglass_empty, Colors.grey, false),
      TimerState.running => ('Running', Icons.play_arrow, AppColors.play, true),
      TimerState.paused => ('Paused', Icons.pause, AppColors.pause, false),
      TimerState.completed => ('Completed!', Icons.check_circle, AppColors.info, false),
    };
    
    return StatusBadge(
      text: text,
      icon: icon,
      color: color,
      isAnimated: animated,
    );
  }

  Widget _buildMessageLog(TimerProvider provider) {
    if (provider.recentMessages.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.chat_bubble_outline,
              size: 40,
              color: Colors.white.withValues(alpha: 0.2),
            ),
            const SizedBox(height: AppDimens.sm),
            Text(
              'Messages will appear here',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.3),
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: AppDimens.md),
      itemCount: provider.recentMessages.length,
      itemBuilder: (context, index) {
        final message = provider.recentMessages[index];
        final isFirst = index == 0;
        
        return AnimatedContainer(
          duration: AppDurations.fast,
          margin: const EdgeInsets.only(bottom: AppDimens.sm),
          padding: const EdgeInsets.all(AppDimens.md),
          decoration: BoxDecoration(
            color: isFirst 
                ? AppColors.play.withValues(alpha: 0.15)
                : Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(AppDimens.radiusMd),
            border: isFirst 
                ? Border.all(color: AppColors.play.withValues(alpha: 0.4))
                : null,
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimens.sm,
                  vertical: AppDimens.xs,
                ),
                decoration: BoxDecoration(
                  color: isFirst ? AppColors.play : Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppDimens.radiusSm),
                ),
                child: Text(
                  _formatSecond(message.second),
                  style: TextStyle(
                    color: isFirst ? Colors.white : Colors.white.withValues(alpha: 0.6),
                    fontSize: 12,
                    fontFamily: 'monospace',
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: AppDimens.md),
              Expanded(
                child: Text(
                  message.message,
                  style: TextStyle(
                    color: isFirst ? Colors.white : Colors.white.withValues(alpha: 0.6),
                    fontSize: isFirst ? 16 : 14,
                    fontWeight: isFirst ? FontWeight.w500 : FontWeight.normal,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildControls(BuildContext context, TimerProvider provider) {
    final state = provider.timerState;
    
    return Container(
      padding: const EdgeInsets.all(AppDimens.lg),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Reset button
          TimerControlButton(
            icon: Icons.replay,
            label: 'Reset',
            color: AppColors.reset,
            onPressed: state != TimerState.idle
                ? () => provider.resetTimer()
                : null,
          ),
          
          // Main Play/Pause button
          _buildMainControlButton(provider),
          
          // Stop button
          TimerControlButton(
            icon: Icons.stop,
            label: 'Stop',
            color: AppColors.stop,
            onPressed: state != TimerState.idle
                ? () {
                    provider.stopTimer();
                    Navigator.pop(context);
                  }
                : null,
          ),
        ],
      ),
    );
  }

  Widget _buildMainControlButton(TimerProvider provider) {
    final state = provider.timerState;
    
    final (icon, label, color, onPressed) = switch (state) {
      TimerState.idle => (
          Icons.play_arrow,
          'Start',
          AppColors.play,
          () => provider.startTimer(),
        ),
      TimerState.running => (
          Icons.pause,
          'Pause',
          AppColors.pause,
          () => provider.pauseTimer(),
        ),
      TimerState.paused => (
          Icons.play_arrow,
          'Resume',
          AppColors.play,
          () => provider.resumeTimer(),
        ),
      TimerState.completed => (
          Icons.replay,
          'Repeat',
          AppColors.info,
          () {
            provider.resetTimer();
            provider.startTimer();
          },
        ),
    };

    return TimerControlButton(
      icon: icon,
      label: label,
      color: color,
      isPrimary: true,
      showPulse: state == TimerState.running,
      onPressed: onPressed,
    );
  }

  Color _getStateColor(TimerState state) {
    return switch (state) {
      TimerState.idle => Colors.grey,
      TimerState.running => AppColors.play,
      TimerState.paused => AppColors.pause,
      TimerState.completed => AppColors.info,
    };
  }

  void _showVolumeDialog(BuildContext context, TimerProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Volumen de voz'),
        content: StatefulBuilder(
          builder: (context, setDialogState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Slider(
                  value: provider.ttsService.volume,
                  onChanged: (value) {
                    setDialogState(() {});
                    provider.setVolume(value);
                  },
                ),
                Text(
                  '${(provider.ttsService.volume * 100).toInt()}%',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: AppDimens.md),
                SecondaryButton(
                  label: 'Probar voz',
                  icon: Icons.volume_up,
                  onPressed: () => provider.testVoice(),
                ),
              ],
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  String _formatSecond(int totalSeconds) {
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}
