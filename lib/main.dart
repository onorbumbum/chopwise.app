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
  String selectedMaterial = '2x4x96';
  double kerfValue = 0.125;
  List<Cut> cuts = [];
  double boardLength = 96.0;

  void updateMaterial(String material) {
    setState(() {
      selectedMaterial = material;
      boardLength = double.parse(material.split('x').last);
    });
  }

  void updateKerf(double kerf) {
    setState(() {
      kerfValue = kerf;
    });
  }

  void updateCuts(List<Cut> newCuts) {
    setState(() {
      cuts = newCuts;
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
                    selectedMaterial: selectedMaterial,
                    kerfValue: kerfValue,
                    cuts: cuts,
                    boardLength: boardLength,
                    onMaterialSelected: updateMaterial,
                    onKerfChanged: updateKerf,
                    onCutsChanged: updateCuts,
                  ),
                ),
                Expanded(
                  child: OptimizerOutputSection(
                    selectedMaterial: selectedMaterial,
                    kerfValue: kerfValue,
                    cuts: cuts,
                    boardLength: boardLength,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: VisualizerSection(
              selectedMaterial: selectedMaterial,
              kerfValue: kerfValue,
              cuts: cuts,
              boardLength: boardLength,
            ),
          ),
        ],
      ),
    );
  }
}
