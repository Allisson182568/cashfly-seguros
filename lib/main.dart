// lib/main.dart
// Entry point da aplicação Cashfy Seguros

import 'package:cashflyseguros/supabase_cliente.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializa locale PT-BR para formatação de datas e moedas
  await initializeDateFormatting('pt_BR');

  // Inicializa Supabase
  await SupabaseService.initialize();

  runApp(const CashfyApp());
}