import 'dart:math';
import 'package:terranova/core/constants/constantes.dart';

class NameService {
  final Random _rng;
  NameService({Random? rng}) : _rng = rng ?? Random();

  String generateRandomName({int minSyll = 2, int maxSyll = 3}) {
    final count = minSyll + _rng.nextInt((maxSyll - minSyll) + 1);
    final parts = <String>[];
    for (var i = 0; i < count; i++) {
      parts.add(AppNames.syllabes[_rng.nextInt(AppNames.syllabes.length)]);
    }
    final s = parts.join('');
    return s[0].toUpperCase() + s.substring(1);
  }
}
