class FavoriteCombo {
  final List<String> defenderIds;
  final String? label;

  FavoriteCombo({
    required this.defenderIds,
    this.label,
  });

  factory FavoriteCombo.fromJson(Map<String, dynamic> json) {
    return FavoriteCombo(
      defenderIds: List<String>.from(json['defenderIds'] as List),
      label: json['label'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'defenderIds': defenderIds,
      'label': label,
    };
  }
}
