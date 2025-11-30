/// Domain: regroupe un ensemble d'éléments (personnages, bâtiments, ressources) pour une zone.
/// Fournit un modèle simple avec sérialisation via toMap().

import './personnage.dart';
import './batiment.dart';
import './ressource.dart';
import 'package:terranova/core/models/xp/xp_stats.dart';

class Domain {
  final String id;
  final String nom;
  final int nvx;
  final List<Personnage> personnages;
  final List<Batiment> batiments;
  final List<Ressource> ressources;
  final XPStats? playerXp;

  const Domain({
    required this.id,
    required this.nom,
    required this.nvx,
    required this.personnages,
    required this.batiments,
    required this.ressources,
    this.playerXp,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nom': nom,
      'nvx': nvx,
      'personnages': personnages.map((e) => e.toMap()).toList(),
      'batiments': batiments.map((e) => e.toMap()).toList(),
      'ressources': ressources.map((e) => e.toMap()).toList(),
      if (playerXp != null) 'playerXp': playerXp!.toJson(),
    };
  }
}
