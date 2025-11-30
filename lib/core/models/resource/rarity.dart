// Rarity enum for resources

enum Rarity { abundant, common, uncommon, rare, legendary }

extension RarityX on Rarity {
  String get displayName {
    switch (this) {
      case Rarity.abundant:
        return 'Abondante';
      case Rarity.common:
        return 'Commune';
      case Rarity.uncommon:
        return 'Peu commune';
      case Rarity.rare:
        return 'Rare';
      case Rarity.legendary:
        return 'Légendaire';
    }
  }
}
