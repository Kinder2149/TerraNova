# TerraNova 1.1 — Mission d’audit complet et corrections

## 0) Contexte et objectifs
- Stack: Flutter/Dart, application mobile multi-plateforme.
- Architecture: constants, models, services, managers, ui/screens (mapping + dev).
- Source de vérité: `lib/core/constants/constantes.dart`.
- Etat: tout en mémoire, aucun IO externe.
- Objectif: auditer l’architecture et le code, corriger divergences/incohérences, centraliser, harmoniser et sécuriser sans régression.

## 1) Méthodologie (Terra Nova – 7 étapes)
1. Mise à jour de ce plan (présent document).
2. Scan de l’architecture et recherche de doublons/incohérences.
3. Analyse détaillée des fichiers clés (constants, models, managers, services, UI).
4. Corrections dans l’ordre logique (centralisation, harmonisation IDs/labels, factorisations, validations).
5. Centralisation supplémentaire dans `constantes.dart` (clés/IDs, libellés, recettes).
6. Vérification des connexions backend mémoire ↔ UI (Mapping/Dev).
7. Rapport final (divergences, corrections, impacts, suites).

## 2) Arborescence (réelle)
```
lib/
  core/
    constants/
      constantes.dart
      rarity_config.dart
      xp_config.dart
    managers/
      building_manager.dart
      domain_manager.dart
      population_manager.dart
      resource_transform_manager.dart
    models/
      base_element.dart
      batiment.dart
      ressource.dart
      personnage.dart
      domain.dart
      resource/rarity.dart
      xp/xp_stats.dart
    services/
      creation_service.dart
      data_init_service.dart
      loop_manager.dart
      name_service.dart
      production_service.dart
      xp_manager.dart
    utils/
  ui/
    screens/
      mapping/mapping_screen.dart
      dev/dev_screen.dart
      dev/tables/{personnages_table.dart, ressources_table.dart, batiments_table.dart}
      dev/create/create_panel.dart
  main.dart
assets/dev_init.json
```

## 3) Divergences détectées (avant corrections)
- Doc (plan.md) en décalage avec le code: fichiers/attributs obsolètes listés (ex: `personnage_artisan.dart`, `assignedArtisanIds`).
- Valeurs en dur non centralisées pour la ressource Animaux dans `DataInitService` (libellés).
- Incohérence de préfixes d’IDs dans `CreationService` (`per-`, `bat_`, `res_` mixtes vs convention `pers-`, `bat-`, `res-`).
- `CreationService.defaultsXp()` ne suivait pas la courbe `XPConfig`.
- `assets/dev_init.json` déclaré mais non utilisé (non bloquant).

## 4) Corrections appliquées
- Centralisation IDs: ajout de `AppIds` dans `constantes.dart` (`pers-`, `bat-`, `res-`).
- Harmonisation `CreationService`:
  - Préfixes d’IDs via `AppIds`.
  - XP par défaut via `XPConfig.getXpForLevel(1)`.
  - Echantillons d’IDs: `bat-mine`, `res-fer` (kebab case cohérent).
- Uniformisation libellés Animaux dans `DataInitService` via `AppStrings.resAnimaux` et `AppStrings.descAnimaux`.
- Documentation (présent plan) mise à jour pour refléter l’état réel et supprimer les éléments obsolètes.

Fichiers modifiés:
- `lib/core/constants/constantes.dart` (ajout `AppIds`).
- `lib/core/services/creation_service.dart` (IDs + XP + échantillons harmonisés).
- `lib/core/services/data_init_service.dart` (libellés Animaux centralisés).

## 5) Cohérence globale validée
- Production/Transformation: `ProductionService` + `ResourceTransformManager` cohérents, recettes dans `constantes.dart`.
- XP: `XPManager` adossé à `XPConfig`. UI fournit des CTA de test (player/char/buildings).
- Boucle: `LoopManager` déclenche `applyProductionTick` (manuel/auto depuis UI).
- UI: `MappingScreen` et `DevScreen` utilisent `DomainManager` et managers spécialisés.
  - Bouton "Tick Once" → applyProductionTick()
  - Logs et aperçu per-tick par ressource (via IDs)

## 7) Commandes pour lancer et vérifier
- flutter pub get
- flutter analyze
- flutter run -d chrome

## 8) Checklist (Missions mises à jour)
- [x] Centralisation production (ProductionService)
- [x] Rareté des ressources (Rarity + RarityConfig)
- [x] Modèles enrichis (Ressource.rarity, Batiment.producedResourceId, XPStats, Artisan)
- [x] LoopManager (optionnel)
- [x] UI Production Test
- [x] Suppression test/data_init_test.dart

## 9) Instructions de test
1. Lancer l’app et ouvrir MappingScreen
2. Créer 2 artisans (bouton "Créer Artisan")
3. Dans la section "Production Test", sélectionner le Puits
4. Affecter les 2 artisans au Puits
5. Cliquer "Tick Once"
6. Vérifier que la ressource Eau augmente d’environ base(1.0) * 2 = 2 (Lv1)

## 10) Éléments en attente (TODO)
- Buffs/effets bonus de production
- Coûts et économie de level-up (BuildingUpgradeService)
- Persistance locale (migrations pour rarity/producers)
- Harmonisation complète Artisan vs Personnage
