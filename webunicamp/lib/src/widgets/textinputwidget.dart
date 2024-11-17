import 'package:flutter/material.dart';

class TextInputWidget extends StatelessWidget {
  final String labelText;
  final TextEditingController controller;
  final bool obscureText;

  const TextInputWidget({
    super.key,
    required this.labelText,
    required this.controller,
    this.obscureText = false, // Default to not obscuring text
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller, // Bind the controller
      obscureText: obscureText, // Set the obscure text behavior
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Color(0xFF707070),
        ),
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Color(0xFFE3E3E3)),
        ),
      ),
    );
  }
}
