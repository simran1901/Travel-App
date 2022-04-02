import 'dart:convert';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:imiego/screens/auth_screen.dart';
import 'package:imiego/screens/transport_screen.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

class TransportBookScreen extends StatefulWidget {
  static String routeName = '/transport-book';
  final QueryDocumentSnapshot docs;
  final Map<String, String> req;
  TransportBookScreen({
    @required this.docs,
    @required this.req,
  });
  @override
  _TransportBookScreenState createState() => _TransportBookScreenState();
}

class _TransportBookScreenState extends State<TransportBookScreen> {
  User user = FirebaseAuth.instance.currentUser;
  num amount;
  Razorpay razorpay;
  var msg;

  @override
  void initState() {
    super.initState();

    razorpay = Razorpay();

    razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, handlerPaymentSuccess);
    razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, handlerErrorFailure);
    razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, handlerExternalWallet);
  }

  @override
  void dispose() {
    super.dispose();
    razorpay.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: GridTileBar(
                backgroundColor: Colors.black54,
                title: Text(
                  widget.docs['name'],
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
              background: Image.network(
                widget.docs['url'],
                fit: BoxFit.cover,
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate([
              SizedBox(height: 10),
              ListTile(
                leading: Icon(Icons.departure_board),
                title: AutoSizeText('Departure Time: ', maxLines: 1),
                trailing: AutoSizeText('${widget.docs['time']}', maxLines: 1),
              ),
              ListTile(
                leading: Icon(Icons.luggage),
                title: AutoSizeText('Loading Point: ', maxLines: 1),
                trailing: AutoSizeText('${widget.docs['pickup']}', maxLines: 1),
              ),
              ListTile(
                leading: Icon(Icons.money),
                title: AutoSizeText('Rent: ', maxLines: 1),
                trailing: AutoSizeText('Rs. ${widget.docs['rate']} per km',
                    maxLines: 1),
              ),
              ListTile(
                leading: Icon(Icons.cabin),
                title: AutoSizeText('Capacity: ', maxLines: 1),
                trailing: AutoSizeText('Rs. ${widget.docs['capacity']} ton(s)',
                    maxLines: 1),
              ),
              ListTile(
                leading: Icon(Icons.social_distance),
                title: AutoSizeText(
                    'Distance from ${widget.req['from']} to ${widget.req['to']}: ',
                    maxLines: 1),
                trailing:
                    AutoSizeText('${widget.req['distance']} kms', maxLines: 1),
              ),
              ListTile(
                leading: Icon(Icons.safety_divider),
                title: AutoSizeText('Additional taxes: ', maxLines: 1),
                trailing: AutoSizeText('Rs. 10', maxLines: 1),
              ),
              ListTile(
                leading: Icon(Icons.price_change),
                title: AutoSizeText('Total charges: ', maxLines: 1),
                trailing: AutoSizeText(
                    'Rs. ${num.parse(widget.req['distance']) * widget.docs['rate'] + 10}',
                    maxLines: 1),
              ),
              // Text('Departure Time: ' + widget.docs['time']),
              // Text('Loading point: ' + widget.docs['pickup']),
              // Text('Rent: Rs.${widget.docs['rate']} per km'),
              // Text('Capacity: ' +
              //     widget.docs['capacity'].toString() +
              //     ' ton(s)'),
              // Text(
              // 'Distance from ${widget.req['from']} to ${widget.req['to']} is ${widget.req['distance']} kms'),
              // Text('Additional taxes: Rs.10'),
              // Text(
              // 'Total charges: ${num.parse(widget.req['distance']) * widget.docs['rate'] + 10}'),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: ElevatedButton(
                  style: ButtonStyle(
                    padding:
                        MaterialStateProperty.all<EdgeInsets>(EdgeInsets.all(17)),
                    backgroundColor: MaterialStateProperty.all<Color>(
                      Theme.of(context).primaryColor,
                    ),
                  ),
                  child: Text('Book your ticket'),
                  onPressed: () {
                    if (user == null) {
                      showDialog(
                          context: context,
                          builder: (BuildContext ctx) {
                            return AlertDialog(
                              title: Text("You're not logged in"),
                              content: Text('Sign in now?'),
                              actionsOverflowButtonSpacing: 10,
                              actions: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    ElevatedButton(
                                      style: ButtonStyle(
                                        backgroundColor:
                                            MaterialStateProperty.all<Color>(
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
                                            MaterialStateProperty.all<Color>(
                                          Theme.of(context).primaryColor,
                                        ),
                                      ),
                                      child: Text('Yes'),
                                      onPressed: () {
                                        Navigator.of(ctx).popAndPushNamed(
                                            AuthScreen.routeName);
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            );
                          });
                    } else {
                      amount = num.parse(widget.req['distance']) *
                              widget.docs['rate'] +
                          10;
                      openCheckout();
                    }
                  },
                ),
              ),
            ]),
          ),
        ],
      ),
    );
  }

  void openCheckout() async {
    DocumentSnapshot doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get()
        .whenComplete(() => null);
    var options = {
      "key": "rzp_test_7JQsqAOfdFnb0v",
      "amount": amount * 100, // Convert Paisa to Rupees
      "name": "ImieGo Checkout",
      "description": "This is ImieGo Payment",
      "timeout": "180",
      "theme.color": "#031634",
      "currency": "INR",
      "prefill": {"contact": '${doc['mobile']}', "email": doc['email']},
      "external": {
        "wallets": ["paytm"]
      }
    };

    try {
      razorpay.open(options);
    } catch (e) {
      print(e.toString());
    }
  }

  void handlerPaymentSuccess(PaymentSuccessResponse response) async {
    print("Payment success");
    msg = "SUCCESS: " + response.paymentId;
    // setStatus((){status = true;});
    showToast(msg);

    // setState(() {
    //   status = true;
    // });
    print(widget.docs.data());
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext ctx) => WillPopScope(
        onWillPop: () async => false,
        child: AlertDialog(
          title: Text('Congratulations!'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Your ticket has been booked.'),
              Text('\n\nClick a screenshot of the QR code to avail ticket.\n',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              Center(
                child: QrImage(
                  data:
                      "ImieGo wishes you a safe journey!\n\nYour ticket details:\nPayment ID: ${response.paymentId}\nID: ${widget.docs.reference.id}\nDate: ${widget.req['date']}\nTime: ${widget.docs['time']}",
                  version: QrVersions.auto,
                  size: 200.0,
                ),
              ),
            ],
          ),
          actions: [
            Center(
              child: ElevatedButton(
                child: Text('Okay'),
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(
                      Theme.of(context).primaryColor),
                ),
                onPressed: () async {
                  await FirebaseFirestore.instance
                      .collection('users')
                      .doc(user.uid)
                      .collection('records')
                      .doc()
                      .set({
                    'id': widget.docs.reference.id,
                    'name': widget.docs['name'],
                    'start': widget.req['from'],
                    'end': widget.req['to'],
                    'date': widget.req['date'],
                    'time': widget.docs['time'],
                    'url': widget.docs['url'],
                    'type': 'T',
                    'payment_id': response.paymentId,
                    'status': 'booked',
                  });
                  await FirebaseFirestore.instance
                      .collection('users')
                      .doc(user.uid)
                      .get()
                      .then((value) {
                    value.reference.update({
                      'journeys': value['journeys'] + 1,
                      'transports': value['transports'] + 1,
                    });
                  });
                  await widget.docs.reference.update({'isBooked': true});
                  Navigator.of(ctx)
                      .popUntil(ModalRoute.withName(TransportScreen.routeName));
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void handlerErrorFailure(PaymentFailureResponse response) {
    msg = "ERROR: " +
        response.code.toString() +
        " - " +
        jsonDecode(response.message)['error']['description'];
    showToast(msg);
  }

  void handlerExternalWallet(ExternalWalletResponse response) {
    msg = "EXTERNAL_WALLET: " + response.walletName;
    showToast(msg);
  }

  showToast(msg) {
    Fluttertoast.showToast(
      msg: msg,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.grey.withOpacity(0.1),
      textColor: Colors.black54,
    );
  }
}
