import '../models/resource/rarity.dart';

class RarityConfig {
  static const Map<Rarity, double> BASE_PRODUCTION = {
    Rarity.abundant: 1.0,
    Rarity.common: 0.75,
    Rarity.uncommon: 0.5,
    Rarity.rare: 0.25,
    Rarity.legendary: 0.1,
  };

  static double baseFor(Rarity r) => BASE_PRODUCTION[r] ?? 1.0;
}
