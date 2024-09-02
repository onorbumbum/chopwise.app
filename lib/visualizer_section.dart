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
      double remainingLength = boardLength;
      double remainingWidth = boardWidth;

      for (int i = 0; i < remainingCuts.length; i++) {
        Cut cut = remainingCuts[i];
        if (cut.length <= remainingLength && cut.width <= remainingWidth) {
          currentBoard.add(cut);
          if (cut.width == remainingWidth) {
            remainingLength -= cut.length;
          } else {
            remainingWidth -= cut.width;
          }
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

  int _findSpace(List<bool> used, int length) {
    int count = 0;
    for (int i = 0; i < used.length; i++) {
      if (!used[i]) {
        count++;
        if (count == length) {
          return i - length + 1;
        }
      } else {
        count = 0;
      }
    }
    return -1;
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

    double xOffset = 0;
    double yOffset = 0;
    double scaleX = size.width / boardLength;
    double scaleY = size.height / boardWidth;

    // Draw cuts
    for (int i = 0; i < cuts.length; i++) {
      Cut cut = cuts[i];
      double cutWidth = cut.length * scaleX;
      double cutHeight = cut.width * scaleY;

      // Draw cut
      paint.color = _getColor(i);
      canvas.drawRect(
          Rect.fromLTWH(xOffset, yOffset, cutWidth, cutHeight), paint);

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

      if (cut.width == boardWidth) {
        xOffset += cutWidth;
        yOffset = 0;
      } else {
        yOffset += cutHeight;
      }
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
