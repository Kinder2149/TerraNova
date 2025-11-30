import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:terranova/core/managers/domain_manager.dart';
import 'package:terranova/core/models/base_element.dart';
import 'package:terranova/core/models/domain.dart';
import 'package:terranova/core/models/resource/rarity.dart';
import 'package:terranova/core/models/xp/xp_stats.dart';
import 'package:terranova/core/services/creation_service.dart';

class CreatePanel extends StatefulWidget {
  const CreatePanel({super.key});

  @override
  State<CreatePanel> createState() => _CreatePanelState();
}

class _CreatePanelState extends State<CreatePanel> with SingleTickerProviderStateMixin {
  final DomainManager _manager = DomainManager();
  final CreationService _creation = CreationService();
  Domain? _domain;
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    final domains = _manager.getDomains();
    if (domains.isNotEmpty) _domain = domains.first;
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_domain == null) {
      return const SizedBox(width: 460, child: Center(child: Text('Aucun domaine chargé')));
    }
    return SizedBox(
      width: 520,
      height: 640,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const Text('Créer un élément'),
          bottom: TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: 'Personnage'),
              Tab(text: 'Ressource'),
              Tab(text: 'Bâtiment'),
            ],
          ),
          actions: [
            IconButton(
              tooltip: 'Importer batch (assets/dev_init.json)',
              onPressed: _importBatch,
              icon: const Icon(Icons.file_upload),
            ),
          ],
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            _PersonnageForm(domain: _domain!, creation: _creation, onCreated: _onCreated),
            _RessourceForm(domain: _domain!, creation: _creation, onCreated: _onCreated),
            _BatimentForm(domain: _domain!, creation: _creation, onCreated: _onCreated),
          ],
        ),
      ),
    );
  }

  Future<void> _onCreated() async {
    if (!mounted) return;
    Navigator.of(context).pop(true);
  }

  Future<void> _importBatch() async {
    final d = _domain;
    if (d == null) return;
    try {
      final content = await rootBundle.loadString('assets/dev_init.json');
      final jsonData = jsonDecode(content) as Map<String, dynamic>;
      final domainMap = d.toMap();
      final created = CreationService();
      final dm = DomainManager();

      final ressources = (jsonData['ressources'] as List?) ?? const [];
      for (final r in ressources) {
        final res = created.createRessource(Map<String, dynamic>.from(r as Map), domain: domainMap);
        await dm.addRessource(d.id, res);
      }
      final batiments = (jsonData['batiments'] as List?) ?? const [];
      for (final b in batiments) {
        final bat = created.createBatiment(Map<String, dynamic>.from(b as Map), domain: domainMap);
        await dm.addBatiment(d.id, bat);
      }
      final personnages = (jsonData['personnages'] as List?) ?? const [];
      for (final p in personnages) {
        final pers = created.createPersonnage(Map<String, dynamic>.from(p as Map), domain: domainMap);
        await dm.addPersonnage(d.id, pers);
      }

      if (!mounted) return;
      final warns = created.warnings;
      if (warns.isNotEmpty) {
        // Show a brief dialog summarizing warnings
        await showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Avertissements import'),
            content: SizedBox(
              width: 420,
              child: SingleChildScrollView(
                child: Text(warns.join('\n')),
              ),
            ),
            actions: [TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('OK'))],
          ),
        );
      }
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Import batch terminé')));
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      _showError(context, 'Import échoué: $e');
    }
  }
}

class _Field extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final TextInputType? keyboardType;
  const _Field({required this.label, required this.controller, this.keyboardType});
  @override
  Widget build(BuildContext context) {
    return TextField(decoration: InputDecoration(labelText: label), controller: controller, keyboardType: keyboardType);
  }
}

class _EnumDropdown<T> extends StatelessWidget {
  final String label;
  final T? value;
  final List<T> items;
  final String Function(T) display;
  final ValueChanged<T?> onChanged;
  const _EnumDropdown({required this.label, required this.value, required this.items, required this.display, required this.onChanged});
  @override
  Widget build(BuildContext context) {
    return InputDecorator(
      decoration: InputDecoration(labelText: label),
      child: DropdownButton<T>(
        isExpanded: true,
        value: value,
        items: items.map((e) => DropdownMenuItem<T>(value: e, child: Text(display(e)))).toList(),
        onChanged: onChanged,
      ),
    );
  }
}

class _XPFields extends StatelessWidget {
  final TextEditingController level;
  final TextEditingController current;
  final TextEditingController toNext;
  const _XPFields({required this.level, required this.current, required this.toNext});
  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Expanded(child: TextField(decoration: const InputDecoration(labelText: 'XP Level'), controller: level, keyboardType: TextInputType.number)),
      const SizedBox(width: 8),
      Expanded(child: TextField(decoration: const InputDecoration(labelText: 'XP Courant'), controller: current, keyboardType: TextInputType.number)),
      const SizedBox(width: 8),
      Expanded(child: TextField(decoration: const InputDecoration(labelText: 'XP Suivant'), controller: toNext, keyboardType: TextInputType.number)),
    ]);
  }
}

class _Actions extends StatelessWidget {
  final VoidCallback onPrefill;
  final VoidCallback onCreate;
  final VoidCallback onExport;
  final VoidCallback onCopyMap;
  const _Actions({required this.onPrefill, required this.onCreate, required this.onExport, required this.onCopyMap});
  @override
  Widget build(BuildContext context) {
    return Row(children: [
      ElevatedButton(onPressed: onCreate, child: const Text('Créer')),
      const SizedBox(width: 8),
      OutlinedButton(onPressed: onPrefill, child: const Text('Pré-remplir')),
      const SizedBox(width: 8),
      OutlinedButton(onPressed: onExport, child: const Text('Exporter JSON')),
      const SizedBox(width: 8),
      OutlinedButton(onPressed: onCopyMap, child: const Text('Copier Dart map')),
    ]);
  }
}

class _PersonnageForm extends StatefulWidget {
  final Domain domain;
  final CreationService creation;
  final Future<void> Function() onCreated;
  const _PersonnageForm({required this.domain, required this.creation, required this.onCreated});
  @override
  State<_PersonnageForm> createState() => _PersonnageFormState();
}

class _PersonnageFormState extends State<_PersonnageForm> {
  final _nom = TextEditingController();
  final _fonction = TextEditingController();
  SousCategorie _cat = SousCategorie.vitale;
  final _niveau = TextEditingController(text: '1');
  final _type = TextEditingController(text: 'Villageois');
  final _etat = TextEditingController();
  final _metier = TextEditingController();
  String? _assignedBatimentId;
  final _dortoir = TextEditingController();
  final _pvMax = TextEditingController();
  final _attaque = TextEditingController();
  final _xpLevel = TextEditingController(text: '1');
  final _xpCurrent = TextEditingController(text: '0');
  final _xpToNext = TextEditingController(text: '100');

  @override
  void dispose() {
    _nom.dispose();
    _fonction.dispose();
    _niveau.dispose();
    _type.dispose();
    _etat.dispose();
    _metier.dispose();
    _dortoir.dispose();
    _pvMax.dispose();
    _attaque.dispose();
    _xpLevel.dispose();
    _xpCurrent.dispose();
    _xpToNext.dispose();
    super.dispose();
  }

  void _prefill() {
    final s = widget.creation.samplePersonnageInput();
    _nom.text = s['nom'];
    _fonction.text = s['fonction'];
    _cat = SousCategorie.values.firstWhere((e) => e.name == s['sousCategorie']);
    _niveau.text = '${s['niveau']}';
    _type.text = s['type'];
    _etat.text = s['etat'];
    _metier.text = s['metier'] ?? '';
    _assignedBatimentId = s['assignedBatimentId'];
    _dortoir.text = s['dortoir'] ?? '';
    _pvMax.text = '${s['pvMax']}';
    _attaque.text = '${s['attaque']}';
    final xp = s['xpStats'] as Map<String, dynamic>;
    _xpLevel.text = '${xp['level']}';
    _xpCurrent.text = '${xp['currentXp']}';
    _xpToNext.text = '${xp['xpToNextLevel']}';
    setState(() {});
  }

  Future<void> _create() async {
    final d = widget.domain;
    final domainMap = d.toMap();
    final input = {
      'nom': _nom.text,
      'fonction': _fonction.text,
      'sousCategorie': _cat.name,
      'niveau': int.tryParse(_niveau.text) ?? 1,
      'type': _type.text,
      if (_etat.text.isNotEmpty) 'etat': _etat.text,
      if (_metier.text.isNotEmpty) 'metier': _metier.text,
      if (_assignedBatimentId != null && _assignedBatimentId!.isNotEmpty) 'assignedBatimentId': _assignedBatimentId,
      if (_dortoir.text.isNotEmpty) 'dortoir': _dortoir.text,
      if (_pvMax.text.isNotEmpty) 'pvMax': int.tryParse(_pvMax.text),
      if (_attaque.text.isNotEmpty) 'attaque': int.tryParse(_attaque.text),
      'xpStats': {
        'level': int.tryParse(_xpLevel.text) ?? 1,
        'currentXp': int.tryParse(_xpCurrent.text) ?? 0,
        'xpToNextLevel': int.tryParse(_xpToNext.text) ?? 100,
      }
    };
    try {
      final pers = widget.creation.createPersonnage(input, domain: domainMap);
      final warns = widget.creation.warnings;
      await DomainManager().addPersonnage(d.id, pers);
      if (warns.isNotEmpty && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(warns.join(' \u2022 '))));
      }
      await widget.onCreated();
    } catch (e) {
      _showError(context, e.toString());
    }
  }

  void _export() {
    final input = {
      'nom': _nom.text,
      'fonction': _fonction.text,
      'sousCategorie': _cat.name,
      'niveau': int.tryParse(_niveau.text) ?? 1,
      'type': _type.text,
      'etat': _etat.text,
      'metier': _metier.text,
      'assignedBatimentId': _assignedBatimentId,
      'dortoir': _dortoir.text,
      'pvMax': int.tryParse(_pvMax.text),
      'attaque': int.tryParse(_attaque.text),
      'xpStats': {
        'level': int.tryParse(_xpLevel.text) ?? 1,
        'currentXp': int.tryParse(_xpCurrent.text) ?? 0,
        'xpToNextLevel': int.tryParse(_xpToNext.text) ?? 100,
      }
    };
    _showJson(context, input);
  }

  void _copyMap() {
    final map = {
      'nom': _nom.text,
      'fonction': _fonction.text,
      'sousCategorie': _cat.name,
      'niveau': int.tryParse(_niveau.text) ?? 1,
      'type': _type.text,
      if (_etat.text.isNotEmpty) 'etat': _etat.text,
      if (_metier.text.isNotEmpty) 'metier': _metier.text,
      if (_assignedBatimentId != null && _assignedBatimentId!.isNotEmpty) 'assignedBatimentId': _assignedBatimentId,
      if (_dortoir.text.isNotEmpty) 'dortoir': _dortoir.text,
      if (_pvMax.text.isNotEmpty) 'pvMax': int.tryParse(_pvMax.text),
      if (_attaque.text.isNotEmpty) 'attaque': int.tryParse(_attaque.text),
      'xpStats': {
        'level': int.tryParse(_xpLevel.text) ?? 1,
        'currentXp': int.tryParse(_xpCurrent.text) ?? 0,
        'xpToNextLevel': int.tryParse(_xpToNext.text) ?? 100,
      }
    };
    final text = const JsonEncoder.withIndent('  ').convert(map);
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Dart map copiée')));
  }

  @override
  Widget build(BuildContext context) {
    final d = widget.domain;
    final batiments = d.batiments;
    return Padding(
      padding: const EdgeInsets.all(12),
      child: ListView(
        children: [
          _Field(label: 'Nom', controller: _nom),
          _Field(label: 'Fonction', controller: _fonction),
          const SizedBox(height: 8),
          _EnumDropdown<SousCategorie>(
            label: 'Sous-catégorie',
            value: _cat,
            items: SousCategorie.values,
            display: (e) => e.name,
            onChanged: (v) => setState(() => _cat = v ?? _cat),
          ),
          const SizedBox(height: 8),
          Row(children: [
            Expanded(child: _Field(label: 'Niveau', controller: _niveau, keyboardType: TextInputType.number)),
            const SizedBox(width: 8),
            Expanded(child: _Field(label: 'Type', controller: _type)),
          ]),
          const SizedBox(height: 8),
          Row(children: [
            Expanded(child: _Field(label: 'État', controller: _etat)),
            const SizedBox(width: 8),
            Expanded(child: _Field(label: 'Métier', controller: _metier)),
          ]),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: _assignedBatimentId,
            decoration: const InputDecoration(labelText: 'Bâtiment assigné'),
            items: [const DropdownMenuItem<String>(value: null, child: Text('Aucun')),
              ...batiments.map((b) => DropdownMenuItem<String>(value: b.id, child: Text(b.nom)))],
            onChanged: (v) => setState(() => _assignedBatimentId = v),
          ),
          const SizedBox(height: 8),
          Row(children: [
            Expanded(child: _Field(label: 'Dortoir', controller: _dortoir)),
            const SizedBox(width: 8),
            Expanded(child: _Field(label: 'PV Max', controller: _pvMax, keyboardType: TextInputType.number)),
            const SizedBox(width: 8),
            Expanded(child: _Field(label: 'ATK', controller: _attaque, keyboardType: TextInputType.number)),
          ]),
          const SizedBox(height: 8),
          _XPFields(level: _xpLevel, current: _xpCurrent, toNext: _xpToNext),
          const SizedBox(height: 12),
          _Actions(onPrefill: _prefill, onCreate: _create, onExport: _export, onCopyMap: _copyMap),
        ],
      ),
    );
  }
}

class _RessourceForm extends StatefulWidget {
  final Domain domain;
  final CreationService creation;
  final Future<void> Function() onCreated;
  const _RessourceForm({required this.domain, required this.creation, required this.onCreated});
  @override
  State<_RessourceForm> createState() => _RessourceFormState();
}

class _RessourceFormState extends State<_RessourceForm> {
  final _nom = TextEditingController();
  final _fonction = TextEditingController();
  SousCategorie _cat = SousCategorie.production;
  final _description = TextEditingController();
  final _quantite = TextEditingController(text: '0');
  Rarity _rarity = Rarity.abundant;

  @override
  void dispose() {
    _nom.dispose();
    _fonction.dispose();
    _description.dispose();
    _quantite.dispose();
    super.dispose();
  }

  void _prefill() {
    final s = widget.creation.sampleRessourceInput();
    _nom.text = s['nom'];
    _fonction.text = s['fonction'];
    _cat = SousCategorie.values.firstWhere((e) => e.name == s['sousCategorie']);
    _description.text = s['description'];
    _quantite.text = '${s['quantiteStock']}';
    _rarity = Rarity.values.byName(s['rarity']);
    setState(() {});
  }

  Future<void> _create() async {
    final d = widget.domain;
    final domainMap = d.toMap();
    final input = {
      'nom': _nom.text,
      'fonction': _fonction.text,
      'sousCategorie': _cat.name,
      'description': _description.text,
      'quantiteStock': double.tryParse(_quantite.text) ?? 0.0,
      'rarity': _rarity.name,
    };
    try {
      final res = widget.creation.createRessource(input, domain: domainMap);
      final warns = widget.creation.warnings;
      await DomainManager().addRessource(d.id, res);
      if (warns.isNotEmpty && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(warns.join(' \u2022 '))));
      }
      await widget.onCreated();
    } catch (e) {
      _showError(context, e.toString());
    }
  }

  void _export() {
    final input = {
      'nom': _nom.text,
      'fonction': _fonction.text,
      'sousCategorie': _cat.name,
      'description': _description.text,
      'quantiteStock': double.tryParse(_quantite.text) ?? 0.0,
      'rarity': _rarity.name,
    };
    _showJson(context, input);
  }

  void _copyMap() {
    final map = {
      'nom': _nom.text,
      'fonction': _fonction.text,
      'sousCategorie': _cat.name,
      'description': _description.text,
      'quantiteStock': double.tryParse(_quantite.text) ?? 0.0,
      'rarity': _rarity.name,
    };
    final text = const JsonEncoder.withIndent('  ').convert(map);
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Dart map copiée')));
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: ListView(children: [
        _Field(label: 'Nom', controller: _nom),
        _Field(label: 'Fonction', controller: _fonction),
        const SizedBox(height: 8),
        _EnumDropdown<SousCategorie>(label: 'Sous-catégorie', value: _cat, items: SousCategorie.values, display: (e) => e.name, onChanged: (v) => setState(() => _cat = v ?? _cat)),
        const SizedBox(height: 8),
        _Field(label: 'Description', controller: _description),
        Row(children: [
          Expanded(child: _Field(label: 'Quantité', controller: _quantite, keyboardType: TextInputType.number)),
          const SizedBox(width: 8),
          Expanded(
            child: InputDecorator(
              decoration: const InputDecoration(labelText: 'Rareté'),
              child: DropdownButton<Rarity>(
                isExpanded: true,
                value: _rarity,
                items: Rarity.values.map((r) => DropdownMenuItem<Rarity>(value: r, child: Text(r.displayName))).toList(),
                onChanged: (v) => setState(() => _rarity = v ?? _rarity),
              ),
            ),
          ),
        ]),
        const SizedBox(height: 12),
        _Actions(onPrefill: _prefill, onCreate: _create, onExport: _export, onCopyMap: _copyMap),
      ]),
    );
  }
}

class _BatimentForm extends StatefulWidget {
  final Domain domain;
  final CreationService creation;
  final Future<void> Function() onCreated;
  const _BatimentForm({required this.domain, required this.creation, required this.onCreated});
  @override
  State<_BatimentForm> createState() => _BatimentFormState();
}

class _BatimentFormState extends State<_BatimentForm> {
  final _nom = TextEditingController();
  final _fonction = TextEditingController();
  SousCategorie _cat = SousCategorie.production;
  final _description = TextEditingController();
  final _niveau = TextEditingController(text: '1');
  String? _producedResourceId;
  final _xpLevel = TextEditingController(text: '1');
  final _xpCurrent = TextEditingController(text: '0');
  final _xpToNext = TextEditingController(text: '100');

  @override
  void dispose() {
    _nom.dispose();
    _fonction.dispose();
    _description.dispose();
    _niveau.dispose();
    _xpLevel.dispose();
    _xpCurrent.dispose();
    _xpToNext.dispose();
    super.dispose();
  }

  void _prefill() {
    final s = widget.creation.sampleBatimentInput();
    _nom.text = s['nom'];
    _fonction.text = s['fonction'];
    _cat = SousCategorie.values.firstWhere((e) => e.name == s['sousCategorie']);
    _description.text = s['description'];
    _niveau.text = '${s['niveau']}';
    _producedResourceId = s['producedResourceId'];
    final xp = s['xpStats'] as Map<String, dynamic>;
    _xpLevel.text = '${xp['level']}';
    _xpCurrent.text = '${xp['currentXp']}';
    _xpToNext.text = '${xp['xpToNextLevel']}';
    setState(() {});
  }

  Future<void> _create() async {
    final d = widget.domain;
    final domainMap = d.toMap();
    final input = {
      'nom': _nom.text,
      'fonction': _fonction.text,
      'sousCategorie': _cat.name,
      'description': _description.text,
      'niveau': int.tryParse(_niveau.text) ?? 1,
      if (_producedResourceId != null && _producedResourceId!.isNotEmpty) 'producedResourceId': _producedResourceId,
      'xpStats': {
        'level': int.tryParse(_xpLevel.text) ?? 1,
        'currentXp': int.tryParse(_xpCurrent.text) ?? 0,
        'xpToNextLevel': int.tryParse(_xpToNext.text) ?? 100,
      }
    };
    try {
      final bat = widget.creation.createBatiment(input, domain: domainMap);
      final warns = widget.creation.warnings;
      await DomainManager().addBatiment(d.id, bat);
      if (warns.isNotEmpty && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(warns.join(' \u2022 '))));
      }
      await widget.onCreated();
    } catch (e) {
      _showError(context, e.toString());
    }
  }

  void _export() {
    final input = {
      'nom': _nom.text,
      'fonction': _fonction.text,
      'sousCategorie': _cat.name,
      'description': _description.text,
      'niveau': int.tryParse(_niveau.text) ?? 1,
      'producedResourceId': _producedResourceId,
      'xpStats': {
        'level': int.tryParse(_xpLevel.text) ?? 1,
        'currentXp': int.tryParse(_xpCurrent.text) ?? 0,
        'xpToNextLevel': int.tryParse(_xpToNext.text) ?? 100,
      }
    };
    _showJson(context, input);
  }

  void _copyMap() {
    final map = {
      'nom': _nom.text,
      'fonction': _fonction.text,
      'sousCategorie': _cat.name,
      'description': _description.text,
      'niveau': int.tryParse(_niveau.text) ?? 1,
      if (_producedResourceId != null && _producedResourceId!.isNotEmpty) 'producedResourceId': _producedResourceId,
      'xpStats': {
        'level': int.tryParse(_xpLevel.text) ?? 1,
        'currentXp': int.tryParse(_xpCurrent.text) ?? 0,
        'xpToNextLevel': int.tryParse(_xpToNext.text) ?? 100,
      }
    };
    final text = const JsonEncoder.withIndent('  ').convert(map);
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Dart map copiée')));
  }

  @override
  Widget build(BuildContext context) {
    final ressources = widget.domain.ressources;
    return Padding(
      padding: const EdgeInsets.all(12),
      child: ListView(children: [
        _Field(label: 'Nom', controller: _nom),
        _Field(label: 'Fonction', controller: _fonction),
        const SizedBox(height: 8),
        _EnumDropdown<SousCategorie>(label: 'Sous-catégorie', value: _cat, items: SousCategorie.values, display: (e) => e.name, onChanged: (v) => setState(() => _cat = v ?? _cat)),
        const SizedBox(height: 8),
        _Field(label: 'Description', controller: _description),
        Row(children: [
          Expanded(child: _Field(label: 'Niveau', controller: _niveau, keyboardType: TextInputType.number)),
          const SizedBox(width: 8),
          Expanded(
            child: DropdownButtonFormField<String>(
              value: _producedResourceId,
              decoration: const InputDecoration(labelText: 'Ressource produite'),
              items: [const DropdownMenuItem<String>(value: null, child: Text('Aucune')),
                ...ressources.map((r) => DropdownMenuItem<String>(value: r.id, child: Text(r.nom)))],
              onChanged: (v) => setState(() => _producedResourceId = v),
            ),
          ),
        ]),
        const SizedBox(height: 8),
        _XPFields(level: _xpLevel, current: _xpCurrent, toNext: _xpToNext),
        const SizedBox(height: 12),
        _Actions(onPrefill: _prefill, onCreate: _create, onExport: _export, onCopyMap: _copyMap),
      ]),
    );
  }
}

void _showJson(BuildContext context, Map<String, dynamic> input) {
  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text('Export JSON (pré-création)')
      ,
      content: SingleChildScrollView(child: SelectableText(const JsonEncoder.withIndent('  ').convert(input))),
    ),
  );
}

void _showError(BuildContext context, String message) {
  showDialog(
    context: context,
    builder: (_) => AlertDialog(title: const Text('Erreur'), content: Text(message)),
  );
}
