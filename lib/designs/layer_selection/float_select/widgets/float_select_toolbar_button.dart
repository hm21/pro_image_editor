import 'package:material_ui/material_ui.dart';

/// A styled text button used in the FloatSelect toolbar
class FloatSelectToolbarButton extends StatelessWidget {
  /// Creates a toolbar button with custom styles
  const FloatSelectToolbarButton({
    super.key,
    this.onTap,
    required this.text,
    required this.textStyle,
    required this.disabledTextStyle,
  });

  /// The text label of the button
  final String text;

  /// Text style when the button is enabled
  final TextStyle textStyle;

  /// Text style when the button is disabled
  final TextStyle disabledTextStyle;

  /// Callback triggered when the button is tapped
  final Function()? onTap;

  @override
  Widget build(BuildContext context) {
    final isEnabled = onTap != null;

    return TextButton(
      onPressed: onTap,
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
        backgroundColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      ),
      child: Text(text, style: isEnabled ? textStyle : disabledTextStyle),
    );
  }
}
