import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
    const HomeScreen({super.key});

    @override
    Widget build(BuildContext context) {
        return Column(
          children: [
            Text(
                'Home Screen',
                style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                ),
            ),
            Container(
                width: 300,
                height: 300,
                child: CircularProgressIndicator(
                    value: 0.5,
                )
            )
          ],
        );
    }
}
