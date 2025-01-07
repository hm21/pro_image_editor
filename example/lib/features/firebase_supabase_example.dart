// Package imports:
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pro_image_editor/pro_image_editor.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '/core/constants/example_constants.dart';
import '/core/mixin/example_helper.dart';

/// The Firebase-Supabase example
class FirebaseSupabaseExample extends StatefulWidget {
  /// Creates a new [FirebaseSupabaseExample] widget.
  const FirebaseSupabaseExample({super.key});

  @override
  State<FirebaseSupabaseExample> createState() =>
      _FirebaseSupabaseExampleState();
}

class _FirebaseSupabaseExampleState extends State<FirebaseSupabaseExample>
    with ExampleHelperState<FirebaseSupabaseExample> {
  final _supabase = Supabase.instance.client;
  final String _path = 'your-storage-path/my-image-name.jpg';

  @override
  void initState() {
    preCacheImage(assetPath: kImageEditorExampleAssetPath);
    super.initState();
  }

  Future<void> _uploadFirebase(Uint8List bytes) async {
    try {
      Reference ref = FirebaseStorage.instance.ref(_path);

      /// In some special cases detect firebase the contentType wrong,
      /// so we make sure the contentType is set to jpg.
      await ref.putData(bytes, SettableMetadata(contentType: 'image/jpg'));
    } on FirebaseException catch (e) {
      debugPrint(e.message);
    }
  }

  Future<void> _uploadSupabase(Uint8List bytes) async {
    try {
      await _supabase.storage.from('my_bucket').uploadBinary(
            _path,
            bytes,
            retryAttempts: 3,
          );
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!isPreCached) return const PrepareImageWidget();

    return ProImageEditor.asset(
      kImageEditorExampleAssetPath,
      callbacks: ProImageEditorCallbacks(
        onImageEditingStarted: onImageEditingStarted,
        onImageEditingComplete: (bytes) async {
          editedBytes = bytes;

          try {
            await _uploadFirebase(bytes);
            await _uploadSupabase(bytes);
          } catch (e) {
            debugPrint(
                'Failed: You need to completely set up firebase or supabase in '
                'your project.');
          }
          setGenerationTime();
        },
        onCloseEditor: () => onCloseEditor(enablePop: !isDesktopMode(context)),
      ),
      configs: ProImageEditorConfigs(
        designMode: platformDesignMode,
        mainEditor: MainEditorConfigs(
          enableCloseButton: !isDesktopMode(context),
        ),
        i18n: const I18n(doneLoadingMsg: 'Uploading image...'),
      ),
    );
  }
}
