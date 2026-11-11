import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../../widgets/ui/ui.dart';

/// The free-writing input — the primary interaction of the app.
class JournalCard extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;
  final bool isAnalyzing;

  const JournalCard({
    super.key,
    required this.controller,
    required this.onChanged,
    required this.onClear,
    required this.isAnalyzing,
  });

  static int wordCount(String text) =>
      text.trim().split(RegExp(r'\s+')).where((w) => w.isNotEmpty).length;

  @override
  Widget build(BuildContext context) {
    final p = context.emo;

    return EmoCard(
      padding: const EdgeInsets.fromLTRB(
        EmoSpace.md,
        EmoSpace.md,
        EmoSpace.xs,
        EmoSpace.xxs,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: controller,
            minLines: 3,
            maxLines: 9,
            textCapitalization: TextCapitalization.sentences,
            keyboardType: TextInputType.multiline,
            style: context.text.bodyLarge?.copyWith(height: 1.5),
            cursorColor: p.brand,
            onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
            decoration: InputDecoration(
              isCollapsed: true,
              border: InputBorder.none,
              hintText:
                  "What's on your mind? How did the session leave you feeling?",
              hintStyle: context.text.bodyLarge?.copyWith(
                color: p.textTertiary,
              ),
            ),
            onChanged: onChanged,
          ),
          const SizedBox(height: EmoSpace.md),
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: controller,
            builder: (context, value, _) {
              final words = wordCount(value.text);
              return Row(
                children: [
                  _StatusDot(
                    active: isAnalyzing,
                    color: isAnalyzing ? p.brand : p.textTertiary,
                  ),
                  const SizedBox(width: EmoSpace.xs),
                  AnimatedSwitcher(
                    duration: EmoMotion.fast,
                    child: Text(
                      isAnalyzing
                          ? 'Reading…'
                          : '$words ${words == 1 ? 'word' : 'words'}',
                      key: ValueKey(isAnalyzing ? -1 : words),
                      style: context.text.labelMedium
                          ?.copyWith(color: p.textTertiary)
                          .tabular,
                    ),
                  ),
                  if (!isAnalyzing && words > 0 && words < 4) ...[
                    const SizedBox(width: EmoSpace.xs),
                    Flexible(
                      child: Text(
                        '· a few more words improves accuracy',
                        style: context.text.labelMedium?.copyWith(
                          color: p.caution,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                  const Spacer(),
                  if (value.text.isNotEmpty)
                    IconButton(
                      onPressed: onClear,
                      tooltip: 'Clear entry',
                      visualDensity: VisualDensity.compact,
                      icon: Icon(
                        Icons.close_rounded,
                        size: 18,
                        color: p.textTertiary,
                      ),
                    )
                  else
                    const SizedBox(height: 40),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _StatusDot extends StatefulWidget {
  final bool active;
  final Color color;

  const _StatusDot({required this.active, required this.color});

  @override
  State<_StatusDot> createState() => _StatusDotState();
}

class _StatusDotState extends State<_StatusDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 700),
  );

  @override
  void initState() {
    super.initState();
    if (widget.active) _c.repeat(reverse: true);
  }

  @override
  void didUpdateWidget(_StatusDot old) {
    super.didUpdateWidget(old);
    if (widget.active && !_c.isAnimating) {
      _c.repeat(reverse: true);
    } else if (!widget.active && _c.isAnimating) {
      _c.stop();
    }
  }

  static const _idle = AlwaysStoppedAnimation<double>(1);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: widget.active ? Tween(begin: 0.3, end: 1.0).animate(_c) : _idle,
      child: Container(
        width: 7,
        height: 7,
        decoration: BoxDecoration(color: widget.color, shape: BoxShape.circle),
      ),
    );
  }
}
