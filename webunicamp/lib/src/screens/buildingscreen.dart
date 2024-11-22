import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:webunicamp/src/widgets/location_card.dart';
import 'package:webunicamp/src/widgets/location_modal.dart';

class BuildingDetailsWidget extends StatefulWidget {
  final String name;
  final String description;
  final List<String> photoURLs;

  const BuildingDetailsWidget({
    Key? key,
    required this.name,
    required this.description,
    required this.photoURLs,
  }) : super(key: key);

  @override
  _BuildingDetailsWidgetState createState() => _BuildingDetailsWidgetState();
}

class _BuildingDetailsWidgetState extends State<BuildingDetailsWidget> {
  late Future<List<DocumentSnapshot>> _locationsFuture;

  @override
  void initState() {
    super.initState();
    _locationsFuture = _fetchLocations();
  }

  Future<List<DocumentSnapshot>> _fetchLocations() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('Locations')
        .where('Building', isEqualTo: widget.name)
        .get();
    return snapshot.docs;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Carousel
            if (widget.photoURLs.isNotEmpty)
              AspectRatio(
                aspectRatio: 16 / 9,
                child: CarouselSlider(
                  options: CarouselOptions(
                    viewportFraction: 1.0,
                    enlargeCenterPage: false,
                    autoPlay: true,
                    autoPlayInterval: const Duration(seconds: 5),
                  ),
                  items: widget.photoURLs.map((url) {
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        url,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Center(
                          child: Icon(Icons.broken_image),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              )
            else
              Container(
                height: 200,
                color: Colors.grey[300],
                child: const Center(
                  child: Text('No images available'),
                ),
              ),

            const SizedBox(height: 16),

            // Building Name
            Center(
              child: Text(
                widget.name,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  textStyle: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 8),

            // Description
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                widget.description,
                style: GoogleFonts.poppins(
                  textStyle: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Locations List
            FutureBuilder<List<DocumentSnapshot>>(
              future: _locationsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Text("Error loading locations: ${snapshot.error}"),
                  );
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Text("No locations found for this building"),
                  );
                }

                final locations = snapshot.data!;

                return Wrap(
                  spacing: 12.0, // Horizontal spacing
                  runSpacing: 12.0, // Vertical spacing
                  children: locations.map((document) {
                    final locationData =
                        document.data() as Map<String, dynamic>;

                    final locationName =
                        locationData['Name'] ?? 'Unnamed Location';
                    final locationPhotoURLs =
                        locationData['PhotoURL'] as List<dynamic>?;
                    final photoURL = (locationPhotoURLs != null &&
                            locationPhotoURLs.isNotEmpty)
                        ? locationPhotoURLs[0]
                        : 'https://via.placeholder.com/150';

                    return GestureDetector(
                      onTap: () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (_) {
                            return Container(
                              padding: const EdgeInsets.all(16),
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(16),
                                ),
                              ),
                              child: LocationDetailsWidget(
                                name: locationName,
                                building: locationData['Building'] ?? 'Unknown',
                                email: locationData['Email'] ?? 'No email',
                                description: locationData['Description'] ??
                                    'No Description Available',
                                photoURLs:
                                    locationPhotoURLs?.cast<String>() ?? [],
                              ),
                            );
                          },
                        );
                      },
                      child: LocationCard(
                        imgUrl: photoURL,
                        title: locationName,
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
