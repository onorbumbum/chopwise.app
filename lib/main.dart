import 'package:flutter/material.dart';
import 'cut.dart';
import 'data_input_section.dart';
import 'optimizer_output_section.dart';
import 'visualizer_section.dart';

void main() {
  runApp(const CutOptimizerApp());
}

class CutOptimizerApp extends StatelessWidget {
  const CutOptimizerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cut Optimizer',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const CutOptimizerHome(),
    );
  }
}

class CutOptimizerHome extends StatefulWidget {
  const CutOptimizerHome({super.key});

  @override
  State<CutOptimizerHome> createState() => _CutOptimizerHomeState();
}

class _CutOptimizerHomeState extends State<CutOptimizerHome> {
  double boardLength = 96.0;
  double boardWidth = 3.5;
  double kerfValue = 0.125;
  List<Cut> cuts = [];

  void updateBoardDimensions(double length, double width) {
    setState(() {
      boardLength = length > 0 ? length : 1;
      boardWidth = width > 0 ? width : 1;
    });
  }

  void updateKerf(double kerf) {
    setState(() {
      kerfValue = kerf >= 0 ? kerf : 0;
    });
  }

  void updateCuts(List<Cut> newCuts) {
    setState(() {
      cuts = newCuts
          .where((cut) => cut.length > 0 && cut.width > 0 && cut.quantity > 0)
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cut Optimizer'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Row(
        children: [
          Expanded(
            flex: 1,
            child: Column(
              children: [
                Expanded(
                  child: DataInputSection(
                    boardLength: boardLength,
                    boardWidth: boardWidth,
                    kerfValue: kerfValue,
                    cuts: cuts,
                    onBoardDimensionsChanged: updateBoardDimensions,
                    onKerfChanged: updateKerf,
                    onCutsChanged: updateCuts,
                  ),
                ),
                Expanded(
                  child: OptimizerOutputSection(
                    boardLength: boardLength,
                    boardWidth: boardWidth,
                    kerfValue: kerfValue,
                    cuts: cuts,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: VisualizerSection(
              boardLength: boardLength,
              boardWidth: boardWidth,
              kerfValue: kerfValue,
              cuts: cuts,
            ),
          ),
        ],
      ),
    );
  }
}
