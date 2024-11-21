import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:webunicamp/src/widgets/building_card.dart';
import 'package:webunicamp/src/widgets/custom_appbar.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
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

                // Use SingleChildScrollView to allow scrolling without ListView stretching
                return SingleChildScrollView(
                  child: Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 16, // horizontal spacing between cards
                    runSpacing: 16, // vertical spacing between rows
                    children:
                        snapshot.data!.docs.map((DocumentSnapshot document) {
                      var buildingData =
                          document.data() as Map<String, dynamic>;
                      return BuildingCard(
                        imgUrl: (buildingData['PhotoURL'] is List)
                            ? buildingData['PhotoURL']
                                [0] // Take the first image if it's a list
                            : buildingData[
                                    'PhotoURL'] ?? // Use original URL if not a list
                                'https://firebasestorage.googleapis.com/v0/b/unicamp-ad6f4.firebasestorage.app/o/Bellarmine%20Hall%201.jpg?alt=media&token=1a5a3c18-e171-4bd7-bb37-6d96030f600d',
                        title: buildingData['Name'] ?? 'Unnamed Building',
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
