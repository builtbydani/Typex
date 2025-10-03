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
    // TODO: Implement add logic
    favorites.add(combo);
    await _persistenceService.saveFavorites(favorites);
    notifyListeners();
  }

  Future<void> removeFavorite(int index) async {
    // TODO: Implement remove logic
    favorites.removeAt(index);
    await _persistenceService.saveFavorites(favorites);
    notifyListeners();
  }
}
