// Flutter imports:
import 'package:flutter/material.dart';
import 'package:pro_image_editor/pro_image_editor.dart';

// Project imports:
import 'frosted_glass_effect.dart';

class FrostedGlassLoadingDialog extends StatelessWidget {
  final String message;
  final ProImageEditorConfigs configs;

  const FrostedGlassLoadingDialog({
    super.key,
    required this.message,
    required this.configs,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const ModalBarrier(color: Colors.black38),
        Center(
          child: DefaultTextStyle(
            style: const TextStyle(),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: FrostedGlassEffect(
                radius: BorderRadius.circular(16),
                child: Container(
                  color: Colors.transparent,
                  constraints: const BoxConstraints(maxWidth: 280),
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 20.0),
                        child: SizedBox(
                          height: 40,
                          width: 40,
                          child: FittedBox(
                            child: CircularProgressIndicator(
                              color: Colors.blue.shade200,
                            ),
                          ),
                        ),
                      ),
                      const Expanded(
                        child: Text(
                          'Please wait...',
                          style: TextStyle(fontSize: 16, color: Colors.white),
                          textAlign: TextAlign.start,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
