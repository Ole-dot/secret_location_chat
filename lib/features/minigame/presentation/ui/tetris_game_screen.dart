import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:secret_location_chat/core/theme/app_colors.dart';
import 'package:secret_location_chat/core/widgets/cyberpunk_button.dart';
import 'package:secret_location_chat/features/stones/presentation/bloc/stones_cubit.dart';

class TetrisGameScreen extends StatefulWidget {
  const TetrisGameScreen({super.key});

  @override
  State<TetrisGameScreen> createState() => _TetrisGameScreenState();
}

class _TetrisGameScreenState extends State<TetrisGameScreen> {
  static const _cols = 10;
  static const _rows = 16;
  static const _levelScoreTarget = 100;
  static const _lineScore = 25;

  final _random = Random();

  late List<List<int>> _grid;
  List<List<int>> _activeCells = [];
  int _pieceX = 0;
  int _pieceY = 0;
  int _pieceColor = 1;
  int _score = 0;
  int _level = 1;
  bool _gameOver = false;
  bool _levelCleared = false;
  bool _rewarding = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _resetBoard();
    _spawnPiece();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _resetBoard() {
    _grid = List.generate(
      _rows,
      (_) => List.filled(_cols, 0),
    );
    _score = 0;
    _level = 1;
    _gameOver = false;
    _levelCleared = false;
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(Duration(milliseconds: 520 - (_level * 25).clamp(0, 220)), (_) {
      if (!_gameOver && !_levelCleared) {
        _tick();
      }
    });
  }

  void _spawnPiece() {
    final shapeIndex = _random.nextInt(_shapes.length);
    _activeCells = _shapes[shapeIndex].map((cell) => [cell[0], cell[1]]).toList();
    _pieceColor = shapeIndex + 1;
    _pieceX = _cols ~/ 2 - 2;
    _pieceY = 0;
    if (!_canPlace(_activeCells, _pieceX, _pieceY)) {
      _gameOver = true;
      setState(() {});
    }
  }

  bool _canPlace(List<List<int>> cells, int ox, int oy) {
    for (final cell in cells) {
      final x = ox + cell[0];
      final y = oy + cell[1];
      if (x < 0 || x >= _cols || y >= _rows) return false;
      if (y >= 0 && _grid[y][x] != 0) return false;
    }
    return true;
  }

  void _lockPiece() {
    for (final cell in _activeCells) {
      final x = _pieceX + cell[0];
      final y = _pieceY + cell[1];
      if (y >= 0 && y < _rows && x >= 0 && x < _cols) {
        _grid[y][x] = _pieceColor;
      }
    }
    final cleared = _clearLines();
    _spawnPiece();
    setState(() {});
    if (cleared > 0 || _score >= _levelScoreTarget) {
      _checkLevelCleared();
    }
  }

  int _clearLines() {
    var cleared = 0;
    for (var y = _rows - 1; y >= 0; y--) {
      if (_grid[y].every((cell) => cell != 0)) {
        _grid.removeAt(y);
        _grid.insert(0, List.filled(_cols, 0));
        cleared++;
        y++;
      }
    }
    if (cleared > 0) {
      _score += cleared * _lineScore;
    }
    return cleared;
  }

  void _tick() {
    if (_tryMove(0, 1)) {
      setState(() {});
      return;
    }
    _lockPiece();
  }

  bool _tryMove(int dx, int dy) {
    if (_canPlace(_activeCells, _pieceX + dx, _pieceY + dy)) {
      _pieceX += dx;
      _pieceY += dy;
      return true;
    }
    return false;
  }

  void _rotate() {
    final rotated = _activeCells
        .map((cell) => [-cell[1], cell[0]])
        .map((cell) => [cell[0], cell[1]])
        .toList();
    if (_canPlace(rotated, _pieceX, _pieceY)) {
      _activeCells = rotated;
      setState(() {});
    }
  }

  Future<void> _checkLevelCleared() async {
    if (_levelCleared || _gameOver) return;

    _levelCleared = true;
    _timer?.cancel();
    setState(() {});

    if (!mounted) return;
    await _rewardLevel();
  }

  Future<void> _rewardLevel() async {
    if (_rewarding) return;
    _rewarding = true;

    final cubit = context.read<StonesCubit>();
    final success = await cubit.addStones(10);

    if (!mounted) return;

    if (!success) {
      _rewarding = false;
      _levelCleared = false;
      _startTimer();
      setState(() {});
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.surfaceCard,
        behavior: SnackBarBehavior.floating,
        content: const Text(
          'СИСТЕМА ВЗЛОМАНА: +10 СТОУНОВ ДОБЫТО',
          style: TextStyle(
            color: AppColors.neonRed,
            fontFamily: 'monospace',
            letterSpacing: 1.2,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: AppColors.surfaceCard,
          shape: RoundedRectangleBorder(
            side: const BorderSide(color: AppColors.neonRed),
          ),
          title: const Text(
            'УРОВЕНЬ ПРОЙДЕН',
            style: TextStyle(
              color: AppColors.neonRed,
              fontFamily: 'monospace',
              letterSpacing: 2,
            ),
          ),
          content: Text(
            'ТЕРМИНАЛ ХАК $_level ЗАВЕРШЁН\n+10 СТОУНОВ ЗАЧИСЛЕНО',
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontFamily: 'monospace',
              height: 1.5,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                _continueNextLevel();
              },
              child: const Text(
                'СЛЕД. УРОВЕНЬ',
                style: TextStyle(color: AppColors.neonRed),
              ),
            ),
          ],
        );
      },
    );

    _rewarding = false;
  }

  void _continueNextLevel() {
    _level++;
    _levelCleared = false;
    _grid = List.generate(_rows, (_) => List.filled(_cols, 0));
    _score = 0;
    _gameOver = false;
    _spawnPiece();
    _startTimer();
    setState(() {});
  }

  int _cellAt(int x, int y) {
    if (y < 0) return 0;
    for (final cell in _activeCells) {
      if (_pieceX + cell[0] == x && _pieceY + cell[1] == y) {
        return _pieceColor;
      }
    }
    return _grid[y][x];
  }

  Color _colorFor(int value) {
    return switch (value) {
      1 => AppColors.neonRed,
      2 => const Color(0xFF00E5FF),
      3 => const Color(0xFFFFD500),
      4 => const Color(0xFF76FF03),
      _ => AppColors.transparent,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: const Text(
          'ТЕРМИНАЛ ХАК',
          style: TextStyle(
            fontFamily: 'monospace',
            letterSpacing: 3,
            fontWeight: FontWeight.w900,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: Row(
                children: [
                  _HudChip(label: 'СЧЁТ', value: '$_score'),
                  const SizedBox(width: 8),
                  _HudChip(label: 'УРОВЕНЬ', value: '$_level'),
                  const Spacer(),
                  BlocBuilder<StonesCubit, StonesState>(
                    builder: (context, state) {
                      return _HudChip(label: 'СТОУНЫ', value: '${state.balance}');
                    },
                  ),
                ],
              ),
            ),
            Expanded(
              child: Center(
                child: AspectRatio(
                  aspectRatio: _cols / _rows,
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      border: Border.all(color: AppColors.neonRed, width: 1.5),
                    ),
                    child: _gameOver
                        ? const Center(
                            child: Text(
                              'СБОЙ СИСТЕМЫ',
                              style: TextStyle(
                                color: AppColors.neonRed,
                                fontFamily: 'monospace',
                                letterSpacing: 2,
                              ),
                            ),
                          )
                        : GridView.builder(
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: _cols,
                              mainAxisSpacing: 1,
                              crossAxisSpacing: 1,
                            ),
                            itemCount: _cols * _rows,
                            itemBuilder: (context, index) {
                              final x = index % _cols;
                              final y = index ~/ _cols;
                              final value = _cellAt(x, y);
                              return Container(
                                color: value == 0
                                    ? AppColors.background
                                    : _colorFor(value),
                              );
                            },
                          ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              child: Row(
                children: [
                  Expanded(
                    child: _ControlButton(
                      icon: Icons.arrow_back,
                      onTap: _gameOver || _levelCleared
                          ? null
                          : () {
                              if (_tryMove(-1, 0)) setState(() {});
                            },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _ControlButton(
                      icon: Icons.rotate_right,
                      onTap: _gameOver || _levelCleared ? null : _rotate,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _ControlButton(
                      icon: Icons.arrow_forward,
                      onTap: _gameOver || _levelCleared
                          ? null
                          : () {
                              if (_tryMove(1, 0)) setState(() {});
                            },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _ControlButton(
                      icon: Icons.arrow_downward,
                      onTap: _gameOver || _levelCleared
                          ? null
                          : () {
                              if (_tryMove(0, 1)) setState(() {});
                            },
                    ),
                  ),
                ],
              ),
            ),
            if (_gameOver)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: CyberpunkButton(
                  text: 'РЕБУТ',
                  onPressed: () {
                    _resetBoard();
                    _spawnPiece();
                    _startTimer();
                    setState(() {});
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  static const _shapes = [
    [
      [0, 0],
      [1, 0],
      [0, 1],
      [1, 1],
    ],
    [
      [0, 0],
      [1, 0],
      [2, 0],
      [3, 0],
    ],
    [
      [0, 0],
      [0, 1],
      [0, 2],
      [1, 2],
    ],
    [
      [0, 1],
      [1, 0],
      [1, 1],
      [2, 1],
    ],
  ];
}

class _HudChip extends StatelessWidget {
  final String label;
  final String value;

  const _HudChip({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        border: Border.all(color: AppColors.borderRed),
      ),
      child: Text(
        '$label: $value',
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontFamily: 'monospace',
          fontSize: 10,
          letterSpacing: 1,
        ),
      ),
    );
  }
}

class _ControlButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const _ControlButton({required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surfaceCard,
      child: InkWell(
        onTap: onTap,
        child: Container(
          height: 52,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.neonRed),
          ),
          child: Icon(icon, color: AppColors.neonRed),
        ),
      ),
    );
  }
}
