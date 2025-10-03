class FavoriteCombo {
  final String attackerId;
  final List<String> defenderIds;
  final String? label;

  FavoriteCombo({
    required this.attackerId,
    required this.defenderIds,
    this.label,
  });

  factory FavoriteCombo.fromJson(Map<String, dynamic> json) {
    return FavoriteCombo(
      attackerId: json['attackerId'] as String,
      defenderIds: List<String>.from(json['defenderIds'] as List),
      label: json['label'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'attackerId': attackerId,
      'defenderIds': defenderIds,
      'label': label,
    };
  }
}
