import 'package:baatien/screens/auth_screen.dart';
import 'package:baatien/screens/home_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  static const routeName = "/auth-screen";
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
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
    Future.delayed(const Duration(milliseconds: 100), () {
      _makeLogo();
    });
    Future.delayed(const Duration(seconds: 1), () {
      if (FirebaseAuth.instance.currentUser != null) {
        Navigator.of(context).pushReplacementNamed(HomeScreen.routeName);
      } else {
        Navigator.of(context).pushReplacementNamed(AuthScreen.routeName);
      }
    });
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
            "Welcome to Baatien",
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
