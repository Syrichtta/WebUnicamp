import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:webunicamp/src/widgets/custom_appbar.dart';

class BuildingScreen extends StatelessWidget {
  const BuildingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Retrieve arguments passed from HomeScreen
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

    final name = args['Name'] ?? 'Unnamed Building';
    final description = args['Description'] ?? 'No description available';

    // Fetch locations corresponding to this building
    Stream<QuerySnapshot> _fetchLocations() {
      return FirebaseFirestore.instance
          .collection('Locations')
          .where('Building', isEqualTo: name) // Match Building field with the Name of the building
          .snapshots();
    }

    return Scaffold(
      appBar: CustomAppBar(),
      body: Row(
        children: [
          // Left Side: Background Image
          Expanded(
            flex: 1,
            child: Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("addu.png"),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),

          // Right Side: Details
          Expanded(
            flex: 1,
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Building Name
                    Text(
                      name,
                      style: Theme.of(context).textTheme.headlineLarge,
                      textAlign: TextAlign.start,
                    ),
                    const SizedBox(height: 20),

                    // Building Description
                    Text(
                      description,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 20),
                    Container(height: 1, color: Color(0xFF7a7a7a)),
                    const SizedBox(height: 20), 


                    // Locations Grid
                    StreamBuilder<QuerySnapshot>(
                      stream: _fetchLocations(), // Fetch locations for the building
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        if (snapshot.hasError) {
                          return Center(child: Text("Error loading locations: ${snapshot.error}"));
                        }
                        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                          return const Center(child: Text("No locations found for this building"));
                        }

                        final locations = snapshot.data!.docs;
                        

                        return GridView.builder(
                          shrinkWrap: true, // Allows GridView to fit within SingleChildScrollView
                          physics: const NeverScrollableScrollPhysics(), // Disable scrolling within GridView
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2, // Number of columns
                            crossAxisSpacing: 8.0, // Space between columns
                            mainAxisSpacing: 8.0, // Space between rows
                            childAspectRatio: 0.8, // Adjust card proportions
                          ),
                          itemCount: locations.length,
                          itemBuilder: (context, index) {
                            final location = locations[index];
                            final locationName = location['Name'] ?? 'Unnamed Location';
                            final photoURLs = location['PhotoURL'] as List<dynamic>?; // PhotoURL is a list
                            final locationPhotoURL = (photoURLs != null && photoURLs.isNotEmpty)
                                ? photoURLs[0] // Use the first photo if available
                                : 'https://via.placeholder.com/150'; // Placeholder for missing image

                            return Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                              elevation: 4.0,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Expanded(
                                    flex: 3, 
                                    child: ClipRRect(
                                      borderRadius: const BorderRadius.vertical(top: Radius.circular(12.0)),
                                      child: Image.network(
                                        locationPhotoURL,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) {
                                          return Container(
                                            color: Colors.grey[200],
                                            child: const Icon(Icons.image_not_supported, size: 50),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 1,
                                    child: Container(
                                      padding: const EdgeInsets.all(8.0),
                                      alignment: Alignment.center,
                                      child: Text(
                                        locationName,
                                        style: Theme.of(context).textTheme.titleMedium,
                                        textAlign: TextAlign.center,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
