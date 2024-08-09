// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:pro_image_editor/designs/whatsapp/whatsapp_color_picker.dart';
import 'package:pro_image_editor/pro_image_editor.dart';
import 'package:pro_image_editor/utils/pro_image_editor_icons.dart';

/// Represents the bottom bar for the paint functionality in the WhatsApp theme.
///
/// This widget provides controls for adjusting the stroke width and color
/// for painting operations, using a design inspired by WhatsApp.
class WhatsAppPaintBottomBar extends StatefulWidget {
  /// Creates a [WhatsAppPaintBottomBar] widget.
  ///
  /// This bottom bar allows users to select stroke widths and colors for
  /// painting, integrating seamlessly with the WhatsApp theme.
  ///
  /// Example:
  /// ```
  /// WhatsAppPaintBottomBar(
  ///   configs: myEditorConfigs,
  ///   strokeWidth: 5.0,
  ///   onSetLineWidth: (width) {
  ///     // Handle stroke width change
  ///   },
  ///   initColor: Colors.black,
  ///   onColorChanged: (color) {
  ///     // Handle color change
  ///   },
  /// )
  /// ```
  const WhatsAppPaintBottomBar({
    super.key,
    required this.configs,
    required this.strokeWidth,
    required this.onSetLineWidth,
    required this.initColor,
    required this.onColorChanged,
    this.iconStrokeWidthThin = ProImageEditorIcons.penSize1,
    this.iconStrokeWidthMedium = ProImageEditorIcons.penSize2,
    this.iconStrokeWidthBold = ProImageEditorIcons.penSize3,
  });

  /// The configuration for the image editor.
  ///
  /// These settings determine various aspects of the bottom bar's behavior
  /// and appearance, ensuring it aligns with the application's overall theme.
  final ProImageEditorConfigs configs;

  /// The current stroke width for painting.
  ///
  /// This value determines the thickness of the lines drawn in the painting
  /// editor, allowing users to customize the appearance of their artwork.
  final double strokeWidth;

  /// Callback function for setting the stroke width.
  ///
  /// This function is called whenever the user selects a different stroke
  /// width, allowing the application to update the line thickness.
  final Function(double value) onSetLineWidth;

  /// The initial color for painting.
  ///
  /// This color sets the initial paint color, providing a starting point
  /// for color customization.
  final Color initColor;

  /// Callback function for handling color changes.
  ///
  /// This function is called whenever the user selects a new color, allowing
  /// the application to update the painting color.
  final ValueChanged<Color> onColorChanged;

  /// Icon representing thin stroke width.
  ///
  /// This icon is used to visually represent the option for selecting a
  /// thin stroke width in the paint toolbar.
  final IconData iconStrokeWidthThin;

  /// Icon representing medium stroke width.
  ///
  /// This icon is used to visually represent the option for selecting a
  /// medium stroke width in the paint toolbar.
  final IconData iconStrokeWidthMedium;

  /// Icon representing bold stroke width.
  ///
  /// This icon is used to visually represent the option for selecting a
  /// bold stroke width in the paint toolbar.
  final IconData iconStrokeWidthBold;

  @override
  State<WhatsAppPaintBottomBar> createState() => _WhatsAppPaintBottomBarState();
}

class _WhatsAppPaintBottomBarState extends State<WhatsAppPaintBottomBar> {
  final double _space = 10;

  bool _showColorPicker = true;

  bool get _isMaterial =>
      widget.configs.designMode == ImageEditorDesignModeE.material;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: _space,
      left: _space,
      right: 0,
      height: 40,
      child: !_isMaterial
          ? _buildLineWidths()
          : Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                IconButton(
                  onPressed: () {
                    setState(() {
                      _showColorPicker = !_showColorPicker;
                    });
                  },
                  icon: Icon(
                    _showColorPicker ? Icons.draw : Icons.color_lens,
                  ),
                  style: IconButton.styleFrom(backgroundColor: Colors.black38),
                ),
                Container(
                  margin: const EdgeInsets.fromLTRB(14.0, 4, 0, 4),
                  width: 1.5,
                  decoration: BoxDecoration(
                    color: Colors.white54,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                _showColorPicker
                    ? Expanded(
                        child: WhatsAppColorPicker(
                          onColorChanged: widget.onColorChanged,
                          initColor: widget.initColor,
                        ),
                      )
                    : _buildLineWidths(),
              ],
            ),
    );
  }

  Widget _buildLineWidths() {
    ButtonStyle buttonStyle = IconButton.styleFrom(
      backgroundColor: Colors.black38,
      foregroundColor: widget
          .configs.imageEditorTheme.paintingEditor.bottomBarInactiveItemColor,
      padding: const EdgeInsets.all(10),
      iconSize: 22,
      minimumSize: const Size.fromRadius(10),
    );
    return Padding(
      padding: const EdgeInsets.only(left: 14),
      child: Wrap(
        alignment:
            _isMaterial ? WrapAlignment.start : WrapAlignment.spaceEvenly,
        runAlignment: WrapAlignment.center,
        spacing: 10,
        children: [
          IconButton(
            onPressed: () {
              widget.onSetLineWidth(2);
            },
            icon: Icon(widget.iconStrokeWidthThin),
            style: buttonStyle.copyWith(
              backgroundColor: widget.strokeWidth != 2
                  ? null
                  : const WidgetStatePropertyAll(Colors.white),
              foregroundColor: widget.strokeWidth != 2
                  ? null
                  : const WidgetStatePropertyAll(Colors.black),
            ),
          ),
          IconButton(
            onPressed: () {
              widget.onSetLineWidth(5);
            },
            icon: Icon(widget.iconStrokeWidthMedium),
            style: buttonStyle.copyWith(
              backgroundColor: widget.strokeWidth != 5
                  ? null
                  : const WidgetStatePropertyAll(Colors.white),
              foregroundColor: widget.strokeWidth != 5
                  ? null
                  : const WidgetStatePropertyAll(Colors.black),
            ),
          ),
          IconButton(
            onPressed: () {
              widget.onSetLineWidth(10);
            },
            icon: Icon(widget.iconStrokeWidthBold),
            style: buttonStyle.copyWith(
              backgroundColor: widget.strokeWidth != 10
                  ? null
                  : const WidgetStatePropertyAll(Colors.white),
              foregroundColor: widget.strokeWidth != 10
                  ? null
                  : const WidgetStatePropertyAll(Colors.black),
            ),
          ),
        ],
      ),
    );
  }
}
