// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:pro_image_editor/modules/filter_editor/utils/filter_generator/filter_model.dart';

/// Represents the button for applying filters in the WhatsApp theme.
class WhatsAppFilterBtn extends StatefulWidget {
  final FilterModel filter;
  final bool isSelected;
  final double? scaleFactor;
  final Function() onSelectFilter;
  final Widget editorImage;
  final Key filterKey;

  /// Constructs a WhatsAppFilterBtn widget with the specified parameters.
  const WhatsAppFilterBtn({
    super.key,
    required this.filter,
    required this.isSelected,
    this.scaleFactor,
    required this.onSelectFilter,
    required this.editorImage,
    required this.filterKey,
  });

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
