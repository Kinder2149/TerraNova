# PROJET_CONTEXTE — TerraNova

> Source de vérité absolue. Lire EN ENTIER avant toute action.
> Toute décision qui contredit ce fichier est interdite.
> Si une demande sort de ce cadre : poser UNE question avant d'agir.

**Version** : 1.0
**Famille** : Perso
**Dernière mise à jour** : 2026-08-06

---

## 1. IDENTITÉ

| Champ | Valeur |
|---|---|
| Nom | TerraNova |
| Famille | Perso |
| Type | Mobile/multi-plateforme (Flutter) |
| Objectif (1 phrase) | Jeu de gestion de colonie : production de ressources, artisans affectés à des bâtiments, montée en niveau (XP), boucle de production par "tick". |
| Statut | En pause depuis le 14/03/2026 — dernière mission (« audit complet et corrections ») close, rien depuis |
| Utilisateurs | Aucun, prototype de jeu en développement |
| Dernière mise à jour | Dernier commit git : "Ajout profil développeur" (14/03/2026) |

---

## 2. STACK TECHNIQUE

**Frontend :** Flutter (SDK ^3.6.2), Dart, Material 3.

**Backend :** Aucun — tout en mémoire (voir `plan.md` : "Etat: tout en mémoire, aucun IO externe").

**Base de données :** Aucune persistance à ce stade (TODO listé : "Persistance locale (migrations pour rarity/producers)").

**Services externes :** Aucun.

---

## 3. ARCHITECTURE

```
TerraNova/
├── lib/
│   ├── core/
│   │   ├── constants/   (constantes.dart, rarity_config.dart, xp_config.dart)
│   │   ├── managers/    (building_manager, domain_manager, population_manager, resource_transform_manager)
│   │   ├── models/      (base_element, batiment, ressource, personnage, domain, resource/rarity, xp/xp_stats)
│   │   ├── services/    (creation_service, data_init_service, loop_manager, name_service, production_service, xp_manager)
│   │   └── utils/
│   └── ui/screens/
│       ├── mapping/mapping_screen.dart
│       └── dev/ (dev_screen, tables/*, create/create_panel)
├── assets/dev_init.json
├── docs/archive/obsolete/personnage_artisan.dart   ← fichier obsolète déjà archivé par une session passée
└── docs/audit_cleanup.txt
```

**Services actifs :** ~28 fichiers `.dart` dans `lib/` — pas de compte de "modules" au sens de la méthode formalisé dans la doc existante (`plan.md`).

---

## 4. FONCTIONNALITÉS

**✅ Stables**
- Centralisation de la production (`ProductionService`)
- Rareté des ressources (`Rarity` + `RarityConfig`)
- Modèles enrichis (rareté, ressource produite, XP, Artisan)
- `LoopManager` (tick manuel/auto)
- UI de test production (`MappingScreen`, `DevScreen`)

**🚧 En cours**
- Aucune — dernière session close le 14/03/2026, rien de rouvert depuis.

**❌ Bugs connus**
- Aucun bug formalisé, mais `plan.md` liste des divergences déjà corrigées lors du dernier audit (préfixes d'IDs mixtes, libellés non centralisés) — à re-vérifier si le code a bougé depuis (il n'a pas bougé, dernier commit = 14/03).

**🔒 Hors scope**
- Persistance locale (pas construite)
- Buffs/effets bonus de production (TODO listé dans `plan.md`)
- Coûts et économie de level-up (`BuildingUpgradeService`, pas construit)

---

## 5. RÈGLES SPÉCIFIQUES AU PROJET

- Source de vérité du code : `lib/core/constants/constantes.dart` (IDs centralisés via `AppIds`, préfixes `pers-`, `bat-`, `res-`).

---

## 6. DÉCISIONS FIGÉES

| Date | Décision | Raison |
|---|---|---|
| | (aucune décision figée formellement actée avant cet audit — voir `plan.md` pour l'historique des corrections) | |

---

## 7. FICHIERS DE DOCUMENTATION

| Fichier | Statut | Note |
|---|---|---|
| PROJET_CONTEXTE.md | ✅ créé le 2026-08-06 | |
| README.md | ❌ boilerplate `flutter create` par défaut, jamais personnalisé | |
| plan.md | Présent — journal d'une mission d'audit (14/03/2026), pas un CHANGELOG standard | |
| INSTALLATION_GUIDE.md | Présent — guide d'installation générique | à évaluer si toujours utile |
| installation_audit.md | Présent — rapport ponctuel `flutter doctor` du 14/03/2026, obsolète (ex: état des licences Android à cette date) | candidat à l'archivage |
| installation_report.json | Présent — même nature que ci-dessus | candidat à l'archivage |
| profil_developpeur_keamder.md | Présent — profil développeur généré automatiquement à partir du projet | hors-sujet pour ce fichier, doublon potentiel avec le profil Kinder global (`~/.claude/projects/V--DEV/memory/user_kinder.md`) |

**⚠️ Dépassement de la règle "5 fichiers .md max"** : le projet en compte déjà 6 avant même ce fichier (README, plan, INSTALLATION_GUIDE, installation_audit, profil_developpeur_keamder) — 7 avec PROJET_CONTEXTE.md.

---

## 8. SESSION EN COURS

**Graphify :** ☐ Absent → à initialiser si le projet reprend
**Objectif de la session :** Audit de reprise (doc uniquement)
**Résultat fin de session :** PROJET_CONTEXTE.md créé, écarts constatés consignés en backlog

---

## 9. BACKLOG

1. **Nettoyage documentaire prioritaire** : `installation_audit.md` et `installation_report.json` sont des rapports ponctuels périmés (état `flutter doctor` du 14/03) — à déplacer en archive ou supprimer pour redescendre sous la limite de 5 fichiers `.md`.
2. `profil_developpeur_keamder.md` fait doublon conceptuel avec le profil Kinder global tenu dans la mémoire Claude Code — à archiver ici, la source de vérité du profil est ailleurs.
3. `README.md` resté au boilerplate Flutter par défaut — à réécrire si le projet reprend.
4. Aucun `CHANGELOG.md` — `plan.md` en tient lieu de façon informelle pour une seule mission ; à formaliser si le projet reprend au-delà de cette mission unique.
5. Aucun `graphify-out/` — à initialiser avant toute reprise de fond (28 fichiers Dart, architecture en couches déjà présente).
6. Reprendre la lecture de la section 10 (TODO) de `plan.md` avant toute nouvelle mission — plusieurs chantiers y sont déjà identifiés (buffs, économie de level-up, persistance, harmonisation Artisan vs Personnage).