import 'dart:math';

class XPConfig {
  // Courbe exponentielle douce base=100, multiplier=1.12, arrondie à l'entier
  // XP_LEVELS[i] = XP requis pour passer du niveau (i+1) → (i+2)
  static const List<int> XP_LEVELS = <int>[
    100, 112, 125, 140, 157, 176, 197, 221, 248, 278,
    311, 348, 390, 437, 489, 548, 614, 688, 771, 864,
    968, 1084, 1214, 1360, 1523, 1706, 1911, 2140, 2397, 2685,
    3007, 3368, 3772, 4225, 4732, 5300, 5936, 6648, 7446, 8340,
    9341, 10462, 11717, 13123, 14698, 16462, 18437, 20649, 23127, 25902,
  ];

  static int getXpForLevel(int level) {
    if (level < 1 || level > XP_LEVELS.length) return 0;
    return XP_LEVELS[level - 1];
  }
}
