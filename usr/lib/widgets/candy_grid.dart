import 'package:flutter/material.dart';
import '../models/candy.dart';
import 'candy_widget.dart';

class CandyGrid extends StatelessWidget {
  final List<List<Candy>> grid;
  final Function(Candy) onCandyTapped;

  const CandyGrid({
    super.key,
    required this.grid,
    required this.onCandyTapped,
  });

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.3),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white, width: 3),
        ),
        padding: const EdgeInsets.all(8),
        child: GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: grid.length,
            crossAxisSpacing: 4,
            mainAxisSpacing: 4,
          ),
          itemCount: grid.length * grid.length,
          itemBuilder: (context, index) {
            final row = index ~/ grid.length;
            final col = index % grid.length;
            final candy = grid[row][col];
            
            return CandyWidget(
              candy: candy,
              onTap: () => onCandyTapped(candy),
            );
          },
        ),
      ),
    );
  }
}
