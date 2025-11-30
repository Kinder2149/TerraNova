import 'package:flutter/material.dart';
import 'package:terranova/core/managers/domain_manager.dart';
import 'package:terranova/core/models/domain.dart';
import 'package:terranova/core/models/batiment.dart';
import 'package:terranova/core/models/ressource.dart';
import 'dart:convert';
import 'package:terranova/core/constants/constantes.dart';
import 'package:terranova/core/models/base_element.dart';
import 'package:terranova/core/services/production_service.dart';

class BatimentsTable extends StatefulWidget {
  const BatimentsTable({super.key});

  @override
  State<BatimentsTable> createState() => _BatimentsTableState();
}

class _BatimentsTableState extends State<BatimentsTable> {
  final DomainManager _manager = DomainManager();
  final ProductionService _prod = const ProductionService();
  Domain? get _domain => _manager.getDomains().isEmpty ? null : _manager.getDomains().first;
  String _search = '';
  int? _sortColumnIndex;
  bool _sortAscending = true;
  SousCategorie? _catFilter;
  bool? _isProducer; // null=tous, true=producteurs, false=non-producteurs

  Ressource? _resourceFor(Batiment b) {
    final d = _domain;
    if (d == null) return null;
    final id = b.producedResourceId;
    if (id == null) return null;
    for (final r in d.ressources) {
      if (r.id == id) return r;
    }
    return null;
  }

  ({double total, double coefB, double avgA, int artisans}) _boostFor(Batiment b) {
    final d = _domain;
    if (d == null) return (total: 0, coefB: 1, avgA: 1, artisans: 0);
    final assigned = d.personnages
        .where((p) => p.type == AppStrings.personnageArtisan && p.assignedBatimentId == b.id)
        .toList();
    final nb = assigned.length;
    if (nb == 0) return (total: 0, coefB: _prod.coefForBuildingLevel(b.xpStats.level), avgA: 1, artisans: 0);
    final coefB = _prod.coefForBuildingLevel(b.xpStats.level);
    final avgA = assigned
            .map((a) => _prod.coefForArtisanLevel(a.xpStats.level))
            .fold<double>(0.0, (s, v) => s + v) /
        nb;
    final total = coefB * avgA;
    return (total: total, coefB: coefB, avgA: avgA, artisans: nb);
  }

  List<String> _artisansAssignes(Batiment b) {
    final d = _domain;
    if (d == null) return const [];
    return d.personnages
        .where((p) => p.assignedBatimentId == b.id)
        .map((p) => p.nom)
        .toList(growable: false);
  }

  double _previewForBuilding(Batiment b) {
    final d = _domain;
    if (d == null) return 0.0;
    final preview = _manager.computeProductionPreview(d.id);
    return preview.byBuilding[b.id] ?? 0.0;
  }

  Future<void> _addXpToBuilding(Batiment b, int amount) async {
    final d = _domain;
    if (d == null) return;
    await _manager.addXpToBuilding(d.id, b.id, amount);
    setState(() {});
  }

  Future<void> _assignArtisanTo(Batiment b) async {
    final d = _domain;
    if (d == null) return;
    final artisansDispo = d.personnages.where((p) => p.type == AppStrings.personnageArtisan && p.assignedBatimentId == null).toList();
    if (artisansDispo.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Aucun artisan disponible')));
      return;
    }
    final picked = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Assigner un artisan'),
        content: SizedBox(
          width: 360,
          child: ListView(
            shrinkWrap: true,
            children: artisansDispo
                .map((a) => ListTile(
                      title: Text(a.nom),
                      subtitle: Text('Lv ${a.xpStats.level}')
                      ,
                      onTap: () => Navigator.of(ctx).pop(a.id),
                    ))
                .toList(),
          ),
        ),
      ),
    );
    if (picked != null) {
      await _manager.assignerArtisan(d.id, picked, b.id);
      setState(() {});
    }
  }

  Future<void> _detachArtisanFrom(Batiment b) async {
    final d = _domain;
    if (d == null) return;
    final artisans = d.personnages.where((p) => p.assignedBatimentId == b.id).toList();
    if (artisans.isEmpty) return;
    final picked = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Retirer un artisan'),
        content: SizedBox(
          width: 360,
          child: ListView(
            shrinkWrap: true,
            children: artisans
                .map((a) => ListTile(
                      title: Text(a.nom),
                      subtitle: Text('Lv ${a.xpStats.level}')
                      ,
                      onTap: () => Navigator.of(ctx).pop(a.id),
                    ))
                .toList(),
          ),
        ),
      ),
    );
    if (picked != null) {
      await _manager.retirerArtisanDeBatiment(d.id, picked);
      setState(() {});
    }
  }

  void _exportJson(List<Batiment> rows) {
    final data = rows.map((b) => {
          'id': b.id,
          'nom': b.nom,
          'produit': b.producedResourceId,
          'xpLevel': b.xpStats.level,
          'xpCurrent': b.xpStats.currentXp,
          'xpToNext': b.xpStats.xpToNextLevel,
          'categorie': b.sousCategorie.name,
          'fonction': b.fonction,
          'artisansAssignes': _artisansAssignes(b),
        }).toList();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Export JSON — Bâtiments'),
        content: SingleChildScrollView(child: SelectableText(const JsonEncoder.withIndent('  ').convert(data))),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final d = _domain;
    if (d == null) return const Center(child: Text('Aucun domaine'));
    List<Batiment> rows = d.batiments.where((b) {
      final q = _search.trim().toLowerCase();
      final okSearch = q.isEmpty || b.nom.toLowerCase().contains(q) || b.fonction.toLowerCase().contains(q);
      final okCat = _catFilter == null || b.sousCategorie == _catFilter;
      final isProd = b.producedResourceId != null && b.producedResourceId!.isNotEmpty;
      final okProd = _isProducer == null || _isProducer == isProd;
      return okSearch && okCat && okProd;
    }).toList();

    void sortRows(int col, bool asc) {
      int cmp(String a, String b) => asc ? a.compareTo(b) : b.compareTo(a);
      int cmpNum(num a, num b) => asc ? a.compareTo(b) : b.compareTo(a);
      switch (col) {
        case 0:
          rows.sort((a, b) => cmp(a.nom, b.nom));
          break;
        case 1:
          rows.sort((a, b) => cmp(_resourceFor(a)?.nom ?? '', _resourceFor(b)?.nom ?? ''));
          break;
        case 2:
          rows.sort((a, b) => cmpNum(a.xpStats.level, b.xpStats.level));
          break;
        case 5:
          rows.sort((a, b) => cmp(a.sousCategorie.name, b.sousCategorie.name));
          break;
        default:
          break;
      }
    }
    if (_sortColumnIndex != null) sortRows(_sortColumnIndex!, _sortAscending);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: const InputDecoration(prefixIcon: Icon(Icons.search), hintText: 'Rechercher nom/fonction'),
                  onChanged: (v) => setState(() => _search = v),
                ),
              ),
              const SizedBox(width: 8),
              DropdownButton<SousCategorie?>(
                value: _catFilter,
                hint: const Text('Catégorie'),
                items: <SousCategorie?>[null, ...SousCategorie.values]
                    .map((c) => DropdownMenuItem<SousCategorie?>(value: c, child: Text(c?.name ?? 'Toutes')))
                    .toList(),
                onChanged: (v) => setState(() => _catFilter = v),
              ),
              const SizedBox(width: 8),
              DropdownButton<bool?>(
                value: _isProducer,
                hint: const Text('Producteur'),
                items: const <DropdownMenuItem<bool?>>[
                  DropdownMenuItem<bool?>(value: null, child: Text('Tous')),
                  DropdownMenuItem<bool?>(value: true, child: Text('Oui')),
                  DropdownMenuItem<bool?>(value: false, child: Text('Non')),
                ],
                onChanged: (v) => setState(() => _isProducer = v),
              ),
              const SizedBox(width: 8),
              OutlinedButton(onPressed: () => _exportJson(rows), child: const Text('Export JSON')),
            ],
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: DataTable(
              sortColumnIndex: _sortColumnIndex,
              sortAscending: _sortAscending,
              columns: [
                DataColumn(label: const Text('Nom'), onSort: (i, asc) => setState(() { _sortColumnIndex = i; _sortAscending = asc; })),
                DataColumn(label: const Text('Produit'), onSort: (i, asc) => setState(() { _sortColumnIndex = i; _sortAscending = asc; })),
                DataColumn(label: const Text('Niveau XP'), numeric: true, onSort: (i, asc) => setState(() { _sortColumnIndex = i; _sortAscending = asc; })),
                const DataColumn(label: Text('XP actuel'), numeric: true),
                const DataColumn(label: Text('XP suivant'), numeric: true),
                DataColumn(label: const Text('Catégorie'), onSort: (i, asc) => setState(() { _sortColumnIndex = i; _sortAscending = asc; })),
                const DataColumn(label: Text('Fonction')),
                const DataColumn(label: Text('Artisans assignés')),
                const DataColumn(label: Text('Actif')),
                const DataColumn(label: Text('Boost total')),
                const DataColumn(label: Text('Actions')),
              ],
              rows: rows.map((b) {
                final res = _resourceFor(b);
                final artisans = _artisansAssignes(b);
                final preview = _previewForBuilding(b);
                final boost = _boostFor(b);
                return DataRow(cells: [
                  DataCell(Text(b.nom)),
                  DataCell(Text(res?.nom ?? '—')),
                  DataCell(Text('${b.xpStats.level}')),
                  DataCell(Text('${b.xpStats.currentXp}')),
                  DataCell(Text('${b.xpStats.xpToNextLevel}')),
                  DataCell(Text(b.sousCategorie.name)),
                  DataCell(Text(b.fonction)),
                  DataCell(Tooltip(
                    message: 'Prod/tick estimée: ${preview.toStringAsFixed(2)}',
                    child: Text(artisans.isEmpty ? '—' : artisans.join(', ')),
                  )),
                  DataCell(Text(preview > 0 ? 'Oui' : 'Non')),
                  DataCell(Tooltip(
                    message: 'Coef bâtiment: ${boost.coefB.toStringAsFixed(2)}\nMoyenne artisans: ${boost.avgA.toStringAsFixed(2)}\nArtisans: ${boost.artisans}',
                    child: Text(boost.total == 0 ? '—' : 'x${boost.total.toStringAsFixed(2)}'),
                  )),
                  DataCell(Row(children: [
                    TextButton(onPressed: () => _addXpToBuilding(b, 10), child: const Text('+10 XP')),
                    const SizedBox(width: 4),
                    TextButton(onPressed: () => _addXpToBuilding(b, 25), child: const Text('+25 XP')),
                    const SizedBox(width: 4),
                    if (b.producedResourceId != null && b.producedResourceId!.isNotEmpty)
                      TextButton(onPressed: () => _assignArtisanTo(b), child: const Text('Assigner')),
                    if (artisans.isNotEmpty)
                      TextButton(onPressed: () => _detachArtisanFrom(b), child: const Text('Retirer')),
                  ])),
                ]);
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }
}
