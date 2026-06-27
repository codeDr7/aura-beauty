import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../widgets/common/aura_top_bar.dart';
import '../../widgets/common/aura_card.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const AuraTopBar(
              showBackButton: true,
              title: 'Settings',
            ),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.pageHorizontalPadding,
                  AppSpacing.md,
                  AppSpacing.pageHorizontalPadding,
                  AppSpacing.xxl,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SettingsSection(
                      title: 'Notifications',
                      items: [
                        _SettingItem(icon: Icons.notifications_active_outlined, label: 'Push Notifications', trailing: _ToggleSwitch(value: true)),
                        _SettingItem(icon: Icons.email_outlined, label: 'Email Notifications', trailing: _ToggleSwitch(value: false)),
                        _SettingItem(icon: Icons.campaign_outlined, label: 'Marketing', trailing: _ToggleSwitch(value: false)),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _SettingsSection(
                      title: 'Preferences',
                      items: [
                        _SettingItem(icon: Icons.language_outlined, label: 'Language', trailingText: 'English', showArrow: true),
                        _SettingItem(icon: Icons.dark_mode_outlined, label: 'Theme', trailingText: 'Light', showArrow: true),
                        _SettingItem(icon: Icons.straighten_outlined, label: 'Measurement Unit', trailingText: 'US', showArrow: true),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _SettingsSection(
                      title: 'Privacy',
                      items: [
                        _SettingItem(icon: Icons.lock_outlined, label: 'Privacy Policy', showArrow: true),
                        _SettingItem(icon: Icons.description_outlined, label: 'Terms of Service', showArrow: true),
                        _SettingItem(icon: Icons.shield_outlined, label: 'Data & Analytics', trailing: _ToggleSwitch(value: true)),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _SettingsSection(
                      title: 'Account',
                      items: [
                        _SettingItem(icon: Icons.person_outline, label: 'Change Password', showArrow: true),
                        _SettingItem(icon: Icons.delete_outline, label: 'Delete Account', showArrow: true, isDestructive: true),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _SettingsSection(
                      title: 'About',
                      items: [
                        _SettingItem(icon: Icons.info_outline, label: 'Version', trailingText: '1.0.0'),
                      ],
                    ),
                    const SizedBox(height: 32),
                    Center(
                      child: Text(
                        'Made with ✨ by Aura Beauty Intelligence',
                        style: AppTypography.caption.copyWith(color: AppColors.onSurfaceVariant),
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

class _SettingsSection extends StatelessWidget {
  final String title;
  final List<Widget> items;

  const _SettingsSection({required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppTypography.titleMedium.copyWith(color: AppColors.softCharcoal)),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.outlineVariant.withOpacity(0.5)),
          ),
          child: Column(
            children: items.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              return Column(
                children: [
                  if (index > 0)
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Divider(color: AppColors.outlineVariant, height: 1),
                    ),
                  item,
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class _SettingItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Widget? trailing;
  final String? trailingText;
  final bool showArrow;
  final bool isDestructive;

  const _SettingItem({
    required this.icon,
    required this.label,
    this.trailing,
    this.trailingText,
    this.showArrow = false,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {},
      borderRadius: BorderRadius.circular(18),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(icon, size: 20, color: isDestructive ? AppColors.error : AppColors.onSurfaceVariant),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: AppTypography.bodySmall.copyWith(
                  color: isDestructive ? AppColors.error : AppColors.softCharcoal,
                ),
              ),
            ),
            if (trailing != null) trailing!,
            if (trailingText != null)
              Text(trailingText!, style: AppTypography.bodySmall.copyWith(color: AppColors.onSurfaceVariant)),
            if (showArrow)
              const Padding(
                padding: EdgeInsets.only(left: 4),
                child: Icon(Icons.chevron_right, size: 18, color: AppColors.outlineVariant),
              ),
          ],
        ),
      ),
    );
  }
}

class _ToggleSwitch extends StatefulWidget {
  final bool value;

  const _ToggleSwitch({required this.value});

  @override
  State<_ToggleSwitch> createState() => _ToggleSwitchState();
}

class _ToggleSwitchState extends State<_ToggleSwitch> {
  late bool _value;

  @override
  void initState() {
    super.initState();
    _value = widget.value;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => setState(() => _value = !_value),
      child: Container(
        width: 48,
        height: 28,
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: _value ? AppColors.matteGold : AppColors.outlineVariant,
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 200),
          alignment: _value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: 22,
            height: 22,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
