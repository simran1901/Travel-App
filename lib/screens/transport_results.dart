import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import './transport_book_screen.dart';

class TransportResults extends StatelessWidget {
  static String routeName = '/transport-search';
  @override
  Widget build(BuildContext context) {
    Map<String, String> reqTrans = ModalRoute.of(context).settings.arguments;
    return Scaffold(
      appBar: AppBar(
        title: Text('Available Trucks and Movers'),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('transports')
            .where('isBooked', isEqualTo: false)
            // .where('start', isEqualTo: reqTrans['from'])
            // .where('end', isEqualTo: reqTrans['to'])
            // .where('date', isGreaterThanOrEqualTo: reqTrans['date'])
            .snapshots(),
        builder: (ctx, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          if (snapshot.data == null)
            return Text('No transport available at the moment.');
          final docs = snapshot.data.docs;
          if (docs.length == 0) return Center(
              child: Card(
                color: Colors.blueGrey[100],
                elevation: 6,
                child: Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Text('No transport is available at the moment.'),
                ),
              ),
            );

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (ctx, index) => Card(
              elevation: 3,
              margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              child: ListTile(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TransportBookScreen(
                          docs: docs[index],
                          req: reqTrans,
                        ),
                      ));
                },
                leading: CircleAvatar(
                  backgroundColor: Theme.of(context).primaryColor,
                  backgroundImage: NetworkImage(docs[index]['url']),
                ),
                title: AutoSizeText(docs[index]['name'], maxLines: 1),
                subtitle: AutoSizeText(
                  // docs[index]['start'] + " to " + docs[index]['end'],
                  'Rent: Rs.${docs[index]['rate']} per km',
                  style: TextStyle(fontSize: 12),
                  maxLines: 1,
                ),
                trailing: Wrap(
                  spacing: 10,
                  children: [
                    Column(
                      children: [
                        AutoSizeText(
                          'Capacity: ${docs[index]['capacity']} ton(s)',
                          style: TextStyle(fontSize: 11),
                          maxLines: 1,
                        ),
                        RatingBar(
                          ignoreGestures: true,
                          itemSize: 18,
                          initialRating: double.parse(docs[index]['overall rating']),
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
                          // itemPadding: EdgeInsets.symmetric(horizontal: 1),
                          onRatingUpdate: (rating) {
                            print(rating);
                          },
                        ),
                      ],
                    ),
                    Icon(Icons.more_vert),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
