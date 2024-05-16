import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pro_image_editor/pro_image_editor.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../utils/example_helper.dart';

class FirebaseSupabaseExample extends StatefulWidget {
  const FirebaseSupabaseExample({super.key});

  @override
  State<FirebaseSupabaseExample> createState() =>
      _FirebaseSupabaseExampleState();
}

class _FirebaseSupabaseExampleState extends State<FirebaseSupabaseExample>
    with ExampleHelperState<FirebaseSupabaseExample> {
  final _supabase = Supabase.instance.client;
  final String _path = 'your-storage-path/my-image-name.png';

  Future<void> _uploadFirebase(Uint8List bytes) async {
    try {
      Reference ref = FirebaseStorage.instance.ref(_path);

      /// In some special cases detect firebase the contentType wrong,
      /// so we make sure the contentType is set to png.
      await ref.putData(bytes, SettableMetadata(contentType: 'image/png'));
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
        Navigator.push(
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
      'assets/demo.png',
      callbacks: ProImageEditorCallbacks(
        onImageEditingComplete: (bytes) async {
          editedBytes = bytes;

          await _uploadFirebase(bytes);
          await _uploadSupabase(bytes);

          if (mounted) Navigator.pop(context);
        },
        onCloseEditor: onCloseEditor,
      ),
      configs: const ProImageEditorConfigs(
        allowCompleteWithEmptyEditing: true,
        i18n: I18n(doneLoadingMsg: 'Uploading image...'),
      ),
    );
  }
}
