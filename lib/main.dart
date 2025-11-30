import 'package:flutter/material.dart';
import 'package:terranova/core/constants/constantes.dart';
import 'package:terranova/ui/screens/mapping/mapping_screen.dart';

void main() {
  runApp(const TerraNovaApp());
}

class TerraNovaApp extends StatelessWidget {
  const TerraNovaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppStrings.appTitle,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: AppTheme.seedColor),
        useMaterial3: true,
      ),
      home: const MappingScreen(),
    );
  }
}
