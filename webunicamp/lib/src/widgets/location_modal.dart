import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LocationDetailsWidget extends StatelessWidget {
  final String name;
  final String description;
  final List<String> photoURLs;

  const LocationDetailsWidget({
    Key? key,
    required this.name,
    required this.description,
    required this.photoURLs,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Carousel for larger images
          if (photoURLs.isNotEmpty)
            SizedBox(
              height: MediaQuery.of(context).size.height *
                  0.4, // 40% of screen height
              child: CarouselSlider(
                options: CarouselOptions(
                  height: double.infinity, // Ensures the images fill the space
                  viewportFraction: 1.0,
                  autoPlay: true,
                  autoPlayInterval: const Duration(seconds: 5),
                ),
                items: photoURLs.map((url) {
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      url,
                      fit: BoxFit.cover, // Ensures the image fills the area
                      width: double.infinity, // Takes up full width
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

          // Name and description
          Text(
            name,
            style: GoogleFonts.poppins(
              textStyle: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Text(
            description,
            style: GoogleFonts.poppins(
              textStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
