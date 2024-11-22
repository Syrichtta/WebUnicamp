import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:webunicamp/src/screens/buildingscreen.dart';
import 'package:webunicamp/src/widgets/building_card.dart';
import 'package:webunicamp/src/widgets/custom_appbar.dart';
// import 'package:webunicamp/src/widgets/building_details_widget.dart';

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
                  return const CircularProgressIndicator();
                }
                // Handle error state
                if (snapshot.hasError) {
                  return const Text('Error loading buildings');
                }
                // No buildings found
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Text('No buildings found');
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
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder: (BuildContext context) {
                              final screenHeight =
                                  MediaQuery.of(context).size.height;

                              return Container(
                                height: screenHeight *
                                    0.85, // Set to 3/4 of the screen height
                                padding: const EdgeInsets.all(16),
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(16),
                                  ),
                                ),
                                child: BuildingDetailsWidget(
                                  name: buildingData['Name'] ??
                                      'Unnamed Building',
                                  description: buildingData['Description'] ??
                                      'No Description Available',
                                  photoURLs: photoURLs,
                                ),
                              );
                            },
                          );
                        },
                        child: BuildingCard(
                          imgUrl: photoURLs[0], // Use first image for card
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
