import 'dart:math';

const _adjectives = [
  'цифровой',
  'кислотный',
  'неоновый',
  'квантовый',
  'кибер',
  'скрытный',
  'анонимный',
];

const _nouns = [
  'лев',
  'енот',
  'лис',
  'волк',
  'козел',
  'сова',
  'сталкер',
];

String _capitalizeWord(String word) {
  if (word.isEmpty) return word;
  return word[0].toUpperCase() + word.substring(1);
}

/// Случайный киберпанк-ник: «Кислотный Енот», «Цифровой Лев» и т.д.
String generateCyberpunkNickname([Random? random]) {
  final rng = random ?? Random();
  final adjective = _adjectives[rng.nextInt(_adjectives.length)];
  final noun = _nouns[rng.nextInt(_nouns.length)];
  return '${_capitalizeWord(adjective)} ${_capitalizeWord(noun)}';
}
