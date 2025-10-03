import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/favorite_combo.dart';

class PersistenceService {
  static const String _favoritesKey = 'favorites';

  Future<List<FavoriteCombo>> loadFavorites() async {
    // TODO: Implement actual SharedPreferences loading
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_favoritesKey);
    if (jsonString == null) return [];

    final List<dynamic> jsonList = jsonDecode(jsonString);
    return jsonList.map((json) => FavoriteCombo.fromJson(json)).toList();
  }

  Future<void> saveFavorites(List<FavoriteCombo> favorites) async {
    // TODO: Implement actual SharedPreferences saving
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(favorites.map((f) => f.toJson()).toList());
    await prefs.setString(_favoritesKey, jsonString);
  }
}
