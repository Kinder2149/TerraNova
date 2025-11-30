/// Personnage: entité représentant un acteur du domaine (joueur/NPC).
/// Étend BaseElement et ajoute des attributs de gameplay.

import './base_element.dart';
import 'package:terranova/core/models/xp/xp_stats.dart';

class Personnage extends BaseElement {
  final int niveau;
  final String type; // ex: Villageois, Artisan
  final String? etat; // occupé / inoccupé
  final String? metier; // pour Artisan, dépend du bâtiment assigné
  final String? assignedBatimentId; // bâtiment producteur affecté
  final String? dortoir; // QG ou Maison
  final int? pvMax;
  final int? attaque;
  final XPStats xpStats;

  const Personnage({
    required super.id,
    required super.nom,
    required super.fonction,
    required super.sousCategorie,
    required this.niveau,
    required this.type,
    this.etat,
    this.metier,
    this.assignedBatimentId,
    this.dortoir,
    this.pvMax,
    this.attaque,
    required this.xpStats,
  });

  @override
  Map<String, dynamic> toMap() {
    return {
      ...super.toMap(),
      'niveau': niveau,
      'type': type,
      if (etat != null) 'etat': etat,
      if (metier != null) 'metier': metier,
      if (assignedBatimentId != null) 'assignedBatimentId': assignedBatimentId,
      if (dortoir != null) 'dortoir': dortoir,
      if (pvMax != null) 'pvMax': pvMax,
      if (attaque != null) 'attaque': attaque,
      'xpStats': xpStats.toJson(),
    };
  }
}
