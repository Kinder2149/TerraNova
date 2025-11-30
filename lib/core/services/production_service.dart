import 'package:terranova/core/constants/constantes.dart';
import 'package:terranova/core/models/batiment.dart';
import 'package:terranova/core/models/domain.dart';
import 'package:terranova/core/models/personnage.dart';
import 'package:terranova/core/models/ressource.dart';
import 'package:terranova/core/constants/rarity_config.dart';
import 'package:terranova/core/models/xp/xp_stats.dart';
import 'package:terranova/core/managers/resource_transform_manager.dart';

class ProductionService {
  final void Function(String buildingId, String resourceId, double amount)? onProductionApplied;
  final ResourceTransformManager _transformManager = const ResourceTransformManager();

  const ProductionService({this.onProductionApplied});

  bool _isProducteur(Batiment b) {
    return b.producedResourceId != null && b.producedResourceId!.isNotEmpty;
  }

  // Coefficients
  double coefForBuildingLevel(int lvl) => _transformManager.coefForBuildingLevel(lvl);
  double coefForArtisanLevel(int lvl) => _transformManager.coefForArtisanLevel(lvl);

  int _artisanCountAssigned(Domain d, String batimentId) {
    return d.personnages
        .where((p) => p.type == AppStrings.personnageArtisan && p.assignedBatimentId == batimentId)
        .length;
  }

  List<Personnage> _assignedArtisans(Domain d, String batimentId) {
    return d.personnages
        .where((p) => p.type == AppStrings.personnageArtisan && p.assignedBatimentId == batimentId)
        .toList();
  }

  int _levelForArtisan(Personnage p) {
    return p.xpStats.level;
  }

  Ressource _updateResourceQuantity(Ressource r, double delta) {
    return Ressource(
      id: r.id,
      nom: r.nom,
      fonction: r.fonction,
      sousCategorie: r.sousCategorie,
      description: r.description,
      quantiteStock: r.quantiteStock + delta,
      rarity: r.rarity,
    );
  }

  // Recherche ressource dans le Domain via l'id produit par le bâtiment
  Ressource? _lookupResourceById(Domain d, String resourceId) {
    for (final r in d.ressources) {
      if (r.id == resourceId) return r;
    }
    return null;
  }

  /// Calcul de production pour un bâtiment donné, en se basant sur la rareté
  /// et les niveaux (bâtiment + artisans).
  double computeProductionForBuilding(Domain d, Batiment b) {
    if (!_isProducteur(b)) return 0.0;
    final resId = b.producedResourceId!;
    final res = _lookupResourceById(d, resId);
    if (res == null) return 0.0;

    final artisans = _assignedArtisans(d, b.id);
    final nbArtisans = artisans.length;
    if (nbArtisans == 0) return 0.0;

    final baseRarity = RarityConfig.baseFor(res.rarity);
    final coefB = coefForBuildingLevel(b.xpStats.level);
    final avgCoefA = artisans
            .map((a) => coefForArtisanLevel(_levelForArtisan(a)))
            .fold<double>(0.0, (sum, v) => sum + v) /
        nbArtisans;

    final production = baseRarity * nbArtisans * coefB * avgCoefA;
    return production;
  }

  bool _isTransformingBuilding(Batiment b) {
    return b.nom == AppStrings.batAtelierTannage || b.nom == AppStrings.batAtelierPierre || b.nom == AppStrings.batBoucherie;
  }

  String? _outputKeyForBuilding(Batiment b) {
    if (b.nom == AppStrings.batAtelierTannage) return ResourceKeys.cuir;
    if (b.nom == AppStrings.batAtelierPierre) return ResourceKeys.outilSimple;
    if (b.nom == AppStrings.batBoucherie) return ResourceKeys.viande;
    return null;
  }

  /// Calcule la production potentielle par bâtiment sans modifier l'état.
  /// Retourne un map batimentId -> quantité (double) et un map ressourceNom -> quantité (double).
  ({Map<String, double> byBuilding, Map<String, double> byResource}) computePreview(Domain d) {
    final byBuilding = <String, double>{};
    final byResource = <String, double>{};

    for (final b in d.batiments) {
      if (!_isProducteur(b)) continue;
      final produced = computeProductionForBuilding(d, b);
      byBuilding[b.id] = produced;
      final resId = b.producedResourceId!;
      byResource[resId] = (byResource[resId] ?? 0) + produced;
    }
    return (byBuilding: byBuilding, byResource: byResource);
  }

  /// Applique un tick de production pour tous les bâtiments producteurs.
  Domain applyProductionTick(Domain d) {
    final newResources = d.ressources.map((r) => r).toList();

    for (final b in d.batiments) {
      if (!_isProducteur(b)) continue;
      final resId = b.producedResourceId!;

      if (_isTransformingBuilding(b)) {
        final outputKey = _outputKeyForBuilding(b);
        if (outputKey == null) continue;
        // Calcul du rendement via manager
        final result = _transformManager.transform(d, b.id, outputKey, 1);
        if (!result.ok || result.produced <= 0) {
          print('[TRANSF] ${b.nom} => impossible (${result.error ?? 'aucune sortie'})');
          continue;
        }
        // Calcul des coûts effectifs (facteur limitant basé sur stocks actuels)
        final baseCost = _transformManager.getCost(outputKey, 1);
        double limiting = 1.0;
        for (final e in baseCost.entries) {
          final resName = RESOURCE_KEY_TO_NAME[e.key];
          if (resName == null) continue;
          final idxName = newResources.indexWhere((r) => r.nom == resName);
          if (idxName == -1) {
            limiting = 0;
            break;
          }
          final have = newResources[idxName].quantiteStock;
          final factor = have / e.value;
          if (factor < limiting) limiting = factor;
        }
        if (limiting <= 0) {
          print('[TRANSF] ${b.nom} => intrants insuffisants');
          continue;
        }
        final effectiveCost = baseCost.map((k, v) => MapEntry(k, v * limiting));
        // Déduire intrants
        for (final e in effectiveCost.entries) {
          final resName = RESOURCE_KEY_TO_NAME[e.key];
          if (resName == null) continue;
          final idxIn = newResources.indexWhere((r) => r.nom == resName);
          if (idxIn != -1) {
            newResources[idxIn] = _updateResourceQuantity(newResources[idxIn], -e.value);
          }
        }
        // Ajouter sortie
        final idxOut = newResources.indexWhere((r) => r.id == resId);
        if (idxOut != -1) {
          newResources[idxOut] = _updateResourceQuantity(newResources[idxOut], result.produced);
          print('[TRANSF] ${b.nom} => +${result.produced.toStringAsFixed(2)} (${resId})');
          onProductionApplied?.call(b.id, resId, result.produced);
        }
        continue;
      }

      // Production d'extraction (inchangée)
      final produced = computeProductionForBuilding(d, b);
      if (produced <= 0) {
        print('[PROD] ${b.nom} => +0');
        continue;
      }
      final idx = newResources.indexWhere((r) => r.id == resId);
      if (idx != -1) {
        newResources[idx] = _updateResourceQuantity(newResources[idx], produced);
        print('[PROD] ${b.nom} => +${produced.toStringAsFixed(2)} (${resId})');
        onProductionApplied?.call(b.id, resId, produced);
      }
    }

    return Domain(
      id: d.id,
      nom: d.nom,
      nvx: d.nvx,
      personnages: List<Personnage>.from(d.personnages),
      batiments: List<Batiment>.from(d.batiments),
      ressources: newResources,
    );
  }

  // Compat: ancienne méthode
  Domain applyTick(Domain d) => applyProductionTick(d);
}
