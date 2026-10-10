import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'services/supabase_service.dart';

void main() async {
  // This needs to be called before any platform channels are accessed
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    // First load env variables
    await dotenv.load(fileName: ".env");
    debugPrint('Environment variables loaded');
    
    // Then initialize Mapbox
    final mapboxToken = dotenv.env['MAPBOX_ACCESS_TOKEN'];
    if (mapboxToken != null) {
      MapboxOptions.setAccessToken(mapboxToken);
      debugPrint('Mapbox initialized');
    }
    
    // Try to initialize Supabase but don't block app launch if it fails
    try {
      await SupabaseService.initialize();
      debugPrint('Supabase initialized successfully');
    } catch (e) {
      // Just log the error but continue app launch
      debugPrint('Supabase initialization failed: $e');
      // We'll retry connecting later when needed
    }
  } catch (e) {
    debugPrint('Error during initialization: $e');
  }
  
  // Always launch the app even if some services failed
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Ahtet',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'Ahtet'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('You have pushed the button this many times:'),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
