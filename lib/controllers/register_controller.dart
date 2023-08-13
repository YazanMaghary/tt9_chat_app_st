import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../constants.dart';
import '../view/chat_screen.dart';

final credential = FirebaseAuth.instance;
final isSigned = FirebaseFirestore.instance;
void createUser(context, String? email, String? password) async {
  try {
    await credential
        .createUserWithEmailAndPassword(
      email: email!,
      password: password!,
    )
        .then((value) {
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
    });
  } on FirebaseAuthException catch (e) {
    if (e.code == 'weak-password') {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('The password provided is too weak.')));
    } else if (e.code == 'email-already-in-use') {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('The account already exists for that email.')));
    }
  } catch (e) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(e.toString())));
  }
}

googleRegister(context) async {
  signInWithGoogle().then((value) async {
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

Future<UserCredential> signInWithGoogle() async {
  // Trigger the authentication flow
  final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

  // Obtain the auth details from the request
  final GoogleSignInAuthentication? googleAuth =
      await googleUser?.authentication;

  // Create a new credential
  final credential = GoogleAuthProvider.credential(
    accessToken: googleAuth?.accessToken,
    idToken: googleAuth?.idToken,
  );

  // Once signed in, return the UserCredential
  return await FirebaseAuth.instance.signInWithCredential(credential);
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
