import 'package:flutter/material.dart';
import 'package:jadwal_sholat/page/page_home.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

void main() {
  Intl.defaultLocale = 'in';
  initializeDateFormatting('in', null);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: false,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.amber),
      ),
      home: const PageHome(),
    );
  }
}