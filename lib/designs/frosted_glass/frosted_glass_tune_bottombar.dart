// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:pro_image_editor/pro_image_editor.dart';
import 'frosted_glass_effect.dart';

/// A custom bottom bar widget that creates a frosted glass effect for the
/// Tune Editor.
///
/// This widget is used to display the bottom bar with a frosted glass style
/// on top of the Tune Editor.
class FrostedGlassTuneBottombar extends StatelessWidget {
  /// Creates a [FrostedGlassTuneBottombar] with the provided [tuneEditor]
  /// state.
  ///
  /// The [tuneEditor] parameter is required to access the state of the
  /// Tune Editor.
  const FrostedGlassTuneBottombar({
    super.key,
    required this.tuneEditor,
  });

  /// The current state of the [TuneEditor].
  ///
  /// This provides access to the Tune Editor's state and enables
  /// interaction with its features.
  final TuneEditorState tuneEditor;

  @override
  Widget build(BuildContext context) {
    var bottomTextStyle = const TextStyle(fontSize: 10.0, color: Colors.white);
    double bottomIconSize = 22.0;
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: SafeArea(
        child: FrostedGlassEffect(
          radius: BorderRadius.zero,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 800),
                child: RepaintBoundary(
                  child: StreamBuilder(
                      stream: tuneEditor.uiStream.stream,
                      builder: (context, snapshot) {
                        var activeOption = tuneEditor
                            .tuneAdjustmentList[tuneEditor.selectedIndex];
                        var activeMatrix = tuneEditor
                            .tuneAdjustmentMatrix[tuneEditor.selectedIndex];
                        return SizedBox(
                          height: 40,
                          child: Slider(
                            min: activeOption.min,
                            max: activeOption.max,
                            divisions: activeOption.divisions,
                            label: (activeMatrix.value *
                                    activeOption.labelMultiplier)
                                .round()
                                .toString(),
                            value: activeMatrix.value,
                            onChangeStart: tuneEditor.onChangedStart,
                            onChanged: tuneEditor.onChanged,
                            onChangeEnd: tuneEditor.onChangedEnd,
                          ),
                        );
                      }),
                ),
              ),
              const SizedBox(height: 4),
              SizedBox(
                height: kBottomNavigationBarHeight,
                child: Scrollbar(
                  controller: tuneEditor.bottomBarScrollCtrl,
                  scrollbarOrientation: ScrollbarOrientation.bottom,
                  thickness: isDesktop ? null : 0,
                  child: SingleChildScrollView(
                    controller: tuneEditor.bottomBarScrollCtrl,
                    scrollDirection: Axis.horizontal,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(12.0, 0, 12.0, 6.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        mainAxisSize: MainAxisSize.min,
                        children: List.generate(
                            tuneEditor.tuneAdjustmentMatrix.length, (index) {
                          var item = tuneEditor.tuneAdjustmentList[index];
                          return FlatIconTextButton(
                            label: Text(item.label, style: bottomTextStyle),
                            icon: Icon(
                              item.icon,
                              size: bottomIconSize,
                              color: tuneEditor.selectedIndex == index
                                  ? imageEditorPrimaryColor
                                  : Colors.white,
                            ),
                            onPressed: () {
                              tuneEditor.setState(() {
                                tuneEditor.selectedIndex = index;
                              });
                            },
                          );
                        }),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
