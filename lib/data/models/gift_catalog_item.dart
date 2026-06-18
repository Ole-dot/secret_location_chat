class GiftCatalogItem {
  final String giftId;
  final String name;
  final String description;
  final int stoneCost;
  final String assetKey;
  final String tier;
  final bool isActive;
  final int sortOrder;

  const GiftCatalogItem({
    required this.giftId,
    required this.name,
    this.description = '',
    required this.stoneCost,
    required this.assetKey,
    required this.tier,
    this.isActive = true,
    this.sortOrder = 0,
  });

  factory GiftCatalogItem.fromFirestore(
    String id,
    Map<String, dynamic> data,
  ) =>
      GiftCatalogItem(
        giftId: id,
        name: data['name'] as String? ?? id.toUpperCase(),
        description: data['description'] as String? ?? '',
        stoneCost: (data['stoneCost'] as num?)?.toInt() ??
            (data['price'] as num?)?.toInt() ??
            0,
        assetKey: data['assetKey'] as String? ?? 'gift_default',
        tier: data['tier'] as String? ?? 'common',
        isActive: data['isActive'] as bool? ?? true,
        sortOrder: (data['sortOrder'] as num?)?.toInt() ?? 0,
      );

  static const List<GiftCatalogItem> defaults = [
    GiftCatalogItem(
      giftId: 'neon_rose',
      name: 'NEON ROSE',
      description: 'Цифровая роза с неоновым свечением',
      stoneCost: 20,
      assetKey: 'neon_rose',
      tier: 'common',
      sortOrder: 1,
    ),
    GiftCatalogItem(
      giftId: 'cyber_coffee',
      name: 'CYBER COFFEE',
      description: 'Горячий напиток из подпольного бара',
      stoneCost: 60,
      assetKey: 'cyber_coffee',
      tier: 'common',
      sortOrder: 2,
    ),
    GiftCatalogItem(
      giftId: 'data_crystal',
      name: 'DATA CRYSTAL',
      description: 'Редкий кристалл зашифрованных данных',
      stoneCost: 80,
      assetKey: 'data_crystal',
      tier: 'rare',
      sortOrder: 3,
    ),
    GiftCatalogItem(
      giftId: 'ghost_drone',
      name: 'GHOST DRONE',
      description: 'Мини-дрон для скрытой доставки',
      stoneCost: 100,
      assetKey: 'ghost_drone',
      tier: 'rare',
      sortOrder: 4,
    ),
  ];
}
