import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';

class TierDetails extends StatelessWidget {
  final String title, description;

  const TierDetails(
      {super.key, required this.title, required this.description});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(title + "\n" + description),
    );
  }
}
