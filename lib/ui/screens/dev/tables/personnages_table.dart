import 'package:flutter/material.dart';
import 'package:terranova/core/constants/constantes.dart';
import 'package:terranova/core/managers/domain_manager.dart';
import 'package:terranova/core/models/domain.dart';
import 'package:terranova/core/models/personnage.dart';
import 'package:terranova/core/models/batiment.dart';
import 'package:terranova/core/services/production_service.dart';
import 'dart:convert';

class PersonnagesTable extends StatefulWidget {
  const PersonnagesTable({super.key});

  @override
  State<PersonnagesTable> createState() => _PersonnagesTableState();
}

class _PersonnagesTableState extends State<PersonnagesTable> {
  final DomainManager _manager = DomainManager();
  final ProductionService _prod = const ProductionService();
  String _search = '';
  int? _sortColumnIndex;
  bool _sortAscending = true;

  Domain? get _domain => _manager.getDomains().isEmpty ? null : _manager.getDomains().first;

  String _buildingName(String? id) {
    final d = _domain;
    if (d == null || id == null) return '—';
    for (final b in d.batiments) {
      if (b.id == id) return b.nom;
    }
    return '—';
    }

  List<Personnage> _filtered(List<Personnage> input) {
    final q = _search.trim().toLowerCase();
    if (q.isEmpty) return List<Personnage>.from(input);
    return input.where((p) {
      final inName = p.nom.toLowerCase().contains(q);
      final inType = p.type.toLowerCase().contains(q);
      final inMetier = (p.metier ?? '').toLowerCase().contains(q);
      return inName || inType || inMetier;
    }).toList();
  }

  void _sort(List<Personnage> list, int columnIndex, bool ascending) {
    int cmp(String a, String b) => ascending ? a.compareTo(b) : b.compareTo(a);
    int cmpNum(num a, num b) => ascending ? a.compareTo(b) : b.compareTo(a);
    switch (columnIndex) {
      case 0:
        list.sort((a, b) => cmp(a.nom, b.nom));
        break;
      case 1:
        list.sort((a, b) => cmp(a.type, b.type));
        break;
      case 5:
        list.sort((a, b) => cmpNum(a.xpStats.level, b.xpStats.level));
        break;
      default:
        break;
    }
  }

  Future<void> _assign(Personnage p) async {
    final d = _domain;
    if (d == null) return;
    final producers = d.batiments.where((b) => b.producedResourceId != null && b.producedResourceId!.isNotEmpty).toList();
    final picked = await showDialog<Batiment>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Assigner à un bâtiment'),
        content: SizedBox(
          width: 360,
          child: ListView(
            shrinkWrap: true,
            children: producers
                .map((b) => ListTile(
                      title: Text(b.nom),
                      subtitle: Text('Lv ${b.xpStats.level}'),
                      onTap: () => Navigator.of(ctx).pop(b),
                    ))
                .toList(),
          ),
        ),
      ),
    );
    if (picked != null) {
      await _manager.assignerArtisan(d.id, p.id, picked.id);
      setState(() {});
    }
  }

  Future<void> _unassign(Personnage p) async {
    final d = _domain;
    if (d == null) return;
    await _manager.retirerArtisanDeBatiment(d.id, p.id);
    setState(() {});
  }

  Future<void> _addXpAll(int amount) async {
    final d = _domain;
    if (d == null) return;
    await _manager.addXpToAllCharacters(d.id, amount);
    setState(() {});
  }

  void _exportJson(List<Personnage> rows) {
    final data = rows.map((p) => {
          'id': p.id,
          'nom': p.nom,
          'type': p.type,
          'etat': p.etat,
          'metier': p.metier,
          'dortoir': p.dortoir,
          'xpLevel': p.xpStats.level,
          'xpCurrent': p.xpStats.currentXp,
          'xpToNext': p.xpStats.xpToNextLevel,
          'assignedBatiment': p.assignedBatimentId,
          'pvMax': p.pvMax,
          'attaque': p.attaque,
        }).toList();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Export JSON — Personnages'),
        content: SingleChildScrollView(child: SelectableText(const JsonEncoder.withIndent('  ').convert(data))),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final d = _domain;
    if (d == null) return const Center(child: Text('Aucun domaine'));
    final rows = _filtered(d.personnages);
    if (_sortColumnIndex != null) {
      _sort(rows, _sortColumnIndex!, _sortAscending);
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: const InputDecoration(prefixIcon: Icon(Icons.search), hintText: 'Rechercher nom/type/métier'),
                  onChanged: (v) => setState(() => _search = v),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(onPressed: () => _addXpAll(10), child: const Text('+10 XP tous')),
              const SizedBox(width: 8),
              ElevatedButton(onPressed: () => _addXpAll(50), child: const Text('+50 XP tous')),
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
                DataColumn(label: const Text('Type'), onSort: (i, asc) => setState(() { _sortColumnIndex = i; _sortAscending = asc; })),
                const DataColumn(label: Text('État')),
                const DataColumn(label: Text('Métier')),
                const DataColumn(label: Text('Dortoir')),
                DataColumn(label: const Text('Niveau XP'), numeric: true, onSort: (i, asc) => setState(() { _sortColumnIndex = i; _sortAscending = asc; })),
                const DataColumn(label: Text('XP actuel'), numeric: true),
                const DataColumn(label: Text('XP suivant'), numeric: true),
                const DataColumn(label: Text('Assigné à')),
                const DataColumn(label: Text('Bonus prod')), // (coef-1)*100%
                const DataColumn(label: Text('PV'), numeric: true),
                const DataColumn(label: Text('ATK'), numeric: true),
                const DataColumn(label: Text('Actions')),
              ],
              rows: rows.map((p) {
                final assigned = _buildingName(p.assignedBatimentId);
                final coef = _prod.coefForArtisanLevel(p.xpStats.level);
                final bonusPct = ((coef - 1.0) * 100).toStringAsFixed(0);
                return DataRow(cells: [
                  DataCell(Text(p.nom)),
                  DataCell(Text(p.type)),
                  DataCell(Text(p.etat ?? AppStrings.etatInoccupe)),
                  DataCell(Text(p.metier ?? '—')),
                  DataCell(Text(p.dortoir ?? '—')),
                  DataCell(Text('${p.xpStats.level}')),
                  DataCell(Text('${p.xpStats.currentXp}')),
                  DataCell(Text('${p.xpStats.xpToNextLevel}')),
                  DataCell(Text(assigned)),
                  DataCell(Text(p.type == AppStrings.personnageArtisan && p.assignedBatimentId != null ? '+$bonusPct%' : '—')),
                  DataCell(Text(p.pvMax?.toString() ?? '—')),
                  DataCell(Text(p.attaque?.toString() ?? '—')),
                  DataCell(Row(children: [
                    if (p.type == AppStrings.personnageArtisan && p.assignedBatimentId == null)
                      TextButton(onPressed: () => _assign(p), child: const Text('Assigner')),
                    if (p.type == AppStrings.personnageArtisan && p.assignedBatimentId != null)
                      TextButton(onPressed: () => _unassign(p), child: const Text('Retirer')),
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
