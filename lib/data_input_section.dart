import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;
import 'cut.dart';

class DataInputSection extends StatefulWidget {
  final double boardLength;
  final double boardWidth;
  final double kerfValue;
  final List<Cut> cuts;
  final void Function(double, double) onBoardDimensionsChanged;
  final void Function(double) onKerfChanged;
  final void Function(List<Cut>) onCutsChanged;
  final void Function() onBoardDimensionsSet;

  const DataInputSection({
    Key? key,
    required this.boardLength,
    required this.boardWidth,
    required this.kerfValue,
    required this.cuts,
    required this.onBoardDimensionsChanged,
    required this.onKerfChanged,
    required this.onCutsChanged,
    required this.onBoardDimensionsSet,
  }) : super(key: key);

  @override
  State<DataInputSection> createState() => _DataInputSectionState();
}

class _DataInputSectionState extends State<DataInputSection> {
  late TextEditingController boardLengthController;
  late TextEditingController boardWidthController;
  late TextEditingController kerfController;
  late List<TextEditingController> lengthControllers;
  late List<TextEditingController> widthControllers;
  late List<TextEditingController> quantityControllers;
  late List<FocusNode> lengthFocusNodes;
  late List<FocusNode> widthFocusNodes;
  late List<FocusNode> quantityFocusNodes;
  late FocusNode boardLengthFocusNode;
  late FocusNode boardWidthFocusNode;
  late FocusNode kerfFocusNode;
  final ScrollController _scrollController = ScrollController();
  bool _isBoardDimensionsSet = false;

  @override
  void initState() {
    super.initState();
    boardLengthController =
        TextEditingController(text: widget.boardLength.toString());
    boardWidthController =
        TextEditingController(text: widget.boardWidth.toString());
    kerfController = TextEditingController(text: widget.kerfValue.toString());
    boardLengthFocusNode = FocusNode();
    boardWidthFocusNode = FocusNode();
    kerfFocusNode = FocusNode();
    _initializeCutControllers();
  }

  @override
  void didUpdateWidget(DataInputSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.cuts.length != oldWidget.cuts.length) {
      _initializeCutControllers();
    }
  }

  void _initializeCutControllers() {
    lengthControllers = List.generate(
      widget.cuts.length,
      (index) =>
          TextEditingController(text: widget.cuts[index].length.toString()),
    );
    widthControllers = List.generate(
      widget.cuts.length,
      (index) =>
          TextEditingController(text: widget.cuts[index].width.toString()),
    );
    quantityControllers = List.generate(
      widget.cuts.length,
      (index) =>
          TextEditingController(text: widget.cuts[index].quantity.toString()),
    );
    lengthFocusNodes = List.generate(widget.cuts.length, (_) => FocusNode());
    widthFocusNodes = List.generate(widget.cuts.length, (_) => FocusNode());
    quantityFocusNodes = List.generate(widget.cuts.length, (_) => FocusNode());
  }

  @override
  Widget build(BuildContext context) {
    return FocusScope(
      child: SingleChildScrollView(
        controller: _scrollController,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: NumberInput(
                      controller: boardLengthController,
                      focusNode: boardLengthFocusNode,
                      label: 'Board Length',
                      allowDecimal: true,
                      onChanged: (_) => _updateBoardDimensions(),
                      onEditingComplete: () {
                        FocusScope.of(context)
                            .requestFocus(boardWidthFocusNode);
                      },
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: NumberInput(
                      controller: boardWidthController,
                      focusNode: boardWidthFocusNode,
                      label: 'Board Width',
                      allowDecimal: true,
                      onChanged: (_) => _updateBoardDimensions(),
                      onEditingComplete: () {
                        FocusScope.of(context).requestFocus(kerfFocusNode);
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              NumberInput(
                controller: kerfController,
                focusNode: kerfFocusNode,
                label: 'Blade Kerf',
                allowDecimal: true,
                onChanged: (value) {
                  widget.onKerfChanged(
                      double.tryParse(value) ?? widget.kerfValue);
                },
                onEditingComplete: () {
                  if (lengthFocusNodes.isNotEmpty) {
                    FocusScope.of(context).requestFocus(lengthFocusNodes.first);
                  }
                },
              ),
              SizedBox(height: 16),
              Text('Enter Cuts:',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: lengthControllers.length,
                itemBuilder: (context, index) {
                  return _buildCutRow(index);
                },
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => _addCut(widget.boardLength, widget.boardWidth),
                child: Text('Add Cut'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCutRow(int index) {
    return Row(
      children: [
        Expanded(
          child: NumberInput(
            controller: lengthControllers[index],
            focusNode: lengthFocusNodes[index],
            label: 'Length',
            allowDecimal: true,
            max: widget.boardLength,
            onChanged: (_) => _updateCuts(),
            onEditingComplete: () {
              FocusScope.of(context).requestFocus(widthFocusNodes[index]);
            },
          ),
        ),
        SizedBox(width: 8),
        Expanded(
          child: NumberInput(
            controller: widthControllers[index],
            focusNode: widthFocusNodes[index],
            label: 'Width',
            allowDecimal: true,
            max: widget.boardWidth,
            onChanged: (_) => _updateCuts(),
            onEditingComplete: () {
              FocusScope.of(context).requestFocus(quantityFocusNodes[index]);
            },
          ),
        ),
        SizedBox(width: 8),
        Expanded(
          child: NumberInput(
            controller: quantityControllers[index],
            focusNode: quantityFocusNodes[index],
            label: 'Quantity',
            onChanged: (_) => _updateCuts(),
            textInputAction: TextInputAction.done,
            onEditingComplete: () {
              if (index < lengthFocusNodes.length - 1) {
                FocusScope.of(context)
                    .requestFocus(lengthFocusNodes[index + 1]);
              } else {
                _addCut(widget.boardLength, widget.boardWidth);
              }
            },
          ),
        ),
        IconButton(
          icon: Icon(Icons.delete),
          onPressed: () => _removeCut(index),
        ),
      ],
    );
  }

  void _updateBoardDimensions() {
    double length =
        double.tryParse(boardLengthController.text) ?? widget.boardLength;
    double width =
        double.tryParse(boardWidthController.text) ?? widget.boardWidth;
    widget.onBoardDimensionsChanged(length, width);

    if (!_isBoardDimensionsSet && length > 0 && width > 0) {
      _isBoardDimensionsSet = true;
      widget.onBoardDimensionsSet();
    }
  }

  void _updateCuts() {
    final newCuts = <Cut>[];
    bool hasChanges = false;

    for (int i = 0; i < lengthControllers.length; i++) {
      final length = double.tryParse(lengthControllers[i].text) ?? 0;
      final width = double.tryParse(widthControllers[i].text) ?? 0;
      final quantity =
          math.max(1, int.tryParse(quantityControllers[i].text) ?? 1);

      if (length > 0 && width > 0) {
        final newCut = Cut(length, width, quantity);

        if (i >= widget.cuts.length || newCut != widget.cuts[i]) {
          hasChanges = true;
        }

        newCuts.add(newCut);
      }
    }

    if (hasChanges || newCuts.length != widget.cuts.length) {
      widget.onCutsChanged(newCuts);
    }
  }

  void _addCut(double boardLength, double boardWidth) {
    setState(() {
      lengthControllers
          .add(TextEditingController(text: boardLength.toString()));
      widthControllers.add(TextEditingController(text: boardWidth.toString()));
      quantityControllers.add(TextEditingController(text: '1'));
      lengthFocusNodes.add(FocusNode());
      widthFocusNodes.add(FocusNode());
      quantityFocusNodes.add(FocusNode());
    });

    _updateCuts();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
      if (lengthFocusNodes.isNotEmpty) {
        FocusScope.of(context).requestFocus(lengthFocusNodes.last);
      }
    });
  }

  void _removeCut(int index) {
    setState(() {
      lengthControllers.removeAt(index).dispose();
      widthControllers.removeAt(index).dispose();
      quantityControllers.removeAt(index).dispose();
      lengthFocusNodes.removeAt(index).dispose();
      widthFocusNodes.removeAt(index).dispose();
      quantityFocusNodes.removeAt(index).dispose();
    });
    _updateCuts();
  }

  @override
  void dispose() {
    boardLengthController.dispose();
    boardWidthController.dispose();
    kerfController.dispose();
    boardLengthFocusNode.dispose();
    boardWidthFocusNode.dispose();
    kerfFocusNode.dispose();
    for (var controller in lengthControllers) {
      controller.dispose();
    }
    for (var controller in widthControllers) {
      controller.dispose();
    }
    for (var controller in quantityControllers) {
      controller.dispose();
    }
    for (var node in lengthFocusNodes) {
      node.dispose();
    }
    for (var node in widthFocusNodes) {
      node.dispose();
    }
    for (var node in quantityFocusNodes) {
      node.dispose();
    }
    _scrollController.dispose();
    super.dispose();
  }
}

class NumberInput extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final bool allowDecimal;
  final double? max;
  final VoidCallback? onEnter;
  final ValueChanged<String>? onChanged;
  final FocusNode focusNode;
  final TextInputAction textInputAction;
  final VoidCallback? onEditingComplete;

  const NumberInput({
    Key? key,
    required this.controller,
    required this.label,
    required this.focusNode,
    this.allowDecimal = false,
    this.max,
    this.onEnter,
    this.onChanged,
    this.textInputAction = TextInputAction.next,
    this.onEditingComplete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      decoration: InputDecoration(labelText: label),
      keyboardType: TextInputType.numberWithOptions(decimal: allowDecimal),
      textInputAction: textInputAction,
      inputFormatters: [
        FilteringTextInputFormatter.allow(
            allowDecimal ? RegExp(r'^\d*\.?\d*$') : RegExp(r'^\d*$')),
        if (max != null) _MaxValueFormatter(max!),
      ],
      onChanged: (value) {
        if (value.isNotEmpty) {
          onChanged?.call(value);
        }
      },
      onFieldSubmitted: (_) => onEnter?.call(),
      onEditingComplete: onEditingComplete,
    );
  }
}

class _MaxValueFormatter extends TextInputFormatter {
  final double maxValue;

  _MaxValueFormatter(this.maxValue);

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) {
      return newValue;
    }
    final double? value = double.tryParse(newValue.text);
    if (value == null || value <= maxValue) {
      return newValue;
    }
    return TextEditingValue(
      text: maxValue.toString(),
      selection: TextSelection.collapsed(offset: maxValue.toString().length),
    );
  }
}
