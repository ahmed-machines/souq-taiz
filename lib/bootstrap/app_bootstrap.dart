import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../app/app.dart';
import '../shared/providers/firebase_providers.dart';
import 'firebase_bootstrap.dart';

/// Application startup: binds Flutter, initializes Firebase, runs the app.
Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();
  final status = await FirebaseBootstrap.initialize();
  runApp(
    ProviderScope(
      overrides: [firebaseStatusProvider.overrideWithValue(status)],
      child: const SouqTaizApp(),
    ),
  );
}
