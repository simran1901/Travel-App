import 'package:flutter/material.dart';
import '../widgets/travel_card.dart';

class TravelScreen extends StatelessWidget {
  static String routeName = '/travel';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Choose your locations')),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Center(
              child: TravelCard(),
            ),
          ],
        ),
      ),
    );
  }
}
