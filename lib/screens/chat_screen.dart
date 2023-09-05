import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:chat_app/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatScreen extends StatefulWidget {
  static const String id = 'chat_screen';

  const ChatScreen({super.key});
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _auth = FirebaseAuth.instance;
  late User loggedInUser;
  //store the message
  late String messageText;
  // instantiate the firestore
  final _firestore = FirebaseFirestore.instance;

  void getCurrentUser() {
    final user = _auth.currentUser;
    if (user != null) {
      loggedInUser = user;
    }
  }

  void getMessages() async {
    final messages = await _firestore.collection('messages').get();

    for (var message in messages.docs) {
      print(message.data());
    }
  }

  void messagesStream() async {
    // the stream will automatically pull the messages from the database
    await for (var snapshot in _firestore.collection('messages').snapshots()) {
      for (var message in snapshot.docs) {
        print(message.data());
      }
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getCurrentUser();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: null,
        actions: <Widget>[
          IconButton(
              icon: const Icon(Icons.close),
              onPressed: () {
                //Implement logout functionality
                // _auth.signOut();
                // Navigator.pop(context);
                messagesStream();
              }),
        ],
        title: const Text('⚡️Chat'),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            StreamBuilder<QuerySnapshot>(
              stream: _firestore.collection('messages').snapshots(),
              builder: (context, snapshot) {
                List<Text> messageWidgets = [];

                if (!snapshot.hasData) {
                  // if we don't have data then show a spiiner
                  return const Center(
                    child: CircularProgressIndicator(
                        backgroundColor: Colors.lightBlueAccent),
                  );
                }
                final messages = snapshot.data!.docs; // data! since it gives an error and also it is suggested in the udemy forum comments

                for (var message in messages) {
                  // get text
                  final messageText = message.get('text'); // message.data['text'] does not work now..
                  //get sender
                  final messageSender = message.get('sender');
                  final messageWidget = Text('$messageText from $messageSender');
                  messageWidgets.add(messageWidget);

                }
                return Column(
                    children:
                        messageWidgets); // directly returning the messageWidget is not working
              },
            ),
            Container(
              decoration: kMessageContainerDecoration,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      onChanged: (value) {
                        //Do something with the user input.
                        messageText = value;
                      },
                      decoration: kMessageTextFieldDecoration,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      //Implement send functionality.
                      _firestore.collection('messages').add({
                        // add () expects a map < string,
                        'text': messageText,
                        'sender': loggedInUser.email,
                      });
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
      ),
    );
  }
}
