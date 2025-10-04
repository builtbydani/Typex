import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../viewmodels/favorites_viewmodel.dart';
import '../viewmodels/type_chart_viewmodel.dart';
import 'type_details_screen.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

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
                  SizedBox(height: 8),
                  Text(
                    'Save defensive types from the details screen',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                    textAlign: TextAlign.center,
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
              final defenderTypes = combo.defenderIds
                  .map((id) => typeChartVM.getTypeById(id))
                  .where((type) => type != null)
                  .toList();

              if (defenderTypes.isEmpty) return const SizedBox.shrink();

              final firstType = defenderTypes.first!;

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: SvgPicture.asset(
                    'data/images/${firstType.id}.svg',
                    width: 40,
                    height: 40,
                    colorFilter: ColorFilter.mode(
                      _hexToColor(firstType.colorHex),
                      BlendMode.srcIn,
                    ),
                  ),
                  title: Text(
                    defenderTypes.length == 1
                        ? firstType.name
                        : '${firstType.name} / ${defenderTypes[1]!.name}',
                  ),
                  subtitle: Text(
                    combo.label ?? 'Tap to view defensive matchups',
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () {
                      favoritesVM.removeFavorite(index);
                    },
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TypeDetailsScreen(
                          defenderIds: combo.defenderIds,
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
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
