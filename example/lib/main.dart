import 'package:bot_toast/bot_toast.dart';
import 'package:example/shared/widgets/not_found_example.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:media_kit/media_kit.dart';

import 'package:pro_image_editor/pro_image_editor.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import 'core/constants/example_constants.dart';
import 'core/constants/example_list_constant.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Necessary initialization for package:media_kit.
  MediaKit.ensureInitialized();

  await Supabase.initialize(
    url: 'SUPABASE_URL',
    anonKey: 'SUPABASE_ANON_KEY',
    debug: false,
  );

  runApp(const MyApp());
}

/// The root widget of the application.
class MyApp extends StatelessWidget {
  /// Creates a new [MyApp] widget.
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pro-Image-Editor',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue.shade800,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      builder: BotToastInit(),
      navigatorObservers: [BotToastNavigatorObserver()],
      debugShowCheckedModeBanner: false,
      onGenerateRoute: (settings) {
        int index = kImageEditorExamples
            .indexWhere((example) => example.path == settings.name);

        if (index < 0) {
          return MaterialPageRoute(
            builder: (_) => const NotFoundExample(),
          );
        }

        return MaterialPageRoute(
          builder: (_) => kImageEditorExamples[index].page,
        );
      },
      home: const MyHomePage(),
    );
  }
}

/// The home page of the application.
class MyHomePage extends StatefulWidget {
  /// Creates a new [MyHomePage] widget.
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _navigatorKey = GlobalKey<NavigatorState>();
  late final ScrollController _scrollCtrl;

  final String _initialRoute = kImageEditorExamples.first.path;
  int _railIndex = 0;

  @override
  void initState() {
    super.initState();
    _scrollCtrl = ScrollController();
  }

  @override
  void dispose() {
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _openCodeInGithub() async {
    String path = 'https://github.com/hm21/pro_image_editor/tree/stable/'
        'example/lib/features';
    Uri url = Uri.parse(path);
    if (!await launchUrl(url)) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: ExtendedPopScope(
        child: Scaffold(
          body: Builder(builder: (_) {
            if (MediaQuery.sizeOf(context).width >=
                kImageEditorExampleIsDesktopBreakPoint) {
              /// Build navigation-rail on large screens
              return _buildTabletExamples();
            } else {
              return _buildMobileExamples();
            }
          }),
        ),
      ),
    );
  }

  Widget _buildTabletExamples() {
    return Row(
      children: [
        _buildRailBar(),
        const VerticalDivider(width: 1),
        Expanded(
          // Important that hero animations work correctly
          child: HeroControllerScope(
            controller: MaterialApp.createMaterialHeroController(),
            child: Navigator(
              key: _navigatorKey,
              initialRoute: _initialRoute,
              onGenerateRoute: (settings) {
                int index = kImageEditorExamples
                    .indexWhere((example) => example.path == settings.name);

                if (index < 0) {
                  return MaterialPageRoute(
                    builder: (_) => const NotFoundExample(),
                  );
                }

                return PageRouteBuilder(
                  pageBuilder: (_, __, ___) => kImageEditorExamples[index].page,
                  transitionsBuilder:
                      (_, animation, secondaryAnimation, child) {
                    const begin =
                        Offset(0.0, 0.1); // Start offscreen to the right
                    const end = Offset.zero; // End at the center
                    const curve = Curves.easeInOut;

                    var tween = Tween(begin: begin, end: end)
                        .chain(CurveTween(curve: curve));
                    var offsetAnimation = animation.drive(tween);
                    return SlideTransition(
                      position: offsetAnimation,
                      transformHitTests: false,
                      child: FadeTransition(
                        opacity: animation,
                        child: child,
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRailBar() {
    return LayoutBuilder(builder: (_, constraints) {
      return SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: constraints.maxHeight),
          child: IntrinsicHeight(
            child: NavigationRail(
              leading: Column(
                spacing: 7,
                children: [
                  TextButton(
                    onPressed: _openCodeInGithub,
                    child: const Text('View code in Github'),
                  ),
                  Container(
                    height: 0.4,
                    width: 250,
                    color: Colors.white54,
                  ),
                ],
              ),
              onDestinationSelected: (index) {
                if (_railIndex == index) return;

                _navigatorKey.currentState!.pushNamedAndRemoveUntil(
                  kImageEditorExamples[index].path,
                  ModalRoute.withName(_initialRoute),
                );
                _railIndex = index;
                setState(() {});
              },
              extended: true,
              destinations: kImageEditorExamples.map((example) {
                var color = const Color(0xFFF5F5F5).withAlpha(
                  example.disabled ? 150 : 255,
                );
                return NavigationRailDestination(
                  icon: Icon(
                    example.icon,
                    color: color,
                  ),
                  label: Text(
                    example.name +
                        (example.disabled ? '\nNot supported on the web' : ''),
                    style: TextStyle(
                      color: color,
                    ),
                  ),
                  disabled: example.disabled,
                );
              }).toList(),
              selectedIndex: _railIndex,
            ),
          ),
        ),
      );
    });
  }

  Widget _buildMobileExamples() {
    return SafeArea(
      child: Column(
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
                    style: const TextStyle(color: Colors.white),
                    children: [
                      const TextSpan(text: 'Check out the example code '),
                      TextSpan(
                        recognizer: TapGestureRecognizer()
                          ..onTap = _openCodeInGithub,
                        text: 'here',
                        style: const TextStyle(color: Colors.blue),
                      ),
                      const TextSpan(text: '.'),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 10, thickness: 0),
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
                  children: kImageEditorExamples
                      .map(
                        (example) => Opacity(
                          opacity: example.disabled ? 0.6 : 1,
                          child: ListTile(
                            onTap: example.disabled
                                ? null
                                : () {
                                    Navigator.of(context).pushNamed(
                                      example.path,
                                    );
                                  },
                            leading: Icon(example.icon),
                            title: Text(example.name),
                            subtitle: example.disabled
                                ? Text(example.disabledMessage)
                                : null,
                            trailing: const Icon(Icons.chevron_right_rounded),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// It's handy to then extract the Supabase client in a variable for later uses
final supabase = Supabase.instance.client;
