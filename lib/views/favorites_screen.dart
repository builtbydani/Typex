import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/favorites_viewmodel.dart';
import '../viewmodels/type_chart_viewmodel.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Favorites')),
      body: Consumer2<FavoritesViewModel, TypeChartViewModel>(
        builder: (context, favoritesVM, typeChartVM, child) {
          if (favoritesVM.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (favoritesVM.favorites.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.favorite_border, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No favorites yet',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: favoritesVM.favorites.length,
            itemBuilder: (context, index) {
              final combo = favoritesVM.favorites[index];
              final attackerType = typeChartVM.getTypeById(combo.attackerId);
              final defenderTypes = combo.defenderIds
                  .map((id) => typeChartVM.getTypeById(id))
                  .where((type) => type != null)
                  .toList();

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: attackerType != null
                      ? Text(
                          attackerType.emoji,
                          style: const TextStyle(fontSize: 32),
                        )
                      : null,
                  title: Text(combo.label ?? 'Favorite Combo'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (attackerType != null)
                        Text('Attacker: ${attackerType.name}'),
                      if (defenderTypes.isNotEmpty)
                        Text(
                          'Defenders: ${defenderTypes.map((t) => t!.name).join(', ')}',
                        ),
                    ],
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () {
                      favoritesVM.removeFavorite(index);
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
