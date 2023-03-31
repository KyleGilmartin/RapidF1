import 'package:flutter/material.dart';
import 'package:rapidpixelracing/screens/tier_screen.dart';
import 'package:rapidpixelracing/screens/widgets/tier_list.dart';

class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [Text('Welcome Kyle'), Text('Sign Out')],
        ),
      ),
      body: SizedBox(
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: TiersList(),
        ),
      ),
    );
  }
}
