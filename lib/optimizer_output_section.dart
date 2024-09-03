import 'package:flutter/material.dart';
import 'cut.dart';

class OptimizerOutputSection extends StatelessWidget {
  final double boardLength;
  final double boardWidth;
  final double kerfValue;
  final List<Cut> cuts;

  const OptimizerOutputSection({
    Key? key,
    required this.boardLength,
    required this.boardWidth,
    required this.kerfValue,
    required this.cuts,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<List<Cut>> optimizedBoards = _optimizeCuts();

    return SizedBox.expand(
      child: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Optimization Results:',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              'Number of boards needed: ${optimizedBoards.length}',
            ),
          ),
          const SizedBox(height: 16),
          ...optimizedBoards.asMap().entries.map((entry) {
            return _buildBoardInfo(context, entry.key, entry.value);
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildBoardInfo(
      BuildContext context, int boardIndex, List<Cut> board) {
    double totalArea =
        board.fold(0, (sum, cut) => sum + cut.length * cut.width);
    double boardArea = boardLength * boardWidth;
    double remainingArea = boardArea - totalArea;
    double utilizationPercentage = (totalArea / boardArea) * 100;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Board ${boardIndex + 1}:',
                style: Theme.of(context).textTheme.titleMedium),
            Text('Cuts:'),
            ...board.map((cut) => Text(
                '  ${cut.length.toStringAsFixed(2)} x ${cut.width.toStringAsFixed(2)} (${cut.quantity})')),
            Text(
                'Remaining area: ${remainingArea.toStringAsFixed(2)} sq inches'),
            Text('Utilization: ${utilizationPercentage.toStringAsFixed(2)}%'),
          ],
        ),
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
