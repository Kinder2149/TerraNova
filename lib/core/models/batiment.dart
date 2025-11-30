/// Batiment: structure construite dans un domaine (nom, description, niveau).
/// Étend BaseElement et se sérialise via toMap().

import './base_element.dart';
import 'package:terranova/core/models/xp/xp_stats.dart';
import '../constants/rarity_config.dart';
import './ressource.dart';

class Batiment extends BaseElement {
  final String description;
  final int niveau;
  final XPStats xpStats;
  final String? producedResourceId;

  const Batiment({
    required super.id,
    required super.nom,
    required super.fonction,
    required super.sousCategorie,
    required this.description,
    required this.niveau,
    required this.xpStats,
    this.producedResourceId,
  });

  factory Batiment.fromJson(Map<String, dynamic> json) {
    return Batiment(
      id: json['id'] as String,
      nom: json['nom'] as String,
      fonction: json['fonction'] as String,
      sousCategorie: SousCategorie.values.firstWhere((e) => e.name == json['sousCategorie'] as String),
      description: json['description'] as String,
      niveau: json['niveau'] as int,
      xpStats: XPStats.fromJson(json['xpStats'] as Map<String, dynamic>),
      producedResourceId: json['producedResourceId'] as String?,
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      ...super.toMap(),
      'description': description,
      'niveau': niveau,
      'xpStats': xpStats.toJson(),
      'producedResourceId': producedResourceId,
    };
  }

  Map<String, dynamic> toJson() => toMap();

  // lookup: fonction de résolution synchrone d'une ressource par son id
  double baseProductionFromResource(Ressource? Function(String id) lookup) {
    final id = producedResourceId;
    if (id == null) return 0.0;
    final res = lookup(id);
    if (res == null) return 0.0;
    return RarityConfig.baseFor(res.rarity);
  }
}
