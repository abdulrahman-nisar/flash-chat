import 'package:flutter/material.dart';
import 'package:flashchat/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final _firestore = FirebaseFirestore.instance; // Initialize Firestore.
User? loggedInUser;

class ChatScreen extends StatefulWidget {
  static const String id = 'chat_screen';
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final messageTextController =
      TextEditingController(); // Controller for the message text field.
  final FirebaseAuth _auth = FirebaseAuth.instance; // Initialize Firebase Auth.
  // Variable to hold the logged-in user.
  String? messageText; // Variable to hold the message text input.
  final Timestamp time =
      Timestamp.now(); // Variable to hold the current timestamp.
  @override
  void initState() {
    super.initState();
    getCurrentUser(); // Call the method to get the current user when the screen initializes.
  }

  void getCurrentUser() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        loggedInUser = user; // Assign the current user to loggedInUser.
      }
    } catch (e) {
      print(e); // Print any errors that occur during user retrieval.
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: null,
        actions: <Widget>[
          TextButton(
            style: ButtonStyle(
              backgroundColor: WidgetStateProperty.all<Color>(Colors.lightBlue),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 31.0),
              child: Text(
                'Sign Out',
                style: TextStyle(
                  fontSize: 16.0,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            onPressed: () {
              _auth.signOut();
              Navigator.pop(
                context,
              ); // Navigate back to the previous screen after signing out.
            },
          ),
        ],
        title: Text('⚡️Chat'),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            MessageStream(), // Display the stream of messages.
            Container(
              decoration: kMessageContainerDecoration,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: messageTextController,
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight
                            .bold, // Set text color to black54 for better visibility.
                      ),
                      onChanged: (value) {
                        messageText =
                            value; // Update messageText with user input.
                      },
                      decoration: kMessageTextFieldDecoration,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      messageTextController.clear(); // Clear the text field.
                      _firestore.collection('messages').add({
                        'text':
                            messageText, // Add the message text to Firestore.
                        'sender':
                            loggedInUser?.email, // Add the sender's email.
                        'time': Timestamp.now(), // Add the current timestamp.
                      });
                    },
                    child: Text('Send', style: kSendButtonTextStyle),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MessageStream extends StatelessWidget {
  const MessageStream({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection('messages').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(
            child: CircularProgressIndicator(
              backgroundColor: Colors.lightBlue,
            ), // Show a loading indicator while data is being fetched.
          );
        }
        final messages = snapshot.data?.docs.reversed;
        List<MessageBubble> messageBubbles = [];
        for (var message in messages!) {
          final data = message.data() as Map<String, dynamic>;
          final messageText = data?['text'];
          final messageSender = data?['sender'];
          final time = data?['time'] as Timestamp;

          final currentUser = loggedInUser?.email;
          final messageWidget = MessageBubble(
            text: messageText,
            messageSender: messageSender,
            time: time,
            isMe:
                currentUser ==
                messageSender, // Check if the message is from the current user.
          ); // Create a MessageBubble widget for each message.
          messageBubbles.add(messageWidget);
          messageBubbles.sort((a, b) => b.time.compareTo(a.time));
        }
        return Expanded(
          child: ListView(
            reverse: true,
            padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 20.0),
            children: messageBubbles,
          ),
        );
      },
    );
  }
}

class MessageBubble extends StatelessWidget {
  MessageBubble({
    required this.text,
    required this.messageSender,
    this.isMe,
    required this.time,
  });
  final Timestamp time;
  final String? text; // The text of the message.
  final String? messageSender; // The sender of the message.
  final bool? isMe;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment: isMe!
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start, // Align messages to the left.
        children: [
          Text(
            messageSender!,
            style: TextStyle(fontSize: 12.0, color: Colors.black54),
          ), // Display the sender's email above the message.
          Material(
            borderRadius: isMe!
                ? BorderRadius.only(
                    bottomRight: Radius.circular(
                      30.0,
                    ), // Round the top-left corner.
                    topLeft: Radius.circular(
                      30.0,
                    ), // Round the top-right corner.
                    bottomLeft: Radius.circular(
                      30.0,
                    ), // Round the bottom-left corner.
                  )
                : BorderRadius.only(
                    bottomRight: Radius.circular(
                      30.0,
                    ), // Round the top-left corner.
                    topRight: Radius.circular(
                      30.0,
                    ), // Round the top-right corner.
                    bottomLeft: Radius.circular(
                      30.0,
                    ), // Round the bottom-left corner.
                  ), // Round the corners of the message bubble.
            elevation: 6.0, // Add a shadow effect to the message bubble.
            color: isMe!
                ? Colors.lightBlueAccent
                : Colors.white, // Set the background color based on the sender.
            child: Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 10,
                horizontal: 20.0,
              ),
              child: Text(
                text!,
                style: TextStyle(
                  color: isMe!
                      ? Colors.white
                      : Colors.black, // Set text color based on the sender.
                  fontSize: 15.0,
                  fontWeight: FontWeight
                      .bold, // Set text color to black54 for better visibility.
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
