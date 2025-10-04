import 'package:flutter/foundation.dart';
import '../core/models/pokemon_type.dart';
import '../core/models/effectiveness.dart';

class TeamMember {
  final String? primaryTypeId;
  final String? secondaryTypeId;
  String? nickname;

  TeamMember({
    this.primaryTypeId,
    this.secondaryTypeId,
    this.nickname,
  });

  List<String> get typeIds {
    final ids = <String>[];
    if (primaryTypeId != null) ids.add(primaryTypeId!);
    if (secondaryTypeId != null) ids.add(secondaryTypeId!);
    return ids;
  }

  bool get isEmpty => primaryTypeId == null;
  bool get isComplete => primaryTypeId != null;
}

class TeamAnalysis {
  final Map<String, int> weaknessCounts;
  final Map<String, int> resistanceCounts;
  final Map<String, int> immunityCounts;
  final List<String> criticalWeaknesses;
  final List<String> coverageGaps;

  TeamAnalysis({
    required this.weaknessCounts,
    required this.resistanceCounts,
    required this.immunityCounts,
    required this.criticalWeaknesses,
    required this.coverageGaps,
  });
}

class TeamBuilderViewModel extends ChangeNotifier {
  final List<TeamMember> team = List.generate(6, (_) => TeamMember());
  
  List<PokemonType> get availableTypes => _allTypes;
  List<PokemonType> _allTypes = [];
  EffectivenessMatrix? _matrix;

  void initialize(List<PokemonType> types, EffectivenessMatrix? matrix) {
    _allTypes = types;
    _matrix = matrix;
    notifyListeners();
  }

  void setMemberType(int index, String? primaryTypeId, String? secondaryTypeId) {
    if (index >= 0 && index < team.length) {
      team[index] = TeamMember(
        primaryTypeId: primaryTypeId,
        secondaryTypeId: secondaryTypeId,
        nickname: team[index].nickname,
      );
      notifyListeners();
    }
  }

  void removeMember(int index) {
    if (index >= 0 && index < team.length) {
      team[index] = TeamMember(nickname: team[index].nickname);
      notifyListeners();
    }
  }

  void clearTeam() {
    for (int i = 0; i < team.length; i++) {
      team[i] = TeamMember();
    }
    notifyListeners();
  }

  int get teamSize => team.where((m) => m.isComplete).length;

  TeamAnalysis analyzeTeam() {
    final weaknesses = <String, int>{};
    final resistances = <String, int>{};
    final immunities = <String, int>{};

    if (_matrix == null) {
      return TeamAnalysis(
        weaknessCounts: {},
        resistanceCounts: {},
        immunityCounts: {},
        criticalWeaknesses: [],
        coverageGaps: [],
      );
    }

    // Analyze each attacking type against each team member
    for (final attackerType in _allTypes) {
      int teamMembersWeakTo = 0;
      int teamMembersResistant = 0;
      int teamMembersImmune = 0;

      for (final member in team) {
        if (!member.isComplete) continue;

        double multiplier = 1.0;
        for (final defenderTypeId in member.typeIds) {
          multiplier *= _matrix!.getMultiplier(attackerType.id, defenderTypeId);
        }

        if (multiplier == 0) {
          teamMembersImmune++;
        } else if (multiplier >= 2.0) {
          teamMembersWeakTo++;
        } else if (multiplier <= 0.5) {
          teamMembersResistant++;
        }
      }

      if (teamMembersWeakTo > 0) {
        weaknesses[attackerType.id] = teamMembersWeakTo;
      }
      if (teamMembersResistant > 0) {
        resistances[attackerType.id] = teamMembersResistant;
      }
      if (teamMembersImmune > 0) {
        immunities[attackerType.id] = teamMembersImmune;
      }
    }

    // Find critical weaknesses (affecting 3+ team members)
    final critical = weaknesses.entries
        .where((e) => e.value >= 3)
        .map((e) => e.key)
        .toList();

    // Find coverage gaps (types that no team member resists or is immune to)
    final coverageGaps = _allTypes
        .map((t) => t.id)
        .where((typeId) =>
            !resistances.containsKey(typeId) && !immunities.containsKey(typeId))
        .toList();

    return TeamAnalysis(
      weaknessCounts: weaknesses,
      resistanceCounts: resistances,
      immunityCounts: immunities,
      criticalWeaknesses: critical,
      coverageGaps: coverageGaps,
    );
  }

  Map<String, double> getMemberDefensiveMultipliers(int index) {
    final member = team[index];
    final result = <String, double>{};
    
    if (!member.isComplete || _matrix == null) return result;

    for (final type in _allTypes) {
      double multiplier = 1.0;
      for (final defenderId in member.typeIds) {
        multiplier *= _matrix!.getMultiplier(type.id, defenderId);
      }
      result[type.id] = multiplier;
    }
    return result;
  }
}
