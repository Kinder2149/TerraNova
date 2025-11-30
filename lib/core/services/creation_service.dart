import 'dart:math';

import 'package:terranova/core/models/base_element.dart';
import 'package:terranova/core/models/personnage.dart';
import 'package:terranova/core/models/ressource.dart';
import 'package:terranova/core/models/batiment.dart';
import 'package:terranova/core/models/xp/xp_stats.dart';
import 'package:terranova/core/models/resource/rarity.dart';

class CreationService {
  List<String> _warnings = const [];
  List<String> get warnings => List.unmodifiable(_warnings);

  void _resetWarnings() => _warnings = [];
  void _warn(String msg) {
    _warnings = List<String>.from(_warnings)..add(msg);
  }

  String generateId(String prefix, String slugBase) {
    final slug = _slugify(slugBase);
    final ts = DateTime.now().millisecondsSinceEpoch.toRadixString(36);
    final rnd = Random().nextInt(1 << 20).toRadixString(36);
    final p = prefix.endsWith('-') ? prefix.substring(0, prefix.length - 1) : prefix;
    return '$p-${slug}-$ts$rnd';
  }

  XPStats defaultsXp() {
    return const XPStats(level: 1, currentXp: 0, xpToNextLevel: 100);
  }

  void ensureUniqueId(Map<String, dynamic> domain, String id) {
    final ids = _collectIds(domain);
    if (ids.contains(id)) {
      throw ArgumentError('id already exists: $id');
    }
  }

  void validateRelations(Map<String, dynamic> domain, Map<String, dynamic> input) {
    final assignedBatimentId = input['assignedBatimentId'] as String?;
    final producedResourceId = input['producedResourceId'] as String?;
    if (assignedBatimentId != null) {
      if (!_existsIn(domain, 'batiments', assignedBatimentId)) {
        throw ArgumentError('assignedBatimentId not found in batiments: $assignedBatimentId');
      }
    }
    if (producedResourceId != null) {
      if (!_existsIn(domain, 'ressources', producedResourceId)) {
        _warn('producedResourceId inexistant: $producedResourceId — le bâtiment sera créé sans production.');
        input.remove('producedResourceId');
      }
    }
  }

  Personnage createPersonnage(Map<String, dynamic> input, {Map<String, dynamic>? domain}) {
    _resetWarnings();
    final id = input['id'] as String? ?? generateId('per', input['nom'] as String? ?? 'personnage');
    _validateIdPrefix(id, allowed: const ['per-']);
    if (domain != null) ensureUniqueId(domain, id);
    if (domain != null) validateRelations(domain, input);
    final sousCat = _readSousCategorieSafe(input['sousCategorie']);
    final xp = input['xpStats'] is XPStats
        ? input['xpStats'] as XPStats
        : (input['xpStats'] is Map<String, dynamic>
            ? _readXpSafe(input['xpStats'] as Map<String, dynamic>)
            : defaultsXp());
    final niveau = _readIntMin1(input['niveau'], field: 'niveau');
    return Personnage(
      id: id,
      nom: input['nom'] as String,
      fonction: input['fonction'] as String? ?? '',
      sousCategorie: sousCat,
      niveau: niveau,
      type: input['type'] as String? ?? 'Villageois',
      etat: input['etat'] as String?,
      metier: input['metier'] as String?,
      assignedBatimentId: input['assignedBatimentId'] as String?,
      dortoir: input['dortoir'] as String?,
      pvMax: (input['pvMax'] as num?)?.toInt(),
      attaque: (input['attaque'] as num?)?.toInt(),
      xpStats: xp,
    );
  }

  Ressource createRessource(Map<String, dynamic> input, {Map<String, dynamic>? domain}) {
    _resetWarnings();
    final id = input['id'] as String? ?? generateId('res', input['nom'] as String? ?? 'ressource');
    _validateIdPrefix(id, allowed: const ['res-']);
    if (domain != null) ensureUniqueId(domain, id);
    final rarityVal = input['rarity'];
    final rarity = _readRaritySafe(rarityVal);
    return Ressource(
      id: id,
      nom: input['nom'] as String,
      fonction: input['fonction'] as String? ?? '',
      sousCategorie: _readSousCategorieSafe(input['sousCategorie']),
      description: input['description'] as String? ?? '',
      quantiteStock: (input['quantiteStock'] as num?)?.toDouble() ?? 0.0,
      rarity: rarity,
    );
  }

  Batiment createBatiment(Map<String, dynamic> input, {Map<String, dynamic>? domain}) {
    _resetWarnings();
    final id = input['id'] as String? ?? generateId('bat', input['nom'] as String? ?? 'batiment');
    _validateIdPrefix(id, allowed: const ['bat-']);
    if (domain != null) ensureUniqueId(domain, id);
    if (domain != null) validateRelations(domain, input);
    final xp = input['xpStats'] is XPStats
        ? input['xpStats'] as XPStats
        : (input['xpStats'] is Map<String, dynamic>
            ? _readXpSafe(input['xpStats'] as Map<String, dynamic>)
            : defaultsXp());
    final niveau = _readIntMin1(input['niveau'], field: 'niveau');
    return Batiment(
      id: id,
      nom: input['nom'] as String,
      fonction: input['fonction'] as String? ?? '',
      sousCategorie: _readSousCategorieSafe(input['sousCategorie']),
      description: input['description'] as String? ?? '',
      niveau: niveau,
      xpStats: xp,
      producedResourceId: input['producedResourceId'] as String?,
    );
  }

  void _validateIdPrefix(String id, {required List<String> allowed}) {
    final ok = allowed.any((p) => id.startsWith(p));
    if (!ok) {
      _warn('ID "$id" n\'utilise pas un préfixe autorisé (${allowed.join(', ')}).');
    }
  }

  SousCategorie _readSousCategorie(dynamic v) {
    if (v is SousCategorie) return v;
    if (v is String) {
      return SousCategorie.values.firstWhere((e) => e.name == v);
    }
    return SousCategorie.production;
  }

  SousCategorie _readSousCategorieSafe(dynamic v) {
    try {
      return _readSousCategorie(v);
    } catch (_) {
      _warn('sousCategorie invalide, valeur par défaut appliquée: production');
      return SousCategorie.production;
    }
  }

  XPStats _readXpSafe(Map<String, dynamic> json) {
    try {
      final level = _readIntMin1(json['level'], field: 'xp.level');
      final curr = _readNonNegativeInt(json['currentXp'], field: 'xp.currentXp');
      final toNext = _readIntMin1(json['xpToNextLevel'], field: 'xp.xpToNextLevel');
      return XPStats(level: level, currentXp: curr, xpToNextLevel: toNext);
    } catch (_) {
      _warn('xpStats invalide, valeurs par défaut appliquées');
      return defaultsXp();
    }
  }

  int _readIntMin1(dynamic v, {required String field}) {
    final n = (v as num?)?.toInt() ?? 1;
    if (n < 1) {
      _warn('$field < 1, corrigé à 1');
      return 1;
    }
    return n;
  }

  int _readNonNegativeInt(dynamic v, {required String field}) {
    final n = (v as num?)?.toInt() ?? 0;
    if (n < 0) {
      _warn('$field < 0, corrigé à 0');
      return 0;
    }
    return n;
  }

  Rarity _readRaritySafe(dynamic rarityVal) {
    try {
      if (rarityVal is Rarity) return rarityVal;
      if (rarityVal is String) return Rarity.values.byName(rarityVal);
      return Rarity.abundant;
    } catch (_) {
      _warn('rarity invalide, valeur par défaut appliquée: abundant');
      return Rarity.abundant;
    }
  }

  Set<String> _collectIds(Map<String, dynamic> domain) {
    final result = <String>{};
    void addAll(dynamic list) {
      if (list is Iterable) {
        for (final e in list) {
          final id = _readId(e);
          if (id != null) result.add(id);
        }
      }
    }

    addAll(domain['personnages']);
    addAll(domain['ressources']);
    addAll(domain['batiments']);
    return result;
  }

  bool _existsId(Map<String, dynamic> domain, String id) {
    return _collectIds(domain).contains(id);
  }

  bool _existsIn(Map<String, dynamic> domain, String collectionKey, String id) {
    final list = domain[collectionKey];
    if (list is Iterable) {
      for (final e in list) {
        final eid = _readId(e);
        if (eid == id) return true;
      }
    }
    return false;
  }

  String? _readId(dynamic e) {
    if (e == null) return null;
    if (e is Map) {
      final v = e['id'];
      return v is String ? v : null;
    }
    try {
      final id = (e as dynamic).id;
      if (id is String) return id;
    } catch (_) {}
    return null;
  }

  String _slugify(String s) {
    final lower = s.toLowerCase();
    final normalized = lower.replaceAll(RegExp(r'[^a-z0-9]+'), '-').replaceAll(RegExp(r'-+'), '-');
    return normalized.trim().replaceAll(RegExp(r'^-|-$'), '');
  }

  Map<String, dynamic> samplePersonnageInput() {
    return {
      'nom': 'Jules',
      'fonction': 'Travailleur',
      'sousCategorie': 'vitale',
      'niveau': 2,
      'type': 'Artisan',
      'etat': 'occupé',
      'assignedBatimentId': 'bat_mine',
      'dortoir': 'Maison A',
      'pvMax': 100,
      'attaque': 5,
      'xpStats': {'level': 2, 'currentXp': 40, 'xpToNextLevel': 120},
    };
  }

  Map<String, dynamic> sampleRessourceInput() {
    return {
      'nom': 'Minerai de fer',
      'fonction': 'Craft',
      'sousCategorie': 'production',
      'description': 'Minerai brut',
      'quantiteStock': 125.0,
      'rarity': 'common',
    };
  }

  Map<String, dynamic> sampleBatimentInput() {
    return {
      'nom': 'Mine',
      'fonction': 'Extraction',
      'sousCategorie': 'production',
      'description': 'Extrait des minerais',
      'niveau': 3,
      'xpStats': {'level': 3, 'currentXp': 120, 'xpToNextLevel': 300},
      'producedResourceId': 'res_fer',
    };
  }

  Map<String, dynamic> sampleDomain() {
    return {
      'ressources': [
        {
          'id': 'res_fer',
          'nom': 'Minerai de fer',
          'fonction': 'Craft',
          'sousCategorie': 'production',
          'description': 'Minerai brut',
          'quantiteStock': 50.0,
          'rarity': 'common'
        }
      ],
      'batiments': [
        {
          'id': 'bat_mine',
          'nom': 'Mine',
          'fonction': 'Extraction',
          'sousCategorie': 'production',
          'description': 'Extrait des minerais',
          'niveau': 1,
          'xpStats': {'level': 1, 'currentXp': 0, 'xpToNextLevel': 100}
        }
      ],
      'personnages': []
    };
  }
}
