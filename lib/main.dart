import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:imiego/screens/choose_screen.dart';
import 'package:imiego/screens/contact_screen.dart';
import 'package:imiego/screens/history_screen.dart';
import 'package:imiego/screens/transport_results.dart';
// import 'package:imiego/screens/transport_book_screen.dart';

import './screens/transport_screen.dart';
import './screens/verification_screen.dart';
import './screens/auth_screen.dart';
import './screens/search_results.dart';
import './screens/travel_screen.dart';
import './screens/seat_book_screen.dart';
// import './screens/tab_screen.dart';
import './screens/profile_screen.dart';
import './screens/offer_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ImieGo',
      theme: ThemeData(
        primaryColor: Color.fromRGBO(3, 22, 52, 1),
      ),
      home: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (ctx, userSnapshot) {
          if (userSnapshot.connectionState == ConnectionState.none) {
            return CircularProgressIndicator();
          }
          if (userSnapshot.hasData) {
            User user = FirebaseAuth.instance.currentUser;
            if (user.emailVerified)
              return ChooseScreen();
            else
              return VerificationScreen();
          }
          return AuthScreen();
        },
      ),
      routes: {
        ChooseScreen.routeName: (context) => ChooseScreen(),
        TravelScreen.routeName: (context) => TravelScreen(),
        TransportScreen.routeName: (context) => TransportScreen(),
        SearchResults.routeName: (context) => SearchResults(),
        SeatBookScreen.routeName: (context) => SeatBookScreen(),
        AuthScreen.routeName: (context) => AuthScreen(),
        ProfileScreen.routeName: (context) => ProfileScreen(),
        OfferScreen.routeName: (context) => OfferScreen(),
        HistoryScreen.routeName: (context) => HistoryScreen(),
        ContactScreen.routeName: (context) => ContactScreen(),
        TransportResults.routeName: (context) => TransportResults(),
        VerificationScreen.routeName: (context) => VerificationScreen(),
      },
    );
  }
}
