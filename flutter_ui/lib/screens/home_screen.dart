import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/ui/ui.dart';
import 'check_in_screen.dart';
import 'insights_screen.dart';
import 'practice_screen.dart';

/// App shell: brand header, the three tabs and the floating navigation bar.
///
/// Tabs are kept alive (so a half-written check-in survives switching tabs)
/// and cross-fade on change.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  String _activeTool = 'breathing';
  String _activeEmotion = 'focused';

  static const _navItems = [
    EmoNavItem(icon: Icons.edit_note_outlined, activeIcon: Icons.edit_note_rounded, label: 'Check-in'),
    EmoNavItem(icon: Icons.self_improvement_outlined, activeIcon: Icons.self_improvement_rounded, label: 'Practice'),
    EmoNavItem(icon: Icons.insights_outlined, activeIcon: Icons.insights_rounded, label: 'Insights'),
  ];

  void _navigateToTool(String toolName) {
    setState(() {
      _activeTool = toolName;
      _currentIndex = 1; // Practice
    });
  }

  void _onEmotionChanged(String newEmotion) {
    if (_activeEmotion != newEmotion) {
      setState(() => _activeEmotion = newEmotion);
    }
  }

  @override
  Widget build(BuildContext context) {
    final emotion = EmotionStyle.of(_activeEmotion);
    final accent = emotion.color(context);
    final keyboardOpen = MediaQuery.viewInsetsOf(context).bottom > 0;

    return Scaffold(
      body: AmbientBackdrop(
        tint: accent,
        child: SafeArea(
          bottom: false,
          child: Stack(
            children: [
              Column(
                children: [
                  _BrandHeader(emotion: emotion, accent: accent, onStateTap: () => setState(() => _currentIndex = 0)),
                  Expanded(
                    child: _FadeIndexedStack(
                      index: _currentIndex,
                      children: [
                        CheckInScreen(
                          onNavigateToTool: _navigateToTool,
                          onEmotionChanged: _onEmotionChanged,
                        ),
                        PracticeScreen(
                          key: ValueKey(_activeTool),
                          initialTool: _activeTool,
                        ),
                        const InsightsScreen(),
                      ],
                    ),
                  ),
                ],
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: AnimatedSlide(
                  offset: keyboardOpen ? const Offset(0, 1.5) : Offset.zero,
                  duration: EmoMotion.medium,
                  curve: EmoMotion.standard,
                  child: EmoNavBar(
                    items: _navItems,
                    index: _currentIndex,
                    accent: accent,
                    onChanged: (i) => setState(() => _currentIndex = i),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BrandHeader extends StatelessWidget {
  final EmotionStyle emotion;
  final Color accent;
  final VoidCallback onStateTap;

  const _BrandHeader({required this.emotion, required this.accent, required this.onStateTap});

  @override
  Widget build(BuildContext context) {
    final p = context.emo;
    return Padding(
      padding: const EdgeInsets.fromLTRB(EmoSpace.gutter, EmoSpace.sm, EmoSpace.gutter, EmoSpace.sm),
      child: ContentFrame(
        child: Row(
          children: [
            AnimatedContainer(
              duration: EmoMotion.ambient,
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [accent, Color.lerp(accent, p.brand, 0.6)!],
                ),
                boxShadow: [BoxShadow(color: accent.withValues(alpha: 0.45), blurRadius: 12)],
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Emostate',
                style: context.text.titleLarge?.copyWith(fontWeight: FontWeight.w700, letterSpacing: -0.4),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: EmoSpace.xs),
            Pressable(
              onTap: onStateTap,
              semanticLabel: 'Current state: ${emotion.label}',
              child: AnimatedContainer(
                duration: EmoMotion.slow,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: p.isDark ? 0.14 : 0.1),
                  borderRadius: BorderRadius.circular(EmoRadius.pill),
                  border: Border.all(color: accent.withValues(alpha: 0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(emotion.icon, size: 15, color: accent),
                    const SizedBox(width: 6),
                    AnimatedSwitcher(
                      duration: EmoMotion.medium,
                      child: Text(
                        emotion.label,
                        key: ValueKey(emotion.id),
                        style: context.text.labelMedium?.copyWith(color: accent),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Keeps every tab alive and cross-fades between them. Hidden tabs have
/// tickers paused, pointer input blocked and semantics excluded.
class _FadeIndexedStack extends StatelessWidget {
  final int index;
  final List<Widget> children;

  const _FadeIndexedStack({required this.index, required this.children});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        for (var i = 0; i < children.length; i++)
          AnimatedOpacity(
            opacity: i == index ? 1 : 0,
            duration: EmoMotion.medium,
            curve: EmoMotion.standard,
            child: AnimatedSlide(
              offset: i == index ? Offset.zero : const Offset(0, 0.015),
              duration: EmoMotion.medium,
              curve: EmoMotion.standard,
              child: IgnorePointer(
                ignoring: i != index,
                child: ExcludeSemantics(
                  excluding: i != index,
                  child: TickerMode(enabled: i == index, child: children[i]),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
