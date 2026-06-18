import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:secret_location_chat/core/layout/view_insets.dart';
import 'package:secret_location_chat/core/theme/app_colors.dart';
import 'package:secret_location_chat/l10n/app_localizations.dart';

enum _RegionId { north, baseCamp, southValley, polygonA7 }

String _regionName(AppLocalizations l10n, _RegionId id) {
  switch (id) {
    case _RegionId.north:
      return l10n.offlineRegionNorth;
    case _RegionId.baseCamp:
      return l10n.offlineRegionBaseCamp;
    case _RegionId.southValley:
      return l10n.offlineRegionSouthValley;
    case _RegionId.polygonA7:
      return l10n.offlineRegionPolygonA7;
  }
}

class OfflineMapsScreen extends StatefulWidget {
  const OfflineMapsScreen({super.key});

  @override
  State<OfflineMapsScreen> createState() => _OfflineMapsScreenState();
}

class _OfflineMapsScreenState extends State<OfflineMapsScreen> {
  final _regions = [
    _OfflineRegion(_RegionId.north, '12.4', false),
    _OfflineRegion(_RegionId.baseCamp, '8.1', true),
    _OfflineRegion(_RegionId.southValley, '15.7', false),
    _OfflineRegion(_RegionId.polygonA7, '22.0', false),
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A0A0A),
        title: Text(
          l10n.offlineMapsTitle,
          style: const TextStyle(letterSpacing: 3, fontWeight: FontWeight.w900),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          onPressed: () => context.pop(),
        ),
      ),
      body: ScreenScrollBody(
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
              child: Text(
                l10n.offlineMapsHint,
                style: const TextStyle(
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
                final name = _regionName(l10n, r.id);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: AppColors.surfaceCard,
                    content: Text(
                      r.downloaded
                          ? l10n.offlineRegionCached(name)
                          : l10n.offlineRegionDeleted(name),
                      style: const TextStyle(color: AppColors.textPrimary),
                    ),
                  ),
                );
              },
            )),
            const SizedBox(height: 16),
            Text(
              l10n.offlineMapsSoon,
              style: const TextStyle(color: AppColors.textDisabled, fontSize: 10, letterSpacing: 1),
            ),
          ],
        ),
      ),
    );
  }
}

class _OfflineRegion {
  final _RegionId id;
  final String size;
  bool downloaded;

  _OfflineRegion(this.id, this.size, this.downloaded);
}

class _RegionTile extends StatelessWidget {
  final _OfflineRegion region;
  final VoidCallback onToggle;

  const _RegionTile({required this.region, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
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
          _regionName(l10n, region.id),
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
            letterSpacing: 1,
            fontSize: 12,
          ),
        ),
        subtitle: Text(
          '${region.size} ${l10n.unitMb}',
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
        ),
        trailing: TextButton(
          onPressed: onToggle,
          child: Text(
            region.downloaded ? l10n.commonDelete : l10n.commonDownload,
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
