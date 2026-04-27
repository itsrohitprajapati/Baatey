// ignore_for_file: use_build_context_synchronously
import 'dart:io';
import 'package:baatien/models/apis.dart';
import 'package:baatien/screens/home_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthScreen extends StatefulWidget {
  static const routeName = "/auth-screen";

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  double _blackBubbleRight = 150, _orangeBubbleLeft = 350;

  void _makeLogo() {
    setState(() {
      _blackBubbleRight = 0;
      _orangeBubbleLeft = 100;
    });
  }

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 300), () {
      _makeLogo();
    });
  }

  signInButton() {
    showProgressbar(context);
    signInWithGoogle().then((user) async {
      Navigator.of(context).pop();
      if (user != null) {
        if (await APIs.userExists()) {
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) => const HomeScreen()));
        } else {
          APIs.createUser();
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) => const HomeScreen()));
        }
      }
    });
  }

  static void showSnackbar(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      behavior: SnackBarBehavior.floating,
    ));
  }

  static void showProgressbar(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  Future<UserCredential?> signInWithGoogle() async {
    // Trigger the authentication flow
    try {
      await InternetAddress.lookup("google.com");
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
    } catch (e) {
      showSnackbar(context, "Something Went Wrong (Check Internet!)");
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
          gradient: LinearGradient(colors: [
        Color.fromARGB(255, 121, 189, 193),
        Color.fromARGB(255, 160, 77, 110),
      ], begin: Alignment.topLeft, end: Alignment.bottomRight)),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text(
            "Welcome to Baatey",
            style: TextStyle(
                fontSize: 30,
                fontFamily: "Poppins",
                fontWeight: FontWeight.w700),
          ),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
        ),
        body: Center(
          child: AnimatedContainer(
            width: double.infinity,
            duration: const Duration(seconds: 1),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Stack(
                  alignment: const Alignment(-1, 1),
                  children: [
                    AnimatedContainer(
                        duration: const Duration(milliseconds: 800),
                        padding: EdgeInsets.only(
                            bottom: 20, right: _blackBubbleRight),
                        height: 170,
                        width: 150,
                        child: Image.asset("assets/images/BlackVartalaap.png")),
                    AnimatedContainer(
                        duration: const Duration(seconds: 1),
                        padding:
                            EdgeInsets.only(left: _orangeBubbleLeft, top: 70),
                        height: 300,
                        width: 350,
                        child:
                            Image.asset("assets/images/OrangeVartalaap.png")),
                  ],
                ),
                TextButton(
                  onPressed: () {
                    if (FirebaseAuth.instance.currentUser != null) {
                      Navigator.of(context)
                          .pushReplacementNamed(HomeScreen.routeName);
                    } else {
                      signInButton();
                    }
                  },
                  child: Container(
                    margin: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Colors.amber[100]),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Sign in with"),
                        const SizedBox(
                          width: 5,
                        ),
                        CircleAvatar(
                          backgroundColor: Colors.amber[100],
                          child: Image.asset("assets/images/google.png"),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
