import 'package:terranova/core/constants/constantes.dart';
import 'package:terranova/core/models/batiment.dart';
import 'package:terranova/core/models/domain.dart';
import 'package:terranova/core/models/personnage.dart';

class PopulationManager {
  const PopulationManager();

  // Capacités dérivées par niveau (actuellement niveau 1)
  int _qgCapacityForLevel(int level) {
    // extensible: table par niveau si besoin
    return AppStrings.qgCapVillageoisL1;
  }

  int _maisonCapacityForLevel(int level) {
    return AppStrings.maisonCapArtisansL1;
  }

  // Sélecteurs de bâtiments clés
  Batiment? _findQG(Domain d) {
    for (final b in d.batiments) {
      if (b.nom == AppStrings.batQG) return b;
    }
    return null;
  }

  Batiment? _findMaison(Domain d) {
    for (final b in d.batiments) {
      if (b.nom == AppStrings.batMaison) return b;
    }
    return null;
  }

  // Comptages
  int countVillageois(Domain d) => d.personnages
      .where((p) => p.type == AppStrings.personnageVillageois)
      .length;

  int countArtisans(Domain d) => d.personnages
      .where((p) => p.type == AppStrings.personnageArtisan)
      .length;

  bool canAddVillageois(Domain d) {
    final qg = _findQG(d);
    if (qg == null) return false;
    final cap = _qgCapacityForLevel(qg.niveau);
    return countVillageois(d) < cap;
  }

  bool canAddArtisan(Domain d) {
    final maison = _findMaison(d);
    if (maison == null) return false;
    final cap = _maisonCapacityForLevel(maison.niveau);
    return countArtisans(d) < cap;
  }

  // Place Villageois dans QG (vérifie capacité). Retourne Domain mis à jour.
  Domain placeVillageois(Domain d, Personnage v) {
    if (v.type != AppStrings.personnageVillageois) {
      throw ArgumentError('Le personnage n\'est pas un Villageois');
    }
    if (!canAddVillageois(d)) {
      throw StateError(AppStrings.errCapacityExceeded);
    }
    final updated = Personnage(
      id: v.id,
      nom: v.nom,
      fonction: v.fonction,
      sousCategorie: v.sousCategorie,
      niveau: v.niveau,
      type: v.type,
      etat: v.etat ?? AppStrings.etatInoccupe,
      metier: v.metier,
      assignedBatimentId: v.assignedBatimentId,
      dortoir: AppStrings.batQG,
      pvMax: v.pvMax,
      attaque: v.attaque,
      xpStats: v.xpStats,
    );

    print('[HOST] Villageois ${v.id} hébergé au QG');
    return _withPersonnageAdded(d, updated);
  }

  // Place Artisan dans Maison (vérifie capacité). Retourne Domain mis à jour.
  Domain placeArtisan(Domain d, Personnage a) {
    if (a.type != AppStrings.personnageArtisan) {
      throw ArgumentError('Le personnage n\'est pas un Artisan');
    }
    if (!canAddArtisan(d)) {
      throw StateError(AppStrings.errCapacityExceeded);
    }
    final updated = Personnage(
      id: a.id,
      nom: a.nom,
      fonction: a.fonction,
      sousCategorie: a.sousCategorie,
      niveau: a.niveau,
      type: a.type,
      etat: a.etat ?? AppStrings.etatInoccupe,
      metier: a.metier,
      assignedBatimentId: a.assignedBatimentId,
      dortoir: AppStrings.batMaison,
      pvMax: a.pvMax,
      attaque: a.attaque,
      xpStats: a.xpStats,
    );
    print('[HOST] Artisan ${a.id} hébergé en Maison');
    return _withPersonnageAdded(d, updated);
  }

  // Retire un Villageois du domaine (libère implicitement la place QG)
  Domain removeVillageois(Domain d, String personnageId) {
    final list = List<Personnage>.from(d.personnages)
      ..removeWhere((p) => p.id == personnageId && p.type == AppStrings.personnageVillageois);
    print('[HOST] Villageois $personnageId retiré du QG');
    return Domain(
      id: d.id,
      nom: d.nom,
      nvx: d.nvx,
      personnages: list,
      batiments: List<Batiment>.from(d.batiments),
      ressources: List.from(d.ressources),
    );
  }

  // Retire un Artisan du domaine (libère la place Maison)
  Domain removeArtisan(Domain d, String personnageId) {
    final list = List<Personnage>.from(d.personnages)
      ..removeWhere((p) => p.id == personnageId && p.type == AppStrings.personnageArtisan);
    print('[HOST] Artisan $personnageId retiré de la Maison');
    return Domain(
      id: d.id,
      nom: d.nom,
      nvx: d.nvx,
      personnages: list,
      batiments: List<Batiment>.from(d.batiments),
      ressources: List.from(d.ressources),
    );
  }

  Domain _withPersonnageAdded(Domain d, Personnage p) {
    return Domain(
      id: d.id,
      nom: d.nom,
      nvx: d.nvx,
      personnages: List<Personnage>.from(d.personnages)..add(p),
      batiments: List<Batiment>.from(d.batiments),
      ressources: List.from(d.ressources),
    );
  }
}
