// Flutter imports:
// Project imports:
import 'package:example/utils/example_constants.dart';
// Package imports:
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pro_image_editor/pro_image_editor.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../utils/example_helper.dart';

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
    return ListTile(
      onTap: () async {
        await precacheImage(
            AssetImage(ExampleConstants.of(context)!.demoAssetPath), context);
        if (!context.mounted) return;
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => _buildEditor(),
          ),
        );
      },
      leading: const Icon(Icons.cloud_upload_outlined),
      title: const Text('Firebase and Supabase'),
      trailing: const Icon(Icons.chevron_right),
    );
  }

  Widget _buildEditor() {
    return ProImageEditor.asset(
      ExampleConstants.of(context)!.demoAssetPath,
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
        onCloseEditor: onCloseEditor,
      ),
      configs: ProImageEditorConfigs(
        designMode: platformDesignMode,
        i18n: const I18n(doneLoadingMsg: 'Uploading image...'),
      ),
    );
  }
}
