import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'services/proverb_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'services/gpt_service.dart';

void main() {
  // Set up error handling
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    if (kReleaseMode) {
      // In release mode, report to a logging service
      // You could integrate with services like Firebase Crashlytics here
    }
  };

  runZonedGuarded<Future<void>>(() async {
    WidgetsFlutterBinding.ensureInitialized();

    await dotenv.load(fileName: ".env");

    runApp(const MyApp());
  }, (error, stackTrace) {
    // Handle any errors not caught by the Flutter framework
    debugPrint('Uncaught error: $error');
    debugPrint(stackTrace.toString());
    // You could log to a service here as well
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Divine Data',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Divine Data '),
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
  String _proverb = 'John 3:16 - For God so loved the world...';
  bool _isLoading = false;
  String? _errorMessage;
  String? explanation;


  late final ProverbService _service;
  late final GptService gptService;


  @override
  void initState() {
    super.initState();
    // You could fetch data here if needed
    gptService = GptService(dotenv.env['OPENAI_API_KEY']!);
   _service = ProverbService(dotenv.env['ESV_API_KEY']!);

    _fetchVerseData();
  }

  // Example of how to handle API requests with error handling
  Future<void> _fetchVerseData() async {

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

      try {
        final result = await _service.getRandomProverb();
        final gptResponse = await gptService.explainVerse(result);

        setState((){ _proverb = result;
        explanation = gptResponse;

        });

      } catch (e) {
        _errorMessage = 'Error: ${e.toString()}';

      }

      setState(() => _isLoading = false);


      // Simulating a delay
      await Future.delayed(Duration(seconds: 1));
      setState(() {
        _isLoading = false;
      });

    }


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
        child: Card(
          elevation: 6,
          margin: EdgeInsets.all(16.0),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.indigo.shade300, Colors.indigo.shade800],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12.0),
            ),
            padding: EdgeInsets.all(20.0),
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
          mainAxisSize: MainAxisSize.min,

          children: <Widget>[
            const SizedBox(height: 10),
            const SizedBox(height: 20),

            if (_isLoading)

              const CircularProgressIndicator(color: Colors.white)


            else if (  _proverb != null || explanation != null)
              Container(
                padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),

                child: Column(

    children: [
                  Text(
                  _proverb,
                  style: TextStyle(fontSize: 16, color: Colors.white, fontStyle: FontStyle.italic),
                  textAlign: TextAlign.center,
                ),
                  const SizedBox(height: 20),
                  if (explanation != null)
                    Text(
                      explanation!,
                      style: const TextStyle(fontSize: 16),
                      textAlign: TextAlign.center,
                    ),]
              ),)  else if (_errorMessage != null)

                Container(
                  padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _errorMessage!,
                    style: TextStyle(fontSize: 16, color: Colors.white, fontStyle: FontStyle.italic),
                    textAlign: TextAlign.center,
                  ),
                )
          ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _fetchVerseData,
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        child: const Icon(Icons.refresh),
      ),
    );
  }
}
