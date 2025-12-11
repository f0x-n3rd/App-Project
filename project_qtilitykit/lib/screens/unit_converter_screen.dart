import 'package:flutter/material.dart';
import 'package:project_qtilitykit/services/unit_conversion_service.dart';

class UnitConverterScreen extends StatefulWidget {
  const UnitConverterScreen({super.key});

  @override
  State<UnitConverterScreen> createState() => _UnitConverterScreenState();
}

class _UnitConverterScreenState extends State<UnitConverterScreen> {
  UnitCategory _category = UnitCategory.length;

  final TextEditingController _inputCtrl = TextEditingController();
  final TextEditingController _outputCtrl = TextEditingController();

  // Default units
  LengthUnit _fromLength = LengthUnit.meter;
  LengthUnit _toLength = LengthUnit.kilometer;

  WeightUnit _fromWeight = WeightUnit.kilogram;
  WeightUnit _toWeight = WeightUnit.gram;

  TemperatureUnit _fromTemp = TemperatureUnit.celsius;
  TemperatureUnit _toTemp = TemperatureUnit.fahrenheit;

  VolumeUnit _fromVolume = VolumeUnit.liter;
  VolumeUnit _toVolume = VolumeUnit.milliliter;

  // ----------------------------------------------------------
  // MAIN CONVERSION LOGIC
  // ----------------------------------------------------------
  void _convert({bool reverse = false}) {
    final input = (reverse ? _outputCtrl.text : _inputCtrl.text).trim();
    final value = double.tryParse(input);

    if (value == null) {
      if (reverse) {
        _inputCtrl.text = "";
      } else {
        _outputCtrl.text = "";
      }
      return;
    }

    double result;

    // Correctly compute reversed direction
    switch (_category) {
      case UnitCategory.length:
        result = reverse
            ? UnitConversionService.convertLength(value, _toLength, _fromLength)
            : UnitConversionService.convertLength(
                value,
                _fromLength,
                _toLength,
              );
        break;

      case UnitCategory.weight:
        result = reverse
            ? UnitConversionService.convertWeight(value, _toWeight, _fromWeight)
            : UnitConversionService.convertWeight(
                value,
                _fromWeight,
                _toWeight,
              );
        break;

      case UnitCategory.temperature:
        result = reverse
            ? UnitConversionService.convertTemperature(
                value,
                _toTemp,
                _fromTemp,
              )
            : UnitConversionService.convertTemperature(
                value,
                _fromTemp,
                _toTemp,
              );
        break;

      case UnitCategory.volume:
        result = reverse
            ? UnitConversionService.convertVolume(value, _toVolume, _fromVolume)
            : UnitConversionService.convertVolume(
                value,
                _fromVolume,
                _toVolume,
              );
        break;
    }

    // Correctly update the right controller
    if (reverse) {
      _inputCtrl.text = result.toString();
    } else {
      _outputCtrl.text = result.toString();
    }
  }

  // ----------------------------------------------------------
  // SWAP UNITS + VALUES
  // ----------------------------------------------------------
  void _swapUnits() {
    switch (_category) {
      case UnitCategory.length:
        final temp = _fromLength;
        _fromLength = _toLength;
        _toLength = temp;
        break;

      case UnitCategory.weight:
        final temp = _fromWeight;
        _fromWeight = _toWeight;
        _toWeight = temp;
        break;

      case UnitCategory.temperature:
        final temp = _fromTemp;
        _fromTemp = _toTemp;
        _toTemp = temp;
        break;

      case UnitCategory.volume:
        final temp = _fromVolume;
        _fromVolume = _toVolume;
        _toVolume = temp;
        break;
    }

    // Swap values in the text fields
    final tmp = _inputCtrl.text;
    _inputCtrl.text = _outputCtrl.text;
    _outputCtrl.text = tmp;

    // NEW: recalc based on the swapped input
    _convert();
  }

  // ----------------------------------------------------------
  // UI
  // ----------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Unit Converter"),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // CATEGORY DROPDOWN
            DropdownButton<UnitCategory>(
              value: _category,
              items: UnitCategory.values
                  .map(
                    (c) => DropdownMenuItem(
                      value: c,
                      child: Text(c.name.toUpperCase()),
                    ),
                  )
                  .toList(),
              onChanged: (v) {
                setState(() {
                  _category = v!;
                  _inputCtrl.clear();
                  _outputCtrl.clear();
                });
              },
            ),

            const SizedBox(height: 20),

            // INPUT
            _buildInputSection(),

            const SizedBox(height: 16),

            // SWAP BUTTON
            IconButton(
              onPressed: _swapUnits,
              icon: const Icon(Icons.swap_vert, size: 32),
            ),

            const SizedBox(height: 16),

            // OUTPUT
            _buildOutputSection(),
          ],
        ),
      ),
    );
  }

  // ----------------------------------------------------------
  // INPUT BOX + FROM UNIT
  // ----------------------------------------------------------
  Widget _buildInputSection() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _inputCtrl,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: "Input",
            ),
            onChanged: (_) => _convert(),
          ),
        ),
        const SizedBox(width: 10),
        _unitDropdown(isFrom: true),
      ],
    );
  }

  // ----------------------------------------------------------
  // OUTPUT BOX + TO UNIT
  // ----------------------------------------------------------
  Widget _buildOutputSection() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _outputCtrl,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: "Output",
            ),
            onChanged: (_) => _convert(reverse: true),
          ),
        ),
        const SizedBox(width: 10),
        _unitDropdown(isFrom: false),
      ],
    );
  }

  // ----------------------------------------------------------
  // UNIT DROPDOWNS PER CATEGORY
  // ----------------------------------------------------------
  Widget _unitDropdown({required bool isFrom}) {
    switch (_category) {
      case UnitCategory.length:
        return _dropdown<LengthUnit>(
          isFrom ? _fromLength : _toLength,
          LengthUnit.values,
          (v) {
            setState(() {
              if (isFrom) {
                _fromLength = v;
              } else {
                _toLength = v;
              }
              _convert();
            });
          },
        );

      case UnitCategory.weight:
        return _dropdown<WeightUnit>(
          isFrom ? _fromWeight : _toWeight,
          WeightUnit.values,
          (v) {
            setState(() {
              if (isFrom) {
                _fromWeight = v;
              } else {
                _toWeight = v;
              }
              _convert();
            });
          },
        );

      case UnitCategory.temperature:
        return _dropdown<TemperatureUnit>(
          isFrom ? _fromTemp : _toTemp,
          TemperatureUnit.values,
          (v) {
            setState(() {
              if (isFrom) {
                _fromTemp = v;
              } else {
                _toTemp = v;
              }
              _convert();
            });
          },
        );

      case UnitCategory.volume:
        return _dropdown<VolumeUnit>(
          isFrom ? _fromVolume : _toVolume,
          VolumeUnit.values,
          (v) {
            setState(() {
              if (isFrom) {
                _fromVolume = v;
              } else {
                _toVolume = v;
              }
              _convert();
            });
          },
        );
    }
  }

  // ----------------------------------------------------------
  // GENERIC DROPDOWN BUILDER
  // ----------------------------------------------------------
  Widget _dropdown<T>(T selected, List<T> items, ValueChanged<T> onChanged) {
    return DropdownButton<T>(
      value: selected,
      items: items
          .map(
            (u) => DropdownMenuItem(
              value: u,
              child: Text(u.toString().split('.').last),
            ),
          )
          .toList(),
      onChanged: (v) {
        if (v != null) onChanged(v);
      },
    );
  }
}
