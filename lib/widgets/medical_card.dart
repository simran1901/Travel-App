import 'dart:async';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:imiego/screens/auth_screen.dart';

class MedicalCard extends StatefulWidget {
  @override
  _MedicalCardState createState() => _MedicalCardState();
}

class _MedicalCardState extends State<MedicalCard> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _controller = TextEditingController();
  final TextEditingController _controllerr = TextEditingController();
  Placemark place;

  _getAddressFromLatLng(Position position) async {
    try {
      List<Placemark> p =
          await placemarkFromCoordinates(position.latitude, position.longitude);
      place = p[0];
      setState(() {
        _controller.text =
            "${place.name}, ${place.subLocality}, ${place.locality}, ${place.postalCode}, ${place.country}";
      });
    } catch (e) {
      print(e);
    }
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }
    return await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.best,
            forceAndroidLocationManager: true)
        .then((Position position) {
      setState(() {
        _getAddressFromLatLng(position);
        _controllerr.text = 'Shri Gangaram Hospital';
      });
    }).catchError((e) {
      print(e);
    });
  }

  @override
  Widget build(BuildContext context) {
    User user = FirebaseAuth.instance.currentUser;
    return ListView(
      children: [
        Icon(Icons.add, size: 250),
        SingleChildScrollView(
          child: Card(
            color: Colors.red[100],
            elevation: 8,
            margin: EdgeInsets.all(20),
            child: Container(
              width: MediaQuery.of(context).size.width / 1.2,
              padding: EdgeInsets.all(15),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TypeAheadFormField(
                      noItemsFoundBuilder: (context) {
                        return null;
                      },
                      textFieldConfiguration: TextFieldConfiguration(
                        autofocus: true,
                        style: TextStyle(
                          fontSize: 15,
                        ),
                        decoration: InputDecoration(
                          labelText: 'From',
                          border: OutlineInputBorder(),
                        ),
                        controller: _controller,
                      ),
                      suggestionsCallback: (pattern) async {
                        // Completer<List<String>> completer = Completer();
                        // completer.complete(<String>[...places]
                        //     .where((f) =>
                        //         f.toLowerCase().startsWith(pattern.toLowerCase()) &&
                        //         _controllerr.text != f)
                        //     .toList());
                        // return completer.future;
                        return [];
                      },
                      itemBuilder: (context, suggestion) {
                        return ListTile(
                          title: Text(suggestion),
                        );
                      },
                      onSuggestionSelected: (suggestion) {
                        this._controller.text = suggestion;
                      },
                      // validator: (txt) {
                      //   if (!places.contains(_controller.text))
                      //     // if (places.contains("${txt[0].toUpperCase()}${txt.substring(1)}")) return null;
                      //     return 'Choose one of the given places.';
                      //   return null;
                      // },
                    ),
                    SizedBox(height: 10),
                    TypeAheadFormField(
                      noItemsFoundBuilder: (context) {
                        return null;
                      },
                      textFieldConfiguration: TextFieldConfiguration(
                        autofocus: true,
                        style: TextStyle(
                          fontSize: 15,
                        ),
                        decoration: InputDecoration(
                          labelText: 'To',
                          border: OutlineInputBorder(),
                        ),
                        controller: _controllerr,
                      ),
                      suggestionsCallback: (pattern) async {
                        // Completer<List<String>> completer = Completer();
                        // completer.complete(<String>[...places]
                        //     .where((f) =>
                        //         f.toLowerCase().startsWith(pattern.toLowerCase()) &&
                        //         _controller.text != f)
                        //     .toList());
                        // return completer.future;
                        return [];
                      },
                      itemBuilder: (context, suggestion) {
                        return ListTile(
                          title: Text(suggestion),
                        );
                      },
                      onSuggestionSelected: (suggestion) {
                        this._controllerr.text = suggestion;
                      },
                      validator: (txt) {
                        // if (!places.contains(_controllerr.text))
                        //   // if (places.contains("${txt[0].toUpperCase()}${txt.substring(1)}")) return null;
                        //   return 'Choose one of the given places.';
                        return null;
                      },
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ElevatedButton(
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all(
                              Theme.of(context).primaryColor,
                            ),
                          ),
                          child: Text('Emergency'),
                          onPressed: () async {
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
                                                    MaterialStateProperty.all<
                                                        Color>(
                                                  Theme.of(context)
                                                      .primaryColor,
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
                                                  Theme.of(context)
                                                      .primaryColor,
                                                ),
                                              ),
                                              child: Text('Yes'),
                                              onPressed: () {
                                                Navigator.of(ctx)
                                                    .popAndPushNamed(
                                                        AuthScreen.routeName);
                                              },
                                            ),
                                          ],
                                        ),
                                      ],
                                    );
                                  });
                            } else {
                              await _determinePosition();
                              FocusScope.of(context).unfocus();
                              showDialog(
                                context: context,
                                builder: (BuildContext ctx) => AlertDialog(
                                  title: ListTile(
                                    leading:
                                        Icon(Icons.local_hospital, size: 30),
                                    title: Text(
                                      'Confirmation',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 24),
                                    ),
                                  ),
                                  content: Text(
                                      'Are you sure you want to book this ambulance from your location to the nearest hospital?'),
                                  actions: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        ElevatedButton(
                                          child: Text('Cancel'),
                                          style: ButtonStyle(
                                            backgroundColor:
                                                MaterialStateProperty.all<
                                                        Color>(
                                                    Theme.of(context)
                                                        .primaryColor),
                                          ),
                                          onPressed: () {
                                            Navigator.of(ctx).pop();
                                          },
                                        ),
                                        ElevatedButton(
                                          child: Text('Confirm'),
                                          style: ButtonStyle(
                                            backgroundColor:
                                                MaterialStateProperty.all<
                                                        Color>(
                                                    Theme.of(context)
                                                        .primaryColor),
                                          ),
                                          onPressed: () async {
                                            await FirebaseFirestore.instance
                                                .collection('users')
                                                .doc(user.uid)
                                                .collection('records')
                                                .doc()
                                                .set({
                                              'id': 'A1',
                                              'name':
                                                  '${_controllerr.text} Ambulance',
                                              'start':
                                                  place.locality.toString(),
                                              'end': _controllerr.text,
                                              'date': DateFormat('yyyy-MM-dd')
                                                  .format(DateTime.now()),
                                              'time': DateFormat('kk:mm')
                                                  .format(DateTime.now()),
                                              'url':
                                                  'https://5.imimg.com/data5/JA/KE/YX/SELLER-8229651/force-traveller-3350-wb-ac-cardiac-ambulance-500x500.png',
                                              'type': 'H',
                                              'status': 'booked',
                                            });
                                            await FirebaseFirestore.instance
                                                .collection('users')
                                                .doc(user.uid)
                                                .get()
                                                .then((value) {
                                              value.reference.update({
                                                'journeys':
                                                    value['journeys'] + 1,
                                                'emergencies':
                                                    value['emergencies'] + 1,
                                              });
                                            });
                                            Navigator.of(ctx).pop();
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  'Your Ambulance is on its way!',
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                  ),
                                                ),
                                                backgroundColor: Colors.black54,
                                              ),
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            }
                          },
                        ),
                        ElevatedButton(
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all(
                              Theme.of(context).primaryColor,
                            ),
                          ),
                          child: Text('Search'),
                          onPressed: () {},
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
