/// BaseElement: classe de base pour tous les éléments de TerraNova (id, nom, fonction, sous-catégorie).
/// Fournit une méthode toMap() pour la sérialisation simple.

enum SousCategorie { vitale, production, banque, arme }

class BaseElement {
  final String id;
  final String nom;
  final String fonction;
  final SousCategorie sousCategorie;

  const BaseElement({
    required this.id,
    required this.nom,
    required this.fonction,
    required this.sousCategorie,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nom': nom,
      'fonction': fonction,
      'sousCategorie': sousCategorie.name,
    };
  }
}
