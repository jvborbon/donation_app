import 'package:flutter/material.dart';
import 'login.dart';
import 'about.dart';
import 'loader.dart';
import 'package:google_fonts/google_fonts.dart';


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
          seedColor: const Color.fromARGB(255, 209, 14, 14),
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: seed,
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          backgroundColor: Color.fromARGB(255, 209, 14, 14),
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.white), // Hamburger menu color
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
      future: _precacheAllImagesAndDelay(context),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const ThemeLoader();
        }
        return Scaffold(
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            title: const SizedBox(),
            backgroundColor: theme.appBarTheme.backgroundColor,
            elevation: 0,
            iconTheme: const IconThemeData(color: Colors.white),
          ),
          drawer: Drawer(
            backgroundColor: Colors.white,
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                DrawerHeader(
                  decoration: const BoxDecoration(
                    color: Color.fromARGB(255, 209, 14, 14),
                  ),
                  child: Center(
                    child: Image.asset(
                      'images/lasac.jpeg',
                      height: 64,
                      width: 64,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.home, color: Color.fromARGB(255, 209, 14, 14)),
                  title: const Text('Home'),
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.login, color: Color.fromARGB(255, 209, 14, 14)),
                  title: const Text('Login'),
                  onTap: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const LoginPage()),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.volunteer_activism, color: Color.fromARGB(255, 209, 14, 14)),
                  title: const Text('About Us'),
                  onTap: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const AboutPage()),
                    );
                  },
                ),
              ],
            ),
          ),
          body: SafeArea(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    'images/collage-lasac-bg.png',
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                  ),
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Color.fromARGB(180, 209, 14, 14),
                          Color.fromARGB(180, 209, 14, 14),
                        ],
                      ),
                    ),
                  ),
                  Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.asset(
                            'images/lasac.jpeg',
                            height: 90,
                            width: 90,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'MaLASACkit App',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2,
                            fontSize: 32,
                            shadows: [
                              Shadow(
                                color: Colors.black.withAlpha((0.08 * 255).round()), // was: withOpacity(0.08)
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
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                            fontSize: 18,
                            letterSpacing: 1,
                          ),
                        ),
                        const SizedBox(height: 40),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const LoginPage(),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 20),
                            backgroundColor: Colors.white,
                            foregroundColor: theme.colorScheme.primary,
                            textStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            elevation: 6,
                          ),
                          child: const Text('Join Now!'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
          ),
        );
      },
    );
  }

  Future<void> _precacheAllImagesAndDelay(BuildContext context) async {
    await precacheImage(const AssetImage('images/collage-lasac-bg.png'), context);
    await precacheImage(const AssetImage('images/lasac.jpeg'), context);
    await Future.delayed(const Duration(milliseconds: 800));
  }
}


 