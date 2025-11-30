import 'package:terranova/core/constants/xp_config.dart';
import 'package:terranova/core/models/xp/xp_stats.dart';

/// XPManager: logique centrale d'XP (sans effets de gameplay).
/// - addXp: ajoute de l'XP et gère le passage de niveau
/// - checkForLevelUp: indique si le seuil actuel est atteint
/// - getXpForLevel: lit la courbe dans XPConfig
/// Compatible pour: Player (CiteManager.playerXp), Buildings (building.xpStats), Characters (character.xpStats)
class XPManager {
  const XPManager();

  /// XP requis pour atteindre le niveau suivant depuis `level` courant.
  int getXpForLevel(int level) {
    if (level < 1 || level > XPConfig.XP_LEVELS.length) return 0;
    return XPConfig.XP_LEVELS[level - 1];
  }

  /// Ajoute `amount` d'XP et applique les éventuels passages de niveau.
  /// Retourne un nouvel XPStats mis à jour.
  XPStats addXp(XPStats xp, int amount) {
    var cur = xp.currentXp + amount;
    var lvl = xp.level;
    var toNext = xp.xpToNextLevel;

    // Gestion des level-ups en cascade si plusieurs seuils sont franchis
    final maxLevel = XPConfig.XP_LEVELS.length + 1; // Ex: 50 transitions => niveau max 51 théorique
    while (lvl < maxLevel && toNext > 0 && cur >= toNext) {
      cur -= toNext;
      lvl += 1;
      toNext = (lvl <= XPConfig.XP_LEVELS.length) ? getXpForLevel(lvl) : 0;
      // TODO: effets de level-up (bonus, production, etc.) seront gérés ailleurs
    }

    return xp.copyWith(level: lvl, currentXp: cur, xpToNextLevel: toNext);
  }

  /// Indique si, à l'instant T, l'XP courant suffit pour passer au niveau supérieur.
  bool checkForLevelUp(XPStats xp) {
    return xp.xpToNextLevel > 0 && xp.currentXp >= xp.xpToNextLevel;
  }
}
