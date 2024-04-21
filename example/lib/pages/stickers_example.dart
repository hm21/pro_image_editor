import 'package:flutter/material.dart';
import 'package:pro_image_editor/pro_image_editor.dart';

import '../utils/example_helper.dart';

class StickersExample extends StatefulWidget {
  const StickersExample({super.key});

  @override
  State<StickersExample> createState() => _StickersExampleState();
}

class _StickersExampleState extends State<StickersExample>
    with ExampleHelperState<StickersExample> {
  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => _buildEditor(),
          ),
        );
      },
      leading: const Icon(Icons.image_outlined),
      title: const Text('Custom Stickers'),
      trailing: const Icon(Icons.chevron_right),
    );
  }

  Widget _buildEditor() {
    return ProImageEditor.network(
      'https://picsum.photos/id/176/2000',
      onImageEditingComplete: onImageEditingComplete,
      onCloseEditor: onCloseEditor,
      configs: ProImageEditorConfigs(
        blurEditorConfigs: const BlurEditorConfigs(enabled: false),
        stickerEditorConfigs: StickerEditorConfigs(
          enabled: true,
          buildStickers: (setLayer) {
            return ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(20)),
              child: Container(
                color: const Color.fromARGB(255, 224, 239, 251),
                child: GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 150,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                  ),
                  itemCount: 21,
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    Widget widget = ClipRRect(
                      borderRadius: BorderRadius.circular(7),
                      child: Image.network(
                        'https://picsum.photos/id/${(index + 3) * 3}/2000',
                        width: 120,
                        height: 120,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          return AnimatedSwitcher(
                            layoutBuilder: (currentChild, previousChildren) {
                              return SizedBox(
                                width: 120,
                                height: 120,
                                child: Stack(
                                  fit: StackFit.expand,
                                  alignment: Alignment.center,
                                  children: <Widget>[
                                    ...previousChildren,
                                    if (currentChild != null) currentChild,
                                  ],
                                ),
                              );
                            },
                            duration: const Duration(milliseconds: 200),
                            child: loadingProgress == null
                                ? child
                                : Center(
                                    child: CircularProgressIndicator(
                                      value:
                                          loadingProgress.expectedTotalBytes !=
                                                  null
                                              ? loadingProgress
                                                      .cumulativeBytesLoaded /
                                                  loadingProgress
                                                      .expectedTotalBytes!
                                              : null,
                                    ),
                                  ),
                          );
                        },
                      ),
                    );
                    return GestureDetector(
                      onTap: () => setLayer(widget),
                      child: MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: widget,
                      ),
                    );
                  },
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
