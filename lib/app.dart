// lib/app.dart

import 'package:flutter/material.dart';
import 'app_router.dart';
import 'package:cashflyseguros/theme.dart';

class CashfyApp extends StatelessWidget {
  const CashfyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Cashfy Seguros',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      routerConfig: appRouter,
    );
  }
}