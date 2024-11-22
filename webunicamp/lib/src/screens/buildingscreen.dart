import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:image_network/image_network.dart';
import 'package:webunicamp/src/widgets/custom_appbar.dart';
import 'package:webunicamp/src/widgets/location_card.dart';

class BuildingScreen extends StatelessWidget {
  const BuildingScreen({Key? key}) : super(key: key);

  Future<Map<String, dynamic>> _fetchBuildingData(String? buildingName) async {
    if (buildingName == null) return {};

    try {
      final QuerySnapshot buildingSnapshot = await FirebaseFirestore.instance
          .collection('Buildings')
          .where('Name', isEqualTo: buildingName)
          .limit(1)
          .get();

      if (buildingSnapshot.docs.isNotEmpty) {
        return buildingSnapshot.docs.first.data() as Map<String, dynamic>;
      }
    } catch (e) {
      print('Error fetching building data: $e');
    }
    return {};
  }

  @override
  Widget build(BuildContext context) {
    // Get building name from route parameters or arguments
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final Uri uri = Uri.parse(Uri.base.toString());
    final String? buildingNameFromUrl = uri.queryParameters['building'];

    // Use URL parameter if available, otherwise use route arguments
    final String buildingName =
        buildingNameFromUrl ?? args?['Name'] ?? 'Unnamed Building';

    return FutureBuilder<Map<String, dynamic>>(
      future: _fetchBuildingData(buildingName),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final buildingData = snapshot.data ?? {};
        final name = buildingData['Name'] ?? buildingName;
        final description =
            buildingData['Description'] ?? 'No description available';

        // Process PhotoURL data
        dynamic photoURLData = buildingData['PhotoURL'];
        List<String> photoURLs = [];

        if (photoURLData is List) {
          photoURLs = List<String>.from(photoURLData);
        } else if (photoURLData != null) {
          photoURLs = [photoURLData.toString()];
        }

        // Use route arguments as fallback if available
        if (photoURLs.isEmpty && args?['PhotoURL'] != null) {
          final argsPhotoURL = args!['PhotoURL'];
          if (argsPhotoURL is List) {
            photoURLs = List<String>.from(argsPhotoURL);
          } else {
            photoURLs = [argsPhotoURL.toString()];
          }
        }

        Stream<QuerySnapshot> _fetchLocations() {
          return FirebaseFirestore.instance
              .collection('Locations')
              .where('Building', isEqualTo: name)
              .snapshots();
        }

        return Scaffold(
          appBar: CustomAppBar(),
          body: Column(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: photoURLs.isEmpty
                          ? Container(
                              decoration: const BoxDecoration(
                                color: Colors.grey,
                              ),
                              child: const Center(
                                child: Text('No images available'),
                              ),
                            )
                          : CarouselSlider(
                              options: CarouselOptions(
                                height: double.infinity,
                                viewportFraction: 1.0,
                                enlargeCenterPage: false,
                                autoPlay: true,
                                autoPlayInterval: const Duration(seconds: 5),
                              ),
                              items: photoURLs.map((url) {
                                return Builder(
                                  builder: (BuildContext context) {
                                    return Container(
                                      width: double.infinity,
                                      child: Image.network(
                                        url,
                                        fit: BoxFit.cover,
                                      ),
                                    );
                                  },
                                );
                              }).toList(),
                            ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name,
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineMedium
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              description,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            const SizedBox(height: 24),
                            Container(height: 1, color: Color(0xFF7a7a7a)),
                            const SizedBox(height: 24),
                            Expanded(
                              child: StreamBuilder<QuerySnapshot>(
                                stream: _fetchLocations(),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return const Center(
                                        child: CircularProgressIndicator());
                                  }
                                  if (snapshot.hasError) {
                                    return Center(
                                      child: Text(
                                          "Error loading locations: ${snapshot.error}"),
                                    );
                                  }
                                  if (!snapshot.hasData ||
                                      snapshot.data!.docs.isEmpty) {
                                    return const Center(
                                      child: Text(
                                          "No locations found for this building"),
                                    );
                                  }

                                  final locations = snapshot.data!.docs;

                                  return LayoutBuilder(
                                    builder: (context, constraints) {
                                      int crossAxisCount =
                                          constraints.maxWidth > 800
                                              ? 3
                                              : constraints.maxWidth > 400
                                                  ? 2
                                                  : 1;

                                      return GridView.builder(
                                        gridDelegate:
                                            SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: crossAxisCount,
                                          crossAxisSpacing: 12.0,
                                          mainAxisSpacing: 12.0,
                                          childAspectRatio: 0.8,
                                        ),
                                        itemCount: locations.length,
                                        itemBuilder: (context, index) {
                                          final locationData = locations[index]
                                              .data() as Map<String, dynamic>?;

                                          if (locationData == null) {
                                            return const Center(
                                                child: Text(
                                                    "Invalid location data"));
                                          }

                                          final locationName =
                                              locationData['Name'] ??
                                                  'Unnamed Location';
                                          final locationPhotoURLs =
                                              locationData['PhotoURL']
                                                  as List<dynamic>?;
                                          final photoURL = (locationPhotoURLs !=
                                                      null &&
                                                  locationPhotoURLs.isNotEmpty)
                                              ? locationPhotoURLs[0]
                                              : 'https://via.placeholder.com/150';

                                          return LocationCard(
                                            imgUrl: photoURL,
                                            title: locationName,
                                          );
                                        },
                                      );
                                    },
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Back"),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
