import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
    const HomeScreen({super.key});

    @override
    Widget build(BuildContext context) {
        return const Text(
            'Home Screen',
            style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
            ),
        );
    }
}
