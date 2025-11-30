/// DataInitService: initialise un domaine réel sans mocks.
/// Aucune dépendance externe ni IO réseau/fichier.

import 'dart:async';

import '../models/base_element.dart';
import '../models/batiment.dart';
import '../models/ressource.dart';
import '../models/domain.dart';
import '../models/resource/rarity.dart';
import 'package:terranova/core/constants/constantes.dart';
import 'package:terranova/core/constants/xp_config.dart';
import 'package:terranova/core/models/xp/xp_stats.dart';

class DataInitService {
  const DataInitService();

  /// Initialise l'état de départ réel de Terra Nova.
  /// - Domaine unique (Alpha)
  /// - Bâtiments: QG (L1), Maison (L1)
  /// - Ressources: Eau/Bois/Viande à 0
  /// - Aucun personnage
  Future<List<Domain>> loadSampleDomains() async {
    await Future.delayed(const Duration(milliseconds: 200));

    // XP de base niveau 1
    final xpStart = XPStats(level: 1, currentXp: 0, xpToNextLevel: XPConfig.getXpForLevel(1));

    // Bâtiments initiaux
    final qg = Batiment(
      id: 'bat-qg-1',
      nom: AppStrings.batQG,
      fonction: AppStrings.funcQG,
      sousCategorie: SousCategorie.vitale,
      description: AppStrings.descQG,
      niveau: 1,
      xpStats: xpStart,
    );

    final maison = Batiment(
      id: 'bat-maison-1',
      nom: AppStrings.batMaison,
      fonction: AppStrings.funcMaison,
      sousCategorie: SousCategorie.vitale,
      description: AppStrings.descMaison,
      niveau: 1,
      xpStats: xpStart,
    );

    // Bâtiments producteurs (L1) pour permettre l'assignation immédiate
    final puits = Batiment(
      id: 'bat-puits-1',
      nom: AppStrings.batPuits,
      fonction: AppStrings.funcPuits,
      sousCategorie: SousCategorie.vitale,
      description: AppStrings.descPuits,
      niveau: 1,
      xpStats: xpStart,
      producedResourceId: 'res-eau-1',
    );
    final cabaneB = Batiment(
      id: 'bat-bucheron-1',
      nom: AppStrings.batCabaneBucheron,
      fonction: AppStrings.funcBucheron,
      sousCategorie: SousCategorie.vitale,
      description: AppStrings.descCabaneBucheron,
      niveau: 1,
      xpStats: xpStart,
      producedResourceId: 'res-bois-1',
    );
    final cabaneC = Batiment(
      id: 'bat-chasse-1',
      nom: AppStrings.batCabaneChasse,
      fonction: AppStrings.funcChasse,
      sousCategorie: SousCategorie.vitale,
      description: AppStrings.descCabaneChasse,
      niveau: 1,
      xpStats: xpStart,
      producedResourceId: 'res-viande-1',
    );

    // Ressources vitales à 0
    final eau = Ressource(
      id: 'res-eau-1',
      nom: AppStrings.resEau,
      fonction: '',
      sousCategorie: SousCategorie.vitale,
      description: AppStrings.descEau,
      quantiteStock: 0,
      rarity: Rarity.abundant,
    );
    final bois = Ressource(
      id: 'res-bois-1',
      nom: AppStrings.resBois,
      fonction: '',
      sousCategorie: SousCategorie.vitale,
      description: AppStrings.descBois,
      quantiteStock: 0,
      rarity: Rarity.abundant,
    );
    final viande = Ressource(
      id: 'res-viande-1',
      nom: AppStrings.resViande,
      fonction: '',
      sousCategorie: SousCategorie.vitale,
      description: AppStrings.descViande,
      quantiteStock: 0,
      rarity: Rarity.abundant,
    );

    // Nouvelles ressources de production (stock 0 au départ)
    final animaux = Ressource(
      id: 'res-animaux-1',
      nom: 'Animaux',
      fonction: '',
      sousCategorie: SousCategorie.production,
      description: 'Ressource animale de base.',
      quantiteStock: 0,
      rarity: Rarity.common,
    );
    final poisson = Ressource(
      id: 'res-poisson-1',
      nom: AppStrings.resPoisson,
      fonction: '',
      sousCategorie: SousCategorie.production,
      description: AppStrings.descPoisson,
      quantiteStock: 0,
      rarity: Rarity.common,
    );
    final outilSimple = Ressource(
      id: 'res-outil-simple-1',
      nom: AppStrings.resOutilSimple,
      fonction: '',
      sousCategorie: SousCategorie.production,
      description: AppStrings.descOutilSimple,
      quantiteStock: 0,
      rarity: Rarity.uncommon,
    );
    final pierre = Ressource(
      id: 'res-pierre-1',
      nom: AppStrings.resPierre,
      fonction: '',
      sousCategorie: SousCategorie.production,
      description: AppStrings.descPierre,
      quantiteStock: 0,
      rarity: Rarity.rare,
    );
    final cuir = Ressource(
      id: 'res-cuir-1',
      nom: AppStrings.resCuir,
      fonction: '',
      sousCategorie: SousCategorie.production,
      description: AppStrings.descCuir,
      quantiteStock: 0,
      rarity: Rarity.common,
    );
    final cereale = Ressource(
      id: 'res-cereale-1',
      nom: AppStrings.resCereale,
      fonction: '',
      sousCategorie: SousCategorie.production,
      description: AppStrings.descCereale,
      quantiteStock: 0,
      rarity: Rarity.abundant,
    );

    // Nouveaux bâtiments producteurs / stockage
    final cabanePeche = Batiment(
      id: 'bat-peche-1',
      nom: AppStrings.batCabanePeche,
      fonction: AppStrings.funcPeche,
      sousCategorie: SousCategorie.production,
      description: AppStrings.descCabanePeche,
      niveau: 1,
      xpStats: xpStart,
      producedResourceId: 'res-poisson-1',
    );
    final atelierPierre = Batiment(
      id: 'bat-atelier-pierre-1',
      nom: AppStrings.batAtelierPierre,
      fonction: AppStrings.funcAtelierPierreLbl,
      sousCategorie: SousCategorie.production,
      description: AppStrings.descAtelierPierre,
      niveau: 1,
      xpStats: xpStart,
      producedResourceId: 'res-outil-simple-1',
    );
    final minePierre = Batiment(
      id: 'bat-mine-pierre-1',
      nom: AppStrings.batMinePierre,
      fonction: AppStrings.funcMinePierreLbl,
      sousCategorie: SousCategorie.production,
      description: AppStrings.descMinePierre,
      niveau: 1,
      xpStats: xpStart,
      producedResourceId: 'res-pierre-1',
    );
    final atelierTannage = Batiment(
      id: 'bat-tannage-1',
      nom: AppStrings.batAtelierTannage,
      fonction: AppStrings.funcTannage,
      sousCategorie: SousCategorie.production,
      description: AppStrings.descAtelierTannage,
      niveau: 1,
      xpStats: xpStart,
      producedResourceId: 'res-cuir-1',
    );
    final cabaneAgricole = Batiment(
      id: 'bat-agricole-1',
      nom: AppStrings.batCabaneAgricole,
      fonction: AppStrings.funcAgricole,
      sousCategorie: SousCategorie.production,
      description: AppStrings.descCabaneAgricole,
      niveau: 1,
      xpStats: xpStart,
      producedResourceId: 'res-cereale-1',
    );
    final entrepot = Batiment(
      id: 'bat-entrepot-1',
      nom: AppStrings.batEntrepot,
      fonction: AppStrings.funcStockage,
      sousCategorie: SousCategorie.vitale,
      description: AppStrings.descEntrepot,
      niveau: 1,
      xpStats: xpStart,
    );
    final grenier = Batiment(
      id: 'bat-grenier-1',
      nom: AppStrings.batGrenier,
      fonction: AppStrings.funcStockage,
      sousCategorie: SousCategorie.production,
      description: AppStrings.descGrenier,
      niveau: 1,
      xpStats: xpStart,
    );

    final domaineAlpha = Domain(
      id: 'dom-1',
      nom: AppStrings.defaultDomainName,
      nvx: 1,
      personnages: const [],
      batiments: [
        qg,
        maison,
        puits,
        cabaneB,
        cabaneC,
        cabanePeche,
        atelierPierre,
        minePierre,
        atelierTannage,
        cabaneAgricole,
        entrepot,
        grenier,
      ],
      ressources: [
        eau,
        bois,
        viande,
        animaux,
        poisson,
        outilSimple,
        pierre,
        cuir,
        cereale,
      ],
      playerXp: xpStart,
    );

    return [domaineAlpha];
  }

  /// Compatibilité descendante: ancienne méthode interne qui délègue vers loadSampleDomains().
  Future<List<Domain>> loadInitialData() => loadSampleDomains();
}
