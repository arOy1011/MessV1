import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/constants/supabase_config.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/auth_gate.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: SupabaseConfig.url,
    anonKey: SupabaseConfig.anonKey,
  );

  runApp(const MessApp());
}

class MessApp extends StatelessWidget {
  const MessApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MessMate',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const AuthGate(),
    );
  }
}