import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:webunicamp/src/screens/updatelocationscreen.dart';

class LocationDetailsWidget extends StatelessWidget {
  final String locationId; // Add this
  final GeoPoint Location;
  final String name;
  final String email;
  final String building;
  final String description;
  final List<String> photoURLs;

  const LocationDetailsWidget({
    Key? key,
    required this.locationId, // Add this
    required this.Location,
    required this.name,
    required this.email,
    required this.building,
    required this.description,
    required this.photoURLs,
  }) : super(key: key);

  void _navigateToUpdate(BuildContext context) {
    // Create a map of the location data
    final locationData = {
      'Name': name,
      'Email': email,
      'Building': building,
      'Description': description,
      'PhotoURL': photoURLs,
      'Visibility': true,
      'Location': Location,
    };

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UpdateLocationScreen(
          locationId: locationId,
          locationData: locationData,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Existing carousel code...
          if (photoURLs.isNotEmpty)
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.4,
              child: CarouselSlider(
                options: CarouselOptions(
                  height: double.infinity,
                  viewportFraction: 1.0,
                  autoPlay: true,
                  autoPlayInterval: const Duration(seconds: 5),
                ),
                items: photoURLs.map((url) {
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      url,
                      fit: BoxFit.cover,
                      width: double.infinity,
                    ),
                  );
                }).toList(),
              ),
            )
          else
            Container(
              height: MediaQuery.of(context).size.height * 0.4,
              color: Colors.grey,
              child: const Center(
                child: Text('No images available'),
              ),
            ),
          const SizedBox(height: 16),

          // Existing content...
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                name,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  textStyle: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                email,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  textStyle: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w300,
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              description,
              style: GoogleFonts.poppins(
                textStyle: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          // Add the edit button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _navigateToUpdate(context),
                icon: const Icon(Icons.edit, color: Colors.black),
                label: Text(
                  'Edit Location',
                  style: GoogleFonts.poppins(
                    textStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.normal,
                      color: Colors.black,
                    ),
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32.0,
                    vertical: 16.0,
                  ),
                  backgroundColor: const Color(0xfff3f3f3),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}