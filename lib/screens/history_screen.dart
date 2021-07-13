import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:intl/intl.dart';

class HistoryScreen extends StatelessWidget {
  static String routeName = '/history';

  @override
  Widget build(BuildContext context) {
    final bool cancel = ModalRoute.of(context).settings.arguments;
    User user = FirebaseAuth.instance.currentUser;
    return Scaffold(
      appBar: AppBar(
        title: cancel ? Text('Your current journeys') : Text('Your Records'),
      ),
      body: StreamBuilder(
        stream: cancel
            ? FirebaseFirestore.instance
                .collection('users')
                .doc(user.uid)
                .collection('records')
                .where('date',
                    isGreaterThanOrEqualTo: DateFormat('yyyy-MM-dd')
                        .format(DateTime.now())
                        .toString())
                // .where('status', isEqualTo: "booked")
                .orderBy('date', descending: true)
                .snapshots()
            : FirebaseFirestore.instance
                .collection('users')
                .doc(user.uid)
                .collection('records')
                .orderBy('date', descending: true)
                .snapshots(),
        builder: (context, snapshot) {
          print(user.uid);
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          if (snapshot.data == null)
            return Text('No record available at the moment.');
          final records = snapshot.data.docs;
          if (records.length == 0) return Center(
              child: Card(
                color: Colors.blueGrey[100],
                elevation: 6,
                child: Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Text('No record is available at the moment.'),
                ),
              ),
            );

          return ListView.builder(
            itemCount: records.length,
            itemBuilder: (context, index) => Card(
              shape: Border(
                left: BorderSide(
                    color: records[index]['type'] == 'B'
                        ? Colors.green
                        : records[index]['type'] == 'T'
                            ? Colors.yellow
                            : Colors.red,
                    width: 5),
              ),
              elevation: 3,
              margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              child: ListTile(
                onTap: cancel
                    ? records[index]['status'] != 'booked'
                        ? null
                        : () {
                            showDialog(
                              context: context,
                              builder: (BuildContext ctx) {
                                return AlertDialog(
                                  title: Text("Are You Sure?"),
                                  content: Text(
                                      "Do you want to cancel this ticket? You'll be refunded 50% amount of the ticket."),
                                  actionsOverflowButtonSpacing: 10,
                                  actions: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        ElevatedButton(
                                          style: ButtonStyle(
                                            backgroundColor:
                                                MaterialStateProperty.all<
                                                    Color>(
                                              Theme.of(context).primaryColor,
                                            ),
                                          ),
                                          child: Text('No'),
                                          onPressed: () {
                                            Navigator.of(ctx).pop();
                                          },
                                        ),
                                        ElevatedButton(
                                          style: ButtonStyle(
                                            backgroundColor:
                                                MaterialStateProperty.all<
                                                    Color>(
                                              Theme.of(context).primaryColor,
                                            ),
                                          ),
                                          child: Text('Yes'),
                                          onPressed: () async {
                                            records[index].reference.update(
                                                {'status': 'cancelled'});
                                            if (records[index]['type'] == 'B') {
                                              final busUp = FirebaseFirestore
                                                  .instance
                                                  .collection('buses')
                                                  .doc(records[index]['id']);
                                              for (int i = 0;
                                                  i <
                                                      records[index]['seats']
                                                          .length;
                                                  i++) {
                                                await busUp.update({
                                                  'booked seats.$i':
                                                      FieldValue.delete()
                                                });
                                              }
                                            } else if (records[index]['type'] ==
                                                'T') {
                                              await FirebaseFirestore.instance
                                                  .collection('transports')
                                                  .doc(records[index]['id'])
                                                  .update({'isBooked': false});
                                            }
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(SnackBar(
                                              content: Text(
                                                  'Your amount will be refunded in a few days'),
                                              backgroundColor: Colors.black54,
                                            ));
                                            Navigator.of(context).pop();
                                          },
                                        ),
                                      ],
                                    ),
                                  ],
                                );
                              },
                            );
                          }
                    : null,
                leading: CircleAvatar(
                  backgroundColor: Theme.of(context).primaryColor,
                  backgroundImage: NetworkImage(records[index]['url']),
                ),
                title: AutoSizeText(
                  records[index]['name'],
                  maxLines: 1,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: AutoSizeText(
                  records[index]['type'] != 'H'
                      ? records[index]['start'] + " to " + records[index]['end']
                      : records[index]['start'],
                  style: TextStyle(fontSize: 12),
                  maxLines: 1,
                ),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AutoSizeText(
                      records[index]['date'] + ' | ' + records[index]['time'],
                      style:
                          TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                      maxLines: 1,
                    ),
                    if (records[index]['type'] == 'B')
                      AutoSizeText(
                        'Seats: ' + records[index]['seats'].toString(),
                        style: TextStyle(fontSize: 11),
                        maxLines: 1,
                      ),
                    AutoSizeText(
                      'Status: ' + records[index]['status'],
                      style: TextStyle(fontSize: 11),
                      maxLines: 1,
                    ),
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
