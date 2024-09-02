import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'cut.dart';

class NumberInput extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final bool allowDecimal;
  final double? max;
  final VoidCallback? onEnter;
  final ValueChanged<String>? onChanged;
  final FocusNode? focusNode;

  const NumberInput({
    super.key,
    required this.controller,
    required this.label,
    this.allowDecimal = false,
    this.max,
    this.onEnter,
    this.onChanged,
    this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      decoration: InputDecoration(labelText: label),
      keyboardType: TextInputType.numberWithOptions(decimal: allowDecimal),
      inputFormatters: [
        FilteringTextInputFormatter.allow(
            allowDecimal ? RegExp(r'^\d*\.?\d*$') : RegExp(r'^\d*$')),
        if (max != null) _MaxValueFormatter(max!),
      ],
      onChanged: onChanged,
      onFieldSubmitted: (_) => onEnter?.call(),
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

class DataInputSection extends StatefulWidget {
  final String selectedMaterial;
  final double kerfValue;
  final List<Cut> cuts;
  final double boardLength;
  final void Function(String) onMaterialSelected;
  final void Function(double) onKerfChanged;
  final void Function(List<Cut>) onCutsChanged;

  const DataInputSection({
    super.key,
    required this.selectedMaterial,
    required this.kerfValue,
    required this.cuts,
    required this.boardLength,
    required this.onMaterialSelected,
    required this.onKerfChanged,
    required this.onCutsChanged,
  });

  @override
  State<DataInputSection> createState() => _DataInputSectionState();
}

class _DataInputSectionState extends State<DataInputSection> {
  final List<String> materials = ['2x2x96', '2x4x96'];
  late TextEditingController kerfController;
  late List<TextEditingController> lengthControllers;
  late List<TextEditingController> quantityControllers;
  late List<FocusNode> lengthFocusNodes;
  late List<FocusNode> quantityFocusNodes;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    kerfController = TextEditingController(text: widget.kerfValue.toString());
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
    quantityControllers = List.generate(
      widget.cuts.length,
      (index) =>
          TextEditingController(text: widget.cuts[index].quantity.toString()),
    );
    lengthFocusNodes = List.generate(widget.cuts.length, (_) => FocusNode());
    quantityFocusNodes = List.generate(widget.cuts.length, (_) => FocusNode());
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      controller: _scrollController,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DropdownButtonFormField<String>(
              value: materials.contains(widget.selectedMaterial)
                  ? widget.selectedMaterial
                  : null,
              decoration: const InputDecoration(labelText: 'Select Material'),
              items: materials.map((String material) {
                return DropdownMenuItem<String>(
                  value: material,
                  child: Text(material),
                );
              }).toList(),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  widget.onMaterialSelected(newValue);
                }
              },
            ),
            const SizedBox(height: 16),
            NumberInput(
              controller: kerfController,
              label: 'Blade Kerf (inches)',
              allowDecimal: true,
              onChanged: (value) {
                widget
                    .onKerfChanged(double.tryParse(value) ?? widget.kerfValue);
              },
            ),
            const SizedBox(height: 16),
            const Text('Enter Cuts:',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: widget.cuts.length,
              itemBuilder: (context, index) {
                return _buildCutRow(index);
              },
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _addCut,
              child: const Text('Add Cut'),
            ),
          ],
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
            onEnter: () => quantityFocusNodes[index].requestFocus(),
            onChanged: (_) => _updateCuts(),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: NumberInput(
            controller: quantityControllers[index],
            focusNode: quantityFocusNodes[index],
            label: 'Quantity',
            onEnter: _addCut,
            onChanged: (_) => _updateCuts(),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.delete),
          onPressed: () => _removeCut(index),
        ),
      ],
    );
  }

  void _addCut() {
    setState(() {
      widget.cuts.add(Cut(0, 1));
      lengthControllers.add(TextEditingController(text: '0'));
      quantityControllers.add(TextEditingController(text: '1'));
      lengthFocusNodes.add(FocusNode());
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
        lengthFocusNodes.last.requestFocus();
      }
    });
  }

  void _removeCut(int index) {
    setState(() {
      widget.cuts.removeAt(index);
      lengthControllers.removeAt(index).dispose();
      quantityControllers.removeAt(index).dispose();
      lengthFocusNodes.removeAt(index).dispose();
      quantityFocusNodes.removeAt(index).dispose();
    });
    _updateCuts();
  }

  void _updateCuts() {
    final newCuts = <Cut>[];
    for (int i = 0; i < lengthControllers.length; i++) {
      final length = double.tryParse(lengthControllers[i].text) ?? 0;
      final quantity = int.tryParse(quantityControllers[i].text) ?? 0;
      newCuts.add(Cut(length, quantity));
    }
    widget.onCutsChanged(newCuts);
  }

  @override
  void dispose() {
    kerfController.dispose();
    for (var controller in lengthControllers) {
      controller.dispose();
    }
    for (var controller in quantityControllers) {
      controller.dispose();
    }
    for (var node in lengthFocusNodes) {
      node.dispose();
    }
    for (var node in quantityFocusNodes) {
      node.dispose();
    }
    _scrollController.dispose();
    super.dispose();
  }
}
