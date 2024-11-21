import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:webunicamp/src/widgets/custom_appbar.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Future<void> _logOut(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacementNamed(context, '/');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(),
      body: Row(
        children: [
          Column(),
          Column(
            children: [
              Text("Hello World"),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => _logOut(context), // Log out on button press
                child: Text(
                  'Log Out',
                  style: GoogleFonts.poppins(
                    textStyle:
                        TextStyle(color: Color(0xFFF3F3F3), fontSize: 20),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
