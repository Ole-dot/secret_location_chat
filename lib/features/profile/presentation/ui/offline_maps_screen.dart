import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:secret_location_chat/core/theme/app_colors.dart';

class OfflineMapsScreen extends StatefulWidget {
  const OfflineMapsScreen({super.key});

  @override
  State<OfflineMapsScreen> createState() => _OfflineMapsScreenState();
}

class _OfflineMapsScreenState extends State<OfflineMapsScreen> {
  final _regions = [
    _OfflineRegion('СЕВЕРНЫЙ УЧАСТОК', '12.4 МБ', false),
    _OfflineRegion('БАЗОВЫЙ ЛАГЕРЬ', '8.1 МБ', true),
    _OfflineRegion('ЮЖНАЯ ДОЛИНА', '15.7 МБ', false),
    _OfflineRegion('ПОЛИГОН А-7', '22.0 МБ', false),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A0A0A),
        title: const Text(
          'ОФФЛАЙН КАРТЫ',
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.borderRed),
                borderRadius: BorderRadius.circular(8),
                color: AppColors.neonRed.withValues(alpha: 0.06),
              ),
              child: const Text(
                'СКАЧАЙТЕ УЧАСТКИ КАРТЫ ЗАРАНЕЕ — В ПОЛЕ БЕЗ СВЯЗИ ТАЙЛЫ БУДУТ БРАТЬСЯ ИЗ КЭША.',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 11,
                  letterSpacing: 1,
                  height: 1.4,
                ),
              ),
            ),
            const SizedBox(height: 20),
            ..._regions.map((r) => _RegionTile(
              region: r,
              onToggle: () {
                setState(() => r.downloaded = !r.downloaded);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: AppColors.surfaceCard,
                    content: Text(
                      r.downloaded
                          ? '${r.name} — В КЭШЕ'
                          : '${r.name} — УДАЛЕНО',
                      style: const TextStyle(color: AppColors.textPrimary),
                    ),
                  ),
                );
              },
            )),
            const SizedBox(height: 16),
            const Text(
              '// СКОРО: ВЫБОР ПРЯМОУГОЛЬНИКА НА КАРТЕ //',
              style: TextStyle(color: AppColors.textDisabled, fontSize: 10, letterSpacing: 1),
            ),
          ],
        ),
      ),
    );
  }
}

class _OfflineRegion {
  final String name;
  final String size;
  bool downloaded;

  _OfflineRegion(this.name, this.size, this.downloaded);
}

class _RegionTile extends StatelessWidget {
  final _OfflineRegion region;
  final VoidCallback onToggle;

  const _RegionTile({required this.region, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: region.downloaded ? AppColors.neonRed : AppColors.border,
        ),
      ),
      child: ListTile(
        leading: Icon(
          region.downloaded ? Icons.check_circle_outline : Icons.download_outlined,
          color: AppColors.neonRed,
        ),
        title: Text(
          region.name,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
            letterSpacing: 1,
            fontSize: 12,
          ),
        ),
        subtitle: Text(
          region.size,
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
        ),
        trailing: TextButton(
          onPressed: onToggle,
          child: Text(
            region.downloaded ? 'УДАЛИТЬ' : 'СКАЧАТЬ',
            style: const TextStyle(
              color: AppColors.neonRed,
              fontSize: 10,
              letterSpacing: 1,
            ),
          ),
        ),
      ),
    );
  }
}
