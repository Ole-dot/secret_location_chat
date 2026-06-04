import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:secret_location_chat/core/localization/language_cubit.dart';
import 'package:secret_location_chat/core/theme/app_colors.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A0A0A),
        title: const Text(
          'НАСТРОЙКИ',
          style: TextStyle(letterSpacing: 3, fontWeight: FontWeight.w900),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _SettingsTile(
              icon: Icons.notifications_outlined,
              title: 'УВЕДОМЛЕНИЯ',
              subtitle: 'Настроить',
              onTap: () => context.push('/notifications'),
            ),
            _SettingsTile(
              icon: Icons.security_outlined,
              title: 'БЕЗОПАСНОСТЬ',
              subtitle: 'Настроить',
              onTap: () => context.push('/security'),
            ),
            BlocBuilder<LanguageCubit, LanguageState>(
              builder: (context, languageState) {
                return _SettingsTile(
                  icon: Icons.language_outlined,
                  title: 'ЯЗЫК',
                  subtitle: _languageLabel(languageState.languageCode),
                  onTap: () => context.push('/language'),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  String _languageLabel(String code) {
    return switch (code) {
      'ru' => 'Русский',
      'en' => 'English',
      'kk' => 'Қазақша',
      _ => code.toUpperCase(),
    };
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        leading: Icon(icon, color: AppColors.neonRed),
        title: Text(
          title,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.5,
            fontSize: 12,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
        ),
        trailing: const Icon(Icons.chevron_right, color: AppColors.textDisabled),
        onTap: onTap,
      ),
    );
  }
}
