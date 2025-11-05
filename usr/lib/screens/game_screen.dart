import 'package:flutter/material.dart';
import '../models/candy.dart';
import '../widgets/candy_grid.dart';
import 'dart:math';
import 'dart:async';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  static const int gridSize = 8;
  List<List<Candy>> grid = [];
  Candy? selectedCandy;
  int score = 0;
  int moves = 30;
  bool isProcessing = false;

  @override
  void initState() {
    super.initState();
    initializeGrid();
  }

  void initializeGrid() {
    final random = Random();
    grid = List.generate(
      gridSize,
      (row) => List.generate(
        gridSize,
        (col) => Candy(
          row: row,
          col: col,
          type: CandyType.values[random.nextInt(CandyType.values.length)],
        ),
      ),
    );
    // Clear any initial matches
    _clearInitialMatches();
  }

  void _clearInitialMatches() {
    bool hasMatches = true;
    final random = Random();
    
    while (hasMatches) {
      hasMatches = false;
      for (int row = 0; row < gridSize; row++) {
        for (int col = 0; col < gridSize; col++) {
          if (_hasMatchAt(row, col)) {
            grid[row][col] = Candy(
              row: row,
              col: col,
              type: CandyType.values[random.nextInt(CandyType.values.length)],
            );
            hasMatches = true;
          }
        }
      }
    }
  }

  bool _hasMatchAt(int row, int col) {
    final type = grid[row][col].type;
    
    // Check horizontal match
    if (col >= 2 && grid[row][col - 1].type == type && grid[row][col - 2].type == type) {
      return true;
    }
    
    // Check vertical match
    if (row >= 2 && grid[row - 1][col].type == type && grid[row - 2][col].type == type) {
      return true;
    }
    
    return false;
  }

  void onCandyTapped(Candy candy) {
    if (isProcessing || moves <= 0) return;

    setState(() {
      if (selectedCandy == null) {
        selectedCandy = candy;
        candy.isSelected = true;
      } else {
        if (selectedCandy == candy) {
          // Deselect
          candy.isSelected = false;
          selectedCandy = null;
        } else if (_areAdjacent(selectedCandy!, candy)) {
          // Swap candies
          _swapCandies(selectedCandy!, candy);
        } else {
          // Select new candy
          selectedCandy!.isSelected = false;
          selectedCandy = candy;
          candy.isSelected = true;
        }
      }
    });
  }

  bool _areAdjacent(Candy c1, Candy c2) {
    return (c1.row == c2.row && (c1.col - c2.col).abs() == 1) ||
        (c1.col == c2.col && (c1.row - c2.row).abs() == 1);
  }

  void _swapCandies(Candy c1, Candy c2) async {
    isProcessing = true;
    
    // Swap positions
    final tempType = c1.type;
    setState(() {
      c1.type = c2.type;
      c2.type = tempType;
      c1.isSelected = false;
      c2.isSelected = false;
      selectedCandy = null;
    });

    await Future.delayed(const Duration(milliseconds: 300));

    // Check for matches
    List<Candy> matches = _findMatches();
    
    if (matches.isEmpty) {
      // Swap back if no match
      setState(() {
        final tempType = c1.type;
        c1.type = c2.type;
        c2.type = tempType;
      });
      isProcessing = false;
    } else {
      // Valid move
      setState(() {
        moves--;
      });
      await _processMatches();
      isProcessing = false;
      
      // Check for game over
      if (moves <= 0) {
        _showGameOverDialog();
      }
    }
  }

  List<Candy> _findMatches() {
    Set<Candy> matches = {};

    // Check horizontal matches
    for (int row = 0; row < gridSize; row++) {
      for (int col = 0; col < gridSize - 2; col++) {
        final type = grid[row][col].type;
        if (grid[row][col + 1].type == type && grid[row][col + 2].type == type) {
          matches.add(grid[row][col]);
          matches.add(grid[row][col + 1]);
          matches.add(grid[row][col + 2]);
          
          // Check for longer matches
          int extraCol = col + 3;
          while (extraCol < gridSize && grid[row][extraCol].type == type) {
            matches.add(grid[row][extraCol]);
            extraCol++;
          }
        }
      }
    }

    // Check vertical matches
    for (int col = 0; col < gridSize; col++) {
      for (int row = 0; row < gridSize - 2; row++) {
        final type = grid[row][col].type;
        if (grid[row + 1][col].type == type && grid[row + 2][col].type == type) {
          matches.add(grid[row][col]);
          matches.add(grid[row + 1][col]);
          matches.add(grid[row + 2][col]);
          
          // Check for longer matches
          int extraRow = row + 3;
          while (extraRow < gridSize && grid[extraRow][col].type == type) {
            matches.add(grid[extraRow][col]);
            extraRow++;
          }
        }
      }
    }

    return matches.toList();
  }

  Future<void> _processMatches() async {
    bool hasMatches = true;
    
    while (hasMatches) {
      List<Candy> matches = _findMatches();
      
      if (matches.isEmpty) {
        hasMatches = false;
      } else {
        // Update score
        setState(() {
          score += matches.length * 10;
        });

        // Mark matches as matched
        for (var candy in matches) {
          candy.isMatched = true;
        }
        setState(() {});
        
        await Future.delayed(const Duration(milliseconds: 300));

        // Drop candies and fill empty spaces
        _dropCandies();
        await Future.delayed(const Duration(milliseconds: 300));
      }
    }
  }

  void _dropCandies() {
    final random = Random();
    
    for (int col = 0; col < gridSize; col++) {
      int emptyRow = gridSize - 1;
      
      // Move existing candies down
      for (int row = gridSize - 1; row >= 0; row--) {
        if (!grid[row][col].isMatched) {
          if (row != emptyRow) {
            grid[emptyRow][col] = Candy(
              row: emptyRow,
              col: col,
              type: grid[row][col].type,
            );
            grid[row][col].isMatched = true;
          }
          emptyRow--;
        }
      }
      
      // Fill empty spaces with new candies
      while (emptyRow >= 0) {
        grid[emptyRow][col] = Candy(
          row: emptyRow,
          col: col,
          type: CandyType.values[random.nextInt(CandyType.values.length)],
        );
        emptyRow--;
      }
    }
    
    setState(() {});
  }

  void _showGameOverDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Game Over!'),
        content: Text(
          'Your Score: $score',
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Home'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                score = 0;
                moves = 30;
                selectedCandy = null;
                isProcessing = false;
                initializeGrid();
              });
            },
            child: const Text('Play Again'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.purple.shade200,
              Colors.pink.shade200,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header with score and moves
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white, size: 30),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Column(
                      children: [
                        const Text(
                          'Score',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                        Text(
                          '$score',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        const Text(
                          'Moves',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                        Text(
                          '$moves',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Game Grid
              Expanded(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: CandyGrid(
                      grid: grid,
                      onCandyTapped: onCandyTapped,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
