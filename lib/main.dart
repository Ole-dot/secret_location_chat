import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:secret_location_chat/core/firebase/firestore_setup.dart';
import 'package:secret_location_chat/core/map/map_tile_cache.dart';
import 'package:secret_location_chat/features/app/presentation/ui/app.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFF0A0A0A),
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  await MapTileCache.initialize();

  // Wrap in try-catch so we see the real error if Firebase fails
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    configureFirestoreOfflinePersistence();
  } catch (e) {
    debugPrint('Firebase init error: $e');
  }

  runApp(const SlcApp());
}
