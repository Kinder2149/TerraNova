import 'package:flutter/material.dart';
import 'package:terranova/core/managers/domain_manager.dart';
import 'package:terranova/core/models/domain.dart';
import 'package:terranova/core/models/ressource.dart';
import 'package:terranova/core/models/resource/rarity.dart';
import 'package:terranova/core/models/batiment.dart';
import 'package:terranova/core/constants/rarity_config.dart';
import 'package:terranova/core/constants/constantes.dart';
import 'dart:convert';

class RessourcesTable extends StatefulWidget {
  const RessourcesTable({super.key});

  @override
  State<RessourcesTable> createState() => _RessourcesTableState();
}

class _RessourcesTableState extends State<RessourcesTable> {
  final DomainManager _manager = DomainManager();
  Domain? get _domain => _manager.getDomains().isEmpty ? null : _manager.getDomains().first;
  String _search = '';
  int? _sortColumnIndex;
  bool _sortAscending = true;
  Rarity? _rarityFilter;

  double _previewForResource(String resourceId) {
    final d = _domain;
    if (d == null) return 0;
    final preview = _manager.computeProductionPreview(d.id);
    return preview.byResource[resourceId] ?? 0.0;
  }

  int _artisanCountForResource(String resourceId) {
    final d = _domain;
    if (d == null) return 0;
    final producers = d.batiments.where((b) => b.producedResourceId == resourceId).map((b) => b.id).toSet();
    return d.personnages
        .where((p) => p.type == AppStrings.personnageArtisan && p.assignedBatimentId != null && producers.contains(p.assignedBatimentId))
        .length;
  }

  List<String> _producteurs(Ressource r) {
    final d = _domain;
    if (d == null) return const [];
    return d.batiments
        .where((b) => b.producedResourceId == r.id)
        .map((b) => b.nom)
        .toList(growable: false);
  }

  @override
  Widget build(BuildContext context) {
    final d = _domain;
    if (d == null) return const Center(child: Text('Aucun domaine'));
    List<Ressource> rows = d.ressources.where((r) {
      final okRarity = _rarityFilter == null || r.rarity == _rarityFilter;
      final q = _search.trim().toLowerCase();
      final okSearch = q.isEmpty || r.nom.toLowerCase().contains(q) || r.description.toLowerCase().contains(q);
      return okRarity && okSearch;
    }).toList();

    void sortRows(int col, bool asc) {
      int cmp(String a, String b) => asc ? a.compareTo(b) : b.compareTo(a);
      int cmpNum(num a, num b) => asc ? a.compareTo(b) : b.compareTo(a);
      switch (col) {
        case 0:
          rows.sort((a, b) => cmp(a.nom, b.nom));
          break;
        case 1:
          rows.sort((a, b) => cmp(a.rarity.displayName, b.rarity.displayName));
          break;
        case 2:
          rows.sort((a, b) => cmpNum(a.quantiteStock, b.quantiteStock));
          break;
        default:
          break;
      }
    }
    if (_sortColumnIndex != null) sortRows(_sortColumnIndex!, _sortAscending);

    void exportJson() {
      final data = rows
          .map((r) => {
                'id': r.id,
                'nom': r.nom,
                'rarity': r.rarity.name,
                'quantite': r.quantiteStock,
                'description': r.description,
                'producteurs': _producteurs(r),
              })
          .toList();
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Export JSON — Ressources'),
          content: SingleChildScrollView(child: SelectableText(const JsonEncoder.withIndent('  ').convert(data))),
        ),
      );
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: const InputDecoration(prefixIcon: Icon(Icons.search), hintText: 'Rechercher nom/description'),
                  onChanged: (v) => setState(() => _search = v),
                ),
              ),
              const SizedBox(width: 8),
              DropdownButton<Rarity>(
                value: _rarityFilter,
                hint: const Text('Rareté'),
                items: [null, ...Rarity.values]
                    .map((r) => DropdownMenuItem<Rarity>(
                          value: r,
                          child: Text(r == null ? 'Toutes' : r.displayName),
                        ))
                    .toList(),
                onChanged: (v) => setState(() => _rarityFilter = v),
              ),
              const SizedBox(width: 8),
              OutlinedButton(onPressed: exportJson, child: const Text('Export JSON')),
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
                DataColumn(label: const Text('Rareté'), onSort: (i, asc) => setState(() { _sortColumnIndex = i; _sortAscending = asc; })),
                DataColumn(label: const Text('Quantité'), numeric: true, onSort: (i, asc) => setState(() { _sortColumnIndex = i; _sortAscending = asc; })),
                const DataColumn(label: Text('Description')),
                const DataColumn(label: Text('Producteurs')),
                const DataColumn(label: Text('Actif')), // production > 0
                const DataColumn(label: Text('Artisans')), // nb artisans sur les producteurs
              ],
              rows: rows.map((r) {
                final prod = _producteurs(r);
                final preview = _previewForResource(r.id);
                final rarityCoef = RarityConfig.baseFor(r.rarity);
                final artisans = _artisanCountForResource(r.id);
                return DataRow(cells: [
                  DataCell(Text(r.nom)),
                  DataCell(Text(r.rarity.displayName)),
                  DataCell(Text(r.quantiteStock.toStringAsFixed(2))),
                  DataCell(Text(r.description)),
                  DataCell(Tooltip(
                    message: 'Prod/tick estimée: ${preview.toStringAsFixed(2)}\nBase rareté: ${rarityCoef.toStringAsFixed(2)}',
                    child: Text(prod.isEmpty ? '—' : prod.join(', ')),
                  )),
                  DataCell(Text(preview > 0 ? 'Oui' : 'Non')),
                  DataCell(Text(artisans > 0 ? artisans.toString() : '0')),
                ]);
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }
}
