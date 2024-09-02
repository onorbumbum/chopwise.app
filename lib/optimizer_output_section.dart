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
    List<Cut> remainingCuts = List.from(cuts);
    remainingCuts
        .sort((a, b) => (b.length * b.width).compareTo(a.length * a.width));

    List<List<Cut>> boards = [];

    while (remainingCuts.isNotEmpty) {
      List<Cut> currentBoard = [];
      List<bool> used = List.filled(boardLength.ceil(), false);

      for (int i = 0; i < remainingCuts.length; i++) {
        Cut cut = remainingCuts[i];
        int start = _findSpace(used, cut.length.ceil());

        if (start != -1 && cut.width <= boardWidth) {
          currentBoard.add(cut);
          for (int j = start; j < start + cut.length.ceil(); j++) {
            used[j] = true;
          }
          remainingCuts[i] = Cut(cut.length, cut.width, cut.quantity - 1);
          if (remainingCuts[i].quantity == 0) {
            remainingCuts.removeAt(i);
            i--;
          }
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
