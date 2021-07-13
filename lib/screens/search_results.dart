import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import './seat_book_screen.dart';

class SearchResults extends StatelessWidget {
  static String routeName = '/search';
  @override
  Widget build(BuildContext context) {
    Map<String, String> reqBus = ModalRoute.of(context).settings.arguments;
    return Scaffold(
      appBar: AppBar(
        title: Text('Available Buses'),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('buses')
            .where('start', isEqualTo: reqBus['from'])
            .where('end', isEqualTo: reqBus['to'])
            .where('date', isEqualTo: reqBus['date'])
            .snapshots(),
        builder: (ctx, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          if (snapshot.data == null)
            return Text('No bus available at the moment.');
          final busDocs = snapshot.data.docs;
          if (busDocs.length == 0)
            return Center(
              child: Card(
                color: Colors.blueGrey[100],
                elevation: 6,
                child: Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Text('No bus is available at the moment.'),
                ),
              ),
            );

          return ListView.builder(
            itemCount: busDocs.length,
            itemBuilder: (ctx, index) => Card(
              elevation: 3,
              margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              child: ListTile(
                onTap: () {
                  Navigator.of(context).pushNamed(
                    SeatBookScreen.routeName,
                    arguments: busDocs[index],
                  );
                },
                leading: CircleAvatar(
                  backgroundColor: Theme.of(context).primaryColor,
                  backgroundImage: NetworkImage(busDocs[index]['url']),
                ),
                title: AutoSizeText(busDocs[index]['bus name'], maxLines: 1),
                subtitle: AutoSizeText(
                  busDocs[index]['start'] + " to " + busDocs[index]['end'],
                  style: TextStyle(fontSize: 12),
                  maxLines: 1,
                ),
                trailing: Wrap(
                  spacing: 10,
                  children: [
                    Column(
                      children: [
                        AutoSizeText(
                          busDocs[index]['date'],
                          style: TextStyle(fontSize: 11),
                          maxLines: 1,
                        ),
                        AutoSizeText(
                          'Departs at ' + busDocs[index]['time'],
                          style: TextStyle(fontSize: 11),
                          maxLines: 1,
                        ),
                        RatingBar(
                          ignoreGestures: true,
                          itemSize: 18,
                          initialRating: busDocs[index]['overall rating'],
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
