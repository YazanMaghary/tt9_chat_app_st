import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tt9_chat_app_st/controllers/register_controller.dart';

import '../constants.dart';
import '../view/chat_screen.dart';

final credential = FirebaseAuth.instance;
final isSigned = FirebaseFirestore.instance;
void logIn(context, String? email, String? password) async {
  signed();
  try {
    await credential
        .signInWithEmailAndPassword(email: email!, password: password!)
        .then((value) {
      isSigned
          .collection('users')
          .doc('${credential.currentUser!.email}')
          .set({}).then((value) async {});
      Navigator.pushNamedAndRemoveUntil(
        context,
        ChatScreen.id,
        (route) => false,
      );
    }).catchError((e) {
      print(e);
    });
  } on FirebaseAuthException catch (e) {
    if (e.code == 'user-not-found') {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No user found for that email.')));
    } else if (e.code == 'wrong-password') {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Wrong password provided for that user.')));
    }
  }
}

googleLogIn(context) async {
  signInWithGoogle().then((value) async {
    final isSigned = FirebaseFirestore.instance;
    isSigned
        .collection('users')
        .doc('${credential.currentUser!.email}')
        .set({}).then((value) async {
      signed();

      Navigator.pushNamedAndRemoveUntil(
        context,
        ChatScreen.id,
        (route) => false,
      );
    });
  }).catchError((onError) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text("*********$onError*********")));
  });
}
