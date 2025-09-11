import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'book_appointment_page.dart'; // Import the booking page

class OurServicesPage extends StatelessWidget {
  const OurServicesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Our Services',
          style: GoogleFonts.dynaPuff(color: Colors.black, fontSize: 22),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeroSection(),
            const SizedBox(height: 40),
            _buildSectionTitle('What We Offer'),
            _buildServicesGrid(context),
            const SizedBox(height: 40),
            _buildSectionTitle('Why Choose Us?'),
            _buildWhyChooseUs(),
            const SizedBox(height: 40),
            _buildFinalCTA(context),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // --- WIDGETS ---

  Widget _buildHeroSection() {
    return Container(
      height: 300,
      width: double.infinity,
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/happy 2.jpg'),
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.black.withOpacity(0.6), Colors.transparent],
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
          ),
        ),
        child: Align(
          alignment: Alignment.bottomLeft,
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Text(
              'Expert Care for Your Best Friend',
              style: GoogleFonts.dynaPuff(
                color: Colors.white,
                fontSize: 36,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: Text(
        title,
        style: GoogleFonts.jua(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildServicesGrid(BuildContext context) {
    final services = [
      {
        'icon': Icons.cut,
        'title': 'Pet Grooming',
        'description': 'Top-notch pampering to keep your pet looking sharp.',
      },
      {
        'icon': Icons.local_hospital,
        'title': 'Pet Clinic',
        'description': 'Comprehensive health checks and preventative care.',
      },
      {
        'icon': Icons.hotel,
        'title': 'Pet Hotel',
        'description': 'A safe and fun home away from home for your pet.',
      },
      {
        'icon': Icons.school,
        'title': 'Pet Training',
        'description': 'Positive reinforcement training for a well-behaved pal.',
      },
    ];

    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.8,
        crossAxisSpacing: 20,
        mainAxisSpacing: 20,
      ),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      itemCount: services.length,
      itemBuilder: (context, index) {
        final service = services[index];
        return _buildServiceCard(
          icon: service['icon'] as IconData,
          title: service['title'] as String,
          description: service['description'] as String,
          onPressed: () {
            // Navigate to the booking page with the specific service pre-selected
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => BookAppointmentPage(
                  initialService: service['title'] as String,
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildServiceCard({
    required IconData icon,
    required String title,
    required String description,
    required VoidCallback onPressed,
  }) {
    return Card(
      elevation: 4,
      shadowColor: Colors.amber.withOpacity(0.3),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: Colors.amber[100],
              child: Icon(icon, size: 30, color: Colors.amber[800]),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: GoogleFonts.jua(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Text(
                description,
                style: const TextStyle(fontSize: 14, color: Colors.black54),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber[400],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: Text('Book Now', style: GoogleFonts.dynaPuff(color: Colors.black87)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWhyChooseUs() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        children: [
          _buildBenefitItem(
            Icons.verified_user,
            'Certified Professionals',
            'Our team consists of certified and passionate pet care experts.',
          ),
          _buildBenefitItem(
            Icons.favorite,
            'Pet-Friendly Environment',
            'We prioritize your pet\'s comfort and safety in a calm atmosphere.',
          ),
          _buildBenefitItem(
            Icons.eco,
            'Natural Products',
            'We use only high-quality, natural products for all our services.',
          ),
        ],
      ),
    );
  }

  Widget _buildBenefitItem(IconData icon, String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: Colors.grey[200],
            child: Icon(icon, color: Colors.amber[700]),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 4),
                Text(subtitle, style: const TextStyle(color: Colors.black54)),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildFinalCTA(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Colors.amber[50],
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      child: Column(
        children: [
          Text(
            'Ready to Pamper Your Pet?',
            style: GoogleFonts.jua(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Book an appointment today and let us treat your furry friend like royalty.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Colors.black54),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              // Navigate to the booking page without a pre-selected service
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const BookAppointmentPage()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber[600],
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            child: Text(
              'Book an Appointment',
              style: GoogleFonts.dynaPuff(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}