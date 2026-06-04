import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:secret_location_chat/core/localization/language_cubit.dart';
import 'package:secret_location_chat/core/theme/app_colors.dart';

class LanguageScreen extends StatelessWidget {
  const LanguageScreen({super.key});

  static const _options = [
    _LanguageOption(code: 'ru', label: 'РУССКИЙ', subtitle: 'RU'),
    _LanguageOption(code: 'en', label: 'ENGLISH', subtitle: 'EN'),
    _LanguageOption(code: 'kk', label: 'ҚАЗАҚША', subtitle: 'KK'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: const Text(
          'ЯЗЫК',
          style: TextStyle(letterSpacing: 3, fontWeight: FontWeight.w900),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          onPressed: () => context.pop(),
        ),
      ),
      body: BlocBuilder<LanguageCubit, LanguageState>(
        builder: (context, state) {
          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              const Text(
                '// SELECT INTERFACE LANGUAGE //',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontFamily: 'monospace',
                  fontSize: 10,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 16),
              ..._options.map(
                (option) => _LanguageTile(
                  option: option,
                  selected: state.languageCode == option.code,
                  onTap: () =>
                      context.read<LanguageCubit>().setLanguage(option.code),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _LanguageOption {
  final String code;
  final String label;
  final String subtitle;

  const _LanguageOption({
    required this.code,
    required this.label,
    required this.subtitle,
  });
}

class _LanguageTile extends StatelessWidget {
  final _LanguageOption option;
  final bool selected;
  final VoidCallback onTap;

  const _LanguageTile({
    required this.option,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        border: Border.all(
          color: selected ? AppColors.neonRed : AppColors.border,
          width: selected ? 1.5 : 1,
        ),
        borderRadius: BorderRadius.circular(8),
        boxShadow: selected
            ? const [
                BoxShadow(color: AppColors.neonRedGlow, blurRadius: 10),
              ]
            : null,
      ),
      child: ListTile(
        leading: Icon(
          Icons.language,
          color: selected ? AppColors.neonRed : AppColors.textSecondary,
        ),
        title: Text(
          option.label,
          style: TextStyle(
            color: selected ? AppColors.textPrimary : AppColors.textSecondary,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.5,
            fontSize: 12,
          ),
        ),
        subtitle: Text(
          option.subtitle,
          style: const TextStyle(
            color: AppColors.textDisabled,
            fontFamily: 'monospace',
            fontSize: 11,
          ),
        ),
        trailing: selected
            ? const Icon(Icons.check_circle, color: AppColors.neonRed, size: 20)
            : const Icon(Icons.chevron_right, color: AppColors.textDisabled),
        onTap: onTap,
      ),
    );
  }
}
