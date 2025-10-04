import 'package:flutter/foundation.dart';
import '../core/models/pokemon_type.dart';
import '../core/models/effectiveness.dart';
import '../core/services/local_data_service.dart';

class TypeChartViewModel extends ChangeNotifier {
  final LocalDataService _dataService;
  List<PokemonType> types = [];
  EffectivenessMatrix? matrix;
  bool isLoading = true;

  String? selectedAttackerId;
  List<String> selectedDefenderIds = [];

  TypeChartViewModel(this._dataService);

  Future<void> load() async {
    isLoading = true;
    notifyListeners();

    types = await _dataService.loadTypes();
    matrix = await _dataService.loadEffectiveness();

    isLoading = false;
    notifyListeners();
  }

  void selectAttacker(String typeId) {
    selectedAttackerId = typeId;
    notifyListeners();
  }

  void toggleDefender(String typeId) {
    if (selectedDefenderIds.contains(typeId)) {
      selectedDefenderIds.remove(typeId);
    } else if (selectedDefenderIds.length < 2) {
      selectedDefenderIds.add(typeId);
    }
    notifyListeners();
  }

  void clearSelection() {
    selectedAttackerId = null;
    selectedDefenderIds.clear();
    notifyListeners();
  }

  double getMultiplier() {
    if (selectedAttackerId == null ||
        selectedDefenderIds.isEmpty ||
        matrix == null) {
      return 1.0;
    }

    double result = 1.0;
    for (final defenderId in selectedDefenderIds) {
      result *= matrix!.getMultiplier(selectedAttackerId!, defenderId);
    }
    return result;
  }

  Map<String, double> getDefensiveMultipliers(List<String> defenderIds) {
    final result = <String, double>{};
    if (matrix == null) return result;

    for (final type in types) {
      double multiplier = 1.0;
      for (final defenderId in defenderIds) {
        multiplier *= matrix!.getMultiplier(type.id, defenderId);
      }
      result[type.id] = multiplier;
    }
    return result;
  }

  PokemonType? getTypeById(String id) {
    try {
      return types.firstWhere((t) => t.id == id);
    } catch (e) {
      return null;
    }
  }
}
