import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AboutUsPage extends StatefulWidget {
  const AboutUsPage({super.key});

  @override
  State<AboutUsPage> createState() => _AboutUsPageState();
}

class _AboutUsPageState extends State<AboutUsPage> {
  final _formKey = GlobalKey<FormState>();

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      // In a real app, you would send this data to a server or Firestore
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Thank you for your message! We will get back to you soon.'),
          backgroundColor: Colors.green,
        ),
      );
      _formKey.currentState!.reset();
    }
  }

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
          'About Us',
          style: GoogleFonts.dynaPuff(color: Colors.black, fontSize: 22),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildAboutSection(),
              const SizedBox(height: 40),
              _buildContactDetails(),
              const SizedBox(height: 40),
              _buildContactForm(),
            ],
          ),
        ),
      ),
    );
  }

  // --- WIDGETS ---

  Widget _buildAboutSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Image.asset('assets/doggie.png', height: 150),
        ),
        const SizedBox(height: 24),
        Text(
          'About Glowing Pet',
          style: GoogleFonts.jua(fontSize: 28, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Text(
          'Founded in 2024, Glowing Pet started with a simple mission: to provide exceptional care that makes every pet glow with health and happiness. We believe that pets are family, and they deserve the best. Our team of certified professionals is passionate about animals and dedicated to creating a safe, comfortable, and fun environment for your furry friends. From state-of-the-art grooming facilities to cozy pet hotels, every aspect of our service is designed with your pet\'s well-being in mind.',
          style: TextStyle(fontSize: 16, color: Colors.black87, height: 1.6),
        ),
      ],
    );
  }

  Widget _buildContactDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
         Text(
          'Contact Information',
          style: GoogleFonts.jua(fontSize: 28, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        _buildContactInfoRow(Icons.phone, 'Customer Service', '+91 98765 43210'),
        const SizedBox(height: 12),
        _buildContactInfoRow(Icons.emergency, 'Emergency Line', '+91 91234 56789'),
         const SizedBox(height: 12),
        _buildContactInfoRow(Icons.email, 'Email Address', 'contact@glowingpet.com'),
      ],
    );
  }

   Widget _buildContactInfoRow(IconData icon, String title, String detail) {
    return Row(
      children: [
        Icon(icon, color: Colors.amber[700], size: 24),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Text(detail, style: TextStyle(fontSize: 14, color: Colors.black54)),
          ],
        )
      ],
    );
  }

  Widget _buildContactForm() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.amber[50],
        borderRadius: BorderRadius.circular(15),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Get in Touch',
              style: GoogleFonts.jua(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(child: _buildTextFormField('First Name')),
                const SizedBox(width: 16),
                Expanded(child: _buildTextFormField('Last Name')),
              ],
            ),
            const SizedBox(height: 16),
            _buildTextFormField('Email Address', isEmail: true),
            const SizedBox(height: 16),
            _buildTextFormField('Your Message', maxLines: 5),
            const SizedBox(height: 24),
            Center(
              child: ElevatedButton(
                onPressed: _submitForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber[600],
                  padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 16),
                ),
                child: Text(
                  'Send Message',
                  style: GoogleFonts.dynaPuff(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextFormField(String label, {bool isEmail = false, int maxLines = 1}) {
    return TextFormField(
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your $label';
        }
        if (isEmail && !RegExp(r'\S+@\S+\.\S+').hasMatch(value)) {
          return 'Please enter a valid email address';
        }
        return null;
      },
    );
  }
}