import 'package:flutter/material.dart';
import 'package:terranova/core/constants/constantes.dart';
import 'package:terranova/core/managers/domain_manager.dart';
import 'package:terranova/core/models/base_element.dart';
import 'package:terranova/core/models/batiment.dart';
import 'package:terranova/core/models/domain.dart';
import 'package:terranova/core/models/personnage.dart';
import 'package:terranova/core/models/ressource.dart';
import 'package:terranova/core/services/name_service.dart';
import 'package:terranova/core/constants/xp_config.dart';
import 'package:terranova/core/models/xp/xp_stats.dart';
import 'package:terranova/core/services/loop_manager.dart';
import 'package:terranova/ui/screens/dev/dev_screen.dart';
import 'dart:async';

class MappingScreen extends StatefulWidget {
  const MappingScreen({super.key});

  @override
  State<MappingScreen> createState() => _MappingScreenState();
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppDimens.paddingM, vertical: AppDimens.paddingS),
      child: Text(title, style: Theme.of(context).textTheme.titleSmall),
    );
  }
}

class _MappingScreenState extends State<MappingScreen> {
  final DomainManager _manager = DomainManager();
  final NameService _nameService = NameService();
  bool _loading = true;
  String? _selectedProducerId;
  final List<String> _prodLogs = [];
  bool _autoTickEnabled = false;
  LoopManager? _loop;
  StreamSubscription<LoopTickEvent>? _tickSub;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    await _manager.init();
    // Setup LoopManager on first domain if available
    final domains = _manager.getDomains();
    if (domains.isNotEmpty) {
      _loop = LoopManager(domainManager: _manager, domainId: domains.first.id);
    }
    if (mounted) {
      setState(() {
        _loading = false;
      });
    }
  }

  void _startAutoTick(String domainId, {int intervalMs = 2000}) {
    if (_loop == null) {
      _loop = LoopManager(domainManager: _manager, domainId: domainId);
    }
    _tickSub?.cancel();
    _tickSub = _loop!.onTick.listen((evt) {
      final preview = _manager.computeProductionPreview(domainId);
      if (mounted) {
        setState(() {
          _prodLogs.add('[AutoTick] byBuilding: ' + preview.byBuilding.entries
              .map((e) => '${e.key.substring(0, e.key.length > 6 ? 6 : e.key.length)}=${e.value.toStringAsFixed(2)}')
              .join(', '));
        });
      }
    });
    _loop!.start(intervalMs: intervalMs);
  }

  void _stopAutoTick() {
    _loop?.stop();
    _tickSub?.cancel();
    _tickSub = null;
  }

  @override
  void dispose() {
    _tickSub?.cancel();
    _loop?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final status = _manager.status;
    final domains = _manager.getDomains();

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.mappingTitle),
        actions: [
          IconButton(
            tooltip: 'Ouvrir Onglet Dev',
            icon: const Icon(Icons.table_chart),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const DevScreen()),
              );
            },
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(AppDimens.paddingM),
              children: [
                _InfoTile(title: AppStrings.backendStateLabel, value: status),
                if (domains.isNotEmpty)
                  _InfoTile(
                    title: 'Novas',
                    value: _manager.getNovas(domains.first.id).toStringAsFixed(2),
                  ),
                const SizedBox(height: AppDimens.paddingS),
                Text(AppStrings.domains, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: AppDimens.paddingS),
                if (domains.isEmpty)
                  const _Empty(AppStrings.empty)
                else
                  ...domains.map(_buildDomainTile),
              ],
            ),
    );
  }

  Widget _buildDomainTile(Domain d) {
    final prodPreview = _manager.computeProductionPreview(d.id);

    final villageois = d.personnages.where((p) => p.type == AppStrings.personnageVillageois).toList();
    final artisans = d.personnages.where((p) => p.type == AppStrings.personnageArtisan).toList();
    final artisansDispo = artisans.where((a) => a.assignedBatimentId == null).toList();

    final XPStats _defaultXp = XPStats(level: 1, currentXp: 0, xpToNextLevel: XPConfig.getXpForLevel(1));
    final qg = d.batiments.firstWhere(
      (b) => b.nom == AppStrings.batQG,
      orElse: () => Batiment(
        id: 'none',
        nom: AppStrings.batQG,
        fonction: AppStrings.funcQG,
        sousCategorie: SousCategorie.vitale,
        description: AppStrings.descQG,
        niveau: 1,
        xpStats: _defaultXp,
      ),
    );
    final maison = d.batiments.firstWhere(
      (b) => b.nom == AppStrings.batMaison,
      orElse: () => Batiment(
        id: 'none',
        nom: AppStrings.batMaison,
        fonction: AppStrings.funcMaison,
        sousCategorie: SousCategorie.vitale,
        description: AppStrings.descMaison,
        niveau: 1,
        xpStats: _defaultXp,
      ),
    );

    final qgCap = AppStrings.qgCapVillageoisL1; // niveau 1
    final maisonCap = AppStrings.maisonCapArtisansL1; // niveau 1

    final canCreateVill = villageois.length < qgCap;
    final canCreateArt = artisans.length < maisonCap;

    return Card(
      child: ExpansionTile(
        title: Text('${d.nom}  ${AppStrings.bullet}  ${AppStrings.level}: ${d.nvx}'),
        subtitle: Text('${AppStrings.id}: ${d.id}'),
        children: [
          _SectionTitle(title: 'Production Test'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppDimens.paddingM),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: DropdownButton<String>(
                        isExpanded: true,
                        value: _selectedProducerId,
                        hint: const Text('Sélectionner un bâtiment producteur'),
                        items: d.batiments
                            .where((b) => b.producedResourceId != null && b.producedResourceId!.isNotEmpty)
                            .map((b) => DropdownMenuItem<String>(
                                  value: b.id,
                                  child: Text('${b.nom} (Lv ${b.xpStats.level})'),
                                ))
                            .toList(),
                        onChanged: (val) {
                          setState(() => _selectedProducerId = val);
                        },
                      ),
                    ),
                    const SizedBox(width: AppDimens.gapXS),
                    ElevatedButton(
                      onPressed: () async {
                        final updated = await _manager.applyProductionTick(d.id);
                        final preview = _manager.computeProductionPreview(d.id);
                        setState(() {
                          _prodLogs.add('[Tick] appliqué — byBuilding: '
                              + preview.byBuilding.entries.map((e) => '${e.key.substring(0, e.key.length > 6 ? 6 : e.key.length)}=${e.value.toStringAsFixed(2)}').join(', '));
                        });
                      },
                      child: const Text('Tick Once'),
                    ),
                    const SizedBox(width: AppDimens.gapXS),
                    Row(children: [
                      const Text('Auto'),
                      Switch(
                        value: _autoTickEnabled,
                        onChanged: (val) {
                          setState(() {
                            _autoTickEnabled = val;
                            if (val) {
                              _startAutoTick(d.id);
                            } else {
                              _stopAutoTick();
                            }
                          });
                        },
                      ),
                    ]),
                  ],
                ),
                const SizedBox(height: AppDimens.paddingS),
                if (_selectedProducerId != null)
                  _buildAssignSection(d),
                const SizedBox(height: AppDimens.paddingS),
                Text('Logs', style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: AppDimens.paddingXS),
                if (_prodLogs.isEmpty)
                  const _Empty('Aucun log')
                else
                  ..._prodLogs.reversed.take(5).map((l) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Text(l),
                      )),
              ],
            ),
          ),
          const SizedBox(height: AppDimens.paddingS),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppDimens.paddingM),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () async {
                    final updated = await _manager.applyProductionTick(d.id);
                    setState(() {});
                  },
                  child: const Text('Tick production'),
                ),
              ],
            ),
          ),
          _SectionTitle(title: 'Recrutement'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppDimens.paddingM),
            child: Wrap(
              spacing: AppDimens.gapXS,
              runSpacing: AppDimens.gapXS,
              children: [
                if (d.batiments.any((b) => b.nom == AppStrings.NAME_CASERNE))
                  ElevatedButton(
                    onPressed: () async {
                      final caserne = d.batiments.firstWhere((b) => b.nom == AppStrings.NAME_CASERNE);
                      try {
                        await _manager.recruterSoldat(d.id, caserne.id);
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Soldat recruté (-10 Novas)')));
                        setState(() {});
                      } catch (e) {
                        _showError(context, e.toString());
                      }
                    },
                    child: const Text('Recruter Soldat (10 Novas)'),
                  ),
                if (d.batiments.any((b) => b.nom == AppStrings.NAME_CABANE_EXPLORATEUR))
                  ElevatedButton(
                    onPressed: () async {
                      final cabane = d.batiments.firstWhere((b) => b.nom == AppStrings.NAME_CABANE_EXPLORATEUR);
                      try {
                        await _manager.recruterExplorateur(d.id, cabane.id);
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Explorateur recruté (-8 Novas)')));
                        setState(() {});
                      } catch (e) {
                        _showError(context, e.toString());
                      }
                    },
                    child: const Text('Recruter Explorateur (8 Novas)'),
                  ),
              ],
            ),
          ),
          _SectionTitle(title: 'XP TEST ZONE'),
          _buildXpTestZone(d),
          const SizedBox(height: AppDimens.paddingS),
          _SectionTitle(title: AppStrings.characters.toUpperCase()),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppDimens.paddingM),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(child: Text('${AppStrings.personnageVillageois} (${villageois.length}/$qgCap) — Dortoir: ${AppStrings.batQG}')),
                    ElevatedButton(
                      onPressed: canCreateVill ? () => _createVillageois(d) : null,
                      child: const Text('Créer Villageois'),
                    ),
                  ],
                ),
                const SizedBox(height: AppDimens.paddingXS),
                if (villageois.isEmpty)
                  const _Empty(AppStrings.empty)
                else
                  ...villageois.map((p) => _ItemCard(child: _KeyValueList(entries: [
                        _kv(AppStrings.name, p.nom),
                        _kv(AppStrings.level, p.niveau.toString()),
                        _kv('État', p.etat ?? AppStrings.etatInoccupe),
                        _kv('Dortoir', p.dortoir ?? AppStrings.batQG),
                      ]))),
                const SizedBox(height: AppDimens.paddingS),
                Row(
                  children: [
                    Expanded(child: Text('${AppStrings.personnageArtisan} (${artisans.length}/$maisonCap) — Dortoir: ${AppStrings.batMaison}')),
                    ElevatedButton(
                      onPressed: canCreateArt ? () => _createArtisan(d) : null,
                      child: const Text('Créer Artisan'),
                    ),
                  ],
                ),
                const SizedBox(height: AppDimens.paddingXS),
                if (artisans.isEmpty)
                  const _Empty(AppStrings.empty)
                else
                  ...artisans.map((p) => _ItemCard(child: _KeyValueList(entries: [
                        _kv(AppStrings.name, p.nom),
                        _kv(AppStrings.level, p.niveau.toString()),
                        _kv('Métier', p.metier ?? 'Aucun'),
                        _kv('Dortoir', p.dortoir ?? AppStrings.batMaison),
                        _kv('Assigné à', p.assignedBatimentId ?? 'Aucun'),
                      ]))),
              ],
            ),
          ),
          const SizedBox(height: AppDimens.paddingS),
          _SectionTitle(title: AppStrings.buildings.toUpperCase()),
          _CategorySection<Batiment>(
            title: '',
            items: d.batiments,
            itemBuilder: (b) {
              final nbAssign = d.personnages.where((p) => p.assignedBatimentId == b.id).length;
              final isProducteur = b.nom == AppStrings.batPuits || b.nom == AppStrings.batCabaneBucheron || b.nom == AppStrings.batCabaneChasse;
              final capText = (b.nom == AppStrings.batQG)
                  ? 'Capacité Villageois: $qgCap'
                  : (b.nom == AppStrings.batMaison)
                      ? 'Capacité Artisans: $maisonCap'
                      : null;
              final prodResName = isProducteur
                  ? (b.nom == AppStrings.batPuits
                      ? AppStrings.resEau
                      : (b.nom == AppStrings.batCabaneBucheron ? AppStrings.resBois : AppStrings.resAnimaux))
                  : null;
              final produced = isProducteur ? (prodPreview.byBuilding[b.id] ?? 0) : 0;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _KeyValueList(entries: [
                    _kv(AppStrings.name, b.nom),
                    _kv(AppStrings.level, b.niveau.toString()),
                    _kv(AppStrings.subcategory, _sousCategorieLabel(b.sousCategorie)),
                    _kv(AppStrings.description, b.description),
                    if (capText != null) _kv('Capacité', capText),
                    if (isProducteur) _kv('Production/tick', '${produced.toStringAsFixed(0)} ${prodResName}'),
                    _kv('Artisans affectés', nbAssign.toString()),
                  ]),
                  Row(
                    children: [
                      ElevatedButton(
                        onPressed: isProducteur
                            ? () async {
                                if (artisansDispo.isEmpty) {
                                  _showError(context, 'Aucun artisan disponible');
                                  return;
                                }
                                final selected = await _pickArtisan(context, artisansDispo);
                                if (selected != null) {
                                  await _manager.assignerArtisan(d.id, selected.id, b.id);
                                  setState(() {});
                                }
                              }
                            : null,
                        child: const Text('Affecter Artisan'),
                      ),
                      const SizedBox(width: AppDimens.gapXS),
                      if (nbAssign > 0)
                        ElevatedButton(
                          onPressed: () async {
                            final assigned = d.personnages.where((p) => p.assignedBatimentId == b.id).toList();
                            final selected = await _pickArtisan(context, assigned);
                            if (selected != null) {
                              await _manager.retirerArtisanDeBatiment(d.id, selected.id);
                              setState(() {});
                            }
                          },
                          child: const Text('Retirer Artisan'),
                        ),
                    ],
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: AppDimens.paddingS),
          _SectionTitle(title: AppStrings.resources.toUpperCase()),
          _CategorySection<Ressource>(
            title: '',
            items: d.ressources,
            itemBuilder: (r) {
              final perTick = prodPreview.byResource[r.id] ?? 0;
              return _KeyValueList(entries: [
                _kv(AppStrings.name, r.nom),
                _kv(AppStrings.description, r.description),
                _kv(AppStrings.subcategory, _sousCategorieLabel(r.sousCategorie)),
                _kv(AppStrings.quantity, r.quantiteStock.toStringAsFixed(0)),
                _kv('Production/tick', perTick.toStringAsFixed(0)),
              ]);
            },
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  MapEntry<String, String> _kv(String k, String v) => MapEntry(k, v);

  Widget _buildXpTestZone(Domain d) {
    final XPStats playerXp = d.playerXp ?? XPStats(level: 1, currentXp: 0, xpToNextLevel: XPConfig.getXpForLevel(1));

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppDimens.paddingM),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _KeyValueList(entries: [
            _kv('Niveau joueur', playerXp.level.toString()),
            _kv('XP actuel', playerXp.currentXp.toString()),
            _kv('XP requis', playerXp.xpToNextLevel.toString()),
          ]),
          const SizedBox(height: AppDimens.paddingXS),
          Wrap(
            spacing: AppDimens.gapXS,
            runSpacing: AppDimens.gapXS,
            children: [
              ElevatedButton(
                onPressed: () async {
                  final prev = playerXp.level;
                  final updated = await _manager.addXpToPlayer(d.id, 10);
                  if ((updated.playerXp?.level ?? prev) > prev) {
                    _showLevelUp();
                  }
                  setState(() {});
                },
                child: const Text('+10 XP joueur'),
              ),
              ElevatedButton(
                onPressed: () async {
                  final prev = playerXp.level;
                  final updated = await _manager.addXpToPlayer(d.id, 50);
                  if ((updated.playerXp?.level ?? prev) > prev) {
                    _showLevelUp();
                  }
                  setState(() {});
                },
                child: const Text('+50 XP joueur'),
              ),
              ElevatedButton(
                onPressed: () async {
                  await _manager.addXpToAllBuildings(d.id, 10);
                  setState(() {});
                },
                child: const Text('+10 XP tous bâtiments'),
              ),
              ElevatedButton(
                onPressed: () async {
                  final b = await _pickBuilding(context, d.batiments);
                  if (b != null) {
                    await _manager.addXpToBuilding(d.id, b.id, 25);
                    setState(() {});
                  }
                },
                child: const Text('+25 XP building sélectionné'),
              ),
              ElevatedButton(
                onPressed: () async {
                  await _manager.addXpToAllCharacters(d.id, 50);
                  _showInfo('XP personnages: placeholder');
                  setState(() {});
                },
                child: const Text('+50 XP personnages'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<Batiment?> _pickBuilding(BuildContext context, List<Batiment> batiments) async {
    return showDialog<Batiment>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Sélectionner un bâtiment'),
          content: SizedBox(
            width: 320,
            child: ListView(
              shrinkWrap: true,
              children: batiments
                  .map((b) => ListTile(
                        title: Text(b.nom),
                        subtitle: Text('Niveau ${b.niveau}'),
                        onTap: () => Navigator.of(ctx).pop(b),
                      ))
                  .toList(),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAssignSection(Domain d) {
    final selectedId = _selectedProducerId;
    if (selectedId == null) return const SizedBox.shrink();
    final b = d.batiments.firstWhere((x) => x.id == selectedId, orElse: () => d.batiments.first);
    final artisans = d.personnages.where((p) => p.type == AppStrings.personnageArtisan).toList();
    final available = artisans.where((a) => a.assignedBatimentId == null).toList();
    final assigned = artisans.where((a) => a.assignedBatimentId == b.id).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Bâtiment sélectionné: ${b.nom} (Lv ${b.xpStats.level})'),
        const SizedBox(height: AppDimens.paddingXS),
        Text('Artisans disponibles', style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: AppDimens.paddingXS),
        if (available.isEmpty)
          const _Empty('Aucun artisan disponible')
        else
          ...available.map((a) => Row(
                children: [
                  Expanded(child: Text('${a.nom} (Lv ${a.niveau})')),
                  ElevatedButton(
                    onPressed: () async {
                      await _manager.assignerArtisan(d.id, a.id, b.id);
                      setState(() {});
                    },
                    child: const Text('Affecter'),
                  )
                ],
              )),
        const SizedBox(height: AppDimens.paddingS),
        Text('Artisans affectés', style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: AppDimens.paddingXS),
        if (assigned.isEmpty)
          const _Empty('Aucun artisan affecté')
        else
          ...assigned.map((a) => Row(
                children: [
                  Expanded(child: Text('${a.nom} (Lv ${a.niveau})')),
                  ElevatedButton(
                    onPressed: () async {
                      await _manager.retirerArtisanDeBatiment(d.id, a.id);
                      setState(() {});
                    },
                    child: const Text('Retirer'),
                  )
                ],
              )),
      ],
    );
  }

  void _showLevelUp() {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Niveau +1 !')));
  }

  void _showInfo(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _createVillageois(Domain d) async {
    try {
      final name = _nameService.generateRandomName();
      final xp = XPStats(level: 1, currentXp: 0, xpToNextLevel: XPConfig.getXpForLevel(1));
      final p = Personnage(
        id: 'pers-${DateTime.now().microsecondsSinceEpoch}',
        nom: name,
        fonction: AppStrings.personnageVillageois,
        sousCategorie: SousCategorie.vitale,
        niveau: 1,
        type: AppStrings.personnageVillageois,
        etat: AppStrings.etatInoccupe,
        dortoir: AppStrings.batQG,
        xpStats: xp,
      );
      await _manager.ajouterVillageois(d.id, p);
      setState(() {});
    } catch (e) {
      _showError(context, e.toString().contains(AppStrings.errCapacityExceeded) ? 'Capacité max atteinte' : e.toString());
    }
  }

  Future<void> _createArtisan(Domain d) async {
    try {
      final name = _nameService.generateRandomName();
      final xp = XPStats(level: 1, currentXp: 0, xpToNextLevel: XPConfig.getXpForLevel(1));
      final p = Personnage(
        id: 'pers-${DateTime.now().microsecondsSinceEpoch}',
        nom: name,
        fonction: AppStrings.personnageArtisan,
        sousCategorie: SousCategorie.vitale,
        niveau: 1,
        type: AppStrings.personnageArtisan,
        etat: AppStrings.etatInoccupe,
        dortoir: AppStrings.batMaison,
        xpStats: xp,
      );
      await _manager.ajouterArtisan(d.id, p);
      setState(() {});
    } catch (e) {
      _showError(context, e.toString().contains(AppStrings.errCapacityExceeded) ? 'Capacité max atteinte' : e.toString());
    }
  }

  Future<Personnage?> _pickArtisan(BuildContext context, List<Personnage> artisans) async {
    return showDialog<Personnage>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Sélectionner un artisan'),
          content: SizedBox(
            width: 300,
            child: ListView(
              shrinkWrap: true,
              children: artisans
                  .map((a) => ListTile(
                        title: Text(a.nom),
                        subtitle: Text('Niveau ${a.niveau}'),
                        onTap: () => Navigator.of(ctx).pop(a),
                      ))
                  .toList(),
            ),
          ),
        );
      },
    );
  }

  void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  String _sousCategorieLabel(SousCategorie sc) {
    switch (sc) {
      case SousCategorie.vitale:
        return AppStrings.scVitale;
      case SousCategorie.production:
        return AppStrings.scProduction;
      case SousCategorie.banque:
        return AppStrings.scBanque;
      case SousCategorie.arme:
        return AppStrings.scArme;
    }
  }
}

class _CategorySection<T> extends StatelessWidget {
  final String title;
  final List<T> items;
  final Widget Function(T) itemBuilder;

  const _CategorySection({
    required this.title,
    required this.items,
    required this.itemBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppDimens.paddingM, vertical: AppDimens.paddingS),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: AppDimens.paddingXS),
          if (items.isEmpty)
            const _Empty(AppStrings.empty)
          else
            ...items.map((e) => Padding(
                  padding: const EdgeInsets.only(bottom: AppDimens.paddingS),
                  child: _ItemCard(child: itemBuilder(e)),
                )),
        ],
      ),
    );
  }
}

class _ItemCard extends StatelessWidget {
  final Widget child;
  const _ItemCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(AppDimens.paddingM),
        child: child,
      ),
    );
  }
}

class _KeyValueList extends StatelessWidget {
  final List<MapEntry<String, String>> entries;
  const _KeyValueList({required this.entries});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: entries
          .map((e) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 2.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: AppDimens.labelWidth,
                      child: Text('${e.key}:', style: const TextStyle(fontWeight: FontWeight.w600)),
                    ),
                    const SizedBox(width: AppDimens.gapXS),
                    Expanded(child: Text(e.value)),
                  ],
                ),
              ))
          .toList(),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final String title;
  final String value;
  const _InfoTile({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(title),
        subtitle: Text(value),
        dense: true,
      ),
    );
  }
}

class _Empty extends StatelessWidget {
  final String text;
  const _Empty(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppDimens.paddingXS),
      child: Text(text, style: const TextStyle(fontStyle: FontStyle.italic)),
    );
  }
}
