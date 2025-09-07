import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore
import 'dart:math' as math;

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

// Enum for pet selection
enum Pet { dog, cat, others }

class _SignupPageState extends State<SignupPage> {
  // Controllers
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();

  // State variables for UI
  Pet? _selectedPet = Pet.dog;
  bool _agreeToTerms = false;
  bool _isLoading = false;
  String? _errorText;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  // --- NEW: Function to add user details to Firestore ---
  Future<void> addUserDetails(String userId, String firstName, String lastName, String email, String phone, String age, String petType) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(userId).set({
        'first_name': firstName,
        'last_name': lastName,
        'email': email,
        'phone': phone,
        'age': age,
        'pet_type': petType,
        'created_at': Timestamp.now(),
      });
    } catch (e) {
      // Handle errors, e.g., show a snackbar
      print("Failed to add user details: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving user details: $e')),
      );
    }
  }


  // --- Firebase Sign-Up Logic ---
  // This function is now updated to call addUserDetails
  Future<void> _signUp() async {
    if (!_agreeToTerms) {
      setState(() {
        _errorText = 'You must agree to the Terms & Conditions.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorText = null;
    });

    try {
      final firstName = _firstNameController.text.trim();
      final lastName = _lastNameController.text.trim();
      final phone = _phoneController.text.trim();
      final email = _emailController.text.trim();
      final password = _passwordController.text.trim();
      final age = _ageController.text.trim();
      final petType = _selectedPet.toString().split('.').last; // e.g. "dog"

      // Basic Validations
      if ([firstName, lastName, phone, email, password, age].any((e) => e.isEmpty)) {
        throw FirebaseAuthException(code: 'empty-fields', message: 'All fields are required.');
      }
      if (password.length < 6) {
        throw FirebaseAuthException(code: 'weak-password', message: 'Password must be at least 6 characters.');
      }

      // 1. Create Firebase Auth user
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // 2. Add user details to Firestore
      if (userCredential.user != null) {
          await addUserDetails(
            userCredential.user!.uid,
            firstName,
            lastName,
            email,
            phone,
            age,
            petType,
          );
      }


      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Account created successfully!')),
      );

      // Navigate to the home page upon successful signup
      Navigator.pushReplacementNamed(context, '/home');

    } on FirebaseAuthException catch (e) {
      // Handle specific Firebase errors
      String message;
      switch (e.code) {
        case 'email-already-in-use':
          message = 'This email address is already in use.';
          break;
        case 'invalid-email':
          message = 'The email address is not valid.';
          break;
        case 'weak-password':
          message = e.message ?? 'The password is too weak.';
          break;
        case 'empty-fields':
           message = e.message ?? 'Please fill in all fields.';
           break;
        default:
          message = e.message ?? 'An unknown error occurred. Please try again.';
      }
      setState(() {
        _errorText = message;
      });
    } catch (e) {
      // Handle other generic errors
      setState(() {
        _errorText = 'Something went wrong. Please try again later.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // --- Decorative Background Elements ---
          // You can replace these placeholders with your actual paw print images
          _buildPawPrint(top: screenSize.height * 0.1, left: screenSize.width * 0.1, size: 80, color: Colors.amber[200]!),
          _buildPawPrint(top: screenSize.height * 0.05, right: screenSize.width * 0.2, size: 50, color: Colors.amber[200]!),
          _buildPawPrint(bottom: screenSize.height * 0.15, right: screenSize.width * 0.1, size: 90, color: Colors.amber[200]!),
          _buildPawPrint(bottom: screenSize.height * 0.2, left: screenSize.width * 0.05, size: 40, color: Colors.amber[200]!),
          _buildPawPrint(top: screenSize.height * 0.4, right: screenSize.width * 0.05, size: 60, color: Colors.amber[200]!),
          _buildPawPrint(bottom: 10, left: screenSize.width * 0.4, size: 50, color: Colors.amber[200]!),

          // --- Cat Image ---
          // Replace this with your actual cat image asset
          Positioned(
            top: 30,
            right: -20,
            child: SizedBox(
              width: 150,
              height: 150,
              child: Transform(
                alignment: Alignment.center,
                transform: Matrix4.rotationZ(math.pi), // Flips the image upside down
                child: Image.network('assets/catflipped.png', fit: BoxFit.contain,  errorBuilder: (context, error, stackTrace) => Icon(Icons.pets, size: 80, color: Colors.grey[300])),
              ),
            ),
          ),

          // --- Dog Image ---
          // Replace this with your actual dog image asset
          Positioned(
            bottom: -50,
            left: -30,
            child: SizedBox(
              width: 200,
              height: 200,
              child: Image.network('assets/doggie.png', fit: BoxFit.contain, errorBuilder: (context, error, stackTrace) => Icon(Icons.pets, size: 100, color: Colors.grey[300])),
            ),
          ),

          // --- Main Content ---
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 120),

                  // --- Header Text ---
                  Text(
                    'Glowing pet ✨',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.amber[700],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Create account',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: 4, bottom: 24),
                    height: 3,
                    width: 100,
                    color: Colors.amber[400],
                  ),

                  // --- Form Fields ---
                  Row(
                    children: [
                      Expanded(child: _buildTextField(controller: _firstNameController, label: 'First Name')),
                      const SizedBox(width: 16),
                      Expanded(child: _buildTextField(controller: _lastNameController, label: 'Last Name')),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(child: _buildTextField(controller: _emailController, label: 'Email address', keyboardType: TextInputType.emailAddress)),
                      const SizedBox(width: 16),
                      Expanded(child: _buildTextField(controller: _phoneController, label: 'Phone number', keyboardType: TextInputType.phone)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(controller: _passwordController, label: 'Password', obscureText: true),
                  const SizedBox(height: 20),

                  // --- Pet Selection ---
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text('Your Pet:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                      _buildPetRadio(Pet.dog, 'Dog'),
                      _buildPetRadio(Pet.cat, 'Cat'),
                      _buildPetRadio(Pet.others, 'Others'),
                      const Spacer(),
                      SizedBox(
                        width: 80,
                        child: _buildTextField(controller: _ageController, label: 'Age', keyboardType: TextInputType.number),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // --- Terms and Conditions ---
                  Row(
                    children: [
                      Checkbox(
                        value: _agreeToTerms,
                        onChanged: (value) {
                          setState(() {
                            _agreeToTerms = value ?? false;
                          });
                        },
                        activeColor: Colors.amber[700],
                      ),
                      Expanded(
                        child: RichText(
                          text: TextSpan(
                            style: const TextStyle(fontSize: 14, color: Colors.black54),
                            children: [
                              const TextSpan(text: 'I agree to the '),
                              TextSpan(
                                text: 'Terms & Conditions',
                                style: TextStyle(color: Colors.amber[800], fontWeight: FontWeight.bold),
                                recognizer: TapGestureRecognizer()..onTap = () {
                                  // TODO: Navigate to Terms & Conditions page
                                  print('Navigate to Terms');
                                },
                              ),
                              const TextSpan(text: ' and '),
                              TextSpan(
                                text: 'Privacy Policy',
                                style: TextStyle(color: Colors.amber[800], fontWeight: FontWeight.bold),
                                recognizer: TapGestureRecognizer()..onTap = () {
                                  // TODO: Navigate to Privacy Policy page
                                  print('Navigate to Privacy');
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // --- Error Message Display ---
                  if (_errorText != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: Text(
                        _errorText!,
                        style: const TextStyle(color: Colors.red, fontSize: 14),
                        textAlign: TextAlign.center,
                      ),
                    ),

                  // --- Sign Up Button ---
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _signUp,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.amber[400],
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(strokeWidth: 3, color: Colors.white),
                            )
                          : const Text(
                              'SIGN UP',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                            ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // --- Login Link ---
                  RichText(
                    text: TextSpan(
                      style: const TextStyle(fontSize: 14, color: Colors.black54),
                      children: [
                        const TextSpan(text: 'Already have an account? '),
                        TextSpan(
                          text: 'Login!',
                          style: TextStyle(color: Colors.amber[800], fontWeight: FontWeight.bold),
                          recognizer: TapGestureRecognizer()..onTap = () {
                            Navigator.pushReplacementNamed(context, '/login');
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 80), // Extra space at the bottom
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- Helper Widgets ---

  // Custom widget for text fields to reduce repetition
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black54),
        ),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.grey[200],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
      ],
    );
  }

  // Custom widget for pet radio buttons
  Widget _buildPetRadio(Pet petValue, String title) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Radio<Pet>(
          value: petValue,
          groupValue: _selectedPet,
          onChanged: (Pet? value) {
            setState(() {
              _selectedPet = value;
            });
          },
          activeColor: Colors.amber[700],
        ),
        Text(title),
      ],
    );
  }

  // Custom widget for paw print icons
  Widget _buildPawPrint({double? top, double? bottom, double? left, double? right, required double size, required Color color}) {
    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: Icon(
        Icons.pets,
        size: size,
        color: color.withOpacity(0.7),
      ),
    );
  }
}
