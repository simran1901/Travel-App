import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class ProfileScreen extends StatelessWidget {
  static String routeName = '/profile';
  @override
  Widget build(BuildContext context) {
    User user = FirebaseAuth.instance.currentUser;
    return Scaffold(
      appBar: AppBar(
        title: Text('Your account'),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .snapshots(),
        builder: (ctx, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                    Theme.of(context).primaryColor),
              ),
            );
          }
          final docs = snapshot.data.data();
          return SingleChildScrollView(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(30.0),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: Theme.of(context).primaryColor,
                        radius: 90,
                        backgroundImage: NetworkImage(docs['image_url']),
                      ),
                      Column(
                        children: [
                          Text(
                            'Total Journeys',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(docs['journeys'].toString()),
                          SizedBox(height: 10),
                          Text(
                            'Travel',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(docs['travels'].toString()),
                          SizedBox(height: 10),
                          Text(
                            'Transport',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(docs['transports'].toString()),
                          SizedBox(height: 10),
                          Text(
                            'Emergencies',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(docs['emergencies'].toString()),
                        ],
                      ),
                    ],
                  ),
                ),
                // SizedBox(height: 20),
                ListTile(
                  leading: Icon(Icons.account_box),
                  title: Text('Name'),
                  subtitle: Text(docs['username']),
                  // trailing: IconButton(
                  //   icon: Icon(Icons.edit),
                  //   onPressed: () {},
                  // ),
                ),
                ListTile(
                  leading: Icon(Icons.email),
                  title: Text('Email address'),
                  subtitle: Text(docs['email']),
                ),
                ListTile(
                  leading: Icon(Icons.phone),
                  title: Text('Mobile number'),
                  subtitle: Text(docs['mobile'].toString()),
                ),
                ListTile(
                  title: Text(
                    'Drop us a rating: ',
                    style: TextStyle(fontSize: 20),
                  ),
                  trailing: RatingBar(
                    itemSize: 25,
                    initialRating: 5,
                    direction: Axis.horizontal,
                    allowHalfRating: true,
                    itemCount: 5,
                    ratingWidget: RatingWidget(
                      full: Icon(
                        Icons.star_rate,
                      ),
                      half: Icon(Icons.star_half),
                      empty: Icon(Icons.star_outline),
                    ),
                    onRatingUpdate: (rating) {
                      print(rating);
                    },
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.share),
                  onPressed: () {},
                ),
                Text('SHARE WITH YOUR FRIENDS'),
                SizedBox(height: 10),
              ],
            ),
          );
        },
      ),
    );
  }
}
