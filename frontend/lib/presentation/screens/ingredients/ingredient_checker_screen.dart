import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../widgets/common/aura_card.dart';
import '../../widgets/common/aura_button.dart';
import '../../widgets/common/section_header.dart';

class IngredientCheckerScreen extends ConsumerStatefulWidget {
  const IngredientCheckerScreen({super.key});

  @override
  ConsumerState<IngredientCheckerScreen> createState() => _IngredientCheckerScreenState();
}

class _IngredientCheckerScreenState extends ConsumerState<IngredientCheckerScreen> {
  final _searchController = TextEditingController();
  final _focusNode = FocusNode();
  final List<String> _selectedIngredients = [];
  String _searchText = '';
  bool _showResults = false;

  final _suggestedIngredients = [
    'Vitamin C (Ascorbic Acid)', 'Retinol (Vitamin A)', 'Niacinamide',
    'Hyaluronic Acid', 'Glycolic Acid', 'Salicylic Acid',
    'Benzoyl Peroxide', 'Vitamin E (Tocopherol)', 'Ceramides',
    'Peptides', 'AHAs', 'BHAs', 'Azelaic Acid', 'Kojic Acid',
    'Arbutin', 'Lactic Acid', 'Mandelic Acid', 'Ferulic Acid',
    'Zinc PCA', 'Sulfur', 'Tea Tree Oil', 'Aloe Vera',
  ];

  List<String> get _filteredSuggestions {
    if (_searchText.isEmpty) return _suggestedIngredients.take(6).toList();
    return _suggestedIngredients
        .where((i) => i.toLowerCase().contains(_searchText.toLowerCase()))
        .toList();
  }

  final _conflictResults = <_ConflictResult>[
    _ConflictResult(
      a: 'Vitamin C (Ascorbic Acid)',
      b: 'Retinol (Vitamin A)',
      severity: _ConflictSeverity.medium,
      description: 'Both are potent actives that may cause irritation when used together, especially for sensitive skin.',
      recommendation: 'Use Vitamin C in AM routine and Retinol in PM routine.',
    ),
    _ConflictResult(
      a: 'Benzoyl Peroxide',
      b: 'Retinol (Vitamin A)',
      severity: _ConflictSeverity.high,
      description: 'Benzoyl peroxide oxidizes retinol, rendering it ineffective.',
      recommendation: 'Never apply together. Use Benzoyl Peroxide in AM, Retinol in PM.',
    ),
    _ConflictResult(
      a: 'Vitamin C (Ascorbic Acid)',
      b: 'Niacinamide',
      severity: _ConflictSeverity.low,
      description: 'In high concentrations or low pH, can cause flushing. Modern formulations are generally safe.',
      recommendation: 'Generally safe in current formulations. Apply with brief wait time between layers.',
    ),
    _ConflictResult(
      a: 'AHAs',
      b: 'Retinol (Vitamin A)',
      severity: _ConflictSeverity.critical,
      description: 'Both exfoliate and increase cell turnover. Using together can severely compromise skin barrier.',
      recommendation: 'Never use in same routine. Alternate nights or use AHA in AM and Retinol in PM.',
    ),
    _ConflictResult(
      a: 'Hyaluronic Acid',
      b: 'Vitamin C (Ascorbic Acid)',
      severity: _ConflictSeverity.safe,
      description: 'Safe and beneficial combination. Vitamin C brightens while HA hydrates.',
      recommendation: 'Apply Vitamin C first, then HA on damp skin for best results.',
    ),
    _ConflictResult(
      a: 'Salicylic Acid',
      b: 'Niacinamide',
      severity: _ConflictSeverity.safe,
      description: 'Well-tolerated combination. SA exfoliates pores while Niacinamide soothes.',
      recommendation: 'Safe to use together. Apply SA first, then Niacinamide.',
    ),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _addIngredient(String ingredient) {
    if (!_selectedIngredients.contains(ingredient)) {
      setState(() {
        _selectedIngredients.add(ingredient);
        _searchController.clear();
        _searchText = '';
        _focusNode.unfocus();
        _showResults = _selectedIngredients.length >= 2;
      });
    }
  }

  void _removeIngredient(String ingredient) {
    setState(() {
      _selectedIngredients.remove(ingredient);
      _showResults = _selectedIngredients.length >= 2;
    });
  }

  List<_ConflictResult> get _involvingSelected {
    return _conflictResults.where((c) =>
      _selectedIngredients.contains(c.a) && _selectedIngredients.contains(c.b)
    ).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.only(bottom: AppSpacing.xxl),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSearchBar(),
                    const SizedBox(height: AppSpacing.sm),
                    if (_searchController.text.isNotEmpty || _focusNode.hasFocus)
                      _buildSuggestions(),
                    if (_selectedIngredients.isNotEmpty) ...[
                      _buildSelectedChips(),
                      const SizedBox(height: AppSpacing.sm),
                      _buildQuickAddButtons(),
                    ],
                    if (_showResults) ...[
                      const SizedBox(height: AppSpacing.md),
                      _buildResults(),
                    ],
                    if (_selectedIngredients.isEmpty && !_focusNode.hasFocus) ...[
                      const SizedBox(height: AppSpacing.xxl),
                      _buildEmptyState(),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: AppSpacing.horizontalPadding.copyWith(top: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () => context.pop(),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.warmNude.withOpacity(0.3),
                  ),
                  child: const Icon(Icons.arrow_back_rounded, color: AppColors.softCharcoal, size: 20),
                ),
              ),
              const Spacer(),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Ingredient Checker',
            style: AppTypography.sectionTitle.copyWith(color: AppColors.softCharcoal, fontSize: 30),
          ),
          const SizedBox(height: 4),
          Text(
            'Check ingredient compatibility & conflicts',
            style: AppTypography.bodySmall.copyWith(color: AppColors.onSurfaceVariant),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: AppSpacing.horizontalPadding,
      child: Container(
        height: 52,
        margin: const EdgeInsets.only(top: 8),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.outlineVariant),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: TextField(
          controller: _searchController,
          focusNode: _focusNode,
          onChanged: (v) => setState(() => _searchText = v),
          decoration: InputDecoration(
            hintText: 'Search ingredients or products...',
            hintStyle: AppTypography.bodySmall.copyWith(color: AppColors.onSurfaceVariant.withOpacity(0.6)),
            prefixIcon: const Icon(Icons.search_rounded, color: AppColors.onSurfaceVariant, size: 22),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear_rounded, size: 20, color: AppColors.onSurfaceVariant),
                    onPressed: () {
                      _searchController.clear();
                      setState(() => _searchText = '');
                    },
                  )
                : const Icon(Icons.science_outlined, color: AppColors.matteGold, size: 20),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 14),
          ),
        ),
      ),
    );
  }

  Widget _buildSuggestions() {
    final suggestions = _filteredSuggestions;
    return Padding(
      padding: AppSpacing.horizontalPadding,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.outlineVariant.withOpacity(0.5)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: List.generate(suggestions.length, (i) {
            final ing = suggestions[i];
            return InkWell(
              onTap: () => _addIngredient(ing),
              borderRadius: BorderRadius.vertical(
                top: i == 0 ? const Radius.circular(16) : Radius.zero,
                bottom: i == suggestions.length - 1 ? const Radius.circular(16) : Radius.zero,
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    const Icon(Icons.science_outlined, size: 18, color: AppColors.matteGold),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        ing,
                        style: AppTypography.bodySmall.copyWith(color: AppColors.softCharcoal),
                      ),
                    ),
                    const Icon(Icons.add_circle_outline, size: 18, color: AppColors.matteGold),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildSelectedChips() {
    return Padding(
      padding: AppSpacing.horizontalPadding,
      child: Wrap(
        spacing: 8,
        runSpacing: 6,
        children: _selectedIngredients.map((ing) {
          return Chip(
            label: Text(ing, style: AppTypography.caption.copyWith(
              color: AppColors.softCharcoal,
              fontWeight: FontWeight.w500,
            )),
            deleteIcon: const Icon(Icons.close_rounded, size: 16, color: AppColors.onSurfaceVariant),
            onDeleted: () => _removeIngredient(ing),
            backgroundColor: AppColors.matteGold.withOpacity(0.08),
            side: BorderSide(color: AppColors.matteGold.withOpacity(0.3)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildQuickAddButtons() {
    return Padding(
      padding: AppSpacing.horizontalPadding,
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.spa_outlined, size: 16, color: AppColors.matteGold),
              label: Text(
                'From my routine',
                style: AppTypography.caption.copyWith(color: AppColors.matteGold, fontWeight: FontWeight.w600),
              ),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: AppColors.matteGold.withOpacity(0.4)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 10),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.inventory_2_outlined, size: 16, color: AppColors.matteGold),
              label: Text(
                'From my vanity',
                style: AppTypography.caption.copyWith(color: AppColors.matteGold, fontWeight: FontWeight.w600),
              ),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: AppColors.matteGold.withOpacity(0.4)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 10),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResults() {
    final conflicts = _involvingSelected;
    if (conflicts.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: AppSpacing.horizontalPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            title: 'Compatibility Results',
            subtitle: '${conflicts.length} interactions found',
          ),
          ...List.generate(conflicts.length, (i) {
            final conflict = conflicts[i];
            return Padding(
              padding: EdgeInsets.only(bottom: i < conflicts.length - 1 ? 10 : 0),
              child: _ConflictCard(conflict: conflict),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 48),
        child: Column(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.matteGold.withOpacity(0.08),
              ),
              child: const Icon(Icons.science_outlined, size: 40, color: AppColors.matteGold),
            ),
            const SizedBox(height: 16),
            Text(
              'Check Ingredient Compatibility',
              style: AppTypography.cardTitle.copyWith(color: AppColors.softCharcoal),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Add two or more ingredients to check for conflicts and compatibility advice.',
              style: AppTypography.bodySmall.copyWith(color: AppColors.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

enum _ConflictSeverity { safe, low, medium, high, critical }

class _ConflictResult {
  final String a;
  final String b;
  final _ConflictSeverity severity;
  final String description;
  final String recommendation;

  const _ConflictResult({
    required this.a,
    required this.b,
    required this.severity,
    required this.description,
    required this.recommendation,
  });
}

class _ConflictCard extends StatelessWidget {
  final _ConflictResult conflict;

  const _ConflictCard({required this.conflict});

  Color get _severityColor {
    switch (conflict.severity) {
      case _ConflictSeverity.safe:
        return AppColors.sageGreen;
      case _ConflictSeverity.low:
        return AppColors.warning;
      case _ConflictSeverity.medium:
        return AppColors.warning.withOpacity(0.8);
      case _ConflictSeverity.high:
        return AppColors.error.withOpacity(0.8);
      case _ConflictSeverity.critical:
        return AppColors.error;
    }
  }

  Color get _bgColor {
    switch (conflict.severity) {
      case _ConflictSeverity.safe:
        return AppColors.sageGreen.withOpacity(0.08);
      case _ConflictSeverity.low:
        return AppColors.warning.withOpacity(0.08);
      case _ConflictSeverity.medium:
        return AppColors.warning.withOpacity(0.08);
      case _ConflictSeverity.high:
        return AppColors.error.withOpacity(0.08);
      case _ConflictSeverity.critical:
        return AppColors.error.withOpacity(0.08);
    }
  }

  String get _severityLabel {
    switch (conflict.severity) {
      case _ConflictSeverity.safe:
        return 'Safe';
      case _ConflictSeverity.low:
        return 'Low';
      case _ConflictSeverity.medium:
        return 'Medium';
      case _ConflictSeverity.high:
        return 'High';
      case _ConflictSeverity.critical:
        return 'Critical';
    }
  }

  String get _borderColor {
    switch (conflict.severity) {
      case _ConflictSeverity.safe:
        return 'safe';
      case _ConflictSeverity.low:
        return 'warning';
      case _ConflictSeverity.medium:
        return 'warning';
      case _ConflictSeverity.high:
        return 'error';
      case _ConflictSeverity.critical:
        return 'error';
    }
  }

  IconData get _severityIcon {
    switch (conflict.severity) {
      case _ConflictSeverity.safe:
        return Icons.check_circle_outline;
      case _ConflictSeverity.low:
        return Icons.info_outline;
      case _ConflictSeverity.medium:
        return Icons.warning_amber_rounded;
      case _ConflictSeverity.high:
        return Icons.warning_rounded;
      case _ConflictSeverity.critical:
        return Icons.gpp_bad_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isSafe = conflict.severity == _ConflictSeverity.safe;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _bgColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: _severityColor.withOpacity(isSafe ? 0.4 : 0.5),
          width: isSafe ? 1 : 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(_severityIcon, color: _severityColor, size: 22),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${conflict.a} + ${conflict.b}',
                      style: AppTypography.bodySmall.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.softCharcoal,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _severityColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _severityLabel,
                      style: AppTypography.caption.copyWith(
                        color: _severityColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            conflict.description,
            style: AppTypography.caption.copyWith(color: AppColors.onSurfaceVariant),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  isSafe ? Icons.lightbulb_outline : Icons.tips_and_updates_outlined,
                  size: 16,
                  color: isSafe ? AppColors.sageGreen : AppColors.matteGold,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    conflict.recommendation,
                    style: AppTypography.caption.copyWith(
                      color: AppColors.softCharcoal,
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
