import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../viewmodels/type_chart_viewmodel.dart';
import '../widgets/type_card.dart';
import 'type_details_screen.dart';
import 'settings_screen.dart';
import 'team_builder_screen.dart';
import 'type_coverage_screen.dart';

class TypeChartScreen extends StatelessWidget {
  const TypeChartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('TypeX'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              _showSearchDialog(context);
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Icon(Icons.grid_view, size: 48, color: Colors.white),
                  SizedBox(height: 12),
                  Text(
                    'TypeX',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.grid_view),
              title: const Text('Type Chart'),
              selected: true,
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.group),
              title: const Text('Team Builder'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const TeamBuilderScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.analytics),
              title: const Text('Type Coverage'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const TypeCoverageScreen(),
                  ),
                );
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SettingsScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      body: Consumer<TypeChartViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return Column(
            children: [
              // Instructions banner
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                color: Theme.of(context).colorScheme.primaryContainer,
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 16,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Tap to select attacker • Long press to select defender(s)',
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(
                            context,
                          ).colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    // Calculate optimal columns for responsive design
                    int crossAxisCount = 3;
                    if (constraints.maxWidth > 1200) {
                      crossAxisCount = 9; // Ultra-wide: 2 rows
                    } else if (constraints.maxWidth > 900) {
                      crossAxisCount = 6; // Desktop: 3 rows
                    } else if (constraints.maxWidth > 600) {
                      crossAxisCount = 6; // Tablet landscape: 3 rows
                    } else if (constraints.maxWidth > 400) {
                      crossAxisCount = 3; // Mobile/Tablet portrait: 6 rows
                    } else {
                      crossAxisCount = 2; // Small mobile: 9 rows
                    }

                    return GridView.builder(
                      padding: const EdgeInsets.all(12),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                        childAspectRatio: 1.0,
                      ),
                      itemCount: viewModel.types.length,
                      itemBuilder: (context, index) {
                        final type = viewModel.types[index];
                        final isAttacker =
                            viewModel.selectedAttackerId == type.id;
                        final isDefender = viewModel.selectedDefenderIds
                            .contains(type.id);

                        return TypeCard(
                          type: type,
                          isSelected: isAttacker || isDefender,
                          selectionType: isAttacker
                              ? 'attacker'
                              : (isDefender ? 'defender' : null),
                          onTap: () {
                            viewModel.selectAttacker(type.id);
                          },
                          onLongPress: () {
                            viewModel.toggleDefender(type.id);
                          },
                        );
                      },
                    );
                  },
                ),
              ),
              if (viewModel.selectedAttackerId != null ||
                  viewModel.selectedDefenderIds.isNotEmpty)
                _buildSelectionPanel(context, viewModel),
            ],
          );
        },
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: 'team_builder',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const TeamBuilderScreen(),
                ),
              );
            },
            tooltip: 'Team Builder',
            child: const Icon(Icons.group),
          ),
          const SizedBox(height: 12),
          FloatingActionButton(
            heroTag: 'type_coverage',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const TypeCoverageScreen(),
                ),
              );
            },
            tooltip: 'Type Coverage',
            child: const Icon(Icons.analytics),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectionPanel(
    BuildContext context,
    TypeChartViewModel viewModel,
  ) {
    final attackerType = viewModel.selectedAttackerId != null
        ? viewModel.getTypeById(viewModel.selectedAttackerId!)
        : null;

    final defenderTypes = viewModel.selectedDefenderIds
        .map((id) => viewModel.getTypeById(id))
        .where((type) => type != null)
        .toList();

    final multiplier = viewModel.getMultiplier();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Attacker:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    if (attackerType != null)
                      Chip(
                        avatar: SvgPicture.asset(
                          'data/images/${attackerType.id}.svg',
                          width: 20,
                          height: 20,
                          colorFilter: const ColorFilter.mode(
                            Colors.white,
                            BlendMode.srcIn,
                          ),
                        ),
                        label: Text(attackerType.name),
                      )
                    else
                      const Text('None selected'),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Defender(s):',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    if (defenderTypes.isNotEmpty)
                      Wrap(
                        spacing: 4,
                        children: defenderTypes.map((type) {
                          return Chip(
                            avatar: SvgPicture.asset(
                              'data/images/${type!.id}.svg',
                              width: 20,
                              height: 20,
                              colorFilter: const ColorFilter.mode(
                                Colors.white,
                                BlendMode.srcIn,
                              ),
                            ),
                            label: Text(type.name),
                          );
                        }).toList(),
                      )
                    else
                      const Text('None selected'),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (attackerType != null && defenderTypes.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _getMultiplierColor(multiplier).withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: _getMultiplierColor(multiplier)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Effectiveness: ', style: TextStyle(fontSize: 16)),
                  Text(
                    '×${multiplier.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: _getMultiplierColor(multiplier),
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    if (defenderTypes.isNotEmpty) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TypeDetailsScreen(
                            defenderIds: viewModel.selectedDefenderIds,
                          ),
                        ),
                      );
                    }
                  },
                  child: const Text('View Details'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    viewModel.clearSelection();
                  },
                  child: const Text('Clear'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getMultiplierColor(double multiplier) {
    if (multiplier == 0) return Colors.grey;
    if (multiplier >= 2.0) return Colors.green;
    if (multiplier > 1.0) return Colors.lightGreen;
    if (multiplier == 1.0) return Colors.blue;
    if (multiplier > 0.5) return Colors.orange;
    return Colors.red;
  }

  void _showSearchDialog(BuildContext context) {
    final viewModel = context.read<TypeChartViewModel>();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Search Type'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: viewModel.types.length,
              itemBuilder: (context, index) {
                final type = viewModel.types[index];
                return ListTile(
                  leading: SvgPicture.asset(
                    'data/images/${type.id}.svg',
                    width: 32,
                    height: 32,
                    colorFilter: ColorFilter.mode(
                      _hexToColor(type.colorHex),
                      BlendMode.srcIn,
                    ),
                  ),
                  title: Text(type.name),
                  onTap: () {
                    viewModel.selectAttacker(type.id);
                    Navigator.of(context).pop();
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
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
