import 'package:terranova/core/models/domain.dart';
import 'package:terranova/core/models/ressource.dart';
import 'package:terranova/core/constants/constantes.dart';
import 'package:terranova/core/models/base_element.dart';
import 'package:terranova/core/models/resource/rarity.dart';

/// MonnaieService: gère la monnaie Novas via la Ressource correspondante.
/// Stockage: comme Ressource (nom = AppStrings.NAME_NOVAS), pas de double comptage.
class MonnaieService {
  const MonnaieService();

  Ressource? _findNovas(Domain d) {
    try {
      return d.ressources.firstWhere((r) => r.nom == AppStrings.NAME_NOVAS);
    } catch (_) {
      return null;
    }
  }

  double getNovas(Domain d) {
    return _findNovas(d)?.quantiteStock ?? 0.0;
    }

  Domain addNovas(Domain d, double amount) {
    if (amount == 0) return d;
    final idx = d.ressources.indexWhere((r) => r.nom == AppStrings.NAME_NOVAS);
    if (idx == -1) {
      // Crée la ressource si absente (fallback sécurisé)
      final novas = Ressource(
        id: 'res-novas-${DateTime.now().microsecondsSinceEpoch}',
        nom: AppStrings.NAME_NOVAS,
        fonction: '',
        sousCategorie: SousCategorie.banque,
        description: AppStrings.DESC_NOVAS,
        quantiteStock: amount,
        rarity: Rarity.abundant,
      );
      return Domain(
        id: d.id,
        nom: d.nom,
        nvx: d.nvx,
        personnages: List.from(d.personnages),
        batiments: List.from(d.batiments),
        ressources: List.from(d.ressources)..add(novas),
        playerXp: d.playerXp,
      );
    }
    final list = List<Ressource>.from(d.ressources);
    final r = list[idx];
    list[idx] = Ressource(
      id: r.id,
      nom: r.nom,
      fonction: r.fonction,
      sousCategorie: r.sousCategorie,
      description: r.description,
      quantiteStock: r.quantiteStock + amount,
      rarity: r.rarity,
    );
    return Domain(
      id: d.id,
      nom: d.nom,
      nvx: d.nvx,
      personnages: List.from(d.personnages),
      batiments: List.from(d.batiments),
      ressources: list,
      playerXp: d.playerXp,
    );
  }

  ({Domain domain, bool ok}) spendNovas(Domain d, double amount) {
    if (amount <= 0) return (domain: d, ok: true);
    final idx = d.ressources.indexWhere((r) => r.nom == AppStrings.NAME_NOVAS);
    if (idx == -1) return (domain: d, ok: false);
    final r = d.ressources[idx];
    if (r.quantiteStock < amount) return (domain: d, ok: false);
    final list = List<Ressource>.from(d.ressources);
    list[idx] = Ressource(
      id: r.id,
      nom: r.nom,
      fonction: r.fonction,
      sousCategorie: r.sousCategorie,
      description: r.description,
      quantiteStock: r.quantiteStock - amount,
      rarity: r.rarity,
    );
    return (
      domain: Domain(
        id: d.id,
        nom: d.nom,
        nvx: d.nvx,
        personnages: List.from(d.personnages),
        batiments: List.from(d.batiments),
        ressources: list,
        playerXp: d.playerXp,
      ),
      ok: true,
    );
  }
}
