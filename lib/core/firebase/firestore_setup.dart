import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

/// Включает локальный кэш Firestore для работы без сети.
/// Записи ставятся в очередь и синхронизируются при появлении связи.
void configureFirestoreOfflinePersistence() {
  final firestore = FirebaseFirestore.instance;

  firestore.settings = const Settings(
    persistenceEnabled: true,
    cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
  );

  if (kDebugMode) {
    debugPrint('Firestore: offline persistence enabled');
  }
}
