import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:pet_grooming_app/screens/add_pet_page.dart';

// You can move this model to its own file in a real app
class Pet {
  final String id;
  final String name;
  final String breed;
  final String imageUrl;

  Pet({required this.id, required this.name, required this.breed, required this.imageUrl});

  factory Pet.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return Pet(
      id: doc.id,
      name: data['name'] ?? '',
      breed: data['breed'] ?? '',
      // Using a placeholder image, you can add a real imageUrl field in Firestore
      imageUrl: 'assets/doggie.png',
    );
  }
}

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final User? _currentUser = FirebaseAuth.instance.currentUser;

  Future<void> _signOut() async {
    // Show a confirmation dialog before signing out
    final bool? shouldSignOut = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );

    if (shouldSignOut == true) {
      await FirebaseAuth.instance.signOut();
      // Navigate back to the home page or login screen after sign out
      if (mounted) {
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text('My Profile', style: GoogleFonts.dynaPuff()),
        backgroundColor: Colors.white,
        elevation: 1,
        centerTitle: true,
      ),
      // We now wrap the main content in a StreamBuilder to fetch pets once
      body: _currentUser == null
          ? const Center(child: Text("Please log in to view your profile."))
          : StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(_currentUser.uid)
                  .collection('pets')
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, petSnapshot) {
                if (petSnapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (petSnapshot.hasError) {
                  return const Center(child: Text('Could not load pet data.'));
                }

                // Create a list and a map of pets for efficient lookups
                final pets = petSnapshot.data?.docs.map((doc) => Pet.fromFirestore(doc)).toList() ?? [];
                final petsMap = {for (var pet in pets) pet.id: pet};

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildUserProfileHeader(),
                      const SizedBox(height: 24),
                      _buildSectionCard(
                        title: 'My Pets',
                        actionButton: _buildAddPetButton(),
                        child: _buildMyPetsList(pets), // Pass the pet list
                      ),
                      const SizedBox(height: 24),
                      _buildSectionCard(
                        title: 'Appointment History',
                        child: _buildAppointmentHistoryList(petsMap), // Pass the pet map
                      ),
                      const SizedBox(height: 32),
                      _buildSignOutButton(),
                    ],
                  ),
                );
              },
            ),
    );
  }

  // --- WIDGETS ---

  Widget _buildUserProfileHeader() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 35,
              backgroundColor: Colors.amber[200],
              backgroundImage: _currentUser?.photoURL != null
                  ? NetworkImage(_currentUser!.photoURL!)
                  : null,
              child: _currentUser?.photoURL == null
                  ? Icon(Icons.person, size: 40, color: Colors.amber[800])
                  : null,
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _currentUser?.displayName ?? 'Valued Customer',
                    style: GoogleFonts.jua(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _currentUser?.email ?? 'No email found',
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: Icon(Icons.edit, color: Colors.grey[700]),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Edit Profile feature coming soon!')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required Widget child,
    Widget? actionButton,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: GoogleFonts.jua(fontSize: 18, fontWeight: FontWeight.bold,),
                ),
                if (actionButton != null) actionButton,
              ],
            ),
            const Divider(height: 24, thickness: 1),
            child,
          ],
        ),
      ),
    );
  }

  Widget _buildAddPetButton() {
    return OutlinedButton.icon(
      icon: const Icon(Icons.add, size: 18),
      label: const Text('Add Pet'),
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AddPetPage()),
        );
      },
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.amber[400],
        side: BorderSide(color: Colors.amber[400]!),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
  }

  // This widget now receives the list of pets directly
  Widget _buildMyPetsList(List<Pet> pets) {
    if (pets.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 20.0),
          child: Text('You have not added any pets yet.'),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: pets.length,
      itemBuilder: (context, index) {
        final pet = pets[index];
        return ListTile(
          leading: CircleAvatar(
            backgroundImage: AssetImage(pet.imageUrl),
            radius: 25,
          ),
          title: Text(pet.name, style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text(pet.breed),
        );
      },
    );
  }

  // This widget now receives the map of pets for efficient lookup
  Widget _buildAppointmentHistoryList(Map<String, Pet> petsMap) {
     return StreamBuilder<QuerySnapshot>(
       stream: FirebaseFirestore.instance
            .collection('appointments')
            .where('userId', isEqualTo: _currentUser!.uid)
            // Sorting will be handled client-side to avoid requiring a composite index
            .snapshots(),
       builder: (context, snapshot) {
         if (snapshot.connectionState == ConnectionState.waiting) {
           return const Center(child: CircularProgressIndicator());
         }
         if (snapshot.hasError) {
           return const Center(
             child: Padding(
               padding: EdgeInsets.symmetric(vertical: 20.0),
               child: Text('Failed to load appointments.'),
             ),
           );
         }
         if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
           return const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 20.0),
                child: Text('You have no past appointments.'),
              ),
           );
         }

         final docs = snapshot.data!.docs.toList()
           ..sort((a, b) {
             final aDate = (a['date'] as Timestamp?)?.toDate() ?? DateTime.fromMillisecondsSinceEpoch(0);
             final bDate = (b['date'] as Timestamp?)?.toDate() ?? DateTime.fromMillisecondsSinceEpoch(0);
             return bDate.compareTo(aDate); // descending
           });

         return ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final appointment = docs[index].data() as Map<String, dynamic>;
              final date = (appointment['date'] as Timestamp?)?.toDate();
              
              // Efficiently look up the pet's name from the map
              final petId = appointment['petId'];
              final petName = petsMap[petId]?.name ?? 'Unknown Pet';

              return ListTile(
                leading: const Icon(Icons.calendar_today, color: Colors.amber),
                title: Text((appointment['service'] ?? 'Appointment') as String),
                subtitle: Text(
                  date == null
                    ? 'For $petName at ${appointment['timeSlot'] ?? ''}'
                    : 'For $petName on ${DateFormat.yMMMd().format(date)} at ${appointment['timeSlot'] ?? ''}',
                ),
              );
            },
         );
       },
     );
  }

  Widget _buildSignOutButton() {
    return ElevatedButton.icon(
      icon: const Icon(Icons.logout, color: Colors.white),
      label: Text(
        'Sign Out',
        style: GoogleFonts.dynaPuff(color: Colors.white, fontWeight: FontWeight.bold),
      ),
      onPressed: _signOut,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.amber[400],
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 2,
      ),
    );
  }
}