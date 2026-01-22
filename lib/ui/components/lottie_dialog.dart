import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../ui.dart';

/// Shows a success animation dialog with Lottie.
Future<void> showSuccessAnimation(
  BuildContext context, {
  String? message,
  Duration duration = const Duration(milliseconds: 1500),
}) async {
  await showDialog(
    context: context,
    barrierDismissible: false,
    barrierColor: Colors.black.withValues(alpha: 0.3),
    builder: (context) => _LottieSuccessDialog(
      message: message,
      duration: duration,
    ),
  );
}

class _LottieSuccessDialog extends StatefulWidget {
  final String? message;
  final Duration duration;

  const _LottieSuccessDialog({
    this.message,
    required this.duration,
  });

  @override
  State<_LottieSuccessDialog> createState() => _LottieSuccessDialogState();
}

class _LottieSuccessDialogState extends State<_LottieSuccessDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
    
    // Auto-close dialog after animation completes
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            Navigator.of(context).pop();
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        padding: const EdgeInsets.all(AppDimens.lg),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppDimens.radiusXl),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Lottie animation
            SizedBox(
              width: 150,
              height: 150,
              child: Lottie.asset(
                'assets/lottie/complete.json',
                controller: _controller,
                onLoaded: (composition) {
                  _controller.duration = composition.duration;
                  _controller.forward();
                },
                repeat: false,
              ),
            ),
            
            if (widget.message != null) ...[
              const SizedBox(height: AppDimens.md),
              Text(
                widget.message!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimaryLight,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
