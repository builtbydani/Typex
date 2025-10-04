import 'package:flutter/foundation.dart';
import '../core/models/favorite_combo.dart';
import '../core/services/persistence_service.dart';

class FavoritesViewModel extends ChangeNotifier {
  final PersistenceService _persistenceService = PersistenceService();
  List<FavoriteCombo> favorites = [];
  bool isLoading = false;

  FavoritesViewModel() {
    load();
  }

  Future<void> load() async {
    isLoading = true;
    notifyListeners();

    favorites = await _persistenceService.loadFavorites();

    isLoading = false;
    notifyListeners();
  }

  Future<void> addFavorite(FavoriteCombo combo) async {
    // Check for duplicates, limit to 20
    if (favorites.any(
      (fav) =>
          fav.attackerId == combo.attackerId &&
          listEquals(fav.defenderIds, combo.defenderIds),
    )) {
      return; // Avoid duplicates
    } else if (favorites.length >= 20) {
      favorites.removeAt(0); // Remove oldest if at limit
    }

    // add to list and save
    favorites.add(combo);
    await _persistenceService.saveFavorites(favorites);
    notifyListeners();
  }

  Future<void> removeFavorite(int index) async {
    // remove from list and save, check bounds
    if (index < 0 || index >= favorites.length) {
      return;
    } else {
      favorites.removeAt(index);
      await _persistenceService.saveFavorites(favorites);
    }
    notifyListeners();
  }
}
