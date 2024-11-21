import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:webunicamp/src/widgets/custom_appbar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Future<void> _logOut(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacementNamed(context, '/');
  }

  Stream<QuerySnapshot> _fetchBuildings() {
    return FirebaseFirestore.instance.collection('Buildings').snapshots();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    // Calculate the grid layout dynamically based on screen size
    final int crossAxisCount = (screenWidth / 300).floor(); // Approx 300px per card
    final double childAspectRatio = 11 / 12; // Adjust to make cards proportional

    return Scaffold(
      appBar: CustomAppBar(),
      body: Row(
        children: [
          Opacity(opacity: 0.5,
            child: Container(
              decoration: const BoxDecoration(
                image: DecorationImage(image: AssetImage("addu.png"),
                fit: BoxFit.cover
                )
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: StreamBuilder<QuerySnapshot>(
              stream: _fetchBuildings(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text("Error loading buildings: ${snapshot.error}"));
                }
          
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text("No buildings found"));
                }
          
                final buildings = snapshot.data!.docs;
          
                return GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    childAspectRatio: childAspectRatio,
                    crossAxisSpacing: 16.0,
                    mainAxisSpacing: 16.0,
                  ),
                  itemCount: buildings.length,
                  itemBuilder: (context, index) {
                    final building = buildings[index];
                    final name = building['Name'] ?? 'Unnamed Building';
                    final photoURLs = building['PhotoURL'] as List<dynamic>;
                    final photoURL = photoURLs.isNotEmpty
                        ? photoURLs[0]
                        : 'https://via.placeholder.com/150'; // Fallback image
          
                    return Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      elevation: 4.0,
                      child: InkWell(
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            '/buildings',
                            arguments: {
                              'Name': name,
                              'Description': building['Description'],
                            },
                          );
                        },
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            ClipRRect(
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(12.0)),
                              child: Image.network(
                                photoURL,
                                height: 70, 
                                fit: BoxFit.cover,
                                loadingBuilder: (context, child, loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return const Center(child: CircularProgressIndicator());
                                },
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    height: 240,
                                    color: Colors.grey[200],
                                    child: const Icon(Icons.image_not_supported, size: 50),
                                  );
                                },
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                name,
                                style: Theme.of(context).textTheme.titleMedium,
                                textAlign: TextAlign.center,
                                overflow: TextOverflow.ellipsis, 
                                maxLines: 1, 
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
