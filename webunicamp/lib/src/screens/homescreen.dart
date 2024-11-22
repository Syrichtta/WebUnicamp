import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:webunicamp/src/screens/buildingscreen.dart';
import 'package:webunicamp/src/widgets/building_card.dart';
import 'package:webunicamp/src/widgets/custom_appbar.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: CustomAppBar(),
      body: Stack(
        children: [
          // Background image
          Positioned.fill(
            child: Image.asset(
              'assets/aerial.jpg',
              fit: BoxFit.cover,
            ),
          ),
          // Overlay
          Positioned.fill(
            child: Container(
              color: Colors.white.withOpacity(0.7),
            ),
          ),
          // Centered Firestore Buildings Query
          Center(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('Buildings')
                  .snapshots(),
              builder: (context, snapshot) {
                // Handle loading state
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                }
                // Handle error state
                if (snapshot.hasError) {
                  return Text('Error loading buildings');
                }
                // No buildings found
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Text('No buildings found');
                }

                return SingleChildScrollView(
                  child: Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 16,
                    runSpacing: 16,
                    children:
                        snapshot.data!.docs.map((DocumentSnapshot document) {
                      var buildingData =
                          document.data() as Map<String, dynamic>;

                      // Process PhotoURL data
                      dynamic photoURLData = buildingData['PhotoURL'];
                      List<String> photoURLs = [];

                      if (photoURLData is List) {
                        // If it's already a list, use it
                        photoURLs = List<String>.from(photoURLData);
                      } else if (photoURLData != null) {
                        // If it's a single URL, create a list with one item
                        photoURLs = [photoURLData.toString()];
                      }

                      // If no photos available, add default photo
                      if (photoURLs.isEmpty) {
                        photoURLs = [
                          'https://firebasestorage.googleapis.com/v0/b/unicamp-ad6f4.firebasestorage.app/o/Bellarmine%20Hall%201.jpg?alt=media&token=1a5a3c18-e171-4bd7-bb37-6d96030f600d'
                        ];
                      }

                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => BuildingScreen(
                                name: buildingData['Name'] ?? 'Unnamed Building',
                                description: buildingData['Description'] ?? 'No Description Available',
                                photoURLs: (buildingData['PhotoURL'] as List<dynamic>?) ?? [],
                              ),
                            ),
                          );
},
                        child: BuildingCard(
                          imgUrl: (buildingData['PhotoURL'] is List)
                              ? buildingData['PhotoURL'][0] 
                              : 'https://via.placeholder.com/150',
                          title: buildingData['Name'] ?? 'Unnamed Building',
                        ),
                      );

                    }).toList(),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
