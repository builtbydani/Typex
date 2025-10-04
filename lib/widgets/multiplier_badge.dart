import 'package:flutter/material.dart';

class MultiplierBadge extends StatelessWidget {
  final double multiplier;
  final double size;

  const MultiplierBadge({required this.multiplier, this.size = 16, super.key});

  @override
  Widget build(BuildContext context) {
    final color = _getColor();
    final text = _getText();

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: size * 0.5,
        vertical: size * 0.25,
      ),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(size * 0.5),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: Colors.white,
          fontSize: size,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  String _getText() {
    if (multiplier == 0) return 'IMMUNE';
    if (multiplier == 0.25) return '×0.25';
    if (multiplier == 0.5) return '×0.5';
    if (multiplier == 1.0) return '×1';
    if (multiplier == 2.0) return '×2';
    if (multiplier == 4.0) return '×4';
    return '×${multiplier.toStringAsFixed(2)}';
  }

  Color _getColor() {
    if (multiplier == 0) return Colors.grey;
    if (multiplier >= 2.0) return Colors.green;
    if (multiplier > 1.0) return Colors.lightGreen;
    if (multiplier == 1.0) return Colors.blue;
    if (multiplier > 0.5) return Colors.orange;
    return Colors.red;
  }
}
