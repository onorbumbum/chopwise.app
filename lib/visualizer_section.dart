import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'cut.dart';

class VisualizerSection extends StatelessWidget {
  final double boardLength;
  final double boardWidth;
  final double kerfValue;
  final List<Cut> cuts;

  const VisualizerSection({
    Key? key,
    required this.boardLength,
    required this.boardWidth,
    required this.kerfValue,
    required this.cuts,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<List<Cut>> optimizedBoards = cuts.isEmpty ? [] : _optimizeCuts();

    return Container(
      color: Colors.grey[200],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Cut Visualization:',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          Expanded(
            child: cuts.isEmpty
                ? _buildEmptyBoard(context)
                : ListView.builder(
                    itemCount: optimizedBoards.length,
                    itemBuilder: (context, index) {
                      double remainingLength =
                          _calculateRemainingLength(optimizedBoards[index]);
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Board ${index + 1}:'),
                            SizedBox(height: 8),
                            AspectRatio(
                              aspectRatio: boardLength / boardWidth,
                              child: CustomPaint(
                                painter: BoardPainter(
                                  boardLength: boardLength,
                                  boardWidth: boardWidth,
                                  cuts: optimizedBoards[index],
                                  kerfValue: kerfValue,
                                  remainingLength: remainingLength,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyBoard(BuildContext context) {
    return Center(
      child: AspectRatio(
        aspectRatio: boardLength / boardWidth,
        child: CustomPaint(
          painter: BoardPainter(
            boardLength: boardLength,
            boardWidth: boardWidth,
            cuts: [],
            kerfValue: kerfValue,
            remainingLength: boardLength,
          ),
        ),
      ),
    );
  }

  double _calculateRemainingLength(List<Cut> boardCuts) {
    double usedLength =
        boardCuts.fold(0, (sum, cut) => sum + cut.length + kerfValue);
    return boardLength - usedLength;
  }

  List<List<Cut>> _optimizeCuts() {
    List<Cut> remainingCuts = cuts
        .expand(
            (cut) => List.filled(cut.quantity, Cut(cut.length, cut.width, 1)))
        .toList();
    remainingCuts
        .sort((a, b) => (b.length * b.width).compareTo(a.length * a.width));

    List<List<Cut>> boards = [];

    while (remainingCuts.isNotEmpty) {
      List<Cut> currentBoard = [];
      List<List<bool>> usedSpace = List.generate(
        boardWidth.ceil(),
        (_) => List.filled(boardLength.ceil(), false),
      );

      for (int i = 0; i < remainingCuts.length; i++) {
        Cut cut = remainingCuts[i];
        bool placed = false;

        for (int y = 0; y <= boardWidth.ceil() - cut.width.ceil(); y++) {
          for (int x = 0; x <= boardLength.ceil() - cut.length.ceil(); x++) {
            if (_canPlaceCut(usedSpace, x, y, cut)) {
              _placeCut(usedSpace, x, y, cut);
              currentBoard.add(Cut(cut.length, cut.width, 1,
                  x: x.toDouble(), y: y.toDouble()));
              placed = true;
              break;
            }
          }
          if (placed) break;
        }

        if (placed) {
          remainingCuts.removeAt(i);
          i--;
        }
      }

      if (currentBoard.isNotEmpty) {
        boards.add(currentBoard);
      } else {
        break;
      }
    }

    return boards;
  }

  bool _canPlaceCut(List<List<bool>> usedSpace, int x, int y, Cut cut) {
    if (y + cut.width.ceil() > boardWidth.ceil() ||
        x + cut.length.ceil() > boardLength.ceil()) {
      return false;
    }
    for (int dy = 0; dy < cut.width.ceil(); dy++) {
      for (int dx = 0; dx < cut.length.ceil(); dx++) {
        if (usedSpace[y + dy][x + dx]) {
          return false;
        }
      }
    }
    return true;
  }

  void _placeCut(List<List<bool>> usedSpace, int x, int y, Cut cut) {
    for (int dy = 0; dy < cut.width.ceil(); dy++) {
      for (int dx = 0; dx < cut.length.ceil(); dx++) {
        usedSpace[y + dy][x + dx] = true;
      }
    }
    // Add kerf around the cut
    for (int dy = -1; dy <= cut.width.ceil(); dy++) {
      for (int dx = -1; dx <= cut.length.ceil(); dx++) {
        if (y + dy >= 0 &&
            y + dy < boardWidth.ceil() &&
            x + dx >= 0 &&
            x + dx < boardLength.ceil()) {
          usedSpace[y + dy][x + dx] = true;
        }
      }
    }
  }
}

class BoardPainter extends CustomPainter {
  final double boardLength;
  final double boardWidth;
  final List<Cut> cuts;
  final double kerfValue;
  final double remainingLength;

  BoardPainter({
    required this.boardLength,
    required this.boardWidth,
    required this.cuts,
    required this.kerfValue,
    required this.remainingLength,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );

    // Draw board background
    paint.color = Colors.brown[300]!;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);

    double scaleX = size.width / boardLength;
    double scaleY = size.height / boardWidth;

    // Draw cuts
    for (int i = 0; i < cuts.length; i++) {
      Cut cut = cuts[i];
      double cutWidth = cut.length * scaleX;
      double cutHeight = cut.width * scaleY;
      double xOffset = cut.x! * scaleX;
      double yOffset = cut.y! * scaleY;

      // Draw cut
      paint.color = _getColor(i);
      canvas.drawRect(
          Rect.fromLTWH(xOffset, yOffset, cutWidth, cutHeight), paint);

      // Draw kerf
      paint.color = Colors.grey[600]!;
      canvas.drawRect(
          Rect.fromLTWH(
              xOffset + cutWidth, yOffset, kerfValue * scaleX, cutHeight),
          paint);
      canvas.drawRect(
          Rect.fromLTWH(
              xOffset, yOffset + cutHeight, cutWidth, kerfValue * scaleY),
          paint);

      // Draw cut label
      textPainter.text = TextSpan(
        text:
            '${cut.length.toStringAsFixed(1)}x${cut.width.toStringAsFixed(1)}',
        style: TextStyle(color: Colors.black, fontSize: 10),
      );
      textPainter.layout(maxWidth: cutWidth);
      textPainter.paint(
        canvas,
        Offset(xOffset + (cutWidth - textPainter.width) / 2,
            yOffset + (cutHeight - textPainter.height) / 2),
      );
    }

    // Draw remaining length
    if (remainingLength > 0) {
      double remainingWidth = remainingLength * scaleX;
      double xOffset = size.width - remainingWidth;

      paint.color = Colors.grey[400]!;
      canvas.drawRect(
          Rect.fromLTWH(xOffset, 0, remainingWidth, size.height), paint);

      textPainter.text = TextSpan(
        text: 'Remaining:\n${remainingLength.toStringAsFixed(2)}',
        style: TextStyle(color: Colors.black, fontSize: 10),
      );
      textPainter.layout(maxWidth: remainingWidth);
      textPainter.paint(
        canvas,
        Offset(xOffset + (remainingWidth - textPainter.width) / 2,
            (size.height - textPainter.height) / 2),
      );
    }
    // Draw legends
    paint.color = Colors.black;
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 1;

    // Length legend
    canvas.drawLine(
        Offset(0, size.height), Offset(size.width, size.height), paint);
    textPainter.text = TextSpan(
      text: 'L',
      style: TextStyle(color: Colors.black, fontSize: 12),
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(size.width / 2, size.height + 2));

    // Width legend
    canvas.drawLine(
        Offset(size.width, 0), Offset(size.width, size.height), paint);
    textPainter.text = TextSpan(
      text: 'W',
      style: TextStyle(color: Colors.black, fontSize: 12),
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(size.width + 2, size.height / 2));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }

  Color _getColor(int index) {
    List<Color> colors = [
      Colors.blue[200]!,
      Colors.green[200]!,
      Colors.yellow[200]!,
      Colors.orange[200]!,
      Colors.purple[200]!,
      Colors.pink[200]!,
    ];
    return colors[index % colors.length];
  }
}
