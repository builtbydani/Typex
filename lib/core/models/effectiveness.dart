class EffectivenessMatrix {
  final Map<String, Map<String, double>> matrix;

  EffectivenessMatrix(this.matrix);

  double getMultiplier(String attacker, String defender) {
    return matrix[attacker]?[defender] ?? 1.0;
  }

  factory EffectivenessMatrix.fromJson(Map<String, dynamic> json) {
    final parsed = <String, Map<String, double>>{};
    json.forEach((att, defs) {
      parsed[att] = {};
      (defs as Map<String, dynamic>).forEach((def, val) {
        parsed[att]![def] = (val as num).toDouble();
      });
    });
    return EffectivenessMatrix(parsed);
  }
}
