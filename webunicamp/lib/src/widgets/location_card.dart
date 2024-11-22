import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_network/image_network.dart';

class LocationCard extends StatelessWidget {
  final String imgUrl;
  final String title;

  const LocationCard({
    super.key,
    required this.imgUrl,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 192,
      height: 262,
      child: Card(
          color: Color(0xFFF3F3F3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          elevation: 5,
          child: Column(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
                child: SizedBox(
                  width: 192,
                  height: 211,
                  child: Image.network(
                    imgUrl,
                    fit: BoxFit.cover,
                  ),
                  //     ImageNetwork(
                  //   image: imgUrl,
                  //   height: 211,
                  //   width: 444,
                  //   fitWeb: BoxFitWeb.cover,
                  //   onLoading: const CircularProgressIndicator(
                  //     color: Colors.indigoAccent,
                  //   ),
                  //   onError: const Icon(
                  //     Icons.error,
                  //     color: Colors.red,
                  //   ),
                  // )
                ),
              ),
              Expanded(
                  child: Center(
                child: Text(
                  title,
                  style: GoogleFonts.poppins(
                    textStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ))
            ],
          )),
    );
  }
}
