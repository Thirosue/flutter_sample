import 'package:flutter/material.dart';

class IndexPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('Index'),
      ),
      body: Text(
        'Index Page',
        style: TextStyle(
          fontSize: 24,
        ),
      ),
    );
  }
}
