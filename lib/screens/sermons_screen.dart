import 'package:flutter/material.dart';

class SermonsScreen extends StatelessWidget {
  const SermonsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Sermons')),
      body: Center(child: Text('Sermons will be displayed here')),
    );
  }
}
