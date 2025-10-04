import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../viewmodels/type_chart_viewmodel.dart';
import '../viewmodels/favorites_viewmodel.dart';
import '../core/models/favorite_combo.dart';

class TypeDetailsScreen extends StatelessWidget {
  final List<String> defenderIds;

  const TypeDetailsScreen({required this.defenderIds, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Type Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite_border),
            onPressed: () {
              context.read<FavoritesViewModel>().addFavorite(
                FavoriteCombo(
                  defenderIds: defenderIds,
                ),
              );
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Added to favorites')),
              );
            },
          ),
        ],
      ),
      body: Consumer<TypeChartViewModel>(
        builder: (context, viewModel, child) {
          final defenderTypes = defenderIds
              .map((id) => viewModel.getTypeById(id))
              .where((type) => type != null)
              .toList();

          final multipliers = viewModel.getDefensiveMultipliers(defenderIds);

          // Group by multiplier
          final superEffective = <String>[];
          final notVeryEffective = <String>[];
          final immune = <String>[];
          final normal = <String>[];

          multipliers.forEach((typeId, mult) {
            if (mult == 0) {
              immune.add(typeId);
            } else if (mult >= 2.0) {
              superEffective.add(typeId);
            } else if (mult < 1.0) {
              notVeryEffective.add(typeId);
            } else {
              normal.add(typeId);
            }
          });

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Defending Type',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        children: defenderTypes.map((type) {
                          return Chip(
                            avatar: SvgPicture.asset(
                              'data/images/${type!.id}.svg',
                              width: 24,
                              height: 24,
                              colorFilter: ColorFilter.mode(
                                _hexToColor(type.colorHex),
                                BlendMode.srcIn,
                              ),
                            ),
                            label: Text(
                              type.name,
                              style: const TextStyle(fontSize: 16),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Effectiveness Chart',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              if (immune.isNotEmpty)
                _buildEffectivenessSection(
                  context,
                  'Immune (×0)',
                  immune,
                  Colors.grey,
                  viewModel,
                ),
              if (superEffective.isNotEmpty)
                _buildEffectivenessSection(
                  context,
                  'Weak Against (×2 or more)',
                  superEffective,
                  Colors.red,
                  viewModel,
                ),
              if (notVeryEffective.isNotEmpty)
                _buildEffectivenessSection(
                  context,
                  'Resistant To (×0.5 or less)',
                  notVeryEffective,
                  Colors.green,
                  viewModel,
                ),
              if (normal.isNotEmpty)
                _buildEffectivenessSection(
                  context,
                  'Normal Damage (×1)',
                  normal,
                  Colors.blue,
                  viewModel,
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildEffectivenessSection(
    BuildContext context,
    String title,
    List<String> typeIds,
    Color color,
    TypeChartViewModel viewModel,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: typeIds.map((typeId) {
                final type = viewModel.getTypeById(typeId);
                if (type == null) return const SizedBox.shrink();

                return Chip(
                  avatar: SvgPicture.asset(
                    'data/images/${type.id}.svg',
                    width: 20,
                    height: 20,
                    colorFilter: ColorFilter.mode(
                      color,
                      BlendMode.srcIn,
                    ),
                  ),
                  label: Text(type.name),
                  backgroundColor: color.withValues(alpha: 0.1),
                );
              }).toList(),
            ),
          ],
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
