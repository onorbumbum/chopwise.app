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
    List<List<Cut>> optimizedBoards = _optimizeCuts();

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
            child: ListView.builder(
              itemCount: optimizedBoards.length,
              itemBuilder: (context, index) {
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
        break; // Unable to fit any more cuts
      }
    }

    return boards;
  }

  bool _canPlaceCut(List<List<bool>> usedSpace, int x, int y, Cut cut) {
    for (int dy = 0; dy < cut.width.ceil() + kerfValue.ceil(); dy++) {
      for (int dx = 0; dx < cut.length.ceil() + kerfValue.ceil(); dx++) {
        if (y + dy >= usedSpace.length ||
            x + dx >= usedSpace[0].length ||
            usedSpace[y + dy][x + dx]) {
          return false;
        }
      }
    }
    return true;
  }

  void _placeCut(List<List<bool>> usedSpace, int x, int y, Cut cut) {
    for (int dy = 0; dy < cut.width.ceil() + kerfValue.ceil(); dy++) {
      for (int dx = 0; dx < cut.length.ceil() + kerfValue.ceil(); dx++) {
        usedSpace[y + dy][x + dx] = true;
      }
    }
  }
}

class BoardPainter extends CustomPainter {
  final double boardLength;
  final double boardWidth;
  final List<Cut> cuts;
  final double kerfValue;

  BoardPainter({
    required this.boardLength,
    required this.boardWidth,
    required this.cuts,
    required this.kerfValue,
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
