class Cut {
  final double length;
  final double width;
  final int quantity;
  final double? x;
  final double? y;

  Cut(this.length, this.width, this.quantity, {this.x, this.y});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Cut &&
          runtimeType == other.runtimeType &&
          length == other.length &&
          width == other.width &&
          quantity == other.quantity;

  @override
  int get hashCode => length.hashCode ^ width.hashCode ^ quantity.hashCode;
}
