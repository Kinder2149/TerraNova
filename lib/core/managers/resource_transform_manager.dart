import 'package:terranova/core/constants/constantes.dart';
import 'package:terranova/core/models/batiment.dart';
import 'package:terranova/core/models/domain.dart';
import 'package:terranova/core/models/personnage.dart';
import 'package:terranova/core/models/ressource.dart';

class ResourceTransformManager {
  const ResourceTransformManager();

  // ====== Helpers de résolution ======
  Ressource? _findResourceByName(Domain d, String name) {
    try {
      return d.ressources.firstWhere((r) => r.nom == name);
    } catch (_) {
      return null;
    }
  }

  Ressource? _findResourceByKey(Domain d, String resourceKey) {
    final name = RESOURCE_KEY_TO_NAME[resourceKey];
    if (name == null) return null;
    try {
      return d.ressources.firstWhere((r) => r.nom == name);
    } catch (_) {
      return null;
    }
  }

  Batiment? _findBuildingByKey(Domain d, String buildingKey) {
    final name = BUILDING_KEY_TO_NAME[buildingKey];
    if (name == null) return null;
    try {
      return d.batiments.firstWhere((b) => b.nom == name);
    } catch (_) {
      return null;
    }
  }

  Map<String, Object>? _recipeForOutput(String outputResourceKey) {
    try {
      return TRANSFORM_RECIPES.firstWhere(
        (r) => r['outputResourceKey'] == outputResourceKey,
      );
    } catch (_) {
      return null;
    }
  }

  Map<String, int> getCost(String outputResourceKey, int quantity) {
    final recipe = _recipeForOutput(outputResourceKey);
    if (recipe == null) return {};
    final inputs = (recipe['inputs'] as Map<String, Object>).map(
      (k, v) => MapEntry(k, (v as int) * quantity),
    );
    return inputs;
  }

  double _coefForBuildingLevel(int lvl) => 1 + (lvl - 1) * 0.05;
  double _coefForArtisanLevel(int lvl) => 1 + (lvl - 1) * 0.03;

  List<Personnage> _assignedArtisans(Domain d, String batimentId) {
    return d.personnages
        .where((p) => p.type == AppStrings.personnageArtisan && p.assignedBatimentId == batimentId)
        .toList();
  }

  double computeYield(Domain d, Batiment b, {int quantity = 1}) {
    final recipe = TRANSFORM_RECIPES.firstWhere(
      (r) => BUILDING_KEY_TO_NAME[r['buildingKey'] as String] == b.nom,
      orElse: () => const {},
    );
    if (recipe.isEmpty) return 0.0;
    final base = (recipe['yieldBase'] as double? ?? 1.0) * quantity;

    final artisans = _assignedArtisans(d, b.id);
    if (artisans.isEmpty) return 0.0;
    final coefB = _coefForBuildingLevel(b.xpStats.level);
    final avgCoefA = artisans.map((a) => _coefForArtisanLevel(a.xpStats.level)).fold(0.0, (s, v) => s + v) / artisans.length;
    return base * artisans.length * coefB * avgCoefA;
  }

  bool canTransform(
    Domain d,
    String buildingId,
    String outputResourceKey,
    int quantity, {
    List<String>? warnings,
  }) {
    final warns = warnings ?? <String>[];
    final recipe = _recipeForOutput(outputResourceKey);
    if (recipe == null) {
      warns.add('Recette introuvable pour $outputResourceKey');
      return false;
    }
    final buildingKey = recipe['buildingKey'] as String;
    final b = _findBuildingByKey(d, buildingKey);
    if (b == null || b.id != buildingId) {
      warns.add('Bâtiment requis incompatible ou introuvable');
      return false;
    }
    final minLevel = recipe['minLevel'] as int? ?? 1;
    if (b.xpStats.level < minLevel) {
      warns.add('Niveau bâtiment insuffisant (min $minLevel)');
      return false;
    }

    final artisans = _assignedArtisans(d, b.id);
    if (artisans.isEmpty) {
      warns.add('Aucun artisan assigné');
      return false;
    }

    // Vérifier intrants disponibles
    final cost = getCost(outputResourceKey, quantity);
    for (final entry in cost.entries) {
      final res = _findResourceByKey(d, entry.key);
      final have = res?.quantiteStock ?? 0.0;
      if (have < entry.value) {
        warns.add('Intrant insuffisant: ${RESOURCE_KEY_TO_NAME[entry.key]} (manque ${(entry.value - have).toStringAsFixed(0)})');
        return false;
      }
    }
    return true;
  }

  ({bool ok, int requested, double produced, String? error, List<String> warnings}) transform(
    Domain d,
    String buildingId,
    String outputResourceKey,
    int quantity,
  ) {
    final warnings = <String>[];
    final recipe = _recipeForOutput(outputResourceKey);
    if (recipe == null) {
      return (ok: false, requested: quantity, produced: 0.0, error: 'Recette inconnue', warnings: warnings);
    }
    final buildingKey = recipe['buildingKey'] as String;
    final b = _findBuildingByKey(d, buildingKey);
    if (b == null || b.id != buildingId) {
      return (ok: false, requested: quantity, produced: 0.0, error: 'Bâtiment requis incompatible', warnings: warnings);
    }

    // Calcul du yield potentiel
    final potential = computeYield(d, b, quantity: quantity);
    if (potential <= 0) {
      warnings.add('Aucun rendement possible (pas d\'artisan?)');
      return (ok: false, requested: quantity, produced: 0.0, error: 'Rendement nul', warnings: warnings);
    }

    // Vérifier et consommer intrants — ici on ne mute pas, on renvoie seulement la quantité produite possible.
    final cost = getCost(outputResourceKey, quantity);
    double limitingFactor = 1.0;
    for (final e in cost.entries) {
      final res = _findResourceByKey(d, e.key);
      final have = res?.quantiteStock ?? 0.0;
      final factor = have / e.value;
      if (factor < limitingFactor) limitingFactor = factor;
    }
    if (limitingFactor <= 0) {
      return (ok: false, requested: quantity, produced: 0.0, error: 'Intrants insuffisants', warnings: warnings);
    }

    final produced = potential * limitingFactor;
    return (ok: true, requested: quantity, produced: produced, error: null, warnings: warnings);
  }
}
