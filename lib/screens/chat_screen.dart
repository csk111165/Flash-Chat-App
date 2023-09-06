import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:chat_app/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// make it global to be able to access in other classes.
  final _firestore = FirebaseFirestore.instance;

  late User loggedInUser;

class ChatScreen extends StatefulWidget {
  static const String id = 'chat_screen';

  const ChatScreen({super.key});
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _auth = FirebaseAuth.instance;
  
  //store the message
  late String messageText;

  // adding TextEditingController for clearning out the text field when message is sent
  final messageTextController = TextEditingController();
  

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
        title: const Text('❣️Cutoo-Moon ChatApp❣️'),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            MessageStream(),

            Container(
              decoration: kMessageContainerDecoration,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: messageTextController,
                      onChanged: (value) {
                        //Do something with the user input.
                        messageText = value;
                      },
                      decoration: kMessageTextFieldDecoration,
                    ),
                  ),
                  TextButton(
                    onPressed: () {

                      // clear the input text field using controller
                      messageTextController.clear();
                      //Implement send functionality.
                      _firestore.collection('messages').add({
                        // add () expects a map < string,
                        'text': messageText,
                        'sender': loggedInUser.email,
                        'timestamp': DateTime.now(), // add this for sorting the message based on timestamp
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

// class for refactoring 
class MessageStream extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
              stream: _firestore.collection('messages').orderBy('timestamp').snapshots(),
              builder: (context, snapshot) {
                List<MessageBubble> messageBubbles = [];

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
                  //get sender email
                  final messageSender = message.get('sender');

                  // get the current logged in user, so that we can differentiate between messages sent by other user
                  final currentUser = loggedInUser.email;

                  final messageBubble = MessageBubble(sender: messageSender, text: messageText, isMe: currentUser == messageSender,);
                  messageBubbles.add(messageBubble);
                }
                return Expanded(
                  child: ListView(
                    // reverse is made true to follow the order of the messages received in the ui
                      padding:EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                      children: messageBubbles
                      ),
                ); // directly returning the messageWidget is not working
              },
            );
  }
}  



class MessageBubble extends StatelessWidget {
  late final String sender;
  late final String text;
  // this is to track the messages send by the current user
  late final bool isMe;

  MessageBubble({required this.sender, required this.text, required this.isMe});

  @override
  Widget build(BuildContext context) {
    // wrapping it with Material would allow to add background color and other styling
    return Padding(
      padding:  EdgeInsets.all(10.0),
      child: Column(
        // moving the chats to left in case it is coming form other user
        crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          // sender info come at top
          Text(sender, style: TextStyle(
            fontSize: 12.0,
            color: Colors.black54,
          ),),
          Material(
            // to add shadow under the section
            elevation: 5.0,
            // to make it little bit stylish and conditional formating for message bubble
            borderRadius: isMe ?  BorderRadius.only(
              topLeft: Radius.circular(30),
              bottomLeft: Radius.circular(30),
              bottomRight: Radius.circular(30),
            ) :  BorderRadius.only(
              topRight: Radius.circular(30),
              bottomRight: Radius.circular(30),
              bottomLeft: Radius.circular(30),

            ),
            color: isMe ?  Colors.lightBlue : Colors.amber,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.white,
                ),
                ),
            ),
            ),
        ],
      ),
    );
  }
}
