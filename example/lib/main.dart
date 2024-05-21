// Flutter imports:
import 'package:example/pages/standalone_example.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:supabase_flutter/supabase_flutter.dart';

// Project imports:
import 'package:example/pages/firebase_supabase_example.dart';
import 'package:example/pages/import_export_example.dart';
import 'package:example/pages/pick_image_example.dart';
import 'package:example/pages/selectable_layer_example.dart';
import 'package:example/utils/example_constants.dart';
import 'pages/custom_appbar_bottombar_example.dart';
import 'pages/default_example.dart';
import 'pages/google_font_example.dart';
import 'pages/highly_configurable_example.dart';
import 'pages/image_format_convert_example.dart';
import 'pages/movable_background_image.dart';
import 'pages/reorder_layer_example.dart';
import 'pages/round_cropper_example.dart';
import 'pages/stickers_example.dart';
import 'pages/whatsapp_example.dart';

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
      child: Scaffold(
        body: SafeArea(child: _buildCard()),
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
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Examples',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (kIsWeb)
                Text(
                  'The "web" platform has slower performance compared to the other platforms because the "web" platform doesn\'t support isolates.',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                  textAlign: TextAlign.center,
                ),
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
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  DefaultExample(),
                  Divider(height: 1),
                  StickersExample(),
                  Divider(height: 1),
                  WhatsAppExample(),
                  Divider(height: 1),
                  GoogleFontExample(),
                  Divider(height: 1),
                  CustomAppbarBottombarExample(),
                  Divider(height: 1),
                  MoveableBackgroundImageExample(),
                  Divider(height: 1),
                  HighlyConfigurableExample(),
                  Divider(height: 1),
                  ReorderLayerExample(),
                  Divider(height: 1),
                  SelectableLayerExample(),
                  Divider(height: 1),
                  PickImageExample(),
                  Divider(height: 1),
                  StandaloneExample(),
                  Divider(height: 1),
                  RoundCropperExample(),
                  Divider(height: 1),
                  FirebaseSupabaseExample(),
                  Divider(height: 1),
                  ImportExportExample(),
                  Divider(height: 1),
                  ImageFormatConvertExample(),
                ],
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
