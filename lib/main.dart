import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'cut.dart';
import 'data_input_section.dart';
import 'optimizer_output_section.dart';
import 'visualizer_section.dart';
import 'print_page.dart';

void main() {
  runApp(const CutOptimizerApp());
}

class CutOptimizerApp extends StatelessWidget {
  const CutOptimizerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chopwise - Cut costs, not corners',
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
  bool isBoardDimensionsSet = true;

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

  void setBoardDimensions() {
    setState(() {
      isBoardDimensionsSet = true;
    });
  }

  void _openPrintPage() {
    Navigator.of(context)
        .push(
      MaterialPageRoute(
        builder: (context) => PrintPage(
          boardLength: boardLength,
          boardWidth: boardWidth,
          kerfValue: kerfValue,
          cuts: cuts,
        ),
      ),
    )
        .then((_) {
      // This ensures the main screen is rebuilt after returning from the print page
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cut Optimizer'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.print),
            onPressed: _openPrintPage,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Row(
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
                          onBoardDimensionsSet: setBoardDimensions,
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
          ),
          const StickyFooter(),
        ],
      ),
    );
  }
}

class StickyFooter extends StatelessWidget {
  const StickyFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      color: Theme.of(context).colorScheme.surface,
      child: Center(
        child: InkWell(
          onTap: () => launchUrl(Uri.parse('https://www.uzunu.com/')),
          child: const Text(
            'Courtesy of Uzunu',
            style: TextStyle(
              color: Colors.blue,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      ),
    );
  }
}
