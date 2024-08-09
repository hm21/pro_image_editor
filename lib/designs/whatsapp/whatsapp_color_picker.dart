// Flutter imports:
import 'package:flutter/material.dart';

/// A stateful widget that provides a color picker inspired by WhatsApp.
///
/// This color picker allows users to select a color, providing a callback for
/// color changes and initializing with a specified color.
class WhatsAppColorPicker extends StatefulWidget {
  /// Creates a [WhatsAppColorPicker].
  ///
  /// This color picker lets users select a color, triggering a callback when
  /// the color changes, and initializing with a specified color.
  ///
  /// Example:
  /// ```
  /// WhatsAppColorPicker(
  ///   onColorChanged: (color) {
  ///     // Handle color change
  ///   },
  ///   initColor: Colors.blue,
  /// )
  /// ```
  const WhatsAppColorPicker({
    super.key,
    required this.onColorChanged,
    required this.initColor,
  });

  /// Callback for handling color changes.
  ///
  /// This callback is triggered whenever the user selects a new color, allowing
  /// the application to update its UI or perform other actions.
  final ValueChanged<Color> onColorChanged;

  /// The initial color selected in the color picker.
  ///
  /// This color sets the initial value of the picker, providing a starting
  /// point for color selection.
  final Color initColor;

  @override
  State<WhatsAppColorPicker> createState() => _WhatsAppColorPickerState();
}

class _WhatsAppColorPickerState extends State<WhatsAppColorPicker> {
  Color _selectedColor = Colors.black;

  final List<Color> _colors = [
    Colors.white,
    Colors.black,
    const Color(0xFF81DA58),
    Colors.blue,
    Colors.red,
    Colors.pink,
    Colors.yellow.shade600,
    Colors.green.shade500,
    Colors.orange,
    Colors.purple,
    Colors.redAccent.shade200,
    Colors.brown.shade100,
    Colors.brown.shade800,
    Colors.brown.shade600,
    Colors.brown.shade400,
    Colors.brown.shade200,
    Colors.green.shade800,
    Colors.lightGreen.shade600,
    Colors.blueGrey.shade800,
    Colors.grey.shade700,
    Colors.grey.shade500,
    Colors.grey.shade300,
    Colors.grey.shade100,
  ];

  @override
  void initState() {
    _selectedColor = widget.initColor;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      scrollDirection: Axis.horizontal,
      primary: false,
      shrinkWrap: true,
      itemBuilder: (context, index) {
        Color color = _colors[index];
        bool selected = _selectedColor == color;

        double size = !selected ? 20 : 24;
        double borderWidth = !selected ? 2.5 : 4;

        return Center(
          child: GestureDetector(
            onTap: () {
              setState(() {
                _selectedColor = color;
                widget.onColorChanged(color);
              });
            },
            child: AnimatedContainer(
              margin: const EdgeInsets.symmetric(horizontal: 10.0),
              duration: const Duration(milliseconds: 100),
              width: size,
              height: size,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(100),
                border: Border.all(
                  color: Colors.white,
                  width: borderWidth,
                ),
              ),
            ),
          ),
        );
      },
      itemCount: _colors.length,
    );
  }
}
