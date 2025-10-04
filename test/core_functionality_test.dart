import 'package:flutter_test/flutter_test.dart';
import 'package:typex/core/models/effectiveness.dart';
import 'package:typex/core/models/pokemon_type.dart';
import 'package:typex/core/services/local_data_service.dart';
import 'package:typex/viewmodels/type_chart_viewmodel.dart';

void main() {
  // Initialize the binding for all tests
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Core Functionality Tests', () {
    late TypeChartViewModel viewModel;
    late LocalDataService dataService;

    setUp(() async {
      dataService = LocalDataService();
      viewModel = TypeChartViewModel(dataService);
      await viewModel.load();
    });

    test('All 18 Pokémon types are loaded', () {
      expect(viewModel.types.length, 18);
    });

    test('Types have proper structure with emoji and color', () {
      for (var type in viewModel.types) {
        expect(type.id, isNotEmpty);
        expect(type.name, isNotEmpty);
        expect(type.emoji, isNotEmpty);
        expect(type.colorHex, isNotEmpty);
      }
    });

    test('Fire is super effective against Grass (×2)', () {
      final fireId = viewModel.types.firstWhere((t) => t.name == 'Fire').id;
      final grassId = viewModel.types.firstWhere((t) => t.name == 'Grass').id;
      
      viewModel.selectAttacker(fireId);
      viewModel.toggleDefender(grassId);
      
      final multiplier = viewModel.getMultiplier();
      expect(multiplier, 2.0);
    });

    test('Water is super effective against Fire (×2)', () {
      final waterId = viewModel.types.firstWhere((t) => t.name == 'Water').id;
      final fireId = viewModel.types.firstWhere((t) => t.name == 'Fire').id;
      
      viewModel.selectAttacker(waterId);
      viewModel.toggleDefender(fireId);
      
      final multiplier = viewModel.getMultiplier();
      expect(multiplier, 2.0);
    });

    test('Electric is not effective against Ground (×0)', () {
      final electricId = viewModel.types.firstWhere((t) => t.name == 'Electric').id;
      final groundId = viewModel.types.firstWhere((t) => t.name == 'Ground').id;
      
      viewModel.selectAttacker(electricId);
      viewModel.toggleDefender(groundId);
      
      final multiplier = viewModel.getMultiplier();
      expect(multiplier, 0.0);
    });

    test('Normal is not very effective against Rock (×0.5)', () {
      final normalId = viewModel.types.firstWhere((t) => t.name == 'Normal').id;
      final rockId = viewModel.types.firstWhere((t) => t.name == 'Rock').id;
      
      viewModel.selectAttacker(normalId);
      viewModel.toggleDefender(rockId);
      
      final multiplier = viewModel.getMultiplier();
      expect(multiplier, 0.5);
    });

    test('Dual type defense calculations work correctly', () {
      // Fire/Flying (like Charizard) takes ×4 from Rock
      final rockId = viewModel.types.firstWhere((t) => t.name == 'Rock').id;
      final fireId = viewModel.types.firstWhere((t) => t.name == 'Fire').id;
      final flyingId = viewModel.types.firstWhere((t) => t.name == 'Flying').id;
      
      viewModel.selectAttacker(rockId);
      viewModel.toggleDefender(fireId);
      viewModel.toggleDefender(flyingId);
      
      final multiplier = viewModel.getMultiplier();
      expect(multiplier, 4.0); // 2.0 × 2.0 = 4.0
    });

    test('Selection can be cleared', () {
      final fireId = viewModel.types.firstWhere((t) => t.name == 'Fire').id;
      final grassId = viewModel.types.firstWhere((t) => t.name == 'Grass').id;
      
      viewModel.selectAttacker(fireId);
      viewModel.toggleDefender(grassId);
      
      expect(viewModel.selectedAttackerId, isNotNull);
      expect(viewModel.selectedDefenderIds, isNotEmpty);
      
      viewModel.clearSelection();
      
      expect(viewModel.selectedAttackerId, isNull);
      expect(viewModel.selectedDefenderIds, isEmpty);
    });

    test('Defender toggle works correctly (max 2 defenders)', () {
      final fireId = viewModel.types.firstWhere((t) => t.name == 'Fire').id;
      final grassId = viewModel.types.firstWhere((t) => t.name == 'Grass').id;
      final waterid = viewModel.types.firstWhere((t) => t.name == 'Water').id;
      
      viewModel.toggleDefender(fireId);
      expect(viewModel.selectedDefenderIds.length, 1);
      
      viewModel.toggleDefender(grassId);
      expect(viewModel.selectedDefenderIds.length, 2);
      
      // Should not add a third
      viewModel.toggleDefender(waterid);
      expect(viewModel.selectedDefenderIds.length, 2);
      
      // Toggle off one
      viewModel.toggleDefender(fireId);
      expect(viewModel.selectedDefenderIds.length, 1);
      expect(viewModel.selectedDefenderIds.contains(grassId), true);
    });

    test('getDefensiveMultipliers returns all type matchups', () {
      final fireId = viewModel.types.firstWhere((t) => t.name == 'Fire').id;
      
      final multipliers = viewModel.getDefensiveMultipliers([fireId]);
      
      // Should have multipliers for all 18 types
      expect(multipliers.length, 18);
      
      // Water should be super effective against Fire
      final waterId = viewModel.types.firstWhere((t) => t.name == 'Water').id;
      expect(multipliers[waterId], 2.0);
    });

    test('getTypeById returns correct type', () {
      final fireType = viewModel.types.firstWhere((t) => t.name == 'Fire');
      final retrievedType = viewModel.getTypeById(fireType.id);
      
      expect(retrievedType, isNotNull);
      expect(retrievedType!.name, 'Fire');
      expect(retrievedType.emoji, '🔥');
    });

    test('getTypeById returns null for invalid id', () {
      final retrievedType = viewModel.getTypeById('invalid_id');
      expect(retrievedType, isNull);
    });

    test('Normal effectiveness is ×1', () {
      final normalId = viewModel.types.firstWhere((t) => t.name == 'Normal').id;
      final flyingId = viewModel.types.firstWhere((t) => t.name == 'Flying').id;
      
      viewModel.selectAttacker(normalId);
      viewModel.toggleDefender(flyingId);
      
      final multiplier = viewModel.getMultiplier();
      expect(multiplier, 1.0);
    });

    test('Ghost is immune to Normal (×0)', () {
      final normalId = viewModel.types.firstWhere((t) => t.name == 'Normal').id;
      final ghostId = viewModel.types.firstWhere((t) => t.name == 'Ghost').id;
      
      viewModel.selectAttacker(normalId);
      viewModel.toggleDefender(ghostId);
      
      final multiplier = viewModel.getMultiplier();
      expect(multiplier, 0.0);
    });
  });

  group('EffectivenessMatrix Tests', () {
    test('EffectivenessMatrix handles missing entries correctly', () {
      final matrix = EffectivenessMatrix({
        'fire': {'grass': 2.0},
      });
      
      // Explicit entry
      expect(matrix.getMultiplier('fire', 'grass'), 2.0);
      
      // Missing entry should default to 1.0
      expect(matrix.getMultiplier('fire', 'water'), 1.0);
      expect(matrix.getMultiplier('water', 'grass'), 1.0);
    });
  });

  group('PokemonType Tests', () {
    test('PokemonType fromJson works correctly', () {
      final json = {
        'id': 'fire',
        'name': 'Fire',
        'emoji': '🔥',
        'color': '#F08030'
      };
      
      final type = PokemonType.fromJson(json);
      
      expect(type.id, 'fire');
      expect(type.name, 'Fire');
      expect(type.emoji, '🔥');
      expect(type.colorHex, '#F08030');
    });

    test('PokemonType toJson works correctly', () {
      final type = PokemonType(
        id: 'fire',
        name: 'Fire',
        emoji: '🔥',
        colorHex: '#F08030',
      );
      
      final json = type.toJson();
      
      expect(json['id'], 'fire');
      expect(json['name'], 'Fire');
      expect(json['emoji'], '🔥');
      expect(json['color'], '#F08030');
    });

    test('PokemonType handles missing optional fields', () {
      final json = {'id': 'fire', 'name': 'Fire'};
      
      final type = PokemonType.fromJson(json);
      
      expect(type.id, 'fire');
      expect(type.name, 'Fire');
      expect(type.emoji, '');
      expect(type.colorHex, '#CCCCCC');
    });
  });
}
