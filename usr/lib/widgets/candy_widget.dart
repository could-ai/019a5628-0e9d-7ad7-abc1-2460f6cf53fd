import 'package:flutter/material.dart';
import '../models/candy.dart';

class CandyWidget extends StatelessWidget {
  final Candy candy;
  final VoidCallback onTap;

  const CandyWidget({
    super.key,
    required this.candy,
    required this.onTap,
  });

  Color _getCandyColor() {
    switch (candy.type) {
      case CandyType.red:
        return Colors.red.shade400;
      case CandyType.orange:
        return Colors.orange.shade400;
      case CandyType.yellow:
        return Colors.yellow.shade400;
      case CandyType.green:
        return Colors.green.shade400;
      case CandyType.blue:
        return Colors.blue.shade400;
      case CandyType.purple:
        return Colors.purple.shade400;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: candy.isMatched ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: candy.isMatched
              ? Colors.transparent
              : _getCandyColor(),
          borderRadius: BorderRadius.circular(12),
          border: candy.isSelected
              ? Border.all(color: Colors.white, width: 3)
              : null,
          boxShadow: candy.isMatched
              ? []
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 4,
                    offset: const Offset(2, 2),
                  ),
                ],
        ),
        child: Center(
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 200),
            opacity: candy.isMatched ? 0.0 : 1.0,
            child: AnimatedScale(
              duration: const Duration(milliseconds: 200),
              scale: candy.isSelected ? 1.2 : 1.0,
              child: Text(
                candy.emoji,
                style: const TextStyle(fontSize: 32),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
