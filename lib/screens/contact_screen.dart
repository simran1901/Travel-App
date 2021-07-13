import 'package:flutter/material.dart';

import 'package:firebase_messaging/firebase_messaging.dart';

import '../widgets/messages.dart';
import '../widgets/new_message.dart';

class ContactScreen extends StatefulWidget {
  static String routeName = '/contact';
  @override
  _ContactScreenState createState() => _ContactScreenState();
}

class _ContactScreenState extends State<ContactScreen> {
  @override
  void initState() {
    super.initState();
    final fbm = FirebaseMessaging.instance;
    fbm.requestPermission();
    // fbm.configure(
    //   onMessage: (msg) {
    //     print(msg);
    //     return;
    //   },
    //   onLaunch: (msg) {
    //     print(msg);
    //     return;
    //   },
    //   onResume: (msg) {
    //     print(msg);
    //     return;
    //   },
    // );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Contact Us'),
      ),
      body: Container(
        child: Column(
          children: <Widget>[
            Expanded(
              child: Messages(),
            ),
            NewMessage(),
          ],
        ),
      ),
    );
  }
}
