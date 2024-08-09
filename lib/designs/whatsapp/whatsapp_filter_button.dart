// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:pro_image_editor/modules/filter_editor/utils/filter_generator/filter_model.dart';

/// Represents the button for applying filters in the WhatsApp theme.
///
/// This button allows users to select and apply a filter to an image, providing
/// visual feedback and interaction in a style inspired by WhatsApp.
class WhatsAppFilterBtn extends StatefulWidget {
  /// Constructs a [WhatsAppFilterBtn] widget with the specified parameters.
  ///
  /// This button displays a filter option and indicates whether it is selected,
  /// allowing users to preview and apply filters to an image.
  ///
  /// Example:
  /// ```
  /// WhatsAppFilterBtn(
  ///   filter: myFilter,
  ///   isSelected: true,
  ///   scaleFactor: 1.0,
  ///   onSelectFilter: () {
  ///     // Handle filter selection
  ///   },
  ///   editorImage: myEditorImage,
  ///   filterKey: ValueKey('filter1'),
  /// )
  /// ```
  const WhatsAppFilterBtn({
    super.key,
    required this.filter,
    required this.isSelected,
    this.scaleFactor,
    required this.onSelectFilter,
    required this.editorImage,
    required this.filterKey,
  });

  /// The filter model associated with this button.
  ///
  /// This model contains details about the filter, such as its name and effect,
  /// allowing the button to display and apply the filter correctly.
  final FilterModel filter;

  /// Indicates whether this filter is currently selected.
  ///
  /// This flag determines the visual state of the button, providing feedback
  /// to users about the active filter.
  final bool isSelected;

  /// An optional scale factor for the button's appearance.
  ///
  /// This factor affects the size of the button, allowing for customization
  /// based on the application's design and layout needs.
  final double? scaleFactor;

  /// Callback for handling filter selection.
  ///
  /// This callback is triggered when the user selects this filter, allowing the
  /// application to update the image with the chosen filter effect.
  final Function() onSelectFilter;

  /// The widget representing the image to which the filter is applied.
  ///
  /// This image provides a preview of the filter effect, enabling users to see
  /// how the filter changes the image before applying it.
  final Widget editorImage;

  /// A unique key for this filter button.
  ///
  /// This key helps identify the button within a list of filters, ensuring that
  /// each button is uniquely recognizable by the widget tree.
  final Key filterKey;

  @override
  State<WhatsAppFilterBtn> createState() => _WhatsAppFilterBtnState();
}

class _WhatsAppFilterBtnState extends State<WhatsAppFilterBtn> {
  final Size _size = const Size(58, 88);

  @override
  Widget build(BuildContext context) {
    return Transform.scale(
      scale: widget.scaleFactor,
      child: GestureDetector(
        key: widget.filterKey,
        onTap: widget.onSelectFilter,
        child: AnimatedScale(
          scale: widget.isSelected ? 1.05 : 1,
          alignment: Alignment.bottomCenter,
          duration: const Duration(milliseconds: 200),
          child: Container(
            clipBehavior: Clip.hardEdge,
            height: _size.height,
            width: _size.width,
            decoration: const BoxDecoration(),
            child: Center(
              child: Stack(
                clipBehavior: Clip.hardEdge,
                children: [
                  widget.editorImage,
                  Align(
                    alignment: Alignment.bottomLeft,
                    child: Container(
                      color: Colors.black54,
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(2, 3, 2, 3),
                      child: Text(
                        widget.filter.name,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFFE1E1E1),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.topRight,
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      transitionBuilder: (child, animation) => FadeTransition(
                        opacity: animation,
                        child: ScaleTransition(
                          scale: animation,
                          child: child,
                        ),
                      ),
                      child: widget.isSelected
                          ? Container(
                              margin: const EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Colors.black,
                                  width: 2.5,
                                ),
                                borderRadius: BorderRadius.circular(100),
                                color: const Color(0xFF13A589),
                              ),
                              child: const Padding(
                                padding: EdgeInsets.all(2.0),
                                child: Icon(
                                  Icons.check,
                                  size: 18,
                                  color: Colors.black,
                                ),
                              ),
                            )
                          : const SizedBox.shrink(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
