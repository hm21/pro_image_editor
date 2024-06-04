// Dart imports:
import 'dart:math';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:google_fonts/google_fonts.dart';
import 'package:pro_image_editor/pro_image_editor.dart';
import 'package:pro_image_editor/widgets/loading_dialog.dart';

// Project imports:
import '../utils/example_helper.dart';

class WhatsAppExample extends StatefulWidget {
  const WhatsAppExample({super.key});

  @override
  State<WhatsAppExample> createState() => _WhatsAppExampleState();
}

class _WhatsAppExampleState extends State<WhatsAppExample>
    with ExampleHelperState<WhatsAppExample> {
  final String _url = 'https://picsum.photos/id/350/1500/3000';
  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () async {
        LoadingDialog loading = LoadingDialog();
        await loading.show(
          context,
          configs: const ProImageEditorConfigs(),
          theme: ThemeData.dark(),
        );
        if (!context.mounted) return;
        await precacheImage(NetworkImage(_url), context);
        if (context.mounted) await loading.hide(context);
        if (!context.mounted) return;
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => _buildEditor(),
          ),
        );
      },
      leading: const Icon(Icons.chat_outlined),
      title: const Text('WhatsApp Theme'),
      trailing: const Icon(Icons.chevron_right),
    );
  }

  Widget _buildEditor() {
    return ProImageEditor.network(
      _url,
      key: editorKey,
      callbacks: ProImageEditorCallbacks(
        onImageEditingStarted: onImageEditingStarted,
        onImageEditingComplete: onImageEditingComplete,
        onCloseEditor: onCloseEditor,
      ),
      configs: ProImageEditorConfigs(
        textEditorConfigs: TextEditorConfigs(
          customTextStyles: [
            GoogleFonts.roboto(),
            GoogleFonts.averiaLibre(),
            GoogleFonts.lato(),
            GoogleFonts.comicNeue(),
            GoogleFonts.actor(),
            GoogleFonts.odorMeanChey(),
            GoogleFonts.nabla(),
          ],
        ),
        designMode: platformDesignMode,
        imageEditorTheme: const ImageEditorTheme(
          editorMode: ThemeEditorMode.whatsapp,
          helperLine: HelperLineTheme(
            horizontalColor: Color.fromARGB(255, 129, 218, 88),
            verticalColor: Color.fromARGB(255, 129, 218, 88),
          ),
          emojiEditor: EmojiEditorTheme(
            backgroundColor: Colors.transparent,
          ),
          cropRotateEditor: CropRotateEditorTheme(
            cropCornerColor: Colors.white,
            helperLineColor: Colors.white,
            cropCornerLength: 28,
            cropCornerThickness: 3,
          ),
        ),
        paintEditorConfigs: const PaintEditorConfigs(
          initialColor: Color.fromARGB(255, 129, 218, 88),
          initialStrokeWidth: 5,
        ),
        cropRotateEditorConfigs: const CropRotateEditorConfigs(
          enableDoubleTap: false,
        ),
        filterEditorConfigs: FilterEditorConfigs(
          whatsAppFilterTextOffsetY: 90,
          filterList: [
            const FilterModel(
              name: "None",
              filters: [],
            ),
            FilterModel(
              name: "Pop",
              filters: [
                ColorFilterAddons.colorOverlay(255, 225, 80, 0.08),
                ColorFilterAddons.saturation(0.1),
                ColorFilterAddons.contrast(0.05),
              ],
            ),
            FilterModel(
              name: "B&W",
              filters: [
                ColorFilterAddons.grayscale(),
                ColorFilterAddons.colorOverlay(100, 28, 210, 0.03),
                ColorFilterAddons.brightness(0.1),
              ],
            ),
            FilterModel(
              name: "Cool",
              filters: [
                ColorFilterAddons.addictiveColor(0, 0, 20),
              ],
            ),
            FilterModel(
              name: "Chrome",
              filters: [
                ColorFilterAddons.contrast(0.15),
                ColorFilterAddons.saturation(0.2),
              ],
            ),
            FilterModel(
              name: "Film",
              filters: [
                ColorFilterAddons.brightness(.05),
                ColorFilterAddons.saturation(-0.03),
              ],
            ),
          ],
        ),
        stickerEditorConfigs: StickerEditorConfigs(
          enabled: true,
          onSearchChanged: (value) {
            /// Filter your stickers
            debugPrint(value);
          },
          buildStickers: (setLayer, scrollController) {
            List<String> demoTitels = [
              'Recent',
              'Favorites',
              'Shapes',
              'Funny',
              'Boring',
              'Frog',
              'Snow',
              'More'
            ];
            List<Widget> slivers = [];
            int offset = 0;
            for (var element in demoTitels) {
              slivers.addAll([
                _buildDemoStickersTitle(element),
                _buildDemoStickers(offset, setLayer),
                const SliverToBoxAdapter(child: SizedBox(height: 20)),
              ]);
              offset += 20;
            }

            return Column(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 0),
                    child: CustomScrollView(
                      controller: scrollController,
                      slivers: slivers,
                    ),
                  ),
                ),
                Container(
                  height: 50,
                  color: Colors.grey.shade800,
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.watch_later_outlined),
                        color: Colors.white,
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.mood),
                        color: Colors.white,
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.pets),
                        color: Colors.white,
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.coronavirus),
                        color: Colors.white,
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
        customWidgets: ImageEditorCustomWidgets(
          whatsAppBottomWidget: LayoutBuilder(builder: (context, constraints) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 7, 16, 12),
                    child: TextField(
                      textAlignVertical: TextAlignVertical.center,
                      decoration: InputDecoration(
                        filled: true,
                        isDense: true,
                        prefixIcon: const Padding(
                          padding: EdgeInsets.only(left: 7.0),
                          child: Icon(
                            Icons.add_photo_alternate_rounded,
                            size: 24,
                            color: Colors.white,
                          ),
                        ),
                        hintText: 'Add a caption...',
                        hintStyle: const TextStyle(
                          color: Color.fromARGB(255, 238, 238, 238),
                          fontWeight: FontWeight.w400,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(40),
                          borderSide: BorderSide.none,
                        ),
                        fillColor: const Color(0xFF202D35),
                      ),
                    ),
                  ),
                ),
                Flexible(
                  child: Container(
                    padding: EdgeInsets.fromLTRB(16, 7, 16,
                        12 + MediaQuery.of(context).viewInsets.bottom),
                    color: Colors.black38,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 4,
                            horizontal: 10,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: const Color(0xFF202D35),
                          ),
                          child: const Text(
                            'Alex Frei',
                            style: TextStyle(
                              fontSize: 13,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            editorKey.currentState?.doneEditing();
                          },
                          icon: const Icon(Icons.send),
                          style: IconButton.styleFrom(
                            backgroundColor: const Color(0xFF0DA886),
                          ),
                        )
                      ],
                    ),
                  ),
                )
              ],
            );
          }),
        ),
      ),
    );
  }

  Widget _buildDemoStickersTitle(String text) {
    return SliverPadding(
      padding: const EdgeInsets.only(bottom: 4),
      sliver: SliverToBoxAdapter(
        child: Text(
          text,
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  SliverGrid _buildDemoStickers(int offset, Function(Widget) setLayer) {
    return SliverGrid.builder(
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 80,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
        ),
        itemCount: max(3, 3 + offset % 6),
        itemBuilder: (context, index) {
          String url =
              'https://picsum.photos/id/${offset + (index + 3) * 3}/2000';
          var widget = ClipRRect(
            borderRadius: BorderRadius.circular(7),
            child: Image.network(
              url,
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
          return GestureDetector(
            onTap: () async {
              // Important make sure the image is completly loaded
              // cuz the editor will directly take a screenshot
              // inside of a background isolated thread.
              LoadingDialog loading = LoadingDialog();
              await loading.show(
                context,
                configs: const ProImageEditorConfigs(),
                theme: ThemeData.dark(),
              );

              if (!context.mounted) return;
              await precacheImage(NetworkImage(url), context);
              if (context.mounted) await loading.hide(context);
              setLayer(widget);
            },
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: widget,
            ),
          );
        });
  }
}
