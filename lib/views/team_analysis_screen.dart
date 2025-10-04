import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../viewmodels/team_builder_viewmodel.dart';
import '../viewmodels/type_chart_viewmodel.dart';

class TeamAnalysisScreen extends StatelessWidget {
  const TeamAnalysisScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Team Analysis'),
      ),
      body: Consumer2<TeamBuilderViewModel, TypeChartViewModel>(
        builder: (context, teamVM, typeVM, child) {
          final analysis = teamVM.analyzeTeam();

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Team Overview
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Team Overview',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildOverviewStats(teamVM, analysis),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Critical Weaknesses
              if (analysis.criticalWeaknesses.isNotEmpty) ...[
                _buildSectionHeader(
                  '⚠️ Critical Weaknesses',
                  'Types that 3+ members are weak to',
                  Colors.red,
                ),
                const SizedBox(height: 8),
                _buildTypeList(
                  context,
                  analysis.criticalWeaknesses,
                  analysis.weaknessCounts,
                  typeVM,
                  Colors.red,
                ),
                const SizedBox(height: 16),
              ],

              // All Weaknesses
              if (analysis.weaknessCounts.isNotEmpty) ...[
                _buildSectionHeader(
                  'Weaknesses',
                  'Types the team struggles against',
                  Colors.orange,
                ),
                const SizedBox(height: 8),
                _buildTypeList(
                  context,
                  analysis.weaknessCounts.keys.toList(),
                  analysis.weaknessCounts,
                  typeVM,
                  Colors.orange,
                ),
                const SizedBox(height: 16),
              ],

              // Resistances
              if (analysis.resistanceCounts.isNotEmpty) ...[
                _buildSectionHeader(
                  'Resistances',
                  'Types the team can handle well',
                  Colors.green,
                ),
                const SizedBox(height: 8),
                _buildTypeList(
                  context,
                  analysis.resistanceCounts.keys.toList(),
                  analysis.resistanceCounts,
                  typeVM,
                  Colors.green,
                ),
                const SizedBox(height: 16),
              ],

              // Immunities
              if (analysis.immunityCounts.isNotEmpty) ...[
                _buildSectionHeader(
                  'Immunities',
                  'Types the team is immune to',
                  Colors.grey,
                ),
                const SizedBox(height: 8),
                _buildTypeList(
                  context,
                  analysis.immunityCounts.keys.toList(),
                  analysis.immunityCounts,
                  typeVM,
                  Colors.grey,
                ),
                const SizedBox(height: 16),
              ],

              // Coverage Gaps
              if (analysis.coverageGaps.isNotEmpty) ...[
                _buildSectionHeader(
                  'Coverage Gaps',
                  'Types no member resists',
                  Colors.blue,
                ),
                const SizedBox(height: 8),
                _buildSimpleTypeList(
                  context,
                  analysis.coverageGaps,
                  typeVM,
                ),
              ],
            ],
          );
        },
      ),
    );
  }

  Widget _buildOverviewStats(TeamBuilderViewModel teamVM, TeamAnalysis analysis) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatCard(
              'Members',
              '${teamVM.teamSize}/6',
              Colors.blue,
            ),
            _buildStatCard(
              'Weaknesses',
              '${analysis.weaknessCounts.length}',
              Colors.orange,
            ),
            _buildStatCard(
              'Resistances',
              '${analysis.resistanceCounts.length}',
              Colors.green,
            ),
          ],
        ),
        if (analysis.criticalWeaknesses.isNotEmpty) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.red.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.red),
            ),
            child: Row(
              children: [
                const Icon(Icons.warning, color: Colors.red, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${analysis.criticalWeaknesses.length} critical weakness${analysis.criticalWeaknesses.length == 1 ? '' : 'es'} detected!',
                    style: const TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildStatCard(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title, String subtitle, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildTypeList(
    BuildContext context,
    List<String> typeIds,
    Map<String, int> counts,
    TypeChartViewModel typeVM,
    Color color,
  ) {
    // Sort by count (descending)
    final sortedIds = List<String>.from(typeIds)
      ..sort((a, b) => (counts[b] ?? 0).compareTo(counts[a] ?? 0));

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: sortedIds.map((typeId) {
            final type = typeVM.getTypeById(typeId);
            if (type == null) return const SizedBox.shrink();

            final count = counts[typeId] ?? 0;
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: color),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SvgPicture.asset(
                    'data/images/${type.id}.svg',
                    width: 20,
                    height: 20,
                    colorFilter: ColorFilter.mode(
                      _hexToColor(type.colorHex),
                      BlendMode.srcIn,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    type.name,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '$count',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildSimpleTypeList(
    BuildContext context,
    List<String> typeIds,
    TypeChartViewModel typeVM,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: typeIds.map((typeId) {
            final type = typeVM.getTypeById(typeId);
            if (type == null) return const SizedBox.shrink();

            return Chip(
              avatar: SvgPicture.asset(
                'data/images/${type.id}.svg',
                width: 20,
                height: 20,
                colorFilter: ColorFilter.mode(
                  _hexToColor(type.colorHex),
                  BlendMode.srcIn,
                ),
              ),
              label: Text(type.name),
            );
          }).toList(),
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
