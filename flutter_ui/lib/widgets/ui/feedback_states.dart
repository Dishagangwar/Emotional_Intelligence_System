import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import 'emo_button.dart';

/// Small coloured pill naming an emotional state.
class StateBadge extends StatelessWidget {
  final String state;
  final bool dense;

  const StateBadge({super.key, required this.state, this.dense = false});

  @override
  Widget build(BuildContext context) {
    final style = EmotionStyle.of(state);
    final color = style.color(context);
    final p = context.emo;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: dense ? 8 : 10,
        vertical: dense ? 3 : 5,
      ),
      decoration: BoxDecoration(
        color: p.surfaceRaised,
        borderRadius: BorderRadius.circular(EmoRadius.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            style.label,
            style: context.text.labelMedium?.copyWith(
              color: p.textPrimary,
              fontSize: dense ? 12 : 13,
            ),
          ),
        ],
      ),
    );
  }
}

/// Inline notice row (caution / info).
class InlineNotice extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final Color color;

  const InlineNotice({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.emo;
    return Container(
      padding: const EdgeInsets.all(EmoSpace.sm),
      decoration: BoxDecoration(
        color: color.withValues(alpha: p.isDark ? 0.1 : 0.08),
        borderRadius: BorderRadius.circular(EmoRadius.md),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: EmoSpace.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: context.text.titleSmall?.copyWith(color: color),
                ),
                const SizedBox(height: 2),
                Text(message, style: context.text.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Centered illustration-style message for empty results.
class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.emo;
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: EmoSpace.xxl,
        horizontal: EmoSpace.lg,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: p.surfaceRaised,
              shape: BoxShape.circle,
              border: Border.all(color: p.border),
            ),
            child: Icon(icon, size: 28, color: p.textTertiary),
          ),
          const SizedBox(height: EmoSpace.md),
          Text(
            title,
            style: context.text.titleMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: EmoSpace.xxs),
          Text(
            message,
            style: context.text.bodySmall,
            textAlign: TextAlign.center,
          ),
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: EmoSpace.md),
            EmoButton.secondary(
              label: actionLabel!,
              onPressed: onAction,
              compact: true,
            ),
          ],
        ],
      ),
    );
  }
}

/// Failure message with a retry button.
class ErrorState extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback? onRetry;

  const ErrorState({
    super.key,
    required this.title,
    required this.message,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.emo;
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: EmoSpace.xl,
        horizontal: EmoSpace.md,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: p.danger.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.error_outline_rounded, color: p.danger, size: 26),
          ),
          const SizedBox(height: EmoSpace.md),
          Text(
            title,
            style: context.text.titleMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: EmoSpace.xxs),
          Text(
            message,
            style: context.text.bodySmall,
            textAlign: TextAlign.center,
          ),
          if (onRetry != null) ...[
            const SizedBox(height: EmoSpace.md),
            EmoButton.secondary(
              label: 'Try again',
              icon: Icons.refresh_rounded,
              onPressed: onRetry,
              compact: true,
            ),
          ],
        ],
      ),
    );
  }
}

/// Shimmering placeholder block for loading layouts.
class SkeletonBox extends StatefulWidget {
  final double? width;
  final double height;
  final double radius;

  const SkeletonBox({
    super.key,
    this.width,
    required this.height,
    this.radius = EmoRadius.md,
  });

  @override
  State<SkeletonBox> createState() => _SkeletonBoxState();
}

class _SkeletonBoxState extends State<SkeletonBox>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  )..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = context.emo;
    final base = p.surfaceRaised;
    final shine = p.isDark
        ? Colors.white.withValues(alpha: 0.06)
        : Colors.white.withValues(alpha: 0.7);
    return AnimatedBuilder(
      animation: _c,
      builder: (context, _) {
        final x = -1.5 + _c.value * 3;
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.radius),
            gradient: LinearGradient(
              begin: Alignment(x - 1, 0),
              end: Alignment(x + 1, 0),
              colors: [base, Color.alphaBlend(shine, base), base],
            ),
          ),
        );
      },
    );
  }
}
