// Dart imports:
import 'dart:math';

// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:pro_image_editor/models/editor_configs/pro_image_editor_configs.dart';

/// Represents the button for applying filters in the WhatsApp theme.
class WhatsAppOpenFilterBtn extends StatefulWidget {
  /// Constructs a WhatsAppFilterBtn widget with the specified parameters.
  const WhatsAppOpenFilterBtn({
    super.key,
    required this.opacity,
    required this.configs,
    this.filterTextOffsetY = 0,
  });

  /// The configuration for the image editor.
  final ProImageEditorConfigs configs;

  /// The opacity of the button.
  final double opacity;

  /// Offset for the filter text, helpful if the user has an input field that
  /// overlays in a stack widget.
  final double filterTextOffsetY;

  @override
  State<WhatsAppOpenFilterBtn> createState() => _WhatsAppOpenFilterBtnState();
}

class _WhatsAppOpenFilterBtnState extends State<WhatsAppOpenFilterBtn>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  int _repeatCount = 0;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _animation = Tween<double>(
      begin: -3,
      end: 3,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _controller
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _repeatCount++;
          if (_repeatCount < 2) {
            _controller.reverse();
          }
        } else if (status == AnimationStatus.dismissed && _repeatCount < 2) {
          _controller.forward();
        }
      })
      // Start the animation when the widget initializes
      ..forward();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 50 + widget.filterTextOffsetY,
      child: Opacity(
        opacity: max(0, min(1, widget.opacity)),
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(0, _animation.value),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(Icons.keyboard_arrow_up),
                  Text(
                    widget.configs.i18n.filterEditor.bottomNavigationBarText,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
