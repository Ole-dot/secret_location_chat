import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:secret_location_chat/core/layout/view_insets.dart';
import 'package:secret_location_chat/core/theme/app_colors.dart';
import 'package:secret_location_chat/core/ui/cyber_snackbar.dart';
import 'package:secret_location_chat/core/widgets/cyberpunk_button.dart';
import 'package:secret_location_chat/data/clan/clan_repository.dart';
import 'package:secret_location_chat/features/app/presentation/bloc/app_auth_bloc.dart';
import 'package:secret_location_chat/features/profile/presentation/bloc/clan_map_cubit.dart';

class SetSharedTargetMapScreen extends StatefulWidget {
  const SetSharedTargetMapScreen({super.key});

  @override
  State<SetSharedTargetMapScreen> createState() => _SetSharedTargetMapScreenState();
}

class _SetSharedTargetMapScreenState extends State<SetSharedTargetMapScreen> {
  final _mapController = MapController();
  LatLng? _picked;
  bool _isSaving = false;

  static const _defaultCenter = LatLng(43.2389, 76.9450);

  Future<void> _save() async {
    if (_picked == null) return;
    final auth = context.read<AppAuthBloc>().state;
    if (auth is! AppAuthAuthenticatedState) return;

    final clanOwnerId = context.read<ClanMapCubit>().state.clanOwnerId;
    setState(() => _isSaving = true);
    try {
      await context.read<ClanRepository>().setSharedTarget(
            clanOwnerId: clanOwnerId,
            setByUserId: auth.user.uid,
            latitude: _picked!.latitude,
            longitude: _picked!.longitude,
          );
      if (!mounted) return;
      context.pop(true);
    } catch (e) {
      if (!mounted) return;
      CyberSnackBar.showError(
        context,
        e.toString(),
        backgroundColor: AppColors.surfaceCard,
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: const Text(
          'ОБЩАЯ ЦЕЛЬ',
          style: TextStyle(
            fontFamily: 'monospace',
            letterSpacing: 2,
            fontWeight: FontWeight.w900,
            fontSize: 12,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close, size: 20),
          onPressed: () => context.pop(),
        ),
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _defaultCenter,
              initialZoom: 13,
              onTap: (_, point) => setState(() => _picked = point),
            ),
            children: [
              TileLayer(
                urlTemplate:
                    'https://tiles.stadiamaps.com/tiles/alidade_smooth_dark/{z}/{x}/{y}{r}.png',
                userAgentPackageName: 'com.slc.app',
              ),
              if (_picked != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _picked!,
                      width: 36,
                      height: 36,
                      child: const Icon(
                        Icons.flag,
                        color: Color(0xFF39FF14),
                        size: 32,
                        shadows: [
                          Shadow(color: Color(0x8039FF14), blurRadius: 12),
                        ],
                      ),
                    ),
                  ],
                ),
            ],
          ),
          Positioned(
            left: 16,
            right: 16,
            bottom: 0,
            child: SafeBottom(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceCard.withValues(alpha: 0.92),
                    border: Border.all(color: AppColors.borderRed),
                  ),
                  child: Text(
                    _picked == null
                        ? 'ЖМИ НА КАРТУ · ПОСТАВЬ ОБЩУЮ ЦЕЛЬ'
                        : 'ЦЕЛЬ: ${_picked!.latitude.toStringAsFixed(5)}, ${_picked!.longitude.toStringAsFixed(5)}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontFamily: 'monospace',
                      fontSize: 10,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                CyberpunkButton(
                  text: 'ПОДТВЕРДИТЬ ЦЕЛЬ',
                  isLoading: _isSaving,
                  onPressed: _picked == null || _isSaving ? null : _save,
                ),
              ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
