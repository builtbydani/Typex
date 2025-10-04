import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/pokemon_type.dart';
import '../models/effectiveness.dart';

class LocalDataService {
  Future<List<PokemonType>> loadTypes() async {
    final jsonString = await rootBundle.loadString('data/types.json');
    final List<dynamic> jsonList = jsonDecode(jsonString);
    return jsonList.map((json) => PokemonType.fromJson(json)).toList();
  }

  Future<EffectivenessMatrix> loadEffectiveness() async {
    final jsonString = await rootBundle.loadString('data/effectiveness.json');
    final Map<String, dynamic> jsonMap = jsonDecode(jsonString);
    return EffectivenessMatrix.fromJson(jsonMap);
  }
}
