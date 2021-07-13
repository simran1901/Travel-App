import 'dart:io';

// import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:imiego/screens/choose_screen.dart';
// import 'package:imiego/screens/verification_screen.dart';
// import '../screens/tab_screen.dart';
import './user_image_picker.dart';

class AuthForm extends StatefulWidget {
  AuthForm(
    this.submitFn,
    this.isLoading,
  );

  final bool isLoading;
  final void Function(
    String email,
    String password,
    String userName,
    int userMobile,
    File image,
    bool isLogin,
    BuildContext ctx,
  ) submitFn;

  @override
  _AuthFormState createState() => _AuthFormState();
}

class _AuthFormState extends State<AuthForm> {
  final _formKey = GlobalKey<FormState>();
  var _isLogin = true;
  var _userEmail = '';
  var _userName = '';
  var _userPassword = '';
  var _userImageFile;
  var _userMobile;

  void _pickedImage(File image) {
    _userImageFile = image;
  }

  void _trySubmit() {
    final isValid = _formKey.currentState.validate();
    FocusScope.of(context).unfocus();

    if (_userImageFile == null && !_isLogin) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please pick an image.'),
          backgroundColor: Theme.of(context).errorColor,
        ),
      );
      return;
    }

    if (isValid) {
      _formKey.currentState.save();
      widget.submitFn(
        _userEmail.trim(),
        _userPassword.trim(),
        _userName.trim(),
        _userMobile,
        _userImageFile,
        _isLogin,
        context,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Card(
        margin: EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  if (!_isLogin) UserImagePicker(_pickedImage),
                  TextFormField(
                    key: ValueKey('email'),
                    autocorrect: false,
                    textCapitalization: TextCapitalization.none,
                    enableSuggestions: false,
                    validator: (value) {
                      if (value.isEmpty ||
                          !RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                              .hasMatch(value)) {
                        return 'Please enter a valid email address.';
                      }
                      return null;
                    },
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: 'Email address',
                    ),
                    onSaved: (value) {
                      _userEmail = value;
                    },
                  ),
                  if (!_isLogin)
                    TextFormField(
                      key: ValueKey('username'),
                      autocorrect: true,
                      textCapitalization: TextCapitalization.words,
                      validator: (value) {
                        if (value.isEmpty || value.length < 4) {
                          return 'Please enter at least 4 characters.';
                        }
                        return null;
                      },
                      decoration: InputDecoration(labelText: 'Username'),
                      onSaved: (value) {
                        _userName = value;
                      },
                    ),
                  TextFormField(
                    key: ValueKey('password'),
                    validator: (value) {
                      if (value.isEmpty || value.length < 7) {
                        return 'Password must be at least 7 characters long.';
                      }
                      return null;
                    },
                    decoration: InputDecoration(labelText: 'Password'),
                    obscureText: true,
                    onSaved: (value) {
                      _userPassword = value;
                    },
                  ),
                  if (!_isLogin)
                    TextFormField(
                      key: ValueKey('mobile number'),
                      autocorrect: true,
                      textCapitalization: TextCapitalization.words,
                      validator: (value) {
                        if (value.isEmpty || value.length < 10 || value.isEmpty || value.length > 10) {
                          return 'Please enter exactly 10 digits.';
                        }
                        else if (int.parse(value) == null){
                          return 'Enter a 10-digit number only.';
                        }
                        return null;
                      },
                      decoration: InputDecoration(labelText: 'Mobile number'),
                      onSaved: (value) {
                        _userMobile = int.parse(value);
                      },
                    ),
                  SizedBox(height: 12),
                  if (widget.isLoading) CircularProgressIndicator(),
                  if (!widget.isLoading)
                    ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all<Color>(
                            Theme.of(context).primaryColor),
                      ),
                      child: Text(_isLogin ? 'Login' : 'Sign Up'),
                      onPressed: _trySubmit,
                    ),
                  if (!widget.isLoading)
                    GestureDetector(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 20, bottom: 12),
                        child: Text(
                          _isLogin
                              ? 'Create new account'
                              : 'I already have an account',
                          style:
                              TextStyle(color: Theme.of(context).primaryColor),
                        ),
                      ),
                      onTap: () {
                        setState(() {
                          _isLogin = !_isLogin;
                        });
                      },
                    ),
                  if (!widget.isLoading)
                    GestureDetector(
                      child: Text(
                        'Continue without login...',
                        style: TextStyle(
                          color: Colors.red,
                        ),
                      ),
                      onTap: () {
                        Navigator.of(context).canPop()
                            ? Navigator.of(context).pop()
                            : Navigator.of(context)
                                .pushReplacementNamed(ChooseScreen.routeName);
                      },
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
