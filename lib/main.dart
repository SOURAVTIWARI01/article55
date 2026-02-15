import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:society_voting_firebase/presentation/screens/registration_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Note: Firebase initialization requires google-services.json/GoogleService-Info.plist
  // or explicit options for web/desktop.
  // await Firebase.initializeApp();
  
  runApp(
    const ProviderScope(
      child: SocietyVotingApp(),
    ),
  );
}

class SocietyVotingApp extends StatelessWidget {
  const SocietyVotingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Society Voting System',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0B3C5D),
          primary: const Color(0xFF0B3C5D),
        ),
        useMaterial3: true,
        fontFamily: 'Roboto', // Defaulting to Roboto
      ),
      home: const RegistrationScreen(),
    );
  }
}
