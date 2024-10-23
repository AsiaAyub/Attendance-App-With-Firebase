import 'package:attendence_app/Constants.dart';
import 'package:attendence_app/Screens/HomeScreen.dart';
import 'package:attendence_app/api/FirebaseAuthConfig.dart';
import 'package:attendence_app/utilities/authScreens.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';

import 'firebase_options.dart';

void main() async {

  // local storage to store needed data
  await Hive.initFlutter();
  var box2 = await Hive.openBox('box2');

  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  //configure providers
  FirebaseAuthConfig.configureProvider();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    // Check if the user is signed in
    User? user = FirebaseAuth.instance.currentUser;
    return MaterialApp(
      title: 'Attendance App Home Page',
      theme:ThemeData(
        // Define the default brightness and colors.
        brightness: Brightness.dark,
        primaryColor: Colors.lightGreen,
        fontFamily: 'Georgia',
      ) ,
      darkTheme:ThemeData.dark(),
      debugShowCheckedModeBanner: false,
      initialRoute: user != null ? Constants.homeRoute: Constants.signinRoute,
      routes: _buildAppRoutes(),
    );
  }

  Map<String, WidgetBuilder> _buildAppRoutes(){
    return {
      Constants.signinRoute: (context) => AuthScreens.buildSignInScreen(context),
      Constants.profileRoute: (context) => const ProfileScreen(),
      Constants.homeRoute: (context) => const HomeScreen(),

    };
  }
}


