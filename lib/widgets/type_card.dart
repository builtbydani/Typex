import 'package:flutter/material.dart';
import '../core/models/pokemon_type.dart';

class TypeCard extends StatelessWidget {
  final PokemonType type;
  final bool isSelected;
  final String? selectionType; // 'attacker' or 'defender'
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  const TypeCard({
    required this.type,
    required this.onTap,
    this.isSelected = false,
    this.selectionType,
    this.onLongPress,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final color = _hexToColor(type.colorHex);

    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Card(
        elevation: isSelected ? 8 : 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: isSelected
              ? BorderSide(
                  color: selectionType == 'attacker'
                      ? Colors.blue
                      : Colors.orange,
                  width: 3,
                )
              : BorderSide.none,
        ),
        color: color.withOpacity(0.8),
        child: Container(
          padding: const EdgeInsets.all(8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(type.emoji, style: const TextStyle(fontSize: 32)),
              const SizedBox(height: 4),
              Text(
                type.name,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              if (isSelected)
                Text(
                  selectionType == 'attacker' ? 'ATK' : 'DEF',
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.white70,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Color _hexToColor(String hexString) {
    try {
      final buffer = StringBuffer();
      if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
      buffer.write(hexString.replaceFirst('#', ''));
      return Color(int.parse(buffer.toString(), radix: 16));
    } catch (e) {
      return Colors.grey;
    }
  }
}
