import 'dart:async';
import 'package:flutter/material.dart';

import 'package:intl/intl.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';

import '../screens/search_results.dart';

class TravelCard extends StatefulWidget {
  @override
  _TravelCardState createState() => _TravelCardState();
}

class _TravelCardState extends State<TravelCard> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _controller = TextEditingController();
  final TextEditingController _controllerr = TextEditingController();
  final TextEditingController _controllerrr = TextEditingController();
  final List<String> places = [
    'Delhi',
    'Chandigarh',
    'Mumbai',
    'Ludhiana',
    'Patna',
    'Bihar',
    'Nagpur',
    'Kashmir'
  ];

  DateTime _selectedDate;
  final format = DateFormat("yyyy-MM-dd");

  void _trySubmit() {
    final isValid = _formKey.currentState.validate();
    FocusScope.of(context).unfocus();

    if (isValid) {
      _formKey.currentState.save();
      Navigator.of(context).pushNamed(
        SearchResults.routeName,
        arguments: {
          'from': _controller.text,
          'to': _controllerr.text,
          'date': _controllerrr.text
        },
      );
    } else {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Card(
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
                      Completer<List<String>> completer = Completer();
                      completer.complete(<String>[...places]
                          .where((f) =>
                              f
                                  .toLowerCase()
                                  .startsWith(pattern.toLowerCase()) &&
                              _controllerr.text != f)
                          .toList());
                      return completer.future;
                    },
                    itemBuilder: (context, suggestion) {
                      return ListTile(
                        title: Text(suggestion),
                      );
                    },
                    onSuggestionSelected: (suggestion) {
                      this._controller.text = suggestion;
                    },
                    validator: (txt) {
                      if (!places.contains(_controller.text))
                        // if (places.contains("${txt[0].toUpperCase()}${txt.substring(1)}")) return null;
                        return 'Choose one of the given places.';
                      return null;
                    },
                  ),
                  SizedBox(height: 10),
                  TypeAheadFormField(
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
                      Completer<List<String>> completer = Completer();
                      completer.complete(<String>[...places]
                          .where((f) =>
                              f
                                  .toLowerCase()
                                  .startsWith(pattern.toLowerCase()) &&
                              _controller.text != f)
                          .toList());
                      return completer.future;
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
                      if (!places.contains(_controllerr.text))
                        // if (places.contains("${txt[0].toUpperCase()}${txt.substring(1)}")) return null;
                        return 'Choose one of the given places.';
                      return null;
                    },
                  ),
                  TextFormField(
                    readOnly: true,
                    decoration: InputDecoration(
                      hintText: 'Date',
                    ),
                    controller: _controllerrr,
                    onTap: () async {
                      await showDatePicker(
                        helpText: 'SELECT THE DATE OF YOUR JOURNEY',
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime(2022),
                        builder: (BuildContext ctx, Widget child) {
                          return Theme(
                            data: ThemeData.light().copyWith(
                              primaryColor: Theme.of(context).primaryColor,
                              colorScheme: ColorScheme.light().copyWith(
                                primary: Theme.of(context).primaryColor,
                              ),
                              buttonTheme: ButtonThemeData(
                                textTheme: ButtonTextTheme.primary,
                              ),
                            ),
                            child: child,
                          );
                        },
                      ).then(
                        (pickedDate) {
                          if (pickedDate == null) {
                            return;
                          }
                          setState(() {
                            _selectedDate = pickedDate;
                            print(_selectedDate);
                            _controllerrr.text =
                                '${DateFormat('yyyy-MM-dd').format(_selectedDate)}';
                          });
                        },
                      );
                    },
                    validator: (txt) {
                      if (txt.isEmpty) return 'Please select a date.';
                      return null;
                    },
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(
                        Theme.of(context).primaryColor,
                      ),
                    ),
                    child: Text('Search'),
                    onPressed: _trySubmit,
                  ),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          right: 50,
          top: 65,
          child: RotatedBox(
            quarterTurns: 1,
            child: ElevatedButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(
                  Theme.of(context).primaryColor,
                ),
              ),
              child: Icon(Icons.compare_arrows, size: 32),
              onPressed: () {
                String t = _controller.text;
                _controller.text = _controllerr.text;
                _controllerr.text = t;
              },
            ),
          ),
        ),
      ],
    );
  }
}
