import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:webunicamp/src/screens/buildingscreen.dart';
import 'package:webunicamp/src/screens/loginscreen.dart';
import 'package:webunicamp/src/screens/homescreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");

  try {
    await dotenv.load(fileName: ".env");

    await Firebase.initializeApp(
      options: FirebaseOptions(
        apiKey: '${dotenv.env['FIREBASE_API_KEY']}',
        authDomain: '${dotenv.env['FIREBASE_AUTH_DOMAIN']}',
        projectId: '${dotenv.env['FIREBASE_PROJECT_ID']}',
        storageBucket: '${dotenv.env['FIREBASE_STORAGE_BUCKET']}',
        messagingSenderId: '${dotenv.env['FIREBASE_MESSAGING_SENDER_ID']}',
        appId: '${dotenv.env['FIREBASE_APP_ID']}',
        measurementId: '${dotenv.env['FIREBASE_MEASUREMENT_ID']}',
      ),
    );
    // print("Firebase initialized successfully");
  } catch (e) {
    print("Error initializing Firebase: $e");
  }
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/home',
      routes: {
        '/': (context) => const LoginScreen(),
        '/home': (context) => const HomeScreen(),
        // '/buildings': (context) => const BuildingScreen(name: name, description: description, photoURLs: photoURLs)
      },
    );
  }
}
