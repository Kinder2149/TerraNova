/// DomainManager: point d'accès central en mémoire aux domaines et éléments.
/// Propose un singleton, un état simple et des opérations CRUD minimales.

import '../services/data_init_service.dart';
import '../services/production_service.dart';
import '../managers/building_manager.dart';
import '../services/xp_manager.dart';
import '../models/domain.dart';
import '../models/personnage.dart';
import '../models/batiment.dart';
import '../models/ressource.dart';
import '../managers/population_manager.dart';
import 'package:terranova/core/constants/constantes.dart';
import 'package:terranova/core/constants/xp_config.dart';
import 'package:terranova/core/models/xp/xp_stats.dart';

class DomainManager {
  // Singleton
  static final DomainManager _instance = DomainManager._internal();
  factory DomainManager() => _instance;
  DomainManager._internal();

  final DataInitService _dataInitService = const DataInitService();
  final PopulationManager _populationManager = const PopulationManager();
  final BuildingManager _buildingManager = const BuildingManager();
  final ProductionService _productionService = const ProductionService();
  final XPManager _xpManager = const XPManager();

  String _status = AppStrings.statusNotInitialized;
  List<Domain> _domains = const [];

  String get status => _status;
  List<Domain> getDomains() => List.unmodifiable(_domains);

  /// Initialise les données en mémoire depuis DataInitService et passe le statut à READY.
  Future<void> init() async {
    _status = AppStrings.statusNotInitialized;
    _domains = await _dataInitService.loadSampleDomains();
    _status = AppStrings.statusReady;
  }

  /// Ajoute un domaine en mémoire.
  Future<void> addDomain(Domain d) async {
    _domains = List<Domain>.from(_domains)..add(d);
  }

  int _indexOfDomain(String domainId) => _domains.indexWhere((d) => d.id == domainId);

  Domain _updateAt(int idx, Domain updated) {
    final copy = List<Domain>.from(_domains);
    copy[idx] = updated;
    _domains = copy;
    return updated;
  }

  /// Ajoute un personnage au domaine (utilitaire interne pour UI générique)
  Future<Domain> addPersonnage(String domainId, Personnage p) async {
    final idx = _indexOfDomain(domainId);
    if (idx == -1) throw StateError(AppStrings.errDomainNotFound);
    final target = _domains[idx];
    final updated = Domain(
      id: target.id,
      nom: target.nom,
      nvx: target.nvx,
      personnages: List<Personnage>.from(target.personnages)..add(p),
      batiments: List<Batiment>.from(target.batiments),
      ressources: List<Ressource>.from(target.ressources),
    );
    return _updateAt(idx, updated);
  }

  /// Ajoute une ressource au domaine
  Future<Domain> addRessource(String domainId, Ressource r) async {
    final idx = _indexOfDomain(domainId);
    if (idx == -1) throw StateError(AppStrings.errDomainNotFound);
    final target = _domains[idx];
    final updated = Domain(
      id: target.id,
      nom: target.nom,
      nvx: target.nvx,
      personnages: List<Personnage>.from(target.personnages),
      batiments: List<Batiment>.from(target.batiments),
      ressources: List<Ressource>.from(target.ressources)..add(r),
    );
    return _updateAt(idx, updated);
  }

  /// Ajoute un bâtiment au domaine
  Future<Domain> addBatiment(String domainId, Batiment b) async {
    final idx = _indexOfDomain(domainId);
    if (idx == -1) throw StateError(AppStrings.errDomainNotFound);
    final target = _domains[idx];
    final updated = Domain(
      id: target.id,
      nom: target.nom,
      nvx: target.nvx,
      personnages: List<Personnage>.from(target.personnages),
      batiments: List<Batiment>.from(target.batiments)..add(b),
      ressources: List<Ressource>.from(target.ressources),
    );
    return _updateAt(idx, updated);
  }

  // Hébergement des Personnages
  Future<Domain> ajouterVillageois(String domainId, Personnage v) async {
    final idx = _indexOfDomain(domainId);
    if (idx == -1) throw StateError(AppStrings.errDomainNotFound);
    final updated = _populationManager.placeVillageois(_domains[idx], v);
    return _updateAt(idx, updated);
  }

  Future<Domain> retirerVillageois(String domainId, String personnageId) async {
    final idx = _indexOfDomain(domainId);
    if (idx == -1) throw StateError(AppStrings.errDomainNotFound);
    final updated = _populationManager.removeVillageois(_domains[idx], personnageId);
    return _updateAt(idx, updated);
  }

  Future<Domain> ajouterArtisan(String domainId, Personnage a) async {
    final idx = _indexOfDomain(domainId);
    if (idx == -1) throw StateError(AppStrings.errDomainNotFound);
    final updated = _populationManager.placeArtisan(_domains[idx], a);
    return _updateAt(idx, updated);
  }

  Future<Domain> retirerArtisan(String domainId, String personnageId) async {
    final idx = _indexOfDomain(domainId);
    if (idx == -1) throw StateError(AppStrings.errDomainNotFound);
    final updated = _populationManager.removeArtisan(_domains[idx], personnageId);
    return _updateAt(idx, updated);
  }

  // Assignation Artisans ↔ Bâtiments (via BuildingManager)
  Future<Domain> assignerArtisan(String domainId, String artisanId, String batimentId) async {
    final idx = _indexOfDomain(domainId);
    if (idx == -1) throw StateError(AppStrings.errDomainNotFound);
    final updated = _buildingManager.assignerArtisan(_domains[idx], artisanId, batimentId);
    return _updateAt(idx, updated);
  }

  Future<Domain> retirerArtisanDeBatiment(String domainId, String artisanId) async {
    final idx = _indexOfDomain(domainId);
    if (idx == -1) throw StateError(AppStrings.errDomainNotFound);
    final updated = _buildingManager.retirerArtisan(_domains[idx], artisanId);
    return _updateAt(idx, updated);
  }

  /// Applique une tick de production
  Future<Domain> applyProductionTick(String domainId) async {
    final idx = _indexOfDomain(domainId);
    if (idx == -1) throw StateError(AppStrings.errDomainNotFound);
    final updated = _productionService.applyTick(_domains[idx]);
    return _updateAt(idx, updated);
  }

  /// Prévisualisation de production par bâtiment et par ressource
  ({Map<String, double> byBuilding, Map<String, double> byResource}) computeProductionPreview(String domainId) {
    final idx = _indexOfDomain(domainId);
    if (idx == -1) throw StateError(AppStrings.errDomainNotFound);
    return _productionService.computePreview(_domains[idx]);
  }

  // ===================== XP Helpers =====================
  Future<Domain> addXpToPlayer(String domainId, int amount) async {
    final idx = _indexOfDomain(domainId);
    if (idx == -1) throw StateError(AppStrings.errDomainNotFound);
    final d = _domains[idx];
    final baseXp = d.playerXp ?? XPStats(level: 1, currentXp: 0, xpToNextLevel: XPConfig.getXpForLevel(1));
    final updatedPlayerXp = _xpManager.addXp(baseXp, amount);
    final updated = Domain(
      id: d.id,
      nom: d.nom,
      nvx: d.nvx,
      personnages: List<Personnage>.from(d.personnages),
      batiments: List<Batiment>.from(d.batiments),
      ressources: List<Ressource>.from(d.ressources),
      playerXp: updatedPlayerXp,
    );
    return _updateAt(idx, updated);
  }

  Future<Domain> addXpToAllBuildings(String domainId, int amount) async {
    final idx = _indexOfDomain(domainId);
    if (idx == -1) throw StateError(AppStrings.errDomainNotFound);
    final d = _domains[idx];
    final newBuildings = d.batiments
        .map((b) => Batiment(
              id: b.id,
              nom: b.nom,
              fonction: b.fonction,
              sousCategorie: b.sousCategorie,
              description: b.description,
              niveau: b.niveau,
              xpStats: _xpManager.addXp(b.xpStats, amount),
              producedResourceId: b.producedResourceId,
            ))
        .toList();
    final updated = Domain(
      id: d.id,
      nom: d.nom,
      nvx: d.nvx,
      personnages: List<Personnage>.from(d.personnages),
      batiments: newBuildings,
      ressources: List<Ressource>.from(d.ressources),
      playerXp: d.playerXp,
    );
    return _updateAt(idx, updated);
  }

  Future<Domain> addXpToBuilding(String domainId, String buildingId, int amount) async {
    final idx = _indexOfDomain(domainId);
    if (idx == -1) throw StateError(AppStrings.errDomainNotFound);
    final d = _domains[idx];
    final newBuildings = d.batiments
        .map((b) => b.id == buildingId
            ? Batiment(
                id: b.id,
                nom: b.nom,
                fonction: b.fonction,
                sousCategorie: b.sousCategorie,
                description: b.description,
                niveau: b.niveau,
                xpStats: _xpManager.addXp(b.xpStats, amount),
                producedResourceId: b.producedResourceId,
              )
            : b)
        .toList();
    final updated = Domain(
      id: d.id,
      nom: d.nom,
      nvx: d.nvx,
      personnages: List<Personnage>.from(d.personnages),
      batiments: newBuildings,
      ressources: List<Ressource>.from(d.ressources),
      playerXp: d.playerXp,
    );
    return _updateAt(idx, updated);
  }

  Future<Domain> addXpToAllCharacters(String domainId, int amount) async {
    final idx = _indexOfDomain(domainId);
    if (idx == -1) throw StateError(AppStrings.errDomainNotFound);
    final d = _domains[idx];
    final updatedPersons = d.personnages
        .map((p) => Personnage(
              id: p.id,
              nom: p.nom,
              fonction: p.fonction,
              sousCategorie: p.sousCategorie,
              niveau: p.niveau,
              type: p.type,
              etat: p.etat,
              metier: p.metier,
              assignedBatimentId: p.assignedBatimentId,
              dortoir: p.dortoir,
              pvMax: p.pvMax,
              attaque: p.attaque,
              xpStats: _xpManager.addXp(p.xpStats, amount),
            ))
        .toList();
    final updated = Domain(
      id: d.id,
      nom: d.nom,
      nvx: d.nvx,
      personnages: updatedPersons,
      batiments: List<Batiment>.from(d.batiments),
      ressources: List<Ressource>.from(d.ressources),
      playerXp: d.playerXp,
    );
    return _updateAt(idx, updated);
  }

  Future<Domain> addXpToCharacter(String domainId, String personnageId, int amount) async {
    final idx = _indexOfDomain(domainId);
    if (idx == -1) throw StateError(AppStrings.errDomainNotFound);
    final d = _domains[idx];
    final updatedPersons = d.personnages
        .map((p) => p.id == personnageId
            ? Personnage(
                id: p.id,
                nom: p.nom,
                fonction: p.fonction,
                sousCategorie: p.sousCategorie,
                niveau: p.niveau,
                type: p.type,
                etat: p.etat,
                metier: p.metier,
                assignedBatimentId: p.assignedBatimentId,
                dortoir: p.dortoir,
                pvMax: p.pvMax,
                attaque: p.attaque,
                xpStats: _xpManager.addXp(p.xpStats, amount),
              )
            : p)
        .toList();
    final updated = Domain(
      id: d.id,
      nom: d.nom,
      nvx: d.nvx,
      personnages: updatedPersons,
      batiments: List<Batiment>.from(d.batiments),
      ressources: List<Ressource>.from(d.ressources),
      playerXp: d.playerXp,
    );
    return _updateAt(idx, updated);
  }
}

