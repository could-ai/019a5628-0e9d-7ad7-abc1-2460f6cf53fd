enum CandyType {
  red,
  orange,
  yellow,
  green,
  blue,
  purple,
}

class Candy {
  int row;
  int col;
  CandyType type;
  bool isSelected;
  bool isMatched;

  Candy({
    required this.row,
    required this.col,
    required this.type,
    this.isSelected = false,
    this.isMatched = false,
  });

  String get emoji {
    switch (type) {
      case CandyType.red:
        return '🍎';
      case CandyType.orange:
        return '🍊';
      case CandyType.yellow:
        return '🍋';
      case CandyType.green:
        return '🍏';
      case CandyType.blue:
        return '🫐';
      case CandyType.purple:
        return '🍇';
    }
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Candy && runtimeType == other.runtimeType && row == other.row && col == other.col;

  @override
  int get hashCode => row.hashCode ^ col.hashCode;
}
