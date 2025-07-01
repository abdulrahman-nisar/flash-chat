import 'package:flashchat/constants.dart';
import 'package:flutter/material.dart';
import 'package:flashchat/components/rounded_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flashchat/screens/chat_screen.dart'; // Import the chat screen to navigate after login.
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

class LoginScreen extends StatefulWidget {
  static const String id = 'login_screen';
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool showSpinner = false; // Variable to control the loading indicator.
  String? email;
  String? password;
  final FirebaseAuth _auth = FirebaseAuth.instance; // Initialize Firebase Auth.

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: ModalProgressHUD(
        progressIndicator: CircularProgressIndicator(
          color:
              Colors.lightBlueAccent, // Customize the loading indicator color.
        ),
        inAsyncCall:
            showSpinner, // Set to true if you want to show a loading indicator.
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Hero(
                tag: 'logo',
                child: Container(
                  height: 200.0,
                  child: Image.asset('images/logo.png'),
                ),
              ),
              SizedBox(height: 48.0),
              TextField(
                keyboardType: TextInputType
                    .emailAddress, // Set keyboard type for email input.
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight
                      .bold, // Set text color to black54 for better visibility.
                ),
                onChanged: (value) {
                  email = value; // Store the user input in the email variable.
                },
                decoration: KTextFieldDecoration.copyWith(
                  hintText: 'Enter your email.',
                ),
              ),
              SizedBox(height: 8.0),
              TextField(
                textAlign: TextAlign.center,
                obscureText: true, // Hide the password input.
                style: TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight
                      .bold, // Set text color to black54 for better visibility.
                ),
                onChanged: (value) {
                  password =
                      value; // Store the user input in the password variable.
                },
                decoration: KTextFieldDecoration.copyWith(
                  hintText: 'Enter your password.',
                ),
              ),
              SizedBox(height: 24.0),
              RoundedButton(
                title: 'Log In',
                color: Colors.lightBlueAccent,
                onPressed: () async {
                  try {
                    setState(() {
                      showSpinner = true; // Show the loading indicator.
                    });
                    // Attempt to sign in the user with email and password.
                    final user = await _auth.signInWithEmailAndPassword(
                      email: email!,
                      password: password!,
                    );
                    // If successful, navigate to the chat screen.
                    Navigator.pushNamed(context, ChatScreen.id);
                    setState(() {
                      showSpinner = false; // Hide the loading indicator.
                    });
                  } catch (e) {
                    // Handle any errors that occur during sign-in.
                    print(e);
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
