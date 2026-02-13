import 'package:pro_image_editor/pro_image_editor.dart';

/// A predefined list of example [AudioTrack]s used for demonstration purposes.
final List<AudioTrack> kExampleAudioTracks = <AudioTrack>[
  AudioTrack(
    id: 'track_1',
    title: 'Summer Vibes',
    subtitle: 'Beach Band',
    duration: const Duration(seconds: 10),
    image: EditorImage.network('https://picsum.photos/200/200?random=1'),
    audio: EditorAudio.asset('assets/audio1.mp3'),
  ),
  AudioTrack(
    id: 'track_2',
    title: 'Night Drive',
    subtitle: 'Synthwave Artist',
    duration: const Duration(seconds: 59),
    image: EditorImage.network('https://picsum.photos/200/200?random=2'),
    audio: EditorAudio.asset('assets/audio2.wav'),
  ),
  AudioTrack(
    id: 'track_4',
    title: 'Electronic Pulse',
    subtitle: 'EDM Producer',
    duration: const Duration(seconds: 34),
    image: EditorImage.network('https://picsum.photos/200/200?random=3'),
    audio: EditorAudio.asset('assets/audio3.wav'),
  ),
];
