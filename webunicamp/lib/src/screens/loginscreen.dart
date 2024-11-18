import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _signIn() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await _auth.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      Navigator.pushNamed(context, '/home');
    } on FirebaseAuthException catch (e) {
      _showError(e.message ?? "Authentication error.");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _signInWithGoogle() async {
  setState(() {
    _isLoading = true;
  });

  try {
    // Create a new provider
    GoogleAuthProvider googleProvider = GoogleAuthProvider();

    googleProvider.addScope('https://www.googleapis.com/auth/contacts.readonly');
    googleProvider.setCustomParameters({
      'login_hint': 'user@example.com',
    });

    // Sign in with Google
    UserCredential userCredential =
        await FirebaseAuth.instance.signInWithPopup(googleProvider);

    // Navigate to home on successful login
    Navigator.pushNamed(context, '/home');
  } on FirebaseAuthException catch (e) {
    _showError(e.message ?? "Google Sign-In error.");
  } finally {
    setState(() {
      _isLoading = false;
    });
  }
}

  void _showError(String error) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Error"),
        content: Text(error),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text("OK"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/roxas.jpg',
              fit: BoxFit.cover,
            ),
          ),
          Center(
            child: Card(
              elevation: 10,
              shadowColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Container(
                  width: 250,
                  height: 350,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset('assets/addu_logo.png', height: 100,),
                      SizedBox(height: 15,),
                      Text(
                        'Ateneo WebUniCamp',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          textStyle: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700
                          )
                        )
                      ),
                      SizedBox(height: 15,),
                      Divider(),
                      SizedBox(height: 15,),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _signInWithGoogle,
                          child: Text(
                            'Log In via Gmail',
                            textAlign: TextAlign.center,
                             style: GoogleFonts.poppins(
                                textStyle: TextStyle(
                                  color: Color.fromARGB(255, 231, 231, 231),
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500
                                )
                              )
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF2C2C9A),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5),
                            ),
                            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                          ),
                        ),
                      ),
                      SizedBox(height: 15,),
                      Text(
                          "or",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF707070),
                          ),
                        ),
                      SizedBox(height: 15,),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            // Your onPressed logic here
                          },
                          child: Text(
                            'Continue as Guest',
                            textAlign: TextAlign.center,
                             style: GoogleFonts.poppins(
                                textStyle: TextStyle(
                                  color: Colors.black,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500
                                )
                              )
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFFf5f6fa),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5), // Adjust the radius as needed
                            ),
                            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16), // Optional: Adjust padding
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
