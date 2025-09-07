import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late StreamSubscription<User?> _authSubscription;
  User? _user;

  @override
  void initState() {
    super.initState();
    // Listen to authentication state changes
    _authSubscription = FirebaseAuth.instance.authStateChanges().listen((user) {
      setState(() {
        _user = user;
      });
    });
  }

  @override
  void dispose() {
    // Cancel the subscription when the widget is disposed
    _authSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // A simple check for screen size to adjust layout
    final isDesktop = MediaQuery.of(context).size.width > 800;

    return Scaffold(
      backgroundColor: Colors.white,
      // Using a custom app bar implementation in the body for more control
      body: SafeArea(
        child: Column(
          children: [
            _buildCustomAppBar(context),
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: isDesktop ? 80.0 : 24.0,
                    vertical: 40.0,
                  ),
                  // Use Row for desktop and Column for mobile
                  child: isDesktop
                      ? Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(flex: 3, child: _buildLeftPanel()),
                            const SizedBox(width: 60),
                            Expanded(flex: 2, child: _buildRightPanel()),
                          ],
                        )
                      : Column(
                          children: [
                            _buildLeftPanel(),
                            const SizedBox(height: 40),
                            _buildRightPanel(),
                          ],
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- WIDGETS ---
  void _showComingSoonSnackBar(BuildContext context, String featureName) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$featureName feature is coming soon!'),
        backgroundColor: Colors.amber[800],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(10),
      ),
    );
  }

  // Custom App Bar with dynamic Login/Account functionality
  Widget _buildCustomAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(Icons.menu, size: 28),
              const SizedBox(width: 16),
              RichText(
                text:TextSpan(
                  children: [
                    TextSpan(
                      text: "Glowing",
                      style: GoogleFonts.dynaPuff(
                        fontSize: 20,
                        fontWeight: FontWeight.w400,
                        color: Colors.amber[400],
                      ),
                    ),
                    TextSpan(
                      text: " pet ✨",
                      style: GoogleFonts.dynaPuff(
                        fontSize: 20,
                        fontWeight: FontWeight.w400,
                        color: Colors.black, // Black
                      ),
                    ),
                  ],
                ),
                ),
            ],
          ),
          // For larger screens, show navigation links
          if (MediaQuery.of(context).size.width > 1000)
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  SizedBox(width: 150),
                  _navLink(context, 'Pet Clinic', () => _showComingSoonSnackBar(context, 'Pet Clinic')),
                  _navLink(context, 'Pet Hotels', () => _showComingSoonSnackBar(context, 'Pet Hotels')),
                  _navLink(context, 'Pet Grooming', () => _showComingSoonSnackBar(context, 'Pet Grooming')),
                  _navLink(context, 'Pet Training', () => _showComingSoonSnackBar(context, 'Pet Training')),
                ],
              ),
            ),
          // Conditional Login Button or Account Icon
          if (_user == null)
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.amber[400]!, Colors.orange[400]!],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: Colors.amber.withOpacity(0.3),
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: ElevatedButton.icon(
              onPressed: () => Navigator.pushNamed(context, '/login'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              icon: const Icon(Icons.login, color: Colors.white),
              label: Text(
                'Login',
                style: GoogleFonts.dynaPuff(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 1.2,
                ),
              ),
            ),
          )
          else
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'logout') {
                  FirebaseAuth.instance.signOut();
                }
                // You can add more options like 'profile' here
              },
              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                const PopupMenuItem<String>(
                  value: 'logout',
                  child: Text('Sign Out'),
                ),
              ],
              icon: const Icon(Icons.account_circle, size: 32, color: Colors.black87),
            ),
        ],
      ),
    );
  }

  // Navigation Link Helper
Widget _navLink(BuildContext context, String title, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8), // for a circular ripple effect
      hoverColor: Colors.amber.withOpacity(0.12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
        child: Text(
          title,
          style: GoogleFonts.jua(
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  // Left panel with the cat image and callouts
  Widget _buildLeftPanel() {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        // Yellow circle background
        Container(
          width: 400,
          height: 400,
          decoration: BoxDecoration(
            color: Colors.amber[400],
            shape: BoxShape.circle,
          ),
        ),
        // Cat image
        Positioned(
          bottom: 0,
          child: SizedBox(
            height: 450,
            // Replace with your actual cat image asset
            child: Image.network(
              'assets/Be.png',
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) =>
                  const Icon(Icons.pets, size: 200, color: Colors.grey),
            ),
          ),
        ),
        // Pet Clinic Callout
        Positioned(
          bottom: 50,
          left: -30,
          child: _buildInfoCard(
            icon: Icons.local_hospital,
            title: 'Pet Clinic',
            subtitle: 'Give extra attention to your child, before it\'s too late',
          ),
        ),
        // Pet Grooming Callout
        Positioned(
          top: 125,
          right: -30,
          child: _buildInfoCard(
            // Using a placeholder icon here
            icon: Icons.cut,
            title: 'Pet Grooming',
            subtitle: 'can be called at home or come to our pet shop',
          ),
        ),
      ],
    );
  }

  // Right panel with text and button
  Widget _buildRightPanel() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Be Glowing\nBe Cute ✨',
          style: GoogleFonts.dynaPuff(
            fontSize: 48,
            fontWeight: FontWeight.w600,
            height: 1.3,
            color: Colors.amber[400],
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'Welcome to Glowing Pet, where grooming meets care and compassion. Treat your furry friends to top-notch pampering from our experienced team. Discover why we\'re more than just grooming—we\'re family.',
          style: TextStyle(
            fontSize: 16,
            color: Colors.black54,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 32),
        // Learn More Button with Gradient
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.amber[400]!, Colors.amber[600]!],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: Colors.amber.withOpacity(0.5),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            child: Text(
              'LEARN MORE',
              style: GoogleFonts.dynaPuff(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: const Color.fromARGB(255, 255, 255, 255),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Reusable card widget for the callouts
  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: Colors.grey[100],
            child: Icon(icon, color: Colors.black),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 4),
              SizedBox(
                width: 150, // Constrain width to allow text wrapping
                child: Text(
                  subtitle,
                  style: const TextStyle(fontSize: 12, color: Colors.black54),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}

