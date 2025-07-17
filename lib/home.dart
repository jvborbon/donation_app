import 'package:donation_app_final/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'login.dart';
import 'signup.dart';
import 'loader.dart';
import 'package:google_fonts/google_fonts.dart';

void main() async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const LasacApp());
}

class LasacApp extends StatelessWidget {
  const LasacApp({super.key});

  @override
  Widget build(BuildContext context) {
    const seed = Color(0xFFCB4232);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'LASAC App',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 203, 66, 50),
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: seed, // Set body background to primary color
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          backgroundColor: Color.fromARGB(255, 209, 14, 14), // AppBar is now white
          elevation: 0,
        ),
      ),
      home: const LandingPage(),
    );
  }
}

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return FutureBuilder(
      future: Future.delayed(const Duration(milliseconds: 800)), // Simulate loading
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const ThemeLoader();
        }
        return Scaffold(
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            title: Image.asset('images/lasac.jpeg', height: 40), // Enlarged logo
            backgroundColor: theme.appBarTheme.backgroundColor, // AppBar is white
            elevation: 0,
          ),
          body: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(
                'images/lasac-bg.jpg', // Changed background image
                fit: BoxFit.cover,
              ),
              Container(
                color: Colors.white.withOpacity(0.65), // White overlay for contrast
              ),
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 24),
                    Text(
                      'MaLASACkit App',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                        fontSize: 32,
                        shadows: [
                          Shadow(
                            color: Colors.black.withOpacity(0.08),
                            offset: const Offset(1, 1),
                            blurRadius: 2,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Enlarge The Space Of Your Tent.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        color: Colors.black87,
                        fontWeight: FontWeight.w500,
                        fontSize: 18,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 40),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const LoginPage(),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                            backgroundColor: Colors.white,
                            foregroundColor: theme.colorScheme.primary,
                            textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 4,
                          ),
                          child: const Text('Log‑In'),
                        ),
                        const SizedBox(width: 24),
                        OutlinedButton(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const SignupPage(),
                              ),
                            );
                          },
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                            foregroundColor: Colors.white,
                            backgroundColor: theme.colorScheme.primary,
                            side: BorderSide(color: theme.colorScheme.primary, width: 2),
                            textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 4,
                          ),
                          child: const Text('Sign‑Up'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}


