import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Size preferredSize;

  CustomAppBar({Key? key})
      : preferredSize = const Size.fromHeight(80), // Set the height
        super(key: key);

  Future<void> _logOut(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacementNamed(context, '/');
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF3F3F3),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2), // Shadow color with opacity
            spreadRadius: 2, // Spread radius
            blurRadius: 8, // Blur radius
            offset: const Offset(0, 4), // Offset in x and y direction
          ),
        ],
      ),
      child: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: const Color(0xFFF3F3F3),
        elevation: 0, // Disable AppBar elevation
        flexibleSpace: Padding(
          padding: const EdgeInsets.fromLTRB(32, 10, 32, 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                children: [
                  Image.asset(
                    'assets/addu_logo.png',
                    height: 60,
                  ),
                  const SizedBox(
                    width: 16,
                  ),
                  const Text(
                    'Ateneo De Davao University WebUniCamp',
                    style: TextStyle(
                      fontFamily: 'Trajan',
                      fontSize: 28,
                      color: Color(0xFF2E3192),
                    ),
                  ),
                ],
              ),
              ElevatedButton(
                onPressed: () {
                  _logOut(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E3192),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                  child: Text(
                    'logout',
                    style: GoogleFonts.poppins(
                      textStyle: const TextStyle(
                          color: Color(0xFFF3F3F3F3),
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.8),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
