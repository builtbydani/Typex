class PokemonType {
  final String id;
  final String name;
  final String emoji;
  final String colorHex;

  PokemonType({
    required this.id,
    required this.name,
    this.emoji = '',
    this.colorHex = '#CCCCCC',
  });

  factory PokemonType.fromJson(Map<String, dynamic> json) {
    return PokemonType(
      id: json['id'] as String,
      name: json['name'] as String,
      emoji: json['emoji'] as String? ?? '',
      colorHex: json['color'] as String? ?? '#CCCCCC',
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'emoji': emoji, 'color': colorHex};
  }
}
