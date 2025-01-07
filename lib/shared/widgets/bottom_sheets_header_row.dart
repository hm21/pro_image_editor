// Flutter imports:
import 'package:flutter/material.dart';

/// A custom widget for the header row of a bottom sheet.
class BottomSheetHeaderRow extends StatefulWidget {
  /// Creates a [BottomSheetHeaderRow] widget with the specified title, theme,
  /// and padding.
  const BottomSheetHeaderRow(
      {super.key,
      required this.title,
      required this.theme,
      this.padding,
      this.closeButton,
      this.textStyle});

  /// The text style from the title.
  final TextStyle? textStyle;

  /// The title to display in the header row.
  final String title;

  /// The theme data used for styling the header row.
  final ThemeData theme;

  /// Optional padding to apply around the header row.
  final EdgeInsetsGeometry? padding;

  /// Custom close button
  final Widget Function(Function() tap)? closeButton;

  @override
  State<BottomSheetHeaderRow> createState() => _BottomSheetHeaderRowState();
}

class _BottomSheetHeaderRowState extends State<BottomSheetHeaderRow> {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return Padding(
        padding: widget.padding ?? const EdgeInsets.only(bottom: 8.0, top: 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Flexible(
              child: Text(
                widget.title,
                style: widget.textStyle ??
                    TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: widget.theme.textTheme.bodyLarge?.color,
                    ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            widget.closeButton?.call(() => Navigator.pop(context)) ??
                IconButton(
                  icon: Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      color: widget.theme.brightness == Brightness.dark
                          ? Colors.grey.shade800
                          : Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: Icon(
                      Icons.close,
                      size: 20,
                      color: widget.theme.iconTheme.color,
                    ),
                  ),
                  onPressed: () => Navigator.pop(context),
                )
          ],
        ),
      );
    });
  }
}
