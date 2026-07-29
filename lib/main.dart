import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'shared/widgets/app_text_field.dart';
import 'shared/widgets/app_button.dart';
import 'shared/widgets/empty_state.dart';
import 'shared/widgets/confirm_dialog.dart';
import 'core/router/app_router.dart';
import '../../features/auth/screens/login_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/theme.dart';
import 'core/theme/theme_provider.dart'; // native package
import 'package:window_manager/window_manager.dart'; // native package (desktop-only)

import 'package:flutter/foundation.dart' show kIsWeb; // native Flutter
import 'dart:io'
    show Platform; // native Dart — lets us check what platform we're on

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );
  if (!kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
    await windowManager.ensureInitialized();
    // native Dart — only run this on desktop
    await windowManager.ensureInitialized(); // native window_manager
    const windowOptions = WindowOptions(
      size: Size(
        1038,
        648,
      ), // native Flutter type — pick whatever fixed size/ratio you want (this is a 1.6:1 ratio)
      center: true,
      titleBarStyle: TitleBarStyle.normal,
    );
    windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.setResizable(
        true,
      ); // set false if you want it truly locked
    });
  }
  runApp(const ProviderScope(child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Spotlight Manager',
      routerConfig: appRouter, // hands your router map to the app
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  final TextEditingController _testController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          //
          // TRY THIS: Invoke "debug painting" (choose the "Toggle Debug Paint"
          // action in the IDE, or press "p" in the console), to see the
          // wireframe for each widget.
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AppTextField(
              label: "Email",
              hint: "you@example.com",
              controller: _testController,
            ),
            AppButton(
              label: "Print Field Value",
              onPressed: () {
                print("You typed: ${_testController.text}");
              },
            ),
            EmptyState(
              message: "No routines yet. Add your first one!",
              icon: Icons.checklist,
            ),
            AppButton(
              label: "Delete Item",
              variant: AppButtonVariant.danger,
              onPressed: () {
                showDialog(
                  // native Flutter function
                  context: context,
                  builder: (context) => ConfirmDialog(
                    title: "Delete Routine?",
                    message: "This action cannot be undone.",
                    onConfirm: () {
                      print("Item deleted!");
                    },
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
