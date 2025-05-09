import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'theme/app_theme.dart';
import 'pages/welcome_page.dart';
import 'services/gemini_service.dart';

// Create a global instance of the GeminiService
late GeminiService geminiService;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load environment variables
  await dotenv.load(fileName: '.env');
  
  // Initialize Gemini service with API key
  final apiKey = dotenv.env['GEMINI_API_KEY'];
  geminiService = GeminiService(apiKey: apiKey);
  
  // Set preferred orientations
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: AppTheme.darkerBackground,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );
  
  runApp(const MyDeaApp());
}

class MyDeaApp extends StatelessWidget {
  const MyDeaApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MyDea',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.getTheme(),
      home: const WelcomePage(),
    );
  }
}