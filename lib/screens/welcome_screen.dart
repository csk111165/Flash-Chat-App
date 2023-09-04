

import 'registration_screen.dart';
import 'package:flutter/material.dart';
import 'package:animated_text_kit/animated_text_kit.dart';

import 'login_screen.dart';


class WelcomeScreen extends StatefulWidget {

  static const String id = 'welcome_screen';

  const WelcomeScreen({super.key});

  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> with SingleTickerProviderStateMixin{

  //Non-nullable instance field 'controller' must be initialized. use late to avoid this error
  late AnimationController controller ;
  late Animation animation; 
  
 static const colorizeColors = [
  Colors.purple,
  Colors.blue,
  Colors.yellow,
  Colors.red,
];

static const colorizeTextStyle = TextStyle(
  fontSize: 30.0,
  fontFamily: 'Horizon',
);

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
      duration: Duration(seconds: 1),
      vsync: this,
      );

    animation = ColorTween(begin: Colors.blueGrey, end: Colors.white).animate(controller);
    controller.forward();

  

    controller.addListener(() {
      setState(() {
        
      });
     // print(animation.value);
    });
  }

  @override
  void dispose(){
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: animation.value,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Row(
              children: <Widget>[
                Hero(
                  tag: 'logo',
                  child: Container(
                    height: 60,
                    child: Image.asset('images/logo.png'),
                  ),
                ),
                 DefaultTextStyle(
                style: const TextStyle(
                  fontSize: 30.0, // Specify your desired font size here
                  color: Colors.black, 
                  fontWeight: FontWeight.w900
                  // Text color
                ),
                child:  AnimatedTextKit(
                  animatedTexts: [
                      ColorizeAnimatedText('Flash Chat', textStyle: colorizeTextStyle,colors: colorizeColors,speed: Duration(milliseconds: 200)),
                      ColorizeAnimatedText('We respect your privacy...', textStyle: colorizeTextStyle,colors: colorizeColors,speed: Duration(milliseconds: 300)),
                      ColorizeAnimatedText('We are building future...', textStyle: colorizeTextStyle,colors: colorizeColors,),
                  ],
                  
                  isRepeatingAnimation: true,

                  
           
                ),
                 )
              ],
            ),
            const SizedBox(
              height: 48.0,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Material(
                elevation: 5.0,
                color: Colors.lightBlueAccent,
                borderRadius: BorderRadius.circular(30.0),
                child: MaterialButton(
                  onPressed: () {
                    //Go to login screen.
                    Navigator.pushNamed(context, LoginScreen.id);
                  },
                  minWidth: 200.0,
                  height: 42.0,
                  child: const Text(
                    'Log In',
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Material(
                color: Colors.blueAccent,
                borderRadius: BorderRadius.circular(30.0),
                elevation: 5.0,
                child: MaterialButton(
                  onPressed: () {
                    //Go to registration screen.
                    Navigator.pushNamed(context, RegistrationScreen.id);
                  },
                  minWidth: 200.0,
                  height: 42.0,
                  child: const Text(
                    'Register',
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}