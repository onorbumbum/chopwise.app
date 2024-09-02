import 'package:flutter/material.dart';
import 'cut.dart';

class OptimizerOutputSection extends StatelessWidget {
  final String selectedMaterial;
  final double kerfValue;
  final List<Cut> cuts;
  final double boardLength;

  const OptimizerOutputSection({
    Key? key,
    required this.selectedMaterial,
    required this.kerfValue,
    required this.cuts,
    required this.boardLength,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<List<double>> optimizedBoards = _optimizeCuts();

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
              'Number of $selectedMaterial boards needed: ${optimizedBoards.length}',
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
      BuildContext context, int boardIndex, List<double> board) {
    double totalLength =
        board.reduce((a, b) => a + b) + (board.length - 1) * kerfValue;
    double remaining = boardLength - totalLength;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Board ${boardIndex + 1}:',
                style: Theme.of(context).textTheme.titleMedium),
            Text('Cuts: ${board.map((c) => c.toStringAsFixed(2)).join(', ')}'),
            Text('Remaining: ${remaining.toStringAsFixed(2)}'),
          ],
        ),
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
