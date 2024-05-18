// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:pro_image_editor/pro_image_editor.dart';
import 'package:pro_image_editor/widgets/loading_dialog.dart';

// Project imports:
import '../utils/example_helper.dart';

class StickersExample extends StatefulWidget {
  const StickersExample({super.key});

  @override
  State<StickersExample> createState() => _StickersExampleState();
}

class _StickersExampleState extends State<StickersExample>
    with ExampleHelperState<StickersExample> {
  final Map<int, GlobalKey<StickerState>> _keys = {};

  final String _url = 'https://picsum.photos/id/176/2000';

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () async {
        LoadingDialog loading = LoadingDialog()
          ..show(
            context,
            configs: const ProImageEditorConfigs(),
            theme: ThemeData.dark(),
          );
        await precacheImage(NetworkImage(_url), context);
        if (context.mounted) await loading.hide(context);
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
        onImageEditingComplete: onImageEditingComplete,
        onCloseEditor: onCloseEditor,
      ),
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
                    if (!_keys.containsKey(index)) _keys[index] = GlobalKey();

                    return GestureDetector(
                      onTap: () async {
                        // Important make sure the image is completly loaded
                        // cuz the editor will directly take a screenshot
                        // inside of a background isolated thread.
                        await _keys[index]!
                            .currentState!
                            .imgLoadedCompleter
                            .future;
                        setLayer(Sticker(index: index));
                      },
                      child: MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: Sticker(key: _keys[index], index: index),
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
  final Completer imgLoadedCompleter = Completer.sync();

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(7),
      child: Image.network(
        'https://picsum.photos/id/${(widget.index + 3) * 3}/2000',
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
                ? Builder(builder: (context) {
                    if (!imgLoadedCompleter.isCompleted) {
                      imgLoadedCompleter.complete();
                    }
                    return child;
                  })
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
