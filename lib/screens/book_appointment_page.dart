import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

// To access the Pet model, we import the profile page.
// In a larger app, you would move the Pet class to its own file under a 'models' folder.
import 'profile_page.dart';

class BookAppointmentPage extends StatefulWidget {
  final String? initialService;
  const BookAppointmentPage({super.key, this.initialService});

  @override
  State<BookAppointmentPage> createState() => _BookAppointmentPageState();
}

class _BookAppointmentPageState extends State<BookAppointmentPage> {
  final _formKey = GlobalKey<FormState>();

  // Form state
  String? _selectedService;
  String? _selectedPetId;
  DateTime? _selectedDate;
  String? _selectedTimeSlot;
  bool _isLoading = false;

  final List<String> _services = [
    'Pet Grooming',
    'Pet Clinic',
    'Pet Hotel',
    'Pet Training'
  ];

  final List<String> _timeSlots = [
    '09:00 AM', '10:00 AM', '11:00 AM', '02:00 PM', '03:00 PM', '04:00 PM'
  ];

  @override
  void initState() {
    super.initState();
    _selectedService = widget.initialService;
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _confirmBooking() async {
    if (_isLoading) return;

    if (_formKey.currentState!.validate()) {
      // Additional validation for date and time slot
      if (_selectedDate == null || _selectedTimeSlot == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a date and time slot.'), backgroundColor: Colors.redAccent),
        );
        return;
      }
      
      setState(() => _isLoading = true);

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('You must be logged in to book.'), backgroundColor: Colors.redAccent),
        );
        setState(() => _isLoading = false);
        return;
      }

      try {
        await FirebaseFirestore.instance.collection('appointments').add({
          'userId': user.uid,
          'petId': _selectedPetId,
          'service': _selectedService,
          'date': Timestamp.fromDate(_selectedDate!),
          'timeSlot': _selectedTimeSlot,
          'status': 'Confirmed',
          'createdAt': FieldValue.serverTimestamp(),
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Appointment booked successfully!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.of(context).pop();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to book appointment: $e'), backgroundColor: Colors.redAccent),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text('Book Appointment', style: GoogleFonts.dynaPuff()),
        backgroundColor: Colors.white,
        elevation: 1,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('1. Select a Service'),
              _buildServiceDropdown(),
              const SizedBox(height: 24),
              _buildSectionTitle('2. Choose your Pet'),
              _buildPetDropdown(),
              const SizedBox(height: 24),
              _buildSectionTitle('3. Pick a Date'),
              _buildDatePicker(),
              const SizedBox(height: 24),
              _buildSectionTitle('4. Select a Time Slot'),
              _buildTimeSlotGrid(),
              const SizedBox(height: 40),
              _buildConfirmButton(),
            ],
          ),
        ),
      ),
    );
  }

  // --- WIDGETS ---

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(
        title,
        style: GoogleFonts.jua(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
      ),
    );
  }

  Widget _buildServiceDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedService,
      items: _services.map((service) => DropdownMenuItem(value: service, child: Text(service))).toList(),
      onChanged: (value) => setState(() => _selectedService = value),
      decoration: _inputDecoration('Service Type'),
      validator: (value) => value == null ? 'Please select a service' : null,
    );
  }

  Widget _buildPetDropdown() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return InputDecorator(
        decoration: _inputDecoration('Your Pet').copyWith(
          errorText: 'Please log in to select a pet.',
        ),
        child: const Text(''),
      );
    }

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('users').doc(user.uid).collection('pets').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return const Text('Failed to load pets.');
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return InputDecorator(
            decoration: _inputDecoration('Your Pet').copyWith(
              errorText: 'No pets found. Please add a pet on your profile.',
            ),
            child: const Text(''),
          );
        }

        final pets = snapshot.data!.docs.map((doc) => Pet.fromFirestore(doc)).toList();

        return DropdownButtonFormField<String>(
          value: _selectedPetId,
          items: pets.map((pet) => DropdownMenuItem(value: pet.id, child: Text(pet.name))).toList(),
          onChanged: (value) => setState(() => _selectedPetId = value),
          decoration: _inputDecoration('Your Pet'),
          validator: (value) => value == null ? 'Please select your pet' : null,
        );
      },
    );
  }

  Widget _buildDatePicker() {
    return InkWell(
      onTap: () => _selectDate(context),
      child: InputDecorator(
        decoration: _inputDecoration('Appointment Date'),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _selectedDate == null ? 'Select a date' : DateFormat.yMMMd().format(_selectedDate!),
              style: TextStyle(fontSize: 16, color: _selectedDate == null ? Colors.grey[700] : Colors.black),
            ),
            Icon(Icons.calendar_today, color: Colors.amber[800]),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeSlotGrid() {
    return Wrap(
      spacing: 12.0,
      runSpacing: 12.0,
      children: _timeSlots.map((time) {
        final isSelected = _selectedTimeSlot == time;
        return ChoiceChip(
          label: Text(time),
          selected: isSelected,
          onSelected: (selected) => setState(() => _selectedTimeSlot = selected ? time : null),
          selectedColor: Colors.amber[400],
          labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black, fontWeight: FontWeight.bold),
          backgroundColor: Colors.grey[200],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: isSelected ? Colors.amber[600]! : Colors.grey[300]!),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildConfirmButton() {
    return Center(
      child: ElevatedButton(
        onPressed: _isLoading ? null : _confirmBooking,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.amber[600],
          padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          elevation: 4,
          minimumSize: const Size(200, 56), // Set a minimum size to prevent resizing
        ),
        child: _isLoading
            ? const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 3,
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.check_circle_outline, color: Colors.white),
                  const SizedBox(width: 8),
                  Text(
                    'Confirm Booking',
                    style: GoogleFonts.dynaPuff(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ],
              ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.amber[800]!),
      ),
    );
  }
}