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
    EmoNavItem(
      icon: Icons.edit_note_outlined,
      activeIcon: Icons.edit_note_rounded,
      label: 'Check-in',
    ),
    EmoNavItem(
      icon: Icons.self_improvement_outlined,
      activeIcon: Icons.self_improvement_rounded,
      label: 'Practice',
    ),
    EmoNavItem(
      icon: Icons.insights_outlined,
      activeIcon: Icons.insights_rounded,
      label: 'Insights',
    ),
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
    final keyboardOpen = MediaQuery.viewInsetsOf(context).bottom > 0;

    return Scaffold(
      bottomNavigationBar: keyboardOpen
          ? null
          : EmoNavBar(
              items: _navItems,
              index: _currentIndex,
              onChanged: (i) => setState(() => _currentIndex = i),
            ),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _BrandHeader(
              emotion: emotion,
              onStateTap: () => setState(() => _currentIndex = 0),
            ),
            Expanded(
              child: _KeptAliveTabs(
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
      ),
    );
  }
}

class _BrandHeader extends StatelessWidget {
  final EmotionStyle emotion;
  final VoidCallback onStateTap;

  const _BrandHeader({required this.emotion, required this.onStateTap});

  @override
  Widget build(BuildContext context) {
    final p = context.emo;
    final stateColor = emotion.color(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        EmoSpace.gutter,
        EmoSpace.sm,
        EmoSpace.gutter,
        EmoSpace.xs,
      ),
      child: ContentFrame(
        child: Row(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: p.brand,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.monitor_heart_rounded,
                size: 17,
                color: p.onAccent,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Emostate',
                style: context.text.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.5,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: EmoSpace.xs),
            Pressable(
              onTap: onStateTap,
              semanticLabel: 'Current state: ${emotion.label}',
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: p.surface,
                  borderRadius: BorderRadius.circular(EmoRadius.pill),
                  border: Border.all(color: p.border),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnimatedContainer(
                      duration: EmoMotion.medium,
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: stateColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 7),
                    AnimatedSwitcher(
                      duration: EmoMotion.medium,
                      child: Text(
                        emotion.label,
                        key: ValueKey(emotion.id),
                        style: context.text.labelMedium?.copyWith(
                          color: p.textPrimary,
                        ),
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

/// Keeps every tab alive and switches instantly between them. Hidden tabs have
/// tickers paused, pointer input blocked and semantics excluded.
class _KeptAliveTabs extends StatelessWidget {
  final int index;
  final List<Widget> children;

  const _KeptAliveTabs({required this.index, required this.children});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        for (var i = 0; i < children.length; i++)
          Offstage(
            offstage: i != index,
            child: IgnorePointer(
              ignoring: i != index,
              child: ExcludeSemantics(
                excluding: i != index,
                child: TickerMode(enabled: i == index, child: children[i]),
              ),
            ),
          ),
      ],
    );
  }
}
