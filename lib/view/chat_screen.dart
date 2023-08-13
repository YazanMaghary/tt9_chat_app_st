import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tt9_chat_app_st/controllers/LogIn_controller.dart';
import 'package:tt9_chat_app_st/view/welcome_screen.dart';

import '../constants.dart';

class ChatScreen extends StatefulWidget {
  static const id = '/chatScreen';
  const ChatScreen({super.key});

  @override
  ChatScreenState createState() => ChatScreenState();
}

class ChatScreenState extends State<ChatScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore db = FirebaseFirestore.instance;
  TextEditingController text = TextEditingController();
  bool isTyping = false;
  User? user;
  String? contactEmail;
  String? docid;
  void getUser() {
    user = _auth.currentUser;
    if (user != null) {
      print("Current User :${user!.email}");
    }
  }

  // void getMessage() {
  //   db.collection('message').get().then((value) {
  //     final docs = value.docs;
  //     for (var message in docs) {
  //       print(message.get('email'));
  //     }
  //   });
  // }
  // void streamMessages() async {
  //   await for (var messages in db.collection('message').snapshots()) {
  //     for (var message in messages.docs) {
  //       print(message.data());
  //     }
  //   }
  // }

  @override
  void initState() {
    getUser();
    // getMessage();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        drawer: Drawer(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: StreamBuilder(
                stream: db.collection('users').snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    final message = snapshot.data;
                    return ListView.builder(
                      itemCount: message!.size,
                      itemBuilder: (context, index) {
                        return ElevatedButton(
                            onPressed: () {
                              contactEmail = message.docs[index].id;
                              print(contactEmail);
                              setState(() {});
                            },
                            child: Text(message.docs[index].id));
                      },
                    );
                  }
                  if (snapshot.hasError) {
                    return Text("${snapshot.error}");
                  }
                  return const Text("Loading");
                }),
          ),
        ),
        appBar: AppBar(
          leading: null,
          actions: <Widget>[
            IconButton(
                icon: const Icon(Icons.close),
                onPressed: () async {
                  //Implement logout functionality
                  SharedPreferences prefs =
                      await SharedPreferences.getInstance();
                  prefs.setBool('isSigned', false).then((value) {
                    _auth.signOut();
                    Navigator.pushNamedAndRemoveUntil(
                        context, WelcomeScreen.id, (route) => false);
                  });
                }),
          ],
          title: Text(
              '⚡️Chat ${contactEmail == null ? '' : contactEmail?.split("@").first}'),
          backgroundColor: Colors.lightBlueAccent,
        ),
        body: contactEmail == null
            ? const Center(
                child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  textAlign: TextAlign.center,
                  "Welcome Please Open Drawer and chat with someone 0_0",
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      fontStyle: FontStyle.italic),
                ),
              ))
            : SafeArea(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    StreamBuilder(
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          final messages = snapshot.data?.docs;
                          return Expanded(
                            child: ListView.builder(
                                reverse: true,
                                padding: const EdgeInsets.all(12),
                                itemCount: messages?.length,
                                itemBuilder: (context, index) {
                                  return Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: BubbleWidget(
                                      isMe: messages?[index].data()['email'] ==
                                              user?.email
                                          ? true
                                          : false,
                                      message: messages?[index].data()['Text'],
                                      sender: messages?[index].data()['email'],
                                    ),
                                  );
                                }),
                          );
                        }
                        return const Text("Loading");
                      },
                      stream: db
                          .collection('users')
                          .doc("${credential.currentUser?.email}")
                          .collection('$contactEmail')
                          .orderBy('time', descending: true)
                          .snapshots(),
                    ),
                    Container(
                      decoration: kMessageContainerDecoration,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Expanded(
                            child: TextField(
                              onEditingComplete: () {
                                db
                                    .collection('users')
                                    .doc(contactEmail)
                                    .update({'typing': false});
                                setState(() {});
                              },
                              onSubmitted: (value) {
                                db
                                    .collection('users')
                                    .doc(contactEmail)
                                    .update({'typing': false});
                                setState(() {});
                              },
                              onTapOutside: (event) {
                                // isTyping = false;
                                db
                                    .collection('users')
                                    .doc(contactEmail)
                                    .update({'typing': false});
                                setState(() {});
                              },
                              controller: text,
                              onChanged: (value) {
                                //Do something with the user input.
                                // isTyping = true;
                                db
                                    .collection('users')
                                    .doc(contactEmail)
                                    .update({'typing': true});
                                setState(() {});
                              },
                              decoration: kMessageTextFieldDecoration,
                            ),
                          ),
                          StreamBuilder(
                              stream: db
                                  .collection('users')
                                  .doc('${credential.currentUser!.email}')
                                  .snapshots(),
                              builder: (context, snapshot) {
                                if (snapshot.hasData) {
                                  return snapshot.data?['typing'] == true
                                      ? Text("Typing")
                                      : Text('');
                                }
                                return Text('loading');
                              }),
                          TextButton(
                            onPressed: () {
                              //Implement send functionality.
                              if (contactEmail !=
                                  credential.currentUser!.email) {
                                db
                                    .collection('users')
                                    .doc('${credential.currentUser!.email}')
                                    .collection('$contactEmail')
                                    .add({
                                  'Text': text.text,
                                  'email': user?.email,
                                  'time': DateTime.now(),
                                }).then((value) {
                                  docid = value.id;
                                  print(docid);
                                  text.clear();
                                }).catchError((e) {
                                  print(e);
                                });
                                db
                                    .collection('users')
                                    .doc('$contactEmail')
                                    .collection(
                                        '${credential.currentUser!.email}')
                                    .add({
                                  'Text': text.text,
                                  'email': user?.email,
                                  'time': DateTime.now(),
                                }).then((value) {
                                  docid = value.id;
                                  print(docid);
                                  text.clear();
                                }).catchError((e) {
                                  print(e);
                                });
                              } else {
                                db
                                    .collection('users')
                                    .doc('${credential.currentUser!.email}')
                                    .collection('$contactEmail')
                                    .add({
                                  'Text': text.text,
                                  'email': user?.email,
                                  'time': DateTime.now(),
                                }).then((value) {
                                  docid = value.id;
                                  print(docid);
                                  text.clear();
                                }).catchError((e) {
                                  print(e);
                                });
                              }
                            },
                            child: const Text(
                              'Send',
                              style: kSendButtonTextStyle,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ));
  }
}

class BubbleWidget extends StatelessWidget {
  const BubbleWidget(
      {super.key,
      required this.message,
      required this.sender,
      required this.isMe});

  final String message;
  final String sender;
  final bool isMe;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
          crossAxisAlignment:
              isMe == true ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(
              sender,
              style: const TextStyle(color: Colors.black54),
            ),
            Material(
              elevation: 5,
              borderRadius: isMe == false
                  ? const BorderRadius.only(
                      topRight: Radius.circular(24),
                      bottomRight: Radius.circular(24),
                      bottomLeft: Radius.circular(24))
                  : const BorderRadius.only(
                      topLeft: Radius.circular(24),
                      bottomRight: Radius.circular(24),
                      bottomLeft: Radius.circular(24)),
              color: isMe == false ? Colors.white : Colors.lightBlueAccent,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Text(
                  message,
                  style: TextStyle(
                      fontSize: 18,
                      color: isMe == false ? Colors.black54 : Colors.white),
                ),
              ),
            ),
          ]),
    );
  }
}
