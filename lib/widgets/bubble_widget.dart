import 'package:flutter/material.dart';

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
