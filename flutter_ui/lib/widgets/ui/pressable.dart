import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../theme/emo_tokens.dart';

/// Wraps any widget with a subtle press-down scale, haptic tick, pointer
/// cursor and button semantics. The base micro-interaction for every
/// tappable surface in the app.
class Pressable extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double pressedScale;
  final bool haptic;
  final String? semanticLabel;
  final bool selected;

  const Pressable({
    super.key,
    required this.child,
    this.onTap,
    this.pressedScale = 0.97,
    this.haptic = true,
    this.semanticLabel,
    this.selected = false,
  });

  @override
  State<Pressable> createState() => _PressableState();
}

class _PressableState extends State<Pressable> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (_pressed != value) setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onTap != null;
    return Semantics(
      button: true,
      enabled: enabled,
      selected: widget.selected,
      label: widget.semanticLabel,
      child: MouseRegion(
        cursor: enabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: enabled ? (_) => _setPressed(true) : null,
          onTapUp: enabled ? (_) => _setPressed(false) : null,
          onTapCancel: enabled ? () => _setPressed(false) : null,
          onTap: enabled
              ? () {
                  if (widget.haptic) HapticFeedback.selectionClick();
                  widget.onTap!();
                }
              : null,
          child: AnimatedScale(
            scale: _pressed ? widget.pressedScale : 1,
            duration: EmoMotion.fast,
            curve: EmoMotion.standard,
            child: AnimatedOpacity(
              opacity: enabled ? 1 : 0.45,
              duration: EmoMotion.fast,
              child: widget.child,
            ),
          ),
        ),
      ),
    );
  }
}
