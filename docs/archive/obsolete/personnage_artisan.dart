/// Artisan: personnage spécialisé pouvant être assigné à un bâtiment.
/// Porte ses XP et une éventuelle affectation via assignedBuildingId.

import './base_element.dart';
import 'package:terranova/core/models/xp/xp_stats.dart';

class Artisan extends BaseElement {
  final XPStats xpStats;
  final String? assignedBuildingId;

  const Artisan({
    required super.id,
    required super.nom,
    required super.fonction,
    required super.sousCategorie,
    required this.xpStats,
    this.assignedBuildingId,
  });

  bool isAssigned() => (assignedBuildingId != null && assignedBuildingId!.isNotEmpty);

  factory Artisan.fromJson(Map<String, dynamic> json) {
    return Artisan(
      id: json['id'] as String,
      nom: json['nom'] as String,
      fonction: json['fonction'] as String,
      sousCategorie: SousCategorie.values.byName(json['sousCategorie'] as String),
      xpStats: XPStats.fromJson(json['xpStats'] as Map<String, dynamic>),
      assignedBuildingId: json['assignedBuildingId'] as String?,
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      ...super.toMap(),
      'xpStats': xpStats.toJson(),
      if (assignedBuildingId != null) 'assignedBuildingId': assignedBuildingId,
    };
  }

  Map<String, dynamic> toJson() => toMap();
}
