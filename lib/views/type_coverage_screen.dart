import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../viewmodels/type_chart_viewmodel.dart';
import '../core/models/pokemon_type.dart';

class TypeCoverageScreen extends StatefulWidget {
  const TypeCoverageScreen({super.key});

  @override
  State<TypeCoverageScreen> createState() => _TypeCoverageScreenState();
}

class _TypeCoverageScreenState extends State<TypeCoverageScreen> {
  String _sortBy = 'offensive'; // 'offensive', 'defensive', 'balanced'
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Type Coverage Analysis'),
      ),
      body: Consumer<TypeChartViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final rankings = _calculateTypeRankings(viewModel);

          return Column(
            children: [
              // Sort selector
              Container(
                padding: const EdgeInsets.all(12),
                color: Theme.of(context).colorScheme.primaryContainer,
                child: Row(
                  children: [
                    const Text(
                      'Sort by:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: SegmentedButton<String>(
                        segments: const [
                          ButtonSegment(
                            value: 'offensive',
                            label: Text('Offensive'),
                            icon: Icon(Icons.flash_on, size: 16),
                          ),
                          ButtonSegment(
                            value: 'defensive',
                            label: Text('Defensive'),
                            icon: Icon(Icons.shield, size: 16),
                          ),
                          ButtonSegment(
                            value: 'balanced',
                            label: Text('Balanced'),
                            icon: Icon(Icons.balance, size: 16),
                          ),
                        ],
                        selected: {_sortBy},
                        onSelectionChanged: (Set<String> newSelection) {
                          setState(() {
                            _sortBy = newSelection.first;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: rankings.length,
                  itemBuilder: (context, index) {
                    final ranking = rankings[index];
                    return _buildTypeRankingCard(context, ranking, index + 1, viewModel);
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  List<TypeRanking> _calculateTypeRankings(TypeChartViewModel viewModel) {
    final rankings = <TypeRanking>[];

    for (final type in viewModel.types) {
      final offensive = _calculateOffensiveScore(type.id, viewModel);
      final defensive = _calculateDefensiveScore(type.id, viewModel);
      final balanced = (offensive + defensive) / 2;

      rankings.add(TypeRanking(
        type: type,
        offensiveScore: offensive,
        defensiveScore: defensive,
        balancedScore: balanced,
      ));
    }

    // Sort based on current selection
    switch (_sortBy) {
      case 'offensive':
        rankings.sort((a, b) => b.offensiveScore.compareTo(a.offensiveScore));
        break;
      case 'defensive':
        rankings.sort((a, b) => b.defensiveScore.compareTo(a.defensiveScore));
        break;
      case 'balanced':
        rankings.sort((a, b) => b.balancedScore.compareTo(a.balancedScore));
        break;
    }

    return rankings;
  }

  double _calculateOffensiveScore(String typeId, TypeChartViewModel viewModel) {
    if (viewModel.matrix == null) return 0;

    int superEffective = 0;
    int notEffective = 0;
    int immune = 0;

    for (final defender in viewModel.types) {
      final multiplier = viewModel.matrix!.getMultiplier(typeId, defender.id);
      if (multiplier >= 2.0) {
        superEffective++;
      } else if (multiplier < 1.0) {
        notEffective++;
      }
      if (multiplier == 0) {
        immune++;
      }
    }

    // Score: super effective types are good, not effective/immune are bad
    return superEffective * 2.0 - notEffective - immune * 2.0;
  }

  double _calculateDefensiveScore(String typeId, TypeChartViewModel viewModel) {
    if (viewModel.matrix == null) return 0;

    int resistant = 0;
    int weak = 0;
    int immune = 0;

    for (final attacker in viewModel.types) {
      final multiplier = viewModel.matrix!.getMultiplier(attacker.id, typeId);
      if (multiplier >= 2.0) {
        weak++;
      } else if (multiplier < 1.0) {
        resistant++;
      }
      if (multiplier == 0) {
        immune++;
      }
    }

    // Score: resistances and immunities are good, weaknesses are bad
    return resistant + immune * 2.0 - weak * 2.0;
  }

  Widget _buildTypeRankingCard(
    BuildContext context,
    TypeRanking ranking,
    int rank,
    TypeChartViewModel viewModel,
  ) {
    final type = ranking.type;
    final score = _sortBy == 'offensive'
        ? ranking.offensiveScore
        : _sortBy == 'defensive'
            ? ranking.defensiveScore
            : ranking.balancedScore;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _showTypeDetails(context, ranking, viewModel),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Rank
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _getRankColor(rank).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: _getRankColor(rank)),
                ),
                child: Center(
                  child: Text(
                    '$rank',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: _getRankColor(rank),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Type icon and name
              SvgPicture.asset(
                'data/images/${type.id}.svg',
                width: 32,
                height: 32,
                colorFilter: ColorFilter.mode(
                  _hexToColor(type.colorHex),
                  BlendMode.srcIn,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      type.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Score: ${score.toStringAsFixed(1)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              // Arrow
              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  void _showTypeDetails(
    BuildContext context,
    TypeRanking ranking,
    TypeChartViewModel viewModel,
  ) {
    if (viewModel.matrix == null) return;

    final type = ranking.type;
    final offensiveDetails = _getOffensiveDetails(type.id, viewModel);
    final defensiveDetails = _getDefensiveDetails(type.id, viewModel);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => Container(
          padding: const EdgeInsets.all(16),
          child: ListView(
            controller: scrollController,
            children: [
              // Header
              Row(
                children: [
                  SvgPicture.asset(
                    'data/images/${type.id}.svg',
                    width: 48,
                    height: 48,
                    colorFilter: ColorFilter.mode(
                      _hexToColor(type.colorHex),
                      BlendMode.srcIn,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          type.name,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Type Coverage Details',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Scores
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildScoreColumn(
                    'Offensive',
                    ranking.offensiveScore,
                    Icons.flash_on,
                    Colors.orange,
                  ),
                  _buildScoreColumn(
                    'Defensive',
                    ranking.defensiveScore,
                    Icons.shield,
                    Colors.blue,
                  ),
                  _buildScoreColumn(
                    'Balanced',
                    ranking.balancedScore,
                    Icons.balance,
                    Colors.purple,
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Offensive Details
              const Text(
                'Offensive Coverage',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              if (offensiveDetails['superEffective']!.isNotEmpty) ...[
                _buildDetailSection(
                  'Super Effective Against',
                  offensiveDetails['superEffective']!,
                  Colors.green,
                  viewModel,
                ),
                const SizedBox(height: 8),
              ],
              if (offensiveDetails['notEffective']!.isNotEmpty) ...[
                _buildDetailSection(
                  'Not Very Effective Against',
                  offensiveDetails['notEffective']!,
                  Colors.orange,
                  viewModel,
                ),
                const SizedBox(height: 8),
              ],
              if (offensiveDetails['noEffect']!.isNotEmpty) ...[
                _buildDetailSection(
                  'No Effect Against',
                  offensiveDetails['noEffect']!,
                  Colors.grey,
                  viewModel,
                ),
                const SizedBox(height: 16),
              ],

              // Defensive Details
              const Text(
                'Defensive Coverage',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              if (defensiveDetails['resistant']!.isNotEmpty) ...[
                _buildDetailSection(
                  'Resistant To',
                  defensiveDetails['resistant']!,
                  Colors.green,
                  viewModel,
                ),
                const SizedBox(height: 8),
              ],
              if (defensiveDetails['weak']!.isNotEmpty) ...[
                _buildDetailSection(
                  'Weak To',
                  defensiveDetails['weak']!,
                  Colors.red,
                  viewModel,
                ),
                const SizedBox(height: 8),
              ],
              if (defensiveDetails['immune']!.isNotEmpty) ...[
                _buildDetailSection(
                  'Immune To',
                  defensiveDetails['immune']!,
                  Colors.grey,
                  viewModel,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Map<String, List<String>> _getOffensiveDetails(
    String typeId,
    TypeChartViewModel viewModel,
  ) {
    final superEffective = <String>[];
    final notEffective = <String>[];
    final noEffect = <String>[];

    for (final type in viewModel.types) {
      final multiplier = viewModel.matrix!.getMultiplier(typeId, type.id);
      if (multiplier >= 2.0) {
        superEffective.add(type.id);
      } else if (multiplier == 0) {
        noEffect.add(type.id);
      } else if (multiplier < 1.0) {
        notEffective.add(type.id);
      }
    }

    return {
      'superEffective': superEffective,
      'notEffective': notEffective,
      'noEffect': noEffect,
    };
  }

  Map<String, List<String>> _getDefensiveDetails(
    String typeId,
    TypeChartViewModel viewModel,
  ) {
    final weak = <String>[];
    final resistant = <String>[];
    final immune = <String>[];

    for (final type in viewModel.types) {
      final multiplier = viewModel.matrix!.getMultiplier(type.id, typeId);
      if (multiplier >= 2.0) {
        weak.add(type.id);
      } else if (multiplier == 0) {
        immune.add(type.id);
      } else if (multiplier < 1.0) {
        resistant.add(type.id);
      }
    }

    return {
      'weak': weak,
      'resistant': resistant,
      'immune': immune,
    };
  }

  Widget _buildScoreColumn(String label, double score, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 32),
        const SizedBox(height: 4),
        Text(
          score.toStringAsFixed(1),
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildDetailSection(
    String title,
    List<String> typeIds,
    Color color,
    TypeChartViewModel viewModel,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$title (${typeIds.length})',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: typeIds.map((typeId) {
            final type = viewModel.getTypeById(typeId);
            if (type == null) return const SizedBox.shrink();
            return Chip(
              avatar: SvgPicture.asset(
                'data/images/${type.id}.svg',
                width: 18,
                height: 18,
                colorFilter: ColorFilter.mode(
                  _hexToColor(type.colorHex),
                  BlendMode.srcIn,
                ),
              ),
              label: Text(type.name, style: const TextStyle(fontSize: 12)),
              visualDensity: VisualDensity.compact,
            );
          }).toList(),
        ),
      ],
    );
  }

  Color _getRankColor(int rank) {
    if (rank <= 3) return Colors.amber;
    if (rank <= 6) return Colors.grey;
    return Colors.brown;
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

class TypeRanking {
  final PokemonType type;
  final double offensiveScore;
  final double defensiveScore;
  final double balancedScore;

  TypeRanking({
    required this.type,
    required this.offensiveScore,
    required this.defensiveScore,
    required this.balancedScore,
  });
}
