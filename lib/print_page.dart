import 'package:flutter/material.dart';
import 'dart:html' as html;
import 'cut.dart';

class PrintPage extends StatelessWidget {
  final double boardLength;
  final double boardWidth;
  final double kerfValue;
  final List<Cut> cuts;

  const PrintPage({
    Key? key,
    required this.boardLength,
    required this.boardWidth,
    required this.kerfValue,
    required this.cuts,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    _printPage();
    return Container();
  }

  void _printPage() {
    final String htmlContent = '''
      <!DOCTYPE html>
      <html>
      <head>
        <title>Cut Optimizer - Cut List</title>
        <style>
          body { font-family: Arial, sans-serif; }
          .board-container { position: relative; margin-bottom: 20px; }
          .board { border: 1px solid black; position: relative; }
          .cut { border: 1px solid black; position: absolute; font-size: 10px; overflow: hidden; }
          .remaining { background-color: #eee; border: 1px solid black; position: absolute; font-size: 10px; overflow: hidden; }
          .footer { position: fixed; bottom: 0; width: 100%; text-align: center; font-size: 12px; }
          .legend { position: absolute; font-size: 12px; }
        </style>
      </head>
      <body>
        <h1>Cut Optimizer - Cut List</h1>
        <p>Board Dimensions: $boardLength x $boardWidth</p>
        <p>Kerf: $kerfValue</p>
        ${_generateBoardsHtml()}
        <div class="footer">Courtesy of Uzunu - www.uzunu.com</div>
        <script>
          window.onload = () => {
            window.print();
          };
        </script>
      </body>
      </html>
    ''';

    final html.Blob blob = html.Blob([htmlContent], 'text/html');
    final url = html.Url.createObjectUrlFromBlob(blob);
    html.window.open(url, '_blank');
    html.Url.revokeObjectUrl(url);
  }

  String _generateBoardsHtml() {
    List<List<Cut>> optimizedBoards = _optimizeCuts();
    String boardsHtml = '';

    for (int i = 0; i < optimizedBoards.length; i++) {
      double remainingLength = _calculateRemainingLength(optimizedBoards[i]);
      boardsHtml += '''
        <h2>Board ${i + 1}:</h2>
        <ul>
          ${optimizedBoards[i].map((cut) => '<li>${cut.length.toStringAsFixed(2)} x ${cut.width.toStringAsFixed(2)}</li>').join('')}
        </ul>
        <div class="board-container">
          <div class="board" style="width: 500px; height: ${500 * (boardWidth / boardLength)}px;">
            ${_generateCutDivs(optimizedBoards[i])}
            ${_generateRemainingDiv(remainingLength)}
          </div>
          <div class="legend" style="bottom: -20px; left: 50%;">L</div>
          <div class="legend" style="top: 50%; right: -20px;">W</div>
        </div>
      ''';
    }

    return boardsHtml;
  }

  String _generateCutDivs(List<Cut> boardCuts) {
    final double scale = 500 / boardLength;
    return boardCuts.map((cut) {
      final double left = (cut.x ?? 0) * scale;
      final double top = (cut.y ?? 0) * scale;
      final double width = cut.length * scale;
      final double height = cut.width * scale;
      return '''
        <div class="cut" style="left: ${left}px; top: ${top}px; width: ${width}px; height: ${height}px;">
          ${cut.length.toStringAsFixed(1)}x${cut.width.toStringAsFixed(1)}
        </div>
      ''';
    }).join('');
  }

  String _generateRemainingDiv(double remainingLength) {
    if (remainingLength <= 0) return '';
    final double scale = 500 / boardLength;
    final double width = remainingLength * scale;
    final double left = 500 - width;
    return '''
      <div class="remaining" style="left: ${left}px; top: 0; width: ${width}px; height: 100%;">
        Remaining:<br>${remainingLength.toStringAsFixed(2)}
      </div>
    ''';
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
