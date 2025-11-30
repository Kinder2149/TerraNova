# TerraNova 1.1 — Phase 1 (Base + UI Mapping)

## 1) Objectif de la phase
Mettre en place une base Flutter minimale et propre permettant d’afficher l’état du backend en mémoire via une UI de développement (MappingScreen). Aucun IO externe, données locales simulées, zéro dépendance externe.

## 2) Arborescence créée
```
lib/
  core/
    constants/
      constantes.dart
      rarity_config.dart
    models/
      base_element.dart
      personnage.dart
      personnage_artisan.dart
      batiment.dart
      ressource.dart
      resource/rarity.dart
      domain.dart
    services/
      data_init_service.dart
      production_service.dart
      loop_manager.dart
    managers/
      domain_manager.dart
    utils/
  ui/
    screens/
      mapping/
        mapping_screen.dart
    widgets/
    theming/
  main.dart

test/
  widget_test.dart
```

## 3) Modèles et champs (mis à jour)
- BaseElement
  - id: String
  - nom: String
  - fonction: String
  - sousCategorie: SousCategorie (enum: vitale, production, banque, arme)
  - toMap()
- Personnage extends BaseElement
  - niveau: int
  - type: String
  - etat?: String
  - metier?: String
  - assignedBatimentId?: String
  - dortoir?: String
  - pvMax?: int
  - attaque?: int
  - toMap()
- Artisan extends BaseElement
  - xpStats: XPStats
  - assignedBuildingId?: String
  - isAssigned()
  - toMap()/fromJson()/toJson()
- Batiment extends BaseElement
  - description: String
  - niveau: int
  - xpStats: XPStats
  - producedResourceId?: String
  - assignedArtisanIds: List<String>
  - baseProductionFromResource(lookup)
  - toMap()/fromJson()/toJson()
- Ressource extends BaseElement
  - description: String
  - quantiteStock: double
  - rarity: Rarity
  - toMap()/fromJson()/toJson()
- Domain
  - id: String
  - nom: String
  - nvx: int
  - personnages: List<Personnage>
  - batiments: List<Batiment>
  - ressources: List<Ressource>
  - playerXp?: XPStats
  - toMap()

## 4) Services / Managers (mis à jour)
- DataInitService
  - Initialise Domaine Alpha, bâtiments vitaux (QG, Maison) et producteurs (Puits, Cabane bûcheron, Cabane chasse)
  - Ressources Eau/Bois/Viande: quantiteStock=0, rarity=Abundant
  - producedResourceId assignée aux bâtiments producteurs
- ProductionService
  - coefForBuildingLevel(lvl) = 1 + (lvl - 1) * 0.05
  - coefForArtisanLevel(lvl) = 1 + (lvl - 1) * 0.03
  - computeProductionForBuilding: baseRarity * nbArtisans * coefB * moyenne(coefA)
  - applyProductionTick: met à jour les ressources et déclenche `onProductionApplied` (optionnel)
- LoopManager (nouveau)
  - start/stop/tickOnce + stream onTick
- DomainManager
  - Orchestration: assignations, applyProductionTick, preview

## 5) Constantes & Thème
- AppStrings: libellés, noms des entités, capacités, sections
- Ajout libellés Rareté (Abondante/Commune/Peu commune/Rare/Légendaire)
- RarityConfig: BASE_PRODUCTION + baseFor()

## 6) UI (MappingScreen)
- Section "Production Test" :
  - Dropdown des bâtiments producteurs
  - Assignation/désaffectation artisans
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
