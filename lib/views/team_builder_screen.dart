import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../viewmodels/team_builder_viewmodel.dart';
import '../viewmodels/type_chart_viewmodel.dart';
import '../core/models/pokemon_type.dart';
import 'team_analysis_screen.dart';

class TeamBuilderScreen extends StatefulWidget {
  const TeamBuilderScreen({super.key});

  @override
  State<TeamBuilderScreen> createState() => _TeamBuilderScreenState();
}

class _TeamBuilderScreenState extends State<TeamBuilderScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final typeChartVM = context.read<TypeChartViewModel>();
      final teamBuilderVM = context.read<TeamBuilderViewModel>();
      teamBuilderVM.initialize(typeChartVM.types, typeChartVM.matrix);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Team Builder'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep),
            onPressed: () {
              _showClearConfirmation(context);
            },
          ),
        ],
      ),
      body: Consumer2<TeamBuilderViewModel, TypeChartViewModel>(
        builder: (context, teamVM, typeVM, child) {
          return Column(
            children: [
              // Team size indicator
              Container(
                padding: const EdgeInsets.all(12),
                color: Theme.of(context).colorScheme.primaryContainer,
                child: Row(
                  children: [
                    const Icon(Icons.group, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Team: ${teamVM.teamSize}/6',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    if (teamVM.teamSize > 0)
                      TextButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const TeamAnalysisScreen(),
                            ),
                          );
                        },
                        icon: const Icon(Icons.analytics),
                        label: const Text('Analyze'),
                      ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: 6,
                  itemBuilder: (context, index) {
                    final member = teamVM.team[index];
                    return _buildTeamMemberCard(
                      context,
                      index,
                      member,
                      typeVM,
                      teamVM,
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTeamMemberCard(
    BuildContext context,
    int index,
    TeamMember member,
    TypeChartViewModel typeVM,
    TeamBuilderViewModel teamVM,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Member ${index + 1}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                if (member.isComplete)
                  IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    onPressed: () => teamVM.removeMember(index),
                    tooltip: 'Remove',
                  ),
              ],
            ),
            const SizedBox(height: 12),
            if (member.isComplete) ...[
              Wrap(
                spacing: 8,
                children: [
                  if (member.primaryTypeId != null)
                    _buildTypeChip(
                      context,
                      typeVM.getTypeById(member.primaryTypeId!)!,
                    ),
                  if (member.secondaryTypeId != null)
                    _buildTypeChip(
                      context,
                      typeVM.getTypeById(member.secondaryTypeId!)!,
                    ),
                ],
              ),
              const SizedBox(height: 8),
              _buildQuickStats(context, index, teamVM, typeVM),
            ] else ...[
              ElevatedButton.icon(
                onPressed: () => _showTypeSelector(context, index, teamVM, typeVM),
                icon: const Icon(Icons.add),
                label: const Text('Add Type'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTypeChip(BuildContext context, PokemonType type) {
    return Chip(
      avatar: SvgPicture.asset(
        'data/images/${type.id}.svg',
        width: 24,
        height: 24,
        colorFilter: ColorFilter.mode(
          _hexToColor(type.colorHex),
          BlendMode.srcIn,
        ),
      ),
      label: Text(type.name),
    );
  }

  Widget _buildQuickStats(
    BuildContext context,
    int index,
    TeamBuilderViewModel teamVM,
    TypeChartViewModel typeVM,
  ) {
    final multipliers = teamVM.getMemberDefensiveMultipliers(index);
    final weaknesses = multipliers.entries.where((e) => e.value >= 2.0).length;
    final resistances = multipliers.entries.where((e) => e.value <= 0.5 && e.value > 0).length;
    final immunities = multipliers.entries.where((e) => e.value == 0).length;

    return Row(
      children: [
        _buildStatChip('Weak: $weaknesses', Colors.red),
        const SizedBox(width: 8),
        _buildStatChip('Resist: $resistances', Colors.green),
        const SizedBox(width: 8),
        _buildStatChip('Immune: $immunities', Colors.grey),
      ],
    );
  }

  Widget _buildStatChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 12, color: color),
      ),
    );
  }

  void _showTypeSelector(
    BuildContext context,
    int index,
    TeamBuilderViewModel teamVM,
    TypeChartViewModel typeVM,
  ) {
    String? primaryTypeId;
    String? secondaryTypeId;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Select Types'),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Primary Type:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  initialValue: primaryTypeId,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Select primary type',
                  ),
                  items: typeVM.types.map((type) {
                    return DropdownMenuItem(
                      value: type.id,
                      child: Row(
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
                          const SizedBox(width: 8),
                          Text(type.name),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      primaryTypeId = value;
                      if (secondaryTypeId == value) {
                        secondaryTypeId = null;
                      }
                    });
                  },
                ),
                const SizedBox(height: 16),
                const Text('Secondary Type (Optional):', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  initialValue: secondaryTypeId,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Select secondary type',
                  ),
                  items: [
                    const DropdownMenuItem(
                      value: null,
                      child: Text('None'),
                    ),
                    ...typeVM.types
                        .where((type) => type.id != primaryTypeId)
                        .map((type) {
                      return DropdownMenuItem(
                        value: type.id,
                        child: Row(
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
                            const SizedBox(width: 8),
                            Text(type.name),
                          ],
                        ),
                      );
                    }),
                  ],
                  onChanged: (value) {
                    setState(() => secondaryTypeId = value);
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: primaryTypeId == null
                  ? null
                  : () {
                      teamVM.setMemberType(index, primaryTypeId, secondaryTypeId);
                      Navigator.pop(context);
                    },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  void _showClearConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Team?'),
        content: const Text('This will remove all team members. Continue?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<TeamBuilderViewModel>().clearTeam();
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Clear'),
          ),
        ],
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
