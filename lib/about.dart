import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About', style: TextStyle(color: Colors.white),),
        backgroundColor: const Color.fromARGB(255, 209, 14, 14),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              height: 120,
              child: Image.asset(
                'images/lasac-removed-bg.png', 
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 8), // Move logo closer to text
            // Title
            Text(
              'LASAC',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                fontSize: 24,
                color: const Color.fromARGB(255, 209, 14, 14),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            // Paragraph
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Text(
                "As the humanitarian, development and solidarity agent, LASAC is mandated with the mission to reduce the gap between faith and practice in the area of social justice in order for everyone, especially the poor, to realize their temporal liberation and eternal salvation through the application of social teachings of the Church based as they are on the Gospel of the Lord Jesus.",
                style: TextStyle(
                  fontSize: 16,
                  height: 1.5,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.justify,
              ),
            ),
          ],
        ),
      ),
      backgroundColor: const Color(0xFFF8F8F8),
    );
  }
}



