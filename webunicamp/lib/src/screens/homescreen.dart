import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  // Method to log out the user
  Future<void> _logOut(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacementNamed(context, '/'); // Navigate back to login screen
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Home"),
        actions: [
          IconButton(
            icon: Icon(Icons.exit_to_app),
            onPressed: () => _logOut(context), // Call the logout method
          ),
        ],
      ),
      body: Row(
        children: [
          Column(),
          Column(
            children: [
              Text("Hello World"),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => _logOut(context), // Log out on button press
                child: Text('Log Out'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
