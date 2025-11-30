import 'package:flutter/material.dart';
import 'package:terranova/core/managers/domain_manager.dart';
import 'package:terranova/core/models/domain.dart';
import 'tables/personnages_table.dart';
import 'tables/ressources_table.dart';
import 'tables/batiments_table.dart';
import 'create/create_panel.dart';

class DevScreen extends StatefulWidget {
  const DevScreen({super.key});

  @override
  State<DevScreen> createState() => _DevScreenState();
}

class _DevScreenState extends State<DevScreen> with SingleTickerProviderStateMixin {
  final DomainManager _manager = DomainManager();
  Domain? _domain;
  late final TabController _tabController;
  int _refreshTick = 0;

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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Onglet Dev'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Personnages'),
            Tab(text: 'Ressources'),
            Tab(text: 'Bâtiments'),
          ],
        ),
      ),
      body: _domain == null
          ? const Center(child: Text('Aucun domaine chargé'))
          : TabBarView(
              controller: _tabController,
              children: [
                PersonnagesTable(key: ValueKey('pers-$_refreshTick')),
                RessourcesTable(key: ValueKey('res-$_refreshTick')),
                BatimentsTable(key: ValueKey('bat-$_refreshTick')),
              ],
            ),
      floatingActionButton: _domain == null
          ? null
          : FloatingActionButton.extended(
              icon: const Icon(Icons.add),
              label: const Text('Créer un élément'),
              onPressed: () async {
                final created = await showDialog<bool>(
                  context: context,
                  barrierDismissible: true,
                  builder: (_) => const Dialog(child: CreatePanel()),
                );
                if (created == true && mounted) {
                  setState(() { _refreshTick++; });
                }
              },
            ),
    );
  }
}
