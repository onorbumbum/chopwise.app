import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'cut.dart';

class VisualizerSection extends StatelessWidget {
  final String selectedMaterial;
  final double kerfValue;
  final List<Cut> cuts;
  final double boardLength;

  const VisualizerSection({
    Key? key,
    required this.selectedMaterial,
    required this.kerfValue,
    required this.cuts,
    required this.boardLength,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<List<double>> optimizedBoards = _optimizeCuts();

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
                      SizedBox(
                        height: 100,
                        child: CustomPaint(
                          size: Size(double.infinity, 100),
                          painter: BoardPainter(
                            boardLength: boardLength,
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

  List<List<double>> _optimizeCuts() {
    List<double> cutLengths = [];
    for (var cut in cuts) {
      cutLengths.addAll(List.filled(cut.quantity, cut.length));
    }
    cutLengths.sort((a, b) => b.compareTo(a));

    List<List<double>> boards = [];

    for (double cutLength in cutLengths) {
      bool placed = false;
      for (List<double> board in boards) {
        if (_canFitCut(board, cutLength)) {
          board.add(cutLength);
          placed = true;
          break;
        }
      }
      if (!placed) {
        boards.add([cutLength]);
      }
    }

    return boards;
  }

  bool _canFitCut(List<double> board, double cutLength) {
    double boardUsage =
        board.reduce((a, b) => a + b) + (board.length - 1) * kerfValue;
    return boardUsage + cutLength + kerfValue <= boardLength;
  }
}

class BoardPainter extends CustomPainter {
  final double boardLength;
  final List<double> cuts;
  final double kerfValue;

  BoardPainter({
    required this.boardLength,
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

    double xOffset = 0;
    double scale = size.width / boardLength;

    // Draw board background
    paint.color = Colors.brown[300]!;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);

    // Draw cuts
    for (int i = 0; i < cuts.length; i++) {
      double cutWidth = cuts[i] * scale;

      // Draw cut
      paint.color = _getColor(i);
      canvas.drawRect(Rect.fromLTWH(xOffset, 0, cutWidth, size.height), paint);

      // Draw cut label
      textPainter.text = TextSpan(
        text: cuts[i].toStringAsFixed(1),
        style: const TextStyle(color: Colors.black, fontSize: 12),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(xOffset + (cutWidth - textPainter.width) / 2,
            (size.height - textPainter.height) / 2),
      );

      xOffset += cutWidth;

      // Draw kerf
      if (i < cuts.length - 1) {
        paint.color = Colors.red;
        double kerfWidth = kerfValue * scale;
        canvas.drawRect(
            Rect.fromLTWH(xOffset, 0, kerfWidth, size.height), paint);
        xOffset += kerfWidth;
      }
    }

    // Draw remaining space
    double remainingWidth = size.width - xOffset;
    if (remainingWidth > 0) {
      paint.color = Colors.grey[400]!;
      canvas.drawRect(
          Rect.fromLTWH(xOffset, 0, remainingWidth, size.height), paint);

      // Draw remaining label
      double remaining = boardLength -
          (cuts.reduce((a, b) => a + b) + (cuts.length - 1) * kerfValue);
      textPainter.text = TextSpan(
        text: 'Rem: ${remaining.toStringAsFixed(1)}',
        style: const TextStyle(color: Colors.black, fontSize: 12),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(xOffset + (remainingWidth - textPainter.width) / 2,
            (size.height - textPainter.height) / 2),
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
