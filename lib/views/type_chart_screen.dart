import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/type_chart_viewmodel.dart';
import '../widgets/type_card.dart';
import 'type_details_screen.dart';

class TypeChartScreen extends StatelessWidget {
  const TypeChartScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Type Chart'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // TODO: Implement search
            },
          ),
        ],
      ),
      body: Consumer<TypeChartViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return Column(
            children: [
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.0,
                  ),
                  itemCount: viewModel.types.length,
                  itemBuilder: (context, index) {
                    final type = viewModel.types[index];
                    final isAttacker = viewModel.selectedAttackerId == type.id;
                    final isDefender = viewModel.selectedDefenderIds.contains(
                      type.id,
                    );

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
                ),
              ),
              if (viewModel.selectedAttackerId != null ||
                  viewModel.selectedDefenderIds.isNotEmpty)
                _buildSelectionPanel(context, viewModel),
            ],
          );
        },
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
            color: Colors.black.withOpacity(0.1),
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
                        avatar: Text(attackerType.emoji),
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
                            avatar: Text(type!.emoji),
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
                color: _getMultiplierColor(multiplier).withOpacity(0.2),
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
}
