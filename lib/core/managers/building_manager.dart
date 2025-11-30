import 'package:terranova/core/constants/constantes.dart';
import 'package:terranova/core/models/batiment.dart';
import 'package:terranova/core/models/domain.dart';
import 'package:terranova/core/models/personnage.dart';
import 'package:terranova/core/models/ressource.dart';

class BuildingManager {
  const BuildingManager();

  bool _isProducteur(Batiment b) {
    return b.producedResourceId != null && b.producedResourceId!.isNotEmpty;
  }

  String _metierFor(Domain d, Batiment b) {
    final resId = b.producedResourceId;
    if (resId == null || resId.isEmpty) {
      throw ArgumentError('Bâtiment non producteur');
    }
    Ressource? r;
    for (final x in d.ressources) {
      if (x.id == resId) {
        r = x;
        break;
      }
    }
    if (r == null) throw StateError('Ressource produite introuvable');
    if (r.nom == AppStrings.resEau) return AppStrings.funcPuits;
    if (r.nom == AppStrings.resBois) return AppStrings.funcBucheron;
    if (r.nom == AppStrings.resViande) return AppStrings.funcChasse;
    // Par défaut: fonction générique
    return 'Production: ${r.nom}';
  }

  Domain assignerArtisan(Domain d, String artisanId, String batimentId) {
    final bat = d.batiments.firstWhere((b) => b.id == batimentId, orElse: () => throw StateError('Bâtiment introuvable'));
    if (!_isProducteur(bat)) {
      throw ArgumentError('Bâtiment non compatible');
    }

    final updatedPers = d.personnages.map((p) {
      if (p.id != artisanId) return p;
      if (p.type != AppStrings.personnageArtisan) {
        throw ArgumentError('Uniquement Artisans assignables');
      }
      if (p.assignedBatimentId == batimentId) {
        throw StateError('Artisan déjà assigné');
      }
      final np = Personnage(
        id: p.id,
        nom: p.nom,
        fonction: p.fonction,
        sousCategorie: p.sousCategorie,
        niveau: p.niveau,
        type: p.type,
        etat: AppStrings.etatOccupe,
        metier: _metierFor(d, bat),
        assignedBatimentId: batimentId,
        dortoir: p.dortoir,
        pvMax: p.pvMax,
        attaque: p.attaque,
        xpStats: p.xpStats,
      );
      print('[ASSIGN] Artisan ${p.id} -> ${bat.id} (${bat.nom})');
      return np;
    }).toList();

    return Domain(
      id: d.id,
      nom: d.nom,
      nvx: d.nvx,
      personnages: updatedPers,
      batiments: List<Batiment>.from(d.batiments),
      ressources: List.from(d.ressources),
    );
  }

  Domain retirerArtisan(Domain d, String artisanId) {
    final updatedPers = d.personnages.map((p) {
      if (p.id != artisanId) return p;
      if (p.type != AppStrings.personnageArtisan) return p;
      final np = Personnage(
        id: p.id,
        nom: p.nom,
        fonction: p.fonction,
        sousCategorie: p.sousCategorie,
        niveau: p.niveau,
        type: p.type,
        etat: AppStrings.etatInoccupe,
        metier: null,
        assignedBatimentId: null,
        dortoir: p.dortoir,
        pvMax: p.pvMax,
        attaque: p.attaque,
        xpStats: p.xpStats,
      );
      print('[UNASSIGN] Artisan ${p.id}');
      return np;
    }).toList();

    return Domain(
      id: d.id,
      nom: d.nom,
      nvx: d.nvx,
      personnages: updatedPers,
      batiments: List<Batiment>.from(d.batiments),
      ressources: List.from(d.ressources),
    );
  }
}
