import 'package:chat_app/components/rounded_button.dart';
import 'package:chat_app/screens/chat_screen.dart';
import 'package:flutter/material.dart';
import 'package:chat_app/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart'; // for spinner

class LoginScreen extends StatefulWidget {
  static const String id = 'login_screen';

  const LoginScreen({super.key});
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _auth = FirebaseAuth.instance;
  late String email;
  late String password;
  bool showSpinner = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: ModalProgressHUD(
        inAsyncCall: showSpinner,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Flexible(
                child: Hero(
                  tag: 'logo',
                  child: Container(
                    height: 200.0,
                    child: Image.asset('images/logo.png'),
                  ),
                ),
              ),
              const SizedBox(
                height: 48.0,
              ),
              TextField(
                textAlign: TextAlign.center,
                keyboardType: TextInputType.emailAddress,
                onChanged: (value) {
                  //Do something with the user input.(email)
                  email = value;
                },
                decoration:
                    kTextFieldDecoration.copyWith(hintText: 'Enter your email'),
              ),
              const SizedBox(
                height: 8.0,
              ),
              TextField(
                textAlign: TextAlign.center,
                obscureText: true,
                onChanged: (value) {
                  //Do something with the user input.(password)
                  password = value;
                },
                decoration: kTextFieldDecoration.copyWith(
                    hintText: 'Enter your password'),
              ),
              const SizedBox(
                height: 24.0,
              ),
              RoundedButton(
                  title: 'Log In',
                  colour: Colors.lightBlueAccent,
                  onPressed: () async {
                    // as soon as register button is pressed we need to start showing the spinner..
                    setState(() {
                      showSpinner = true; // 👉🏼 but if we keep it true forever it would go and spin
                    });

                    final user = await _auth.signInWithEmailAndPassword(email: email, password: password);
                    try {
                      if (user != null) {
                        Navigator.pushNamed(context, ChatScreen.id);
                      }

                      setState(() {
                        showSpinner = false; // 👉🏼 make it false here since user is created now
                      });
                    } catch (e) {
                      print(e);
                    }
                  })
            ],
          ),
        ),
      ),
    );
  }
}
