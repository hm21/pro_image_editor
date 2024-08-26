import 'package:example/pages/video/widgets/combine_video_editor_pages.dart';
import 'package:example/pages/video/widgets/image_video_picker.dart';
import 'package:flutter/material.dart';
import 'package:pro_image_editor/pro_image_editor.dart';

import 'utils/video_image_element.dart';

class CombineVideoEditorExample extends StatefulWidget {
  const CombineVideoEditorExample({super.key});

  @override
  State<CombineVideoEditorExample> createState() =>
      _CombineVideoEditorExampleState();
}

class _CombineVideoEditorExampleState extends State<CombineVideoEditorExample> {
  @override
  Widget build(BuildContext context) {
    return ImageVideoPicker(
      onSelected: (bytes, isVideo) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CombineVideoEditorPages(
              initialElement: ContentElement(
                isVideo: isVideo,
                editorImage: EditorImage(byteArray: bytes),
                imageEditorKey: GlobalKey(),
              ),
            ),
          ),
        );
      },
      child: const ListTile(
        leading: Icon(Icons.video_camera_back_outlined),
        title: Text('Combine with video editor'),
        trailing: Icon(Icons.chevron_right),
      ),
    );
  }
}
