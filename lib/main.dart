import 'dart:developer';
import 'package:baatien/screens/auth_screen.dart';
import 'package:baatien/screens/home_screen.dart';
import 'package:baatien/screens/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:flutter_notification_channel/flutter_notification_channel.dart';
import 'package:flutter_notification_channel/notification_importance.dart';
import 'firebase_options.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  //enter full-screen
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  //for setting orientation to portrait only
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]).then((value) {
    initializeFirebase();
    runApp(const MyApp());
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Baatey',
      theme: ThemeData(
        fontFamily: "Poppins",
        primaryColor: Colors.amber,
        primarySwatch: Colors.amber,
        textTheme: Theme.of(context).textTheme.apply(fontSizeFactor: 1, fontFamily: "Poppins"),
      ),
      home: SplashScreen(),
      routes: {
        AuthScreen.routeName: (context) => AuthScreen(),
        HomeScreen.routeName: (context) => HomeScreen(),
        // DeveloperProfileScreen.routename: (context) =>
        //     const DeveloperProfileScreen(),
      },
    );
  }
}

initializeFirebase() async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  var result = await FlutterNotificationChannel.registerNotificationChannel(description: 'For Showing Message Notification', id: 'chats', importance: NotificationImportance.IMPORTANCE_HIGH, name: 'Chats');
  log('\nNotification Channel Result: $result');
}
