import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
        children: [
            Column(),
            Column(
                children: [
                  Text("hello world")
                ],
            )
        ],
    );
  }
}