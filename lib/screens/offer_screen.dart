import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class OfferScreen extends StatelessWidget {
  static String routeName = '/offers';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Current Offers'),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('offers').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting)
            return Center(child: CircularProgressIndicator());
          if (!snapshot.hasData)
            return Center(
              child: Card(
                color: Colors.blueGrey[100],
                elevation: 6,
                child: Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Text('No offer is available at the moment.'),
                ),
              ),
            );
          final docs = snapshot.data.docs;
          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (ctx, i) {
            return ListTile(
              shape: Border(bottom: BorderSide(color: Colors.grey)),
              title: AutoSizeText(docs[i]['title']),
              subtitle: AutoSizeText(docs[i]['subtitle']),
              trailing: AutoSizeText(docs[i]['trailing']+'%'),
            );
          });
        },
      ),
    );
  }
}
