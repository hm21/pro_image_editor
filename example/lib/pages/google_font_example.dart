// ignore_for_file: depend_on_referenced_packages

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pro_image_editor/pro_image_editor.dart';

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
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => _buildEditor(),
          ),
        );
      },
      leading: const Icon(Icons.emoji_emotions_outlined),
      title: const Text('Google-Font Emojis'),
      trailing: const Icon(Icons.chevron_right),
    );
  }

  Widget _buildEditor() {
    return ProImageEditor.asset(
      'assets/demo.png',
      onImageEditingComplete: onImageEditingComplete,
      onCloseEditor: onCloseEditor,
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
