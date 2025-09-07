import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';

// A simple data model for our carousel items
class CarouselItem {
  final String image;
  final String title;
  final String description;

  CarouselItem({
    required this.image,
    required this.title,
    required this.description,
  });
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // --- Controllers and State Variables ---
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _errorText;
  bool _rememberMe = false;

  // --- Carousel State ---
  final PageController _pageController = PageController();
  int _currentPage = 0;
  Timer? _timer;

  // --- Carousel Dummy Data ---
  final List<CarouselItem> _carouselData = [
    CarouselItem(
      image:
          "assets/golden_retriever.jpg",
      title: 'Golden Retriever',
      description:
          'Golden Retriever puppies are known for their friendly nature, intelligence, and playful spirit. They quickly become cherished members of any family.',
    ),
    CarouselItem(
      image: 'assets/british_shorthair.jpg', // Placeholder kitten image
      title: 'British Shorthair',
      description:
          'Known for their plush coats and sweet, easygoing personalities, British Shorthair kittens make calm and affectionate companions.',
    ),
    CarouselItem(
      image: 'assets/macaw.png', // Placeholder parrot image
      title: 'Macaw',
      description:
          'Macaws are intelligent, social birds that bond closely with their owners. Their vibrant colors and playful antics make them captivating pets.',
    ),
    CarouselItem(
      image: 'assets/beagle.png', // Placeholder kitten image
      title: 'Beagle',
      description:
          'Recognized for their soulful eyes and cheerful, inquisitive nature, beagles are lively and affectionate dogs that thrive on companionship and adventure',
    ),
  ];

  @override
  void initState() {
    super.initState();
    // Start the auto-scroll timer for the carousel
    _timer = Timer.periodic(const Duration(seconds: 5), (Timer timer) {
      if (_currentPage < _carouselData.length - 1) {
        _currentPage++;
      } else {
        _currentPage = 0;
      }
      _pageController.animateToPage(
        _currentPage,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeIn,
      );
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _pageController.dispose();
    _timer?.cancel(); // Cancel the timer to prevent memory leaks
    super.dispose();
  }

  // --- Firebase Sign-In Logic (Unchanged) ---
  Future<void> _signIn() async {
    setState(() {
      _isLoading = true;
      _errorText = null;
    });
    try {
      // Basic validation
      if (_emailController.text.trim().isEmpty ||
          _passwordController.text.trim().isEmpty) {
        throw FirebaseAuthException(
          code: 'fields-empty',
          message: 'Email and password cannot be empty.',
        );
      }

      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (!mounted) return;
      // On successful login, navigate to the home screen
      Navigator.pushReplacementNamed(context, '/home');
    } on FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'user-not-found':
          message = 'No user found for that email.';
          break;
        case 'wrong-password':
          message = 'Wrong password provided for that user.';
          break;
        case 'invalid-email':
          message = 'The email address is not valid.';
          break;
        default:
          message = e.message ?? 'An unknown error occurred.';
      }
      setState(() {
        _errorText = message;
      });
    } catch (e) {
      setState(() {
        _errorText = 'Something went wrong. Please try again.';
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
    // Use LayoutBuilder to handle different screen sizes in a real app
    return Scaffold(
      backgroundColor: Colors.white,
      body: Row(
        children: [
          // --- Left Panel: Login Form ---
          Expanded(
            flex: 3, // Takes up 3/5 of the screen
            child: Padding(
              padding: const EdgeInsets.all(48.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Glowing pet ✨',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.amber[700],
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Get your appointment now !',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 32),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildSocialButton(
                          iconPath: 'assets/google.png',
                        ), // Google
                        const SizedBox(width: 16),
                        _buildSocialButton(
                          iconPath: 'assets/facebook.png',
                        ), // Facebook
                        const SizedBox(width: 16),
                        _buildSocialButton(
                          iconPath: 'assets/x.png',
                        ), // X
                      ],
                    ),
                    const SizedBox(height: 32),
                    _buildDivider(),
                    const SizedBox(height: 32),
                    _buildTextField(
                      controller: _emailController,
                      label: 'Email / Username',
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _passwordController,
                      label: 'Password',
                      obscureText: true,
                      suffix: TextButton(
                        onPressed: () {
                          /* TODO: Handle Forgot Password */
                        },
                        child: Text(
                          'Forgot?',
                          style: TextStyle(color: Colors.pink[300]),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Checkbox(
                          value: _rememberMe,
                          onChanged: (value) =>
                              setState(() => _rememberMe = value!),
                          activeColor: Colors.amber[700],
                        ),
                        const Text('Remember me'),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (_errorText != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: Text(
                          _errorText!,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                    Center(child:
                      SizedBox(
                        width: 200,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _signIn,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.amber[400],
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text(
                                  'LOGIN',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Center(
                      child: RichText(
                        text: TextSpan(
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black54,
                          ),
                          children: [
                            const TextSpan(text: "Don't have an account? "),
                            TextSpan(
                              text: 'Sign up!',
                              style: TextStyle(
                                color: Colors.amber[800],
                                fontWeight: FontWeight.bold,
                              ),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () => Navigator.pushReplacementNamed(
                                  context,
                                  '/signup',
                                ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // --- Right Panel: Image Carousel ---
          Expanded(
            flex: 3, // Takes up 3/5 of the screen
            child: _buildImageCarousel(),
          ),
        ],
      ),
    );
  }

  // --- Helper Widgets ---

  Widget _buildImageCarousel() {
    return Container(
      color: Colors.grey[200],
      child: PageView.builder(
        controller: _pageController,
        itemCount: _carouselData.length,
        onPageChanged: (index) {
          setState(() {
            _currentPage = index;
          });
        },
        itemBuilder: (context, index) {
          final item = _carouselData[index];
          return Stack(
            fit: StackFit.expand,
            children: [
              Image.network(
                item.image,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => const Center(
                  child: Icon(Icons.pets, size: 100, color: Colors.grey),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.black.withOpacity(0.6), Colors.transparent],
                    begin: Alignment.bottomCenter,
                    end: Alignment.center,
                  ),
                ),
              ),
              Positioned(
                bottom: 40,
                left: 40,
                right: 40,
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        item.description,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    bool obscureText = false,
    Widget? suffix,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black54,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: obscureText,
          decoration: InputDecoration(
            suffixIcon: suffix,
            filled: true,
            fillColor: Colors.amber[50],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSocialButton({required String iconPath}) {
    return OutlinedButton(
      onPressed: () {
        /* TODO: Implement social login */
      },
      style: OutlinedButton.styleFrom(
        shape: const CircleBorder(),
        padding: const EdgeInsets.all(16),
        side: BorderSide(color: Colors.grey[300]!),
      ),
      child: Image.network(iconPath, height: 24, width: 24),
    );
  }

  Widget _buildDivider() {
    return Row(
      children: [
        Expanded(child: Divider(color: Colors.grey[300])),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text('OR', style: TextStyle(color: Colors.grey[500])),
        ),
        Expanded(child: Divider(color: Colors.grey[300])),
      ],
    );
  }
}
