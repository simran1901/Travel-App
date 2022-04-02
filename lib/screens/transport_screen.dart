import 'package:flutter/material.dart';
import '../widgets/transport_card.dart';

class TransportScreen extends StatelessWidget {
  static String routeName = '/transport';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Choose your locations')),
      body: TransportCard(),
    );
  }
}