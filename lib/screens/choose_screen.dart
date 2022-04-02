import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:imiego/screens/auth_screen.dart';
import 'package:imiego/screens/contact_screen.dart';
import 'package:imiego/screens/history_screen.dart';
import 'package:imiego/screens/offer_screen.dart';
import 'package:imiego/screens/profile_screen.dart';

import './transport_screen.dart';
import './travel_screen.dart';
import '../widgets/choice.dart';

class ChooseScreen extends StatefulWidget {
  static String routeName = '/choose';
  @override
  _ChooseScreenState createState() => _ChooseScreenState();
}

class _ChooseScreenState extends State<ChooseScreen> {
  @override
  Widget build(BuildContext context) {
    User user = FirebaseAuth.instance.currentUser;
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text('ImieGo')),
        actions: [
          if (user == null)
            TextButton(
              child: Text('Sign in', style: TextStyle(color: Colors.white)),
              onPressed: () {
                Navigator.of(context)
                    .pushReplacementNamed(AuthScreen.routeName);
              },
            ),
          if (user != null)
            IconButton(
              icon: Icon(Icons.history),
              onPressed: () {
                Navigator.of(context)
                    .pushNamed(HistoryScreen.routeName, arguments: false);
              },
            ),
          if (user != null)
            IconButton(
              icon: Icon(Icons.account_circle),
              onPressed: () {
                Navigator.of(context).pushNamed(ProfileScreen.routeName);
              },
            ),
        ],
      ),
      body: GridView(
        padding: const EdgeInsets.all(25),
        children: <Widget>[
          Choice(
            'Travel',
            'https://thumbor.forbes.com/thumbor/fit-in/1200x0/filters%3Aformat%28jpg%29/https%3A%2F%2Fspecials-images.forbesimg.com%2Fimageserve%2F5f709d82fa4f131fa2114a74%2F0x0.jpg',
            () {
              Navigator.of(context).pushNamed(TravelScreen.routeName);
            },
          ),
          Choice(
            'Transport',
            'https://www.unescap.org/sites/default/d8files/2020-12/Large%20image-AsianHighway.png',
            () {
              Navigator.of(context).pushNamed(TransportScreen.routeName);
            },
          ),
        ],
        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: size.width,
          childAspectRatio: (size.height - 60) / 290,
          crossAxisSpacing: 20,
          mainAxisSpacing: 20,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: user != null
          ? FloatingActionButton(
              backgroundColor: Theme.of(context).primaryColor,
              onPressed: () {
                Navigator.of(context).pushNamed(ContactScreen.routeName);
              },
              child: Icon(Icons.message),
              highlightElevation: 5,
              elevation: 6,
              tooltip: 'Chat Support',
              hoverElevation: 15,
              // heroTag: Text('Chat Support'),
            )
          : null,
      drawer: Drawer(
        child: ListView(
          children: [
            Container(
              color: Theme.of(context).primaryColor,
              height: 120,
              child: Center(
                child: Text(
                  "Let's ImieGo!",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 30,
                  ),
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.car_rental),
              title: Text('Search your travel'),
              onTap: () {
                Navigator.of(context).popAndPushNamed(TravelScreen.routeName);
              },
            ),
            ListTile(
              leading: Icon(Icons.bus_alert),
              title: Text('Search your transport'),
              onTap: () {
                Navigator.of(context)
                    .popAndPushNamed(TransportScreen.routeName);
              },
            ),
            if (user != null)
              ListTile(
                leading: Icon(Icons.location_on),
                title: Text('Track your ride'),
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext ctx) => AlertDialog(
                      title: Text('This is a paid feature'),
                      content: Text(
                          'This feature requires some APIs that are paid. Therefore, it will be added to the actual application and not the prototype.'),
                      actions: [
                        Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ElevatedButton(
                                style: ButtonStyle(
                                  backgroundColor:
                                      MaterialStateProperty.all<Color>(
                                    Theme.of(context).primaryColor,
                                  ),
                                ),
                                child: Text('Okay'),
                                onPressed: () {
                                  Navigator.of(ctx).pop();
                                },
                              ),
                            ])
                      ],
                    ),
                  );
                },
              ),
            ListTile(
              leading: Icon(Icons.card_giftcard),
              title: Text('Offers'),
              onTap: () {
                Navigator.of(context).pushNamed(OfferScreen.routeName);
              },
            ),
            // ListTile(
            //   leading: Icon(Icons.money),
            //   title: Text('Refer and earn'),
            //   onTap: () {},
            // ),
            if (user != null)
              ListTile(
                leading: Icon(Icons.cancel),
                title: Text('Cancel Ticket'),
                onTap: () {
                  Navigator.of(context).popAndPushNamed(HistoryScreen.routeName,
                      arguments: true);
                },
              ),
            // ListTile(
            //   leading: Icon(Icons.restore_page),
            //   title: Text('Reschedule Ticket'),
            //   onTap: () {},
            // ),
            if (user != null)
              ListTile(
                leading: Icon(Icons.settings),
                title: Text('Settings'),
                onTap: () {
                  Navigator.of(context).pushNamed(ProfileScreen.routeName);
                },
              ),
            if (user != null)
              ListTile(
                leading: Icon(Icons.contact_phone),
                title: Text('Contact Us'),
                onTap: () {
                  Navigator.of(context).pushNamed(ContactScreen.routeName);
                },
              ),
            ListTile(
              leading: Icon(Icons.exit_to_app),
              title: Text(user != null ? 'Sign Out' : 'Sign Up / Sign In'),
              onTap: () {
                setState(() {
                  if (user != null) {
                    FirebaseAuth.instance.signOut();
                    Navigator.of(context).pop();
                  }
                  Navigator.of(context)
                      .pushReplacementNamed(AuthScreen.routeName);
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}
