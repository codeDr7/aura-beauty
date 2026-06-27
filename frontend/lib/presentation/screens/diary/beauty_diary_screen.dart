import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_gradients.dart';
import '../../widgets/common/aura_card.dart';
import '../../widgets/common/aura_button.dart';
import '../../widgets/common/section_header.dart';

class BeautyDiaryScreen extends ConsumerStatefulWidget {
  const BeautyDiaryScreen({super.key});

  @override
  ConsumerState<BeautyDiaryScreen> createState() => _BeautyDiaryScreenState();
}

class _BeautyDiaryScreenState extends ConsumerState<BeautyDiaryScreen> {
  int _moodIndex = 2;
  String? _selectedSkinCondition;
  double _sleepHours = 7;
  int _waterIntake = 1;
  int _stressLevel = 1;
  final _breakoutController = TextEditingController();
  final _notesController = TextEditingController();
  String? _photoPath;

  final _moods = ['Terrible', 'Bad', 'Okay', 'Good', 'Great'];
  final _moodEmojis = ['😫', '😟', '😐', '🙂', '😍'];

  final _skinConditions = [
    'Clear', 'Minor Breakout', 'Moderate Breakout', 'Dry', 'Oily', 'Red/Irritated',
  ];

  final _recentEntries = [
    _DiaryEntry(date: 'Jun 25', mood: 'Good', skin: 'Clear', sleep: 8, water: 2),
    _DiaryEntry(date: 'Jun 24', mood: 'Okay', skin: 'Minor Breakout', sleep: 6, water: 1),
    _DiaryEntry(date: 'Jun 23', mood: 'Great', skin: 'Clear', sleep: 8.5, water: 2),
    _DiaryEntry(date: 'Jun 22', mood: 'Bad', skin: 'Moderate Breakout', sleep: 5, water: 0),
  ];

  @override
  void dispose() {
    _breakoutController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _onRefresh() async {
    await Future.delayed(const Duration(milliseconds: 800));
  }

  String get _todayDate {
    final now = DateTime.now();
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[now.month - 1]} ${now.day}, ${now.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _onRefresh,
          color: AppColors.matteGold,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.only(bottom: AppSpacing.xxl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: AppSpacing.lg),
                _buildCheckInCard(),
                const SizedBox(height: AppSpacing.lg),
                _buildMoodSelector(),
                const SizedBox(height: AppSpacing.lg),
                _buildSkinCondition(),
                const SizedBox(height: AppSpacing.lg),
                _buildSleepSlider(),
                const SizedBox(height: AppSpacing.lg),
                _buildWaterIntake(),
                const SizedBox(height: AppSpacing.lg),
                _buildStressLevel(),
                const SizedBox(height: AppSpacing.lg),
                _buildBreakoutLocation(),
                const SizedBox(height: AppSpacing.lg),
                _buildNotes(),
                const SizedBox(height: AppSpacing.md),
                _buildPhotoButton(),
                const SizedBox(height: AppSpacing.lg),
                _buildSaveButton(),
                const SizedBox(height: AppSpacing.xl),
                _buildInsightsSection(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: AppSpacing.horizontalPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 12),
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
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.matteGold.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text('Day 6 of 30', style: AppTypography.caption.copyWith(color: AppColors.matteGold, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text('Beauty Diary', style: AppTypography.sectionTitle.copyWith(color: AppColors.softCharcoal)),
          const SizedBox(height: 4),
          Text(_todayDate, style: AppTypography.bodySmall.copyWith(color: AppColors.onSurfaceVariant)),
        ],
      ),
    );
  }

  Widget _buildCheckInCard() {
    return Padding(
      padding: AppSpacing.horizontalPadding,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          gradient: AppGradients.auraGold,
          borderRadius: BorderRadius.circular(AppSpacing.radiusCards),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('How are you feeling today?', style: AppTypography.cardTitle.copyWith(color: Colors.white, fontSize: 18)),
                  const SizedBox(height: 4),
                  Text('Track your daily skin & mood', style: AppTypography.bodySmall.copyWith(color: Colors.white70)),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.auto_awesome, color: Colors.white, size: 28),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMoodSelector() {
    return Padding(
      padding: AppSpacing.horizontalPadding,
      child: AuraCard(
        padding: AppSpacing.cardPadding,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Mood', style: AppTypography.cardTitle.copyWith(fontSize: 16, color: AppColors.softCharcoal)),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(5, (i) {
                final isSelected = _moodIndex == i;
                return GestureDetector(
                  onTap: () => setState(() => _moodIndex = i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isSelected ? AppColors.matteGold : AppColors.surfaceContainerLow,
                      border: Border.all(
                        color: isSelected ? AppColors.matteGold : AppColors.outlineVariant,
                        width: isSelected ? 2 : 1,
                      ),
                      boxShadow: isSelected
                          ? [BoxShadow(color: AppColors.matteGold.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 2))]
                          : [],
                    ),
                    child: Center(
                      child: Text(_moodEmojis[i], style: TextStyle(fontSize: isSelected ? 28 : 22)),
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(
                _moods[_moodIndex],
                style: AppTypography.labelMedium.copyWith(
                  color: AppColors.matteGold,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSkinCondition() {
    return Padding(
      padding: AppSpacing.horizontalPadding,
      child: AuraCard(
        padding: AppSpacing.cardPadding,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Skin Condition', style: AppTypography.cardTitle.copyWith(fontSize: 16, color: AppColors.softCharcoal)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _skinConditions.map((condition) {
                final isSelected = _selectedSkinCondition == condition;
                return GestureDetector(
                  onTap: () => setState(() => _selectedSkinCondition = condition),
                  child: Container(
                    padding: AppSpacing.chipPadding,
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.matteGold : AppColors.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                      border: Border.all(
                        color: isSelected ? AppColors.matteGold : AppColors.outlineVariant,
                      ),
                    ),
                    child: Text(
                      condition,
                      style: AppTypography.bodySmall.copyWith(
                        color: isSelected ? Colors.white : AppColors.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSleepSlider() {
    return Padding(
      padding: AppSpacing.horizontalPadding,
      child: AuraCard(
        padding: AppSpacing.cardPadding,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.bedtime_outlined, size: 18, color: AppColors.matteGold),
                const SizedBox(width: 8),
                Text('Sleep Hours', style: AppTypography.cardTitle.copyWith(fontSize: 16, color: AppColors.softCharcoal)),
                const Spacer(),
                Text('${_sleepHours.toInt()} hrs', style: AppTypography.bodySmall.copyWith(color: AppColors.matteGold, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 8),
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                activeTrackColor: AppColors.matteGold,
                inactiveTrackColor: AppColors.outlineVariant,
                thumbColor: AppColors.matteGold,
                overlayColor: AppColors.matteGold.withOpacity(0.12),
                trackHeight: 4,
              ),
              child: Slider(
                value: _sleepHours,
                min: 0,
                max: 12,
                divisions: 24,
                onChanged: (v) => setState(() => _sleepHours = v),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('0h', style: AppTypography.caption.copyWith(color: AppColors.onSurfaceVariant)),
                Text('12h', style: AppTypography.caption.copyWith(color: AppColors.onSurfaceVariant)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWaterIntake() {
    return Padding(
      padding: AppSpacing.horizontalPadding,
      child: AuraCard(
        padding: AppSpacing.cardPadding,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.water_drop_outlined, size: 18, color: AppColors.matteGold),
                const SizedBox(width: 8),
                Text('Water Intake', style: AppTypography.cardTitle.copyWith(fontSize: 16, color: AppColors.softCharcoal)),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _WaterOption(icon: Icons.water_drop, label: 'Low', value: 0, selected: _waterIntake == 0, onTap: () => setState(() => _waterIntake = 0)),
                const SizedBox(width: 10),
                _WaterOption(icon: Icons.water_drop, label: 'Medium', value: 1, selected: _waterIntake == 1, onTap: () => setState(() => _waterIntake = 1)),
                const SizedBox(width: 10),
                _WaterOption(icon: Icons.water_drop, label: 'High', value: 2, selected: _waterIntake == 2, onTap: () => setState(() => _waterIntake = 2)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStressLevel() {
    return Padding(
      padding: AppSpacing.horizontalPadding,
      child: AuraCard(
        padding: AppSpacing.cardPadding,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.psychology_outlined, size: 18, color: AppColors.matteGold),
                const SizedBox(width: 8),
                Text('Stress Level', style: AppTypography.cardTitle.copyWith(fontSize: 16, color: AppColors.softCharcoal)),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _StressOption(icon: Icons.sentiment_very_satisfied, label: 'Low', value: 0, selected: _stressLevel == 0, onTap: () => setState(() => _stressLevel = 0)),
                const SizedBox(width: 10),
                _StressOption(icon: Icons.sentiment_neutral, label: 'Medium', value: 1, selected: _stressLevel == 1, onTap: () => setState(() => _stressLevel = 1)),
                const SizedBox(width: 10),
                _StressOption(icon: Icons.sentiment_very_dissatisfied, label: 'High', value: 2, selected: _stressLevel == 2, onTap: () => setState(() => _stressLevel = 2)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBreakoutLocation() {
    return Padding(
      padding: AppSpacing.horizontalPadding,
      child: AuraCard(
        padding: AppSpacing.cardPadding,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.location_on_outlined, size: 18, color: AppColors.matteGold),
                const SizedBox(width: 8),
                Text('Breakout Location', style: AppTypography.cardTitle.copyWith(fontSize: 16, color: AppColors.softCharcoal)),
              ],
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _breakoutController,
              decoration: InputDecoration(
                hintText: 'e.g. chin, forehead',
                hintStyle: AppTypography.bodySmall.copyWith(color: AppColors.onSurfaceVariant.withOpacity(0.6)),
                filled: true,
                fillColor: AppColors.surfaceContainerLow,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusInputs),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotes() {
    return Padding(
      padding: AppSpacing.horizontalPadding,
      child: AuraCard(
        padding: AppSpacing.cardPadding,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.edit_note_rounded, size: 18, color: AppColors.matteGold),
                const SizedBox(width: 8),
                Text('Notes', style: AppTypography.cardTitle.copyWith(fontSize: 16, color: AppColors.softCharcoal)),
              ],
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _notesController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'How was your day? Any notable changes...',
                hintStyle: AppTypography.bodySmall.copyWith(color: AppColors.onSurfaceVariant.withOpacity(0.6)),
                filled: true,
                fillColor: AppColors.surfaceContainerLow,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusInputs),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoButton() {
    return Padding(
      padding: AppSpacing.horizontalPadding,
      child: GestureDetector(
        onTap: () {},
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(AppSpacing.radiusInputs),
            border: Border.all(color: AppColors.outlineVariant.withOpacity(0.5), style: BorderStyle.solid),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                _photoPath != null ? Icons.check_circle : Icons.add_a_photo_outlined,
                size: 22,
                color: _photoPath != null ? AppColors.sageGreen : AppColors.matteGold,
              ),
              const SizedBox(width: 8),
              Text(
                _photoPath != null ? 'Photo Added' : 'Add Photo',
                style: AppTypography.bodySmall.copyWith(
                  color: _photoPath != null ? AppColors.sageGreen : AppColors.matteGold,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    return Padding(
      padding: AppSpacing.horizontalPadding,
      child: AuraButton(
        label: 'Save Entry',
        onPressed: () {},
        trailingIcon: Icons.check_rounded,
      ),
    );
  }

  Widget _buildInsightsSection() {
    return Padding(
      padding: AppSpacing.horizontalPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            title: 'Your Insights',
            subtitle: 'Recent diary entries',
            trailingLabel: 'View All',
          ),
          ...List.generate(_recentEntries.length, (i) {
            final entry = _recentEntries[i];
            return Padding(
              padding: EdgeInsets.only(bottom: i < _recentEntries.length - 1 ? 8 : 0),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.outlineVariant.withOpacity(0.5)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.matteGold.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.article_outlined, color: AppColors.matteGold, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(entry.mood, style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.w600, color: AppColors.softCharcoal)),
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.sageGreen.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(entry.skin, style: AppTypography.caption.copyWith(color: AppColors.sageGreen, fontSize: 10, fontWeight: FontWeight.w600)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text('Sleep ${entry.sleep}h · Water ${entry.water == 2 ? "High" : entry.water == 1 ? "Med" : "Low"}', style: AppTypography.caption.copyWith(color: AppColors.onSurfaceVariant)),
                        ],
                      ),
                    ),
                    Text(entry.date, style: AppTypography.caption.copyWith(color: AppColors.onSurfaceVariant)),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _DiaryEntry {
  final String date;
  final String mood;
  final String skin;
  final double sleep;
  final int water;

  const _DiaryEntry({
    required this.date,
    required this.mood,
    required this.skin,
    required this.sleep,
    required this.water,
  });
}

class _WaterOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final int value;
  final bool selected;
  final VoidCallback onTap;

  const _WaterOption({
    required this.icon,
    required this.label,
    required this.value,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: selected ? AppColors.matteGold : AppColors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected ? AppColors.matteGold : AppColors.outlineVariant,
            ),
          ),
          child: Column(
            children: [
              Icon(icon, size: 24, color: selected ? Colors.white : AppColors.onSurfaceVariant),
              const SizedBox(height: 4),
              Text(label, style: AppTypography.caption.copyWith(
                color: selected ? Colors.white : AppColors.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              )),
            ],
          ),
        ),
      ),
    );
  }
}

class _StressOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final int value;
  final bool selected;
  final VoidCallback onTap;

  const _StressOption({
    required this.icon,
    required this.label,
    required this.value,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: selected ? AppColors.matteGold : AppColors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected ? AppColors.matteGold : AppColors.outlineVariant,
            ),
          ),
          child: Column(
            children: [
              Icon(icon, size: 24, color: selected ? Colors.white : AppColors.onSurfaceVariant),
              const SizedBox(height: 4),
              Text(label, style: AppTypography.caption.copyWith(
                color: selected ? Colors.white : AppColors.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              )),
            ],
          ),
        ),
      ),
    );
  }
}
