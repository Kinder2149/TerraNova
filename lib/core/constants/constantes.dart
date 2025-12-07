// ignore_for_file: constant_identifier_names

import 'package:flutter/material.dart';

// ===================== Capacités & coûts (top-level) =====================

/// Capacités de population par bâtiment et par niveau (index 0 = niveau 1)
const Map<String, List<int>> BUILDING_CAPACITY_BY_LEVEL = {
  BuildingKeys.BAT_CABANE_EXPLORATEUR: [2, 4, 6, 8, 10],
  BuildingKeys.BAT_CASERNE: [10, 15, 20, 30, 40],
};

/// Coût en Novas pour recruter des personnages
const Map<String, int> PERSONNAGE_COST_NOVAS = {
  AppStrings.TYPE_EXPLORATEUR: 8,
  AppStrings.TYPE_SOLDAT: 10,
};

/// Solde initial de Novas pour le domaine seed
const double STARTING_NOVAS = 100.0;

class AppStrings {
  // App
  static const String appTitle = 'TerraNova 1.1';

  // Écran
  static const String mappingTitle = 'UI Développement — Mapping';
  static const String welcomeMessage = 'Bienvenue dans TerraNova — base de projet minimale.';

  // Statuts backend
  static const String backendStateLabel = 'État du backend';
  static const String statusNotInitialized = 'NOT_INITIALIZED';
  static const String statusReady = 'READY';

  // Sections
  static const String domains = 'Domaines';
  static const String characters = 'Personnages';
  static const String buildings = 'Bâtiments';
  static const String resources = 'Ressources';

  // Champs
  static const String id = 'ID';
  static const String name = 'Nom';
  static const String level = 'Niveau';
  static const String functionField = 'Fonction';
  static const String subcategory = 'Sous-catégorie';
  static const String type = 'Type';
  static const String description = 'Description';
  static const String quantity = 'Quantité';
  static const String hpMax = 'PV Max';
  static const String attack = 'Attaque';

  // Libellés sous-catégories
  static const String scVitale = 'Vitale';
  static const String scProduction = 'Production';
  static const String scBanque = 'Banque';
  static const String scArme = 'Arme';

  // Divers
  static const String empty = 'Aucun élément';
  static const String bullet = '•';

  // Erreurs
  static const String errDomainNotFound = 'Domaine introuvable';
  static const String errCapacityExceeded = 'Capacité dépassée';

  // Déclarations officielles Terra Nova (aucune valeur en dur dans les modèles)
  // Personnages
  static const String personnageVillageois = 'Villageois';
  static const String personnageArtisan = 'Artisan';
  static const String etatOccupe = 'occupé';
  static const String etatInoccupe = 'inoccupé';

  // Bâtiments — noms
  static const String batQG = 'QG';
  static const String batPuits = 'Puits';
  static const String batCabaneBucheron = 'Cabane de bûcheron';
  static const String batCabaneChasse = 'Cabane de chasse';
  static const String batMaison = 'Maison';
  static const String batCabanePeche = 'Cabane de pêche';
  static const String batAtelierPierre = 'Atelier de pierre';
  static const String batMinePierre = 'Mine de pierre';
  static const String batAtelierTannage = 'Atelier de tannage';
  static const String batCabaneAgricole = 'Cabane agricole';
  static const String batEntrepot = 'Entrepôt';
  static const String batGrenier = 'Grenier';
  static const String batBoucherie = 'Boucherie';

  // Bâtiments — descriptions
  static const String descQG = 'Quartier Général, centre de commandement du domaine.';
  static const String descPuits = 'Source d\'eau potable.';
  static const String descCabaneBucheron = 'Production de bois via coupe.';
  static const String descCabaneChasse = 'Produit des animaux.';
  static const String descMaison = 'Logement des artisans.';
  static const String descCabanePeche = 'Produit du poisson.';
  static const String descAtelierPierre = 'Transforme la pierre en outils simples.';
  static const String descMinePierre = 'Produit de la pierre.';
  static const String descAtelierTannage = 'Transforme des animaux en cuir.';
  static const String descBoucherie = 'Transforme des animaux en viande.';
  static const String descCabaneAgricole = 'Produit des céréales.';
  static const String descEntrepot = 'Stocke les éléments vitaux.';
  static const String descGrenier = 'Stocke les éléments de production.';

  // Bâtiments — capacités de base (niveau 1)
  static const int qgCapVillageoisL1 = 3;
  static const int maisonCapArtisansL1 = 5;

  // Production — boucle de base
  static const int baseProductionParArtisan = 1;

  // Ressources — noms
  static const String resEau = 'Eau';
  static const String resBois = 'Bois';
  static const String resViande = 'Viande';
  static const String resAnimaux = 'Animaux';
  static const String resPoisson = 'Poisson';
  static const String resOutilSimple = 'Outils simple';
  static const String resPierre = 'Pierre';
  static const String resCuir = 'Cuir';
  static const String resCereale = 'Céréale';
  static const String NAME_NOVAS = 'Novas';

  // Ressources — descriptions
  static const String descEau = 'Ressource vitale: eau.';
  static const String descBois = 'Ressource vitale: bois.';
  static const String descViande = 'Ressource vitale: viande.';
  static const String descAnimaux = 'Matière première biologique: animaux.';
  static const String descPoisson = 'Ressource de pêche: poisson.';
  static const String descOutilSimple = 'Outils simples fabriqués.';
  static const String descPierre = 'Roche brute.';
  static const String descCuir = 'Cuir tanné.';
  static const String descCereale = 'Céréales de base.';
  static const String DESC_NOVAS = 'Monnaie officielle du Domaine, utilisée pour recruter des personnages et payer des services.';

  // Raretés — libellés
  static const String rarityAbundant = 'Abondante';
  static const String rarityCommon = 'Commune';
  static const String rarityUncommon = 'Peu commune';
  static const String rarityRare = 'Rare';
  static const String rarityLegendary = 'Légendaire';

  // Domain — valeurs par défaut
  static const String defaultDomainName = 'Domaine Alpha';

  // Bâtiments — nouveaux noms & descriptions
  static const String NAME_CASERNE = 'Caserne';
  static const String DESC_CASERNE = 'Bâtiment militaire permettant de recruter et héberger des Soldats.';
  static const String NAME_CABANE_EXPLORATEUR = 'Cabane d\'explorateur';
  static const String DESC_CABANE_EXPLORATEUR = 'Petit camp qui forme des Explorateurs et permet d\'étendre la découverte.';

  // Personnages — nouveaux types
  static const String TYPE_SOLDAT = 'Soldat';
  static const String TYPE_EXPLORATEUR = 'Explorateur';

  // Fonctions — libellés pour éléments
  static const String funcQG = 'Centre de commandement';
  static const String funcMaison = 'Logement des artisans';
  static const String funcPuits = 'Production: Eau';
  static const String funcBucheron = 'Production: Bois';
  static const String funcChasse = 'Production: Animaux';
  static const String funcPeche = 'Production: Poisson';
  static const String funcAtelierPierreLbl = 'Production: Outils simple';
  static const String funcMinePierreLbl = 'Production: Pierre';
  static const String funcTannage = 'Production: Cuir';
  static const String funcAgricole = 'Production: Céréale';
  static const String funcStockage = 'Stockage';
  static const String funcBoucherie = 'Production: Viande';
}

class AppDimens {
  static const double paddingXS = 4.0;
  static const double paddingS = 8.0;
  static const double paddingM = 12.0;
  static const double labelWidth = 120.0;
  static const double gapXS = 6.0;
  static const double titleFontSize = 20.0;
}

class AppTheme {
  static const Color seedColor = Colors.teal;
}

class AppNames {
  static const List<String> syllabes = [
    'al', 'be', 'cor', 'dan', 'el', 'fir', 'gal', 'hal', 'ian', 'jor', 'ker', 'lin', 'mor', 'nel', 'or', 'per', 'quin', 'ron', 'sar', 'tor', 'ul', 'vor', 'wen', 'yor', 'zan'
  ];
}

class AppIds {
  // Préfixes canoniques d'identifiants
  static const String persPrefix = 'pers-';
  static const String batPrefix = 'bat-';
  static const String resPrefix = 'res-';
}

// ===================== Clés canoniques & recettes de transformation =====================

/// Identifiants canoniques des ressources (indépendants des IDs runtime)
class ResourceKeys {
  static const String eau = 'res_key_eau';
  static const String bois = 'res_key_bois';
  static const String viande = 'res_key_viande';
  static const String animaux = 'res_key_animaux';
  static const String poisson = 'res_key_poisson';
  static const String pierre = 'res_key_pierre';
  static const String cereale = 'res_key_cereale';
  static const String cuir = 'res_key_cuir';
  static const String outilSimple = 'res_key_outil_simple';
  static const String RES_NOVAS = 'res-novas';
}

/// Identifiants canoniques des bâtiments (pour les ateliers de transformation)
class BuildingKeys {
  static const String atelierTannage = 'build_key_atelier_tannage';
  static const String atelierPierre = 'build_key_atelier_pierre';
  static const String boucherie = 'build_key_boucherie';
  static const String BAT_CASERNE = 'bat-caserne';
  static const String BAT_CABANE_EXPLORATEUR = 'bat-cabane-explorateur';
}

/// Mapping clé ressource -> libellé officiel (résolution dans le Domain par nom)
const Map<String, String> RESOURCE_KEY_TO_NAME = {
  ResourceKeys.eau: AppStrings.resEau,
  ResourceKeys.bois: AppStrings.resBois,
  ResourceKeys.viande: AppStrings.resViande,
  ResourceKeys.animaux: AppStrings.resAnimaux,
  ResourceKeys.poisson: AppStrings.resPoisson,
  ResourceKeys.pierre: AppStrings.resPierre,
  ResourceKeys.cereale: AppStrings.resCereale,
  ResourceKeys.cuir: AppStrings.resCuir,
  ResourceKeys.outilSimple: AppStrings.resOutilSimple,
  ResourceKeys.RES_NOVAS: AppStrings.NAME_NOVAS,
};

/// Mapping clé bâtiment -> libellé officiel (résolution dans le Domain par nom)
const Map<String, String> BUILDING_KEY_TO_NAME = {
  BuildingKeys.atelierTannage: AppStrings.batAtelierTannage,
  BuildingKeys.atelierPierre: AppStrings.batAtelierPierre,
  BuildingKeys.boucherie: AppStrings.batBoucherie,
  BuildingKeys.BAT_CASERNE: AppStrings.NAME_CASERNE,
  BuildingKeys.BAT_CABANE_EXPLORATEUR: AppStrings.NAME_CABANE_EXPLORATEUR,
};

/// Recettes de transformation
/// Chaque entrée: {
///  'outputResourceKey': String,
///  'inputs': Map<String,int>,
///  'buildingKey': String,
///  'minLevel': int,
///  'yieldBase': double
/// }
const List<Map<String, Object>> TRANSFORM_RECIPES = [
  {
    'outputResourceKey': ResourceKeys.cuir,
    'inputs': {ResourceKeys.animaux: 1},
    'buildingKey': BuildingKeys.atelierTannage,
    'minLevel': 1,
    'yieldBase': 0.9,
  },
  {
    'outputResourceKey': ResourceKeys.outilSimple,
    'inputs': {ResourceKeys.pierre: 2},
    'buildingKey': BuildingKeys.atelierPierre,
    'minLevel': 1,
    'yieldBase': 1.0,
  },
  {
    'outputResourceKey': ResourceKeys.viande,
    'inputs': {ResourceKeys.animaux: 1},
    'buildingKey': BuildingKeys.boucherie,
    'minLevel': 1,
    'yieldBase': 1.0,
  },
];
