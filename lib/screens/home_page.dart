import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pet_grooming_app/screens/profile_page.dart';
import 'our_services_page.dart'; 
import 'about_us_page.dart'; 

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
    _authSubscription = FirebaseAuth.instance.authStateChanges().listen((user) {
      setState(() {
        _user = user;
      });
    });
  }

  @override
  void dispose() {
    _authSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 800;

    return Scaffold(
      backgroundColor: Colors.white,
      drawer: !isDesktop ? _buildNavDrawer(context) : null,
      body: SafeArea(
        child: Column(
          children: [
            _buildCustomAppBar(context, isDesktop),
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: isDesktop ? 80.0 : 24.0,
                    vertical: 40.0,
                  ),
                  child: isDesktop
                      ? Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(flex: 3, child: _buildLeftPanel(isDesktop)),
                            const SizedBox(width: 60),
                            Expanded(flex: 2, child: _buildRightPanel(isDesktop)),
                          ],
                        )
                      : Column(
                          children: [
                            _buildLeftPanel(isDesktop),
                            const SizedBox(height: 60),
                            _buildRightPanel(isDesktop),
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

  // --- NAVIGATION LOGIC ---

  void _navigateToHome(BuildContext context) {
    // If we are already on the home page, do nothing.
    // If not, pop until we are back at the initial route.
    if (ModalRoute.of(context)?.isFirst == false) {
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
  }

  void _navigateToOurServices(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const OurServicesPage()),
    );
  }

  void _navigateToAboutUs(BuildContext context) {
     Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AboutUsPage()),
    );
  }


  // --- WIDGETS ---

  Widget _buildCustomAppBar(BuildContext context, bool isDesktop) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: Row(
        children: [
          if (!isDesktop)
            Builder(
              builder: (context) => IconButton(
                icon: const Icon(Icons.menu, size: 28),
                onPressed: () => Scaffold.of(context).openDrawer(),
              ),
            ),
          if (isDesktop) const SizedBox(width: 16),
          RichText(
            text: TextSpan(
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
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (isDesktop)
                  Row(
                    children: [
                      _navLink(context, 'Home', () => _navigateToHome(context)),
                      _navLink(context, 'Our Services', () => _navigateToOurServices(context)),
                      _navLink(context, 'About Us', () => _navigateToAboutUs(context)),
                      const SizedBox(width: 20),
                    ],
                  ),
                if (_user == null)
                  _buildLoginButton(isDesktop)
                else
                  _buildAccountMenu(),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildNavDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
           DrawerHeader(
            decoration: BoxDecoration(color: Colors.amber[400]),
            child: Text('Glowing Pet', style: GoogleFonts.dynaPuff(fontSize: 24, color: Colors.white)),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Home'),
            onTap: () {
              Navigator.pop(context); // Close the drawer
              _navigateToHome(context);
            },
          ),
           ListTile(
            leading: const Icon(Icons.pets),
            title: const Text('Our Services'),
            onTap: () {
              Navigator.pop(context);
              _navigateToOurServices(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('About Us'),
            onTap: () {
              Navigator.pop(context);
              _navigateToAboutUs(context);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLoginButton(bool isDesktop) {
    return Container(
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
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton.icon(
        onPressed: () => Navigator.pushNamed(context, '/login'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: EdgeInsets.symmetric(horizontal: isDesktop ? 28 : 18, vertical: isDesktop ? 14 : 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        ),
        icon: const Icon(Icons.login, color: Colors.white, size: 20),
        label: Text(
          'Login',
          style: GoogleFonts.dynaPuff(
            fontSize: isDesktop ? 18 : 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildAccountMenu() {
  return PopupMenuButton<String>(
    onSelected: (value) {
      if (value == 'logout') {
        FirebaseAuth.instance.signOut();
      } else if (value == 'profile') {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ProfilePage()),
        );
      }
    },
    itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
      const PopupMenuItem<String>(
        value: 'profile',
        child: Text('Profile'),
      ),
    ],
    icon: Icon(Icons.account_circle, size: 32, color: Colors.amber[400]),
  );
}

  Widget _navLink(BuildContext context, String title, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      hoverColor: Colors.amber.withOpacity(0.12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
        child: Text(title, style: GoogleFonts.jua(fontSize: 16)),
      ),
    );
  }

  Widget _buildLeftPanel(bool isDesktop) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: isDesktop ? 400 : 300,
          height: isDesktop ? 400 : 300,
          decoration: BoxDecoration(
            color: Colors.amber[400],
            shape: BoxShape.circle,
          ),
        ),
        SizedBox(
          height: isDesktop ? 450 : 350,
          child: Image.asset( // Changed to AssetImage
            'assets/Be.png', 
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) =>
                const Icon(Icons.pets, size: 200, color: Colors.grey),
          ),
        ),
        if (isDesktop) ...[
          Positioned(
            bottom: 50,
            left: -30,
            child: _buildInfoCard(
              icon: Icons.local_hospital,
              title: 'Pet Clinic',
            ),
          ),
          Positioned(
            top: 125,
            right: -30,
            child: _buildInfoCard(
              icon: Icons.cut,
              title: 'Pet Grooming',
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildRightPanel(bool isDesktop) {
    return Column(
      crossAxisAlignment: isDesktop ? CrossAxisAlignment.start : CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Be Glowing\nBe Cute ✨',
          textAlign: isDesktop ? TextAlign.start : TextAlign.center,
          style: GoogleFonts.dynaPuff(
            fontSize: isDesktop ? 48 : 36,
            fontWeight: FontWeight.w600,
            height: 1.3,
            color: Colors.amber[400],
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Welcome to Glowing Pet, where grooming meets care and compassion. Treat your furry friends to top-notch pampering from our experienced team.',
          textAlign: isDesktop ? TextAlign.start : TextAlign.center,
          style: TextStyle(
            fontSize: isDesktop ? 16 : 14,
            color: Colors.black54,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 32),
        ElevatedButton(
          onPressed: () => _navigateToOurServices(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.amber[500],
            padding: EdgeInsets.symmetric(horizontal: isDesktop ? 40 : 30, vertical: isDesktop ? 20 : 15),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            elevation: 8,
            shadowColor: Colors.amber.withOpacity(0.5),
          ),
          child: Text(
            'Learn More',
            style: GoogleFonts.dynaPuff(
              fontSize: isDesktop ? 16 : 14,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard({ required IconData icon, required String title,}) {
    return Container(
      padding: const EdgeInsets.all(16),
      width: 200,
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
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ],
      ),
    );
  }
}
