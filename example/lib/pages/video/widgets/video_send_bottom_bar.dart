import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../utils/video_image_element.dart';
import 'image_video_picker.dart';

class VideoSendBottomBar extends StatefulWidget {
  const VideoSendBottomBar({
    super.key,
    required this.onPickFile,
    required this.onTapFile,
    required this.onRemoveItem,
    required this.opacity,
    required this.editors,
    required this.selected,
  });

  final double opacity;
  final Function(int index) onRemoveItem;
  final Function(Uint8List bytes, bool isVideo) onPickFile;
  final Function(int index) onTapFile;
  final List<ContentElement> editors;
  final int selected;

  @override
  State<VideoSendBottomBar> createState() => _VideoSendBottomBarState();
}

class _VideoSendBottomBarState extends State<VideoSendBottomBar> {
  final double _thumbnailSize = 50;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Opacity(
        opacity: widget.opacity,
        child: Material(
          type: MaterialType.transparency,
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildThumbnailList(),
                  _buildInput(),
                  _buildUserNameAndSendButton(),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildThumbnailList() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: widget.editors.length > 1
          ? Row(
              children: List.generate(widget.editors.length, (index) {
                return GestureDetector(
                  onTap: () => widget.onTapFile(index),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        width: _thumbnailSize,
                        height: _thumbnailSize,
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(3),
                          border: Border.all(
                            width: 1.5,
                            color: index == widget.selected
                                ? Colors.green
                                : Colors.transparent,
                          ),
                        ),
                        child: Image.memory(
                          widget.editors[index].editorImage.byteArray!,
                          fit: BoxFit.cover,
                          cacheWidth: (_thumbnailSize *
                                  MediaQuery.of(context).devicePixelRatio)
                              .toInt(),
                        ),
                      ),
                      if (index == widget.selected)
                        IconButton(
                          onPressed: () => widget.onRemoveItem(index),
                          icon: const Icon(
                            Icons.delete_outline,
                            color: Colors.white,
                          ),
                        ),
                    ],
                  ),
                );
              }),
            )
          : null,
    );
  }

  Widget _buildInput() {
    return Flexible(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 7, 16, 12),
        child: TextField(
          textAlignVertical: TextAlignVertical.center,
          decoration: InputDecoration(
            filled: true,
            isDense: true,
            prefixIcon: ImageVideoPicker(
              onSelected: widget.onPickFile,
              child: const Padding(
                padding: EdgeInsets.only(left: 7.0),
                child: Icon(
                  Icons.add_photo_alternate_rounded,
                  size: 24,
                  color: Colors.white,
                ),
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
    );
  }

  Widget _buildUserNameAndSendButton() {
    return Flexible(
      child: Container(
        padding: EdgeInsets.fromLTRB(
            16,
            7,
            16,
            12 +
                (widget.editors[widget.selected].imageEditor!.isSubEditorOpen
                    ? 0
                    : MediaQuery.of(context).viewInsets.bottom)),
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
                  color: Colors.white,
                ),
              ),
            ),
            IconButton(
              onPressed: () {
                widget.editors[widget.selected].imageEditor!.doneEditing();
              },
              icon: const Icon(Icons.send),
              style: IconButton.styleFrom(
                backgroundColor: const Color(0xFF0DA886),
                foregroundColor: Colors.white,
              ),
            )
          ],
        ),
      ),
    );
  }
}
