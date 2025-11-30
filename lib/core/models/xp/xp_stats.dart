class XPStats {
  final int level;
  final int currentXp;
  final int xpToNextLevel;

  const XPStats({
    required this.level,
    required this.currentXp,
    required this.xpToNextLevel,
  });

  XPStats copyWith({
    int? level,
    int? currentXp,
    int? xpToNextLevel,
  }) {
    return XPStats(
      level: level ?? this.level,
      currentXp: currentXp ?? this.currentXp,
      xpToNextLevel: xpToNextLevel ?? this.xpToNextLevel,
    );
  }

  XPStats resetXp() => copyWith(currentXp: 0);

  factory XPStats.fromJson(Map<String, dynamic> json) {
    return XPStats(
      level: json['level'] as int,
      currentXp: json['currentXp'] as int,
      xpToNextLevel: json['xpToNextLevel'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'level': level,
      'currentXp': currentXp,
      'xpToNextLevel': xpToNextLevel,
    };
  }
}
