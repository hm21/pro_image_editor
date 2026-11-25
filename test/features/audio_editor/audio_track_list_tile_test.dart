import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:pro_image_editor/features/audio_editor/widgets/audio_track_list_tile.dart';
import 'package:pro_image_editor/pro_image_editor.dart';

void main() {
  final audioTrack = AudioTrack(
    id: 'track',
    title: 'Title',
    subtitle: 'Subtitle',
    duration: const Duration(seconds: 30),
    audio: EditorAudio.asset('assets/track.mp3'),
  );

  for (final isSelected in [false, true]) {
    testWidgets('renders inside a colored track list without a ListTile error '
        '(selected: $isSelected)', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ColoredBox(
              color: Colors.black45,
              child: AudioTrackListTile(
                configs: const ProImageEditorConfigs(),
                audioTrack: audioTrack,
                videoDuration: const Duration(seconds: 30),
                isSelected: isSelected,
                onTap: () {},
              ),
            ),
          ),
        ),
      );

      expect(tester.takeException(), isNull);
      expect(find.text('Title'), findsOneWidget);
    });
  }
}
