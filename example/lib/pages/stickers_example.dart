// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:pro_image_editor/pro_image_editor.dart';

// Project imports:
import '../utils/example_helper.dart';

class StickersExample extends StatefulWidget {
  const StickersExample({super.key});

  @override
  State<StickersExample> createState() => _StickersExampleState();
}

class _StickersExampleState extends State<StickersExample>
    with ExampleHelperState<StickersExample> {
  final String _url = 'https://picsum.photos/id/176/2000';

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () async {
        LoadingDialog.instance.show(
          context,
          configs: const ProImageEditorConfigs(),
          theme: ThemeData.dark(),
        );
        await precacheImage(NetworkImage(_url), context);
        LoadingDialog.instance.hide();
        if (!context.mounted) return;
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
      _url,
      callbacks: ProImageEditorCallbacks(
        onImageEditingStarted: onImageEditingStarted,
        onImageEditingComplete: onImageEditingComplete,
        onCloseEditor: onCloseEditor,
      ),
      configs: ProImageEditorConfigs(
        designMode: platformDesignMode,
        blurEditorConfigs: const BlurEditorConfigs(enabled: false),
        stickerEditorConfigs: StickerEditorConfigs(
          enabled: true,
          buildStickers: (setLayer, scrollController) {
            return ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(20)),
              child: GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 80,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                ),
                controller: scrollController,
                itemCount: 21,
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () async {
                      // Important make sure the image is completely loaded
                      // cuz the editor will directly take a screenshot
                      // inside of a background isolated thread.
                      LoadingDialog.instance.show(
                        context,
                        configs: const ProImageEditorConfigs(),
                        theme: ThemeData.dark(),
                      );
                      await precacheImage(
                          NetworkImage(
                              'https://picsum.photos/id/${(index + 3) * 3}/2000'),
                          context);
                      LoadingDialog.instance.hide();
                      setLayer(Sticker(index: index));
                    },
                    child: MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: Sticker(index: index),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}

class Sticker extends StatefulWidget {
  final int index;

  const Sticker({
    super.key,
    required this.index,
  });

  @override
  State<Sticker> createState() => StickerState();
}

class StickerState extends State<Sticker> {
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(7),
      child: Image.network(
        'https://picsum.photos/id/${(widget.index + 3) * 3}/2000',
        width: 80,
        height: 80,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          return AnimatedSwitcher(
            layoutBuilder: (currentChild, previousChildren) {
              return SizedBox(
                width: 80,
                height: 80,
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
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                          : null,
                    ),
                  ),
          );
        },
      ),
    );
  }
}
