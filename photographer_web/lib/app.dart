import 'package:flutter/material.dart';

import 'core/routes/app_router.dart';

class PixoraApp extends StatelessWidget {
  const PixoraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Pixora Photographer',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.indigo,
      ),
      routerConfig: appRouter,
    );
  }
}