// Flutter imports:
import 'package:example/pages/crop_to_main_editor.dart';
import 'package:example/pages/design_examples/design_example.dart';
import 'package:example/pages/zoom_move_editor_example.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pro_image_editor/pro_image_editor.dart';

// Package imports:
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

// Project imports:
import '/utils/example_constants.dart';
import '/pages/firebase_supabase_example.dart';
import '/pages/import_export_example.dart';
import '/pages/pick_image_example.dart';
import '/pages/selectable_layer_example.dart';
import 'pages/custom_appbar_bottombar_example.dart';
import 'pages/default_example.dart';
import 'pages/generation_configs_example.dart';
import 'pages/google_font_example.dart';
import 'pages/image_format_convert_example.dart';
import 'pages/movable_background_image.dart';
import 'pages/reorder_layer_example.dart';
import 'pages/round_cropper_example.dart';
import 'pages/signature_drawing_example.dart';
import 'pages/standalone_example.dart';
import 'pages/stickers_example.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'SUPABASE_URL',
    anonKey: 'SUPABASE_ANON_KEY',
    debug: false,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pro-Image-Editor',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue.shade800),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late final ScrollController _scrollCtrl;

  final List<Widget> _examples = [
    const DefaultExample(),
    const DesignExample(),
    const StandaloneExample(),
    const CropToMainEditorExample(),
    const SignatureDrawingExample(),
    const StickersExample(),
    const FirebaseSupabaseExample(),
    const ReorderLayerExample(),
    const RoundCropperExample(),
    const SelectableLayerExample(),
    const GenerationConfigsExample(),
    const PickImageExample(),
    const GoogleFontExample(),
    const CustomAppbarBottombarExample(),
    const ImportExportExample(),
    const MoveableBackgroundImageExample(),
    const ZoomMoveEditorExample(),
    const ImageFormatConvertExample(),
  ];

  @override
  void initState() {
    _scrollCtrl = ScrollController();
    super.initState();
  }

  @override
  void dispose() {
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ExampleConstants(
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.dark,
        child: ExtendedPopScope(
          child: Scaffold(
            body: SafeArea(child: _buildCard()),
          ),
        ),
      ),
    );
  }

  Widget _buildCard() {
    return Center(
      child: LayoutBuilder(builder: (context, constraints) {
        if (constraints.maxWidth >= 750) {
          return Container(
            constraints: const BoxConstraints(maxWidth: 700),
            child: Card.outlined(
              margin: const EdgeInsets.all(16),
              clipBehavior: Clip.hardEdge,
              child: _buildExamples(),
            ),
          );
        } else {
          return _buildExamples();
        }
      }),
    );
  }

  Widget _buildExamples() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Examples',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w600,
                ),
              ),
              RichText(
                  text: TextSpan(
                style: const TextStyle(color: Colors.black87),
                children: [
                  const TextSpan(text: 'Check out the example code '),
                  TextSpan(
                    recognizer: TapGestureRecognizer()
                      ..onTap = () async {
                        String path =
                            'https://github.com/hm21/pro_image_editor/tree/stable/example/lib/pages';
                        Uri url = Uri.parse(path);
                        if (!await launchUrl(url)) {
                          throw Exception('Could not launch $url');
                        }
                      },
                    text: 'here',
                    style: const TextStyle(color: Colors.blue),
                  ),
                  const TextSpan(text: '.'),
                ],
              )),
            ],
          ),
        ),
        const Divider(height: 1),
        Flexible(
          child: Scrollbar(
            controller: _scrollCtrl,
            thumbVisibility: true,
            trackVisibility: true,
            child: SingleChildScrollView(
              controller: _scrollCtrl,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: ListTile.divideTiles(
                  context: context,
                  tiles: _examples,
                ).toList(),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// It's handy to then extract the Supabase client in a variable for later uses
final supabase = Supabase.instance.client;
