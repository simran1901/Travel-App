import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:imiego/screens/auth_screen.dart';
import 'package:imiego/screens/travel_screen.dart';
import '../widgets/seat_layout.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:convert';
import 'package:qr_flutter/qr_flutter.dart';

class SeatBookScreen extends StatefulWidget {
  static String routeName = '/seat-book';
  @override
  _SeatBookScreenState createState() => _SeatBookScreenState();
}

class _SeatBookScreenState extends State<SeatBookScreen> {
  User user = FirebaseAuth.instance.currentUser;
  List<int> seatnos;
  Razorpay razorpay;
  num amount;
  FocusNode textFocusController = FocusNode();
  var msg;
  // bool status = false;
  QueryDocumentSnapshot busDocs;

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

  void seatSelect(List<int> seats) {
    setState(() {
      seatnos = seats;
    });
  }

  @override
  Widget build(BuildContext context) {
    busDocs = ModalRoute.of(context).settings.arguments;
    return Scaffold(
      appBar: AppBar(
        title: Text(busDocs['bus name']),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            GridView(
              shrinkWrap: true,
              children: [
                GridTile(
                  child: Icon(Icons.event_seat, color: Colors.grey),
                  footer: Center(
                    child: Text('Available'),
                  ),
                ),
                GridTile(
                  child: Icon(Icons.event_seat,
                      color: Theme.of(context).primaryColor),
                  footer: Center(
                    child: Text('Booked'),
                  ),
                ),
                GridTile(
                  child: Icon(Icons.event_seat, color: Colors.green),
                  footer: Center(
                    child: Text('Selected'),
                  ),
                ),
              ],
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 4 / 2,
                crossAxisSpacing: 1,
                mainAxisSpacing: 1,
              ),
            ),
            Divider(thickness: 1),
            Card(
              margin: EdgeInsets.all(10),
              elevation: 6,
              shape: RoundedRectangleBorder(
                  side: BorderSide(width: 1, color: Colors.grey[350]),
                  borderRadius: BorderRadius.circular(25)),
              child: Wrap(
                children: [
                  Align(
                    alignment: Alignment.centerRight,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 30.0,
                        vertical: 10,
                      ),
                      child: Icon(Icons.adjust, size: 50),
                    ),
                  ),
                  SeatLayout(seatSelect,
                      busDocs['booked seats'].keys.map(int.parse).toList()),
                ],
              ),
            ),
            ListTile(
              leading: Icon(Icons.money_rounded),
              title: AutoSizeText("Fare for one ticket: ", maxLines: 1),
              trailing: AutoSizeText('Rs. ${busDocs['fare']}', maxLines: 1),
            ),
            ListTile(
              leading: Icon(Icons.add_box),
              title: AutoSizeText('Pickup point: ', maxLines: 1),
              trailing: AutoSizeText('${busDocs['pickup']}', maxLines: 1),
            ),
            if (seatnos != null)
              if (seatnos.length != 0)
                ListTile(
                  leading: Icon(Icons.event),
                  title: AutoSizeText('Seat(s) selected: ', maxLines: 1),
                  trailing: AutoSizeText('${seatnos.length}', maxLines: 1),
                ),
            if (seatnos != null)
              if (seatnos.length != 0)
                ListTile(
                  leading: Icon(Icons.safety_divider),
                  title: AutoSizeText('Additional Taxes: ', maxLines: 1),
                  trailing: AutoSizeText(
                    "10",
                    maxLines: 1,
                  ),
                ),
            if (seatnos != null)
              if (seatnos.length != 0)
                ListTile(
                  leading: Icon(Icons.price_change),
                  title: AutoSizeText('Total Fare: ', maxLines: 1),
                  trailing: AutoSizeText(
                    "Rs. ${seatnos.length}x${busDocs['fare']}+10 = ${seatnos.length * busDocs['fare']+10}",
                    maxLines: 1,
                  ),
                ),
            if (seatnos != null)
              if (seatnos.length != 0)
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: ElevatedButton(
                    style: ButtonStyle(
                      padding: MaterialStateProperty.all<EdgeInsets>(
                          EdgeInsets.all(17)),
                      backgroundColor: MaterialStateProperty.all<Color>(
                        Theme.of(context).primaryColor,
                      ),
                    ),
                    child: Text(
                      'Book your ticket',
                      style: TextStyle(color: Colors.white),
                    ),
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
                        amount = seatnos.length * busDocs['fare'] + 10;
                        openCheckout();
                      }
                    },
                  ),
                ),
            // if (status)
            //   Padding(
            //     padding: const EdgeInsets.all(20.0),
            //     child: Text('Congratulations!\nYour ticket has been booked.',
            //         style: TextStyle(
            //             color: Colors.red,
            //             fontSize: 20,
            //             fontWeight: FontWeight.bold)),
            //   ),
          ],
        ),
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
    print(busDocs.data());
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) => WillPopScope(
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
                      "ImieGo wishes you a safe journey!\n\nYour ticket details:\nPayment ID: ${response.paymentId}\nID: ${busDocs.reference.id}\nDate: ${busDocs['date']}\nTime: ${busDocs['time']}\nSeats: $seatnos",
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
                  for (var i = 0; i < seatnos.length; i++) {
                    int s = seatnos[i];
                    busDocs.reference
                        .update({'booked seats.$s': response.paymentId});
                  }
                  await FirebaseFirestore.instance
                      .collection('users')
                      .doc(user.uid)
                      .collection('records')
                      .doc()
                      .set({
                    'id': busDocs.reference.id,
                    'payment_id': response.paymentId,
                    'name': busDocs['bus name'],
                    'start': busDocs['start'],
                    'end': busDocs['end'],
                    'date': busDocs['date'],
                    'time': busDocs['time'],
                    'url': busDocs['url'],
                    'type': 'B',
                    'seats': seatnos,
                    'status': 'booked',
                  });
                  await FirebaseFirestore.instance
                      .collection('users')
                      .doc(user.uid)
                      .get()
                      .then((value) {
                    value.reference.update({
                      'journeys': value['journeys'] + 1,
                      'travels': value['travels'] + 1,
                    });
                  });
                  Navigator.of(context)
                      .popUntil(ModalRoute.withName(TravelScreen.routeName));
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
