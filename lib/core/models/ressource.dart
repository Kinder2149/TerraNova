/// Ressource: consommable ou matériau stocké.
/// Étend BaseElement et ajoute description et quantité en stock.

import './base_element.dart';
import './resource/rarity.dart';

class Ressource extends BaseElement {
  final String description;
  final double quantiteStock;
  final Rarity rarity;

  const Ressource({
    required super.id,
    required super.nom,
    required super.fonction,
    required super.sousCategorie,
    required this.description,
    required this.quantiteStock,
    this.rarity = Rarity.abundant,
  });

  @override
  Map<String, dynamic> toMap() {
    return {
      ...super.toMap(),
      'description': description,
      'quantiteStock': quantiteStock,
      'rarity': rarity.name,
    };
  }

  factory Ressource.fromJson(Map<String, dynamic> json) {
    return Ressource(
      id: json['id'] as String,
      nom: json['nom'] as String,
      fonction: (json['fonction'] ?? '') as String,
      sousCategorie: SousCategorie.values.byName(json['sousCategorie'] as String),
      description: (json['description'] ?? '') as String,
      quantiteStock: (json['quantiteStock'] as num).toDouble(),
      rarity: json['rarity'] != null
          ? Rarity.values.byName(json['rarity'] as String)
          : Rarity.abundant,
    );
  }

  Map<String, dynamic> toJson() => toMap();
}
