import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/pokemon_type.dart';
import '../models/effectiveness.dart';

class LocalDataService {
  Future<List<PokemonType>> loadTypes() async {
    // TODO: Implement actual JSON loading
    // For now, return stub data
    return [
      PokemonType(
        id: 'normal',
        name: 'Normal',
        emoji: '⚪',
        colorHex: '#A8A878',
      ),
      PokemonType(id: 'fire', name: 'Fire', emoji: '🔥', colorHex: '#F08030'),
      PokemonType(id: 'water', name: 'Water', emoji: '💧', colorHex: '#6890F0'),
      PokemonType(
        id: 'electric',
        name: 'Electric',
        emoji: '⚡',
        colorHex: '#F8D030',
      ),
      PokemonType(id: 'grass', name: 'Grass', emoji: '🌿', colorHex: '#78C850'),
      PokemonType(id: 'ice', name: 'Ice', emoji: '❄️', colorHex: '#98D8D8'),
      PokemonType(
        id: 'fighting',
        name: 'Fighting',
        emoji: '🥊',
        colorHex: '#C03028',
      ),
      PokemonType(
        id: 'poison',
        name: 'Poison',
        emoji: '☠️',
        colorHex: '#A040A0',
      ),
      PokemonType(
        id: 'ground',
        name: 'Ground',
        emoji: '⛰️',
        colorHex: '#E0C068',
      ),
      PokemonType(
        id: 'flying',
        name: 'Flying',
        emoji: '🦅',
        colorHex: '#A890F0',
      ),
      PokemonType(
        id: 'psychic',
        name: 'Psychic',
        emoji: '🔮',
        colorHex: '#F85888',
      ),
      PokemonType(id: 'bug', name: 'Bug', emoji: '🐛', colorHex: '#A8B820'),
      PokemonType(id: 'rock', name: 'Rock', emoji: '🪨', colorHex: '#B8A038'),
      PokemonType(id: 'ghost', name: 'Ghost', emoji: '👻', colorHex: '#705898'),
      PokemonType(
        id: 'dragon',
        name: 'Dragon',
        emoji: '🐉',
        colorHex: '#7038F8',
      ),
      PokemonType(id: 'dark', name: 'Dark', emoji: '🌑', colorHex: '#705848'),
      PokemonType(id: 'steel', name: 'Steel', emoji: '⚙️', colorHex: '#B8B8D0'),
      PokemonType(id: 'fairy', name: 'Fairy', emoji: '🧚', colorHex: '#EE99AC'),
    ];
  }

  Future<EffectivenessMatrix> loadEffectiveness() async {
    // TODO: Implement actual JSON loading from assets/effectiveness.json
    // For now, return stub matrix
    final matrix = <String, Map<String, double>>{
      'fire': {
        'grass': 2.0,
        'ice': 2.0,
        'bug': 2.0,
        'steel': 2.0,
        'water': 0.5,
        'rock': 0.5,
        'dragon': 0.5,
      },
      'water': {
        'fire': 2.0,
        'ground': 2.0,
        'rock': 2.0,
        'grass': 0.5,
        'dragon': 0.5,
      },
      'grass': {
        'water': 2.0,
        'ground': 2.0,
        'rock': 2.0,
        'fire': 0.5,
        'grass': 0.5,
        'poison': 0.5,
      },
      // Add more mappings as needed
    };
    return EffectivenessMatrix(matrix);
  }
}
