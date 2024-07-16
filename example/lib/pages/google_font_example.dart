// ignore_for_file: depend_on_referenced_packages

// Dart imports:
import 'dart:io';

// Flutter imports:
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:google_fonts/google_fonts.dart';
import 'package:pro_image_editor/pro_image_editor.dart';

// Project imports:
import '../utils/example_constants.dart';
import '../utils/example_helper.dart';

class GoogleFontExample extends StatefulWidget {
  const GoogleFontExample({super.key});

  @override
  State<GoogleFontExample> createState() => _GoogleFontExampleState();
}

class _GoogleFontExampleState extends State<GoogleFontExample>
    with ExampleHelperState<GoogleFontExample> {
  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () async {
        await precacheImage(
            AssetImage(ExampleConstants.of(context)!.demoAssetPath), context);
        if (!context.mounted) return;
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => _buildEditor(),
          ),
        );
      },
      leading: const Icon(Icons.emoji_emotions_outlined),
      title: const Text('Google-Font Emojis'),
      subtitle: !kIsWeb && Platform.isWindows
          ? const Text('Windows didn\'t support "GoogleFonts.notoColorEmoji".')
          : null,
      trailing: const Icon(Icons.chevron_right),
    );
  }

  Widget _buildEditor() {
    return ProImageEditor.asset(
      ExampleConstants.of(context)!.demoAssetPath,
      callbacks: ProImageEditorCallbacks(
        onImageEditingStarted: onImageEditingStarted,
        onImageEditingComplete: onImageEditingComplete,
        onCloseEditor: onCloseEditor,
      ),
      configs: ProImageEditorConfigs(
        designMode: platformDesignMode,
        textEditorConfigs: TextEditorConfigs(
          showSelectFontStyleBottomBar: true,
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
        imageEditorTheme: ImageEditorTheme(
            emojiEditor: EmojiEditorTheme(
          textStyle: DefaultEmojiTextStyle.copyWith(
            fontFamily: GoogleFonts.notoColorEmoji().fontFamily,
          ),
        )),
        emojiEditorConfigs: const EmojiEditorConfigs(
          checkPlatformCompatibility: false,
        ),
      ),
    );
  }
}
