import 'dart:async';

import 'package:flutter/material.dart';

import '../../models/check_in_record.dart';
import '../../services/auth_service.dart';
import '../../services/check_in_repository.dart';
import '../../theme/app_theme.dart';
import '../../widgets/ui/ui.dart';
import '../account/account_sheet.dart';

/// "My history" — the signed-in user's saved check-ins from Supabase,
/// rendered as slivers inside the Insights scroll view.
class HistorySection extends StatefulWidget {
  final EdgeInsets padding;

  const HistorySection({super.key, required this.padding});

  @override
  State<HistorySection> createState() => _HistorySectionState();
}

class _HistorySectionState extends State<HistorySection> {
  List<CheckInRecord> _records = [];
  bool _loading = false;
  String? _error;
  StreamSubscription<Object?>? _authSub;

  @override
  void initState() {
    super.initState();
    CheckInRepository.revision.addListener(_load);
    _authSub = AuthService.changes.listen((_) => _load());
    _load();
  }

  @override
  void dispose() {
    CheckInRepository.revision.removeListener(_load);
    _authSub?.cancel();
    super.dispose();
  }

  Future<void> _load() async {
    if (!AuthService.isSignedIn) {
      if (mounted) setState(() => _records = []);
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final records = await CheckInRepository.fetchMine();
      if (!mounted) return;
      setState(() {
        _records = records;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = CheckInRepository.describeError(e);
        _loading = false;
      });
    }
  }

  Future<void> _delete(CheckInRecord r) async {
    try {
      await CheckInRepository.delete(r.id);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(CheckInRepository.describeError(e))),
        );
      }
    }
  }

  Widget _box(Widget child) => SliverPadding(
    padding: widget.padding,
    sliver: SliverToBoxAdapter(child: child),
  );

  @override
  Widget build(BuildContext context) {
    if (!AuthService.isSignedIn) {
      return _box(
        EmoCard(
          child: EmptyState(
            icon: Icons.lock_outline_rounded,
            title: 'Sign in to see your history',
            message: 'Save readings from Check-in and track how your states change over time.',
            actionLabel: 'Sign in',
            onAction: () => showAccountSheet(context),
          ),
        ),
      );
    }

    if (_loading && _records.isEmpty) {
      return _box(
        const Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SkeletonBox(height: 84, radius: EmoRadius.lg),
            SizedBox(height: EmoSpace.sm),
            SkeletonBox(height: 110, radius: EmoRadius.lg),
            SizedBox(height: EmoSpace.sm),
            SkeletonBox(height: 90, radius: EmoRadius.lg),
          ],
        ),
      );
    }

    if (_error != null) {
      return _box(
        EmoCard(
          child: ErrorState(
            title: "Couldn't load your history",
            message: _error!,
            onRetry: _load,
          ),
        ),
      );
    }

    if (_records.isEmpty) {
      return _box(
        const EmoCard(
          child: EmptyState(
            icon: Icons.bookmark_border_rounded,
            title: 'No saved check-ins yet',
            message: 'Tap "Save to history" under a reading on the Check-in tab to start your timeline.',
          ),
        ),
      );
    }

    return SliverMainAxisGroup(
      slivers: [
        _box(_HistoryOverview(records: _records)),
        SliverPadding(
          padding: widget.padding.copyWith(
            top: EmoSpace.xl,
            bottom: EmoSpace.xs,
          ),
          sliver: SliverToBoxAdapter(
            child: Text(
              '${_records.length} saved ${_records.length == 1 ? 'check-in' : 'check-ins'}',
              style: context.text.labelMedium?.tabular,
            ),
          ),
        ),
        SliverPadding(
          padding: widget.padding,
          sliver: SliverList.separated(
            itemCount: _records.length,
            separatorBuilder: (_, _) => const SizedBox(height: EmoSpace.xs),
            itemBuilder: (context, i) => _HistoryTile(
              key: ValueKey(_records[i].id),
              record: _records[i],
              onDelete: () => _delete(_records[i]),
            ),
          ),
        ),
      ],
    );
  }
}

class _HistoryOverview extends StatelessWidget {
  final List<CheckInRecord> records;

  const _HistoryOverview({required this.records});

  @override
  Widget build(BuildContext context) {
    final p = context.emo;
    final counts = <String, int>{};
    for (final r in records) {
      final id = EmotionStyle.of(r.result.predictedState).id;
      counts[id] = (counts[id] ?? 0) + 1;
    }
    final top = counts.entries.reduce((a, b) => a.value >= b.value ? a : b);
    final avgStress =
        records.map((r) => r.input.stressLevel).reduce((a, b) => a + b) /
        records.length;
    // Oldest → newest, last 14 entries.
    final recent = records.take(14).toList().reversed.toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: _Metric(label: 'Check-ins', value: '${records.length}'),
              ),
              const SizedBox(width: EmoSpace.xs),
              Expanded(
                child: _Metric(
                  label: 'Most often',
                  value: EmotionStyle.of(top.key).label,
                  dot: EmotionStyle.of(top.key).color(context),
                ),
              ),
              const SizedBox(width: EmoSpace.xs),
              Expanded(
                child: _Metric(
                  label: 'Avg stress',
                  value: '${avgStress.toStringAsFixed(1)}/5',
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: EmoSpace.sm),
        EmoCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Recent states', style: context.text.titleMedium),
              const SizedBox(height: 2),
              Text(
                'Your last ${recent.length} check-ins, oldest to newest.',
                style: context.text.bodySmall,
              ),
              const SizedBox(height: EmoSpace.md),
              Row(
                children: [
                  for (final r in recent)
                    Expanded(
                      child: Tooltip(
                        message: EmotionStyle.of(r.result.predictedState).label,
                        child: Container(
                          height: 28,
                          margin: const EdgeInsets.symmetric(horizontal: 1.5),
                          decoration: BoxDecoration(
                            color: EmotionStyle.of(r.result.predictedState)
                                .color(context),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ),
                  for (var i = recent.length; i < 14; i++)
                    Expanded(
                      child: Container(
                        height: 28,
                        margin: const EdgeInsets.symmetric(horizontal: 1.5),
                        decoration: BoxDecoration(
                          color: p.surfaceRaised,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: EmoSpace.lg),
              Text('State mix', style: context.text.titleSmall),
              const SizedBox(height: EmoSpace.sm),
              DistributionBar(counts: counts),
            ],
          ),
        ),
      ],
    );
  }
}

class _Metric extends StatelessWidget {
  final String label;
  final String value;
  final Color? dot;

  const _Metric({required this.label, required this.value, this.dot});

  @override
  Widget build(BuildContext context) {
    return EmoCard(
      padding: const EdgeInsets.all(EmoSpace.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: context.text.labelSmall?.copyWith(letterSpacing: 0.2),
            maxLines: 1,
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              if (dot != null) ...[
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(color: dot, shape: BoxShape.circle),
                ),
                const SizedBox(width: 6),
              ],
              Expanded(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(value, style: context.text.titleLarge?.tabular),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HistoryTile extends StatefulWidget {
  final CheckInRecord record;
  final VoidCallback onDelete;

  const _HistoryTile({super.key, required this.record, required this.onDelete});

  @override
  State<_HistoryTile> createState() => _HistoryTileState();
}

class _HistoryTileState extends State<_HistoryTile> {
  bool _expanded = false;

  static const _months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  static String _when(DateTime t) {
    final now = DateTime.now();
    final hm =
        '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
    final today = DateTime(now.year, now.month, now.day);
    final day = DateTime(t.year, t.month, t.day);
    final diff = today.difference(day).inDays;
    if (diff == 0) return 'Today, $hm';
    if (diff == 1) return 'Yesterday, $hm';
    return '${t.day} ${_months[t.month - 1]}${t.year != now.year ? ' ${t.year}' : ''}, $hm';
  }

  Future<void> _confirmDelete() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete this check-in?'),
        content: const Text(
          'It will be permanently removed from your history.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: ctx.emo.danger),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (ok == true) widget.onDelete();
  }

  @override
  Widget build(BuildContext context) {
    final p = context.emo;
    final r = widget.record;
    final action = ActionStyle.of(r.result.whatToDo);

    return Pressable(
      onTap: () => setState(() => _expanded = !_expanded),
      pressedScale: 0.985,
      haptic: false,
      semanticLabel:
          '${_when(r.createdAt)}, ${EmotionStyle.of(r.result.predictedState).label}',
      child: EmoCard(
        padding: const EdgeInsets.all(EmoSpace.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                StateBadge(state: r.result.predictedState, dense: true),
                const SizedBox(width: EmoSpace.xs),
                Expanded(
                  child: Text(
                    _when(r.createdAt),
                    style: context.text.labelSmall?.copyWith(
                      letterSpacing: 0.1,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  '${(r.result.confidence * 100).round()}%',
                  style: context.text.labelMedium
                      ?.copyWith(
                        color: r.result.isUncertain
                            ? p.caution
                            : p.textSecondary,
                      )
                      .tabular,
                ),
              ],
            ),
            const SizedBox(height: EmoSpace.sm),
            Text(
              r.input.journalText,
              maxLines: _expanded ? null : 2,
              overflow: _expanded ? null : TextOverflow.ellipsis,
              style: context.text.bodyMedium?.copyWith(color: p.textPrimary),
            ),
            const SizedBox(height: EmoSpace.xs),
            Row(
              children: [
                Icon(action.icon, size: 16, color: p.textTertiary),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    '${action.label} · ${ActionStyle.timingLabel(r.result.whenToDo)}',
                    style: context.text.bodySmall,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            AnimatedSize(
              duration: EmoMotion.medium,
              alignment: Alignment.topCenter,
              child: _expanded
                  ? Padding(
                      padding: const EdgeInsets.only(top: EmoSpace.sm),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Divider(color: p.border, height: 1),
                          const SizedBox(height: EmoSpace.sm),
                          Text(
                            'Stress ${r.input.stressLevel}/5 · Energy ${r.input.energyLevel}/5 · '
                            'Sleep ${r.input.sleepHours}h · Intensity ${r.result.predictedIntensity}/5',
                            style: context.text.labelSmall
                                ?.copyWith(letterSpacing: 0.1)
                                .tabular,
                          ),
                          if (r.result.supportMessage.isNotEmpty) ...[
                            const SizedBox(height: EmoSpace.xs),
                            Text(
                              r.result.supportMessage,
                              style: context.text.bodySmall,
                            ),
                          ],
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton.icon(
                              onPressed: _confirmDelete,
                              style: TextButton.styleFrom(
                                foregroundColor: p.danger,
                              ),
                              icon: const Icon(
                                Icons.delete_outline_rounded,
                                size: 18,
                              ),
                              label: const Text('Delete'),
                            ),
                          ),
                        ],
                      ),
                    )
                  : const SizedBox(width: double.infinity),
            ),
          ],
        ),
      ),
    );
  }
}
