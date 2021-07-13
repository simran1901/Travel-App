import 'dart:io';
import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

import 'package:imiego/screens/choose_screen.dart';
// import 'package:imiego/screens/tab_screen.dart';
import 'package:imiego/screens/verification_screen.dart';

import '../widgets/auth_form.dart';

class AuthScreen extends StatefulWidget {
  static String routeName = '/auth-screen';
  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _auth = FirebaseAuth.instance;
  var _isLoading = false;

  void _submitAuthForm(
    String email,
    String password,
    String username,
    int userMobile,
    File image,
    bool isLogin,
    BuildContext ctx,
  ) async {
    UserCredential authResult;
    try {
      setState(() {
        _isLoading = true;
      });
      if (isLogin) {
        authResult = await _auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
      } else {
        authResult = await _auth
            .createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
        await authResult.user.sendEmailVerification();
        final ref = FirebaseStorage.instance
            .ref()
            .child('user_image')
            .child(authResult.user.uid + '.jpg');

        await ref.putFile(image).whenComplete(() => null);
        final url = await ref.getDownloadURL();

        final inst = FirebaseFirestore.instance
            .collection('users')
            .doc(authResult.user.uid);

        await inst.set({
          'username': username,
          'email': email,
          'mobile': userMobile,
          'image_url': url,
          'emergencies': 0,
          'journeys': 0,
          'travels': 0,
          'transports': 0,
        });
        await inst.collection('chat').doc().set({
          'createdAt': DateTime.now(),
          'text': 'Hey! Welcome to ImieGo. How may we help you?',
          'isUser': false,
        });
      }
      setState(() {
        _isLoading = false;
      });
      User user = FirebaseAuth.instance.currentUser;
      Navigator.of(context).canPop()
          ? Navigator.of(context).pop()
          : Navigator.of(context).pushReplacementNamed(user.emailVerified
              ? ChooseScreen.routeName
              : VerificationScreen.routeName);
    } on FirebaseException catch (err) {
      var message = 'An error occurred, please check your credentials!';

      if (err.message != null) {
        message = err.message;
        print(message);
      }
      ScaffoldMessenger.of(ctx).showSnackBar(
        SnackBar(
          content: Text(
            message,
            style: TextStyle(
              color: Colors.white,
            ),
          ),
          backgroundColor: Colors.black54,
        ),
      );
      setState(() {
        _isLoading = false;
      });
    } catch (err) {
      print(err);
      // setState(() {
      //   _isLoading = false;
      // });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).primaryColor,
            Theme.of(context).accentColor,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          stops: [0, 1],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: AuthForm(
          _submitAuthForm,
          _isLoading,
        ),
      ),
    );
  }
}
