import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:reflect/screens/splash_screen_v2.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await Supabase.initialize(url: dotenv.env['SUPABASE_URL']!, publishableKey: dotenv.env['SUPABASE_PUBLISHABLE_KEY']!);
  runApp(const ReflectApp());
}

final supabase = Supabase.instance.client;

class ReflectApp extends StatelessWidget{
  const ReflectApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Reflect',
      home: SplashScreen()
    );
    
  }
}