import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../models/prediction_result.dart';
import '../services/backend.dart';
import '../services/data_repository.dart';
import '../theme/app_theme.dart';
import '../widgets/ui/ui.dart';
import 'insights/history_section.dart';
import 'insights/insights_overview.dart';
import 'insights/prediction_tile.dart';

/// Insights tab: explores the trained model's batch predictions
/// (`assets/predictions.csv`), joined with the original journal text.
class InsightsScreen extends StatefulWidget {
  const InsightsScreen({super.key});

  @override
  State<InsightsScreen> createState() => _InsightsScreenState();
}

class _InsightsScreenState extends State<InsightsScreen> {
  List<PredictionResult> _allPredictions = [];
  List<PredictionResult> _filtered = [];
  Map<int, String> _journalById = {};
  bool _isLoading = true;
  Object? _loadError;

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedEmotion = 'all';
  bool _onlyUncertain = false;

  /// true = My history (cloud), false = Model performance.
  bool _showHistory = Backend.isAvailable;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _loadError = null;
    });
    try {
      final (predictions, inputs) = await (
        DataRepository.loadAllPredictions(),
        DataRepository.loadAllTestInputs(),
      ).wait;
      if (!mounted) return;
      setState(() {
        _allPredictions = predictions;
        _journalById = {
          for (final i in inputs)
            if (i.id != null) i.id!: i.journalText,
        };
        _isLoading = false;
        _applyFilter();
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loadError = e;
        _isLoading = false;
      });
    }
  }

  void _applyFilter() {
    final q = _searchQuery.toLowerCase();
    setState(() {
      _filtered = _allPredictions.where((item) {
        final matchesQuery =
            q.isEmpty ||
            item.id.toString().contains(q) ||
            item.whatToDo.toLowerCase().contains(q) ||
            item.whatToDo.replaceAll('_', ' ').toLowerCase().contains(q) ||
            item.supportMessage.toLowerCase().contains(q) ||
            (_journalById[item.id]?.toLowerCase().contains(q) ?? false);

        final matchesEmotion =
            _selectedEmotion == 'all' ||
            item.predictedState.toLowerCase() == _selectedEmotion;

        final matchesUncertain = !_onlyUncertain || item.uncertainFlag == 1;

        return matchesQuery && matchesEmotion && matchesUncertain;
      }).toList();
    });
  }

  void _clearFilters() {
    _searchController.clear();
    _searchQuery = '';
    _selectedEmotion = 'all';
    _onlyUncertain = false;
    _applyFilter();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final side = math.max(
          EmoSpace.gutter,
          (constraints.maxWidth - EmoSpace.maxContentWidth) / 2,
        );
        final pad = EdgeInsets.symmetric(horizontal: side);

        return CustomScrollView(
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          slivers: [
            SliverPadding(
              padding: pad.copyWith(top: EmoSpace.xs),
              sliver: SliverToBoxAdapter(
                child: PageHeader(
                  eyebrow: 'Insights',
                  title: _showHistory ? 'Your history' : 'Model insights',
                  subtitle: _showHistory
                      ? 'Your saved check-ins and how your state changes over time.'
                      : 'Predictions from the trained XGBoost model on the held-out test set.',
                ),
              ),
            ),
            if (Backend.isAvailable)
              SliverPadding(
                padding: pad.copyWith(top: EmoSpace.md),
                sliver: SliverToBoxAdapter(
                  child: _ViewSwitch(
                    showHistory: _showHistory,
                    onChanged: (v) => setState(() => _showHistory = v),
                  ),
                ),
              ),
            const SliverToBoxAdapter(child: SizedBox(height: EmoSpace.lg)),
            if (_showHistory)
              HistorySection(padding: pad)
            else
              ..._content(pad),
            const SliverToBoxAdapter(
              child: SizedBox(height: EmoSpace.navClearance),
            ),
          ],
        );
      },
    );
  }

  List<Widget> _content(EdgeInsets pad) {
    if (_isLoading) {
      return [
        SliverPadding(
          padding: pad,
          sliver: const SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: SkeletonBox(height: 84, radius: EmoRadius.lg),
                    ),
                    SizedBox(width: EmoSpace.xs),
                    Expanded(
                      child: SkeletonBox(height: 84, radius: EmoRadius.lg),
                    ),
                  ],
                ),
                SizedBox(height: EmoSpace.md),
                SkeletonBox(height: 120, radius: EmoRadius.lg),
                SizedBox(height: EmoSpace.md),
                SkeletonBox(height: 96, radius: EmoRadius.lg),
                SizedBox(height: EmoSpace.xs),
                SkeletonBox(height: 96, radius: EmoRadius.lg),
              ],
            ),
          ),
        ),
      ];
    }

    if (_loadError != null) {
      return [
        SliverPadding(
          padding: pad,
          sliver: SliverToBoxAdapter(
            child: EmoCard(
              child: ErrorState(
                title: "Couldn't load predictions",
                message: 'The prediction data failed to load. Check that assets/predictions.csv is bundled.',
                onRetry: _loadData,
              ),
            ),
          ),
        ),
      ];
    }

    if (_allPredictions.isEmpty) {
      return [
        SliverPadding(
          padding: pad,
          sliver: const SliverToBoxAdapter(
            child: EmoCard(
              child: EmptyState(
                icon: Icons.insights_rounded,
                title: 'No predictions yet',
                message: 'Run the model notebook to generate predictions.csv, then bundle it with the app.',
              ),
            ),
          ),
        ),
      ];
    }

    final p = context.emo;
    final countByState = <String, int>{};
    for (final pr in _allPredictions) {
      countByState[pr.predictedState.toLowerCase()] =
          (countByState[pr.predictedState.toLowerCase()] ?? 0) + 1;
    }
    final hasFilters =
        _searchQuery.isNotEmpty || _selectedEmotion != 'all' || _onlyUncertain;

    return [
      SliverPadding(
        padding: pad,
        sliver: SliverToBoxAdapter(
          child: InsightsOverview(predictions: _allPredictions),
        ),
      ),
      const SliverToBoxAdapter(child: SizedBox(height: EmoSpace.xl)),
      SliverPadding(
        padding: pad,
        sliver: SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SectionHeader(title: 'Browse entries'),
              _SearchField(
                controller: _searchController,
                onChanged: (v) {
                  _searchQuery = v;
                  _applyFilter();
                },
              ),
              const SizedBox(height: EmoSpace.sm),
            ],
          ),
        ),
      ),
      SliverToBoxAdapter(
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          padding: pad,
          child: Row(
            children: [
              EmoChip(
                label: 'All',
                selected: _selectedEmotion == 'all',
                trailing: '${_allPredictions.length}',
                onTap: () {
                  _selectedEmotion = 'all';
                  _applyFilter();
                },
              ),
              for (final s in EmotionStyle.all) ...[
                const SizedBox(width: EmoSpace.xs),
                EmoChip(
                  label: s.label,
                  dot: s.color(context),
                  selected: _selectedEmotion == s.id,
                  trailing: '${countByState[s.id] ?? 0}',
                  onTap: () {
                    _selectedEmotion = s.id;
                    _applyFilter();
                  },
                ),
              ],
              const SizedBox(width: EmoSpace.xs),
              Container(width: 1, height: 24, color: p.border),
              const SizedBox(width: EmoSpace.xs),
              EmoChip(
                label: 'Low confidence',
                icon: Icons.help_outline_rounded,
                selected: _onlyUncertain,
                onTap: () {
                  _onlyUncertain = !_onlyUncertain;
                  _applyFilter();
                },
              ),
            ],
          ),
        ),
      ),
      SliverPadding(
        padding: pad.copyWith(top: EmoSpace.md, bottom: EmoSpace.xs),
        sliver: SliverToBoxAdapter(
          child: Row(
            children: [
              Text(
                '${_filtered.length} ${_filtered.length == 1 ? 'entry' : 'entries'}',
                style: context.text.labelMedium?.tabular,
              ),
              const Spacer(),
              if (hasFilters)
                EmoButton.ghost(
                  label: 'Clear filters',
                  onPressed: _clearFilters,
                ),
            ],
          ),
        ),
      ),
      if (_filtered.isEmpty)
        SliverPadding(
          padding: pad,
          sliver: SliverToBoxAdapter(
            child: EmptyState(
              icon: Icons.search_off_rounded,
              title: 'No entries match',
              message: 'Try a different search term or remove a filter.',
              actionLabel: 'Clear filters',
              onAction: _clearFilters,
            ),
          ),
        )
      else
        SliverPadding(
          padding: pad,
          sliver: SliverList.separated(
            itemCount: _filtered.length,
            separatorBuilder: (_, _) => const SizedBox(height: EmoSpace.xs),
            itemBuilder: (context, index) {
              final item = _filtered[index];
              return PredictionTile(
                key: ValueKey(item.id),
                item: item,
                journalText: _journalById[item.id],
              );
            },
          ),
        ),
    ];
  }
}

class _SearchField extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  const _SearchField({required this.controller, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final p = context.emo;
    OutlineInputBorder border(Color c) => OutlineInputBorder(
      borderRadius: BorderRadius.circular(EmoRadius.md),
      borderSide: BorderSide(color: c),
    );

    return TextField(
      controller: controller,
      onChanged: onChanged,
      onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
      textInputAction: TextInputAction.search,
      style: context.text.bodyLarge?.copyWith(fontSize: 15),
      decoration: InputDecoration(
        hintText: 'Search by ID, action or words',
        hintStyle: context.text.bodyMedium?.copyWith(color: p.textTertiary),
        prefixIcon: Icon(Icons.search_rounded, color: p.textTertiary, size: 20),
        suffixIcon: ValueListenableBuilder<TextEditingValue>(
          valueListenable: controller,
          builder: (context, v, _) => v.text.isEmpty
              ? const SizedBox.shrink()
              : IconButton(
                  tooltip: 'Clear search',
                  icon: Icon(
                    Icons.close_rounded,
                    size: 18,
                    color: p.textTertiary,
                  ),
                  onPressed: () {
                    controller.clear();
                    onChanged('');
                  },
                ),
        ),
        filled: true,
        fillColor: p.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: EmoSpace.md,
          vertical: 14,
        ),
        border: border(p.border),
        enabledBorder: border(p.border),
        focusedBorder: border(p.brand),
      ),
    );
  }
}

/// Two-segment control: My history | Model performance.
class _ViewSwitch extends StatelessWidget {
  final bool showHistory;
  final ValueChanged<bool> onChanged;

  const _ViewSwitch({required this.showHistory, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final p = context.emo;
    Widget segment(String label, bool value) {
      final selected = showHistory == value;
      return Expanded(
        child: Pressable(
          onTap: () => onChanged(value),
          selected: selected,
          semanticLabel: label,
          child: AnimatedContainer(
            duration: EmoMotion.fast,
            height: 34,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: selected ? p.surface : Colors.transparent,
              borderRadius: BorderRadius.circular(EmoRadius.sm),
              boxShadow: selected
                  ? const [
                      BoxShadow(
                        color: Color(0x140F172A),
                        blurRadius: 4,
                        offset: Offset(0, 1),
                      ),
                    ]
                  : null,
            ),
            child: Text(
              label,
              style: context.text.labelMedium?.copyWith(
                color: selected ? p.textPrimary : p.textSecondary,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: p.surfaceSunken,
        borderRadius: BorderRadius.circular(EmoRadius.md),
      ),
      child: Row(
        children: [
          segment('My history', true),
          segment('Model performance', false),
        ],
      ),
    );
  }
}
