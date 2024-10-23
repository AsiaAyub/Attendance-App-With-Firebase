
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../Constants.dart';
import 'global_widgets.dart';


class AuthScreens {
  // build signIn screen
  static Widget buildSignInScreen(BuildContext context) {
    return PopScope(
        canPop: false, // Prevent back navigation
        onPopInvokedWithResult: (didPop, result) {
          if(didPop){
            return;
          }
          const bool shouldPop = false;

          if(shouldPop == false){
            SystemNavigator.pop();
          }

        },
        child:  SignInScreen(
      providers: FirebaseUIAuth.providersFor(FirebaseAuth.instance.app),
      actions: [
        _handleUserCreation(),
        _handleUserSignIn(context)
      ],
    ));
  }

  // handle user creation
  static AuthStateChangeAction<UserCreated> _handleUserCreation(){
    return AuthStateChangeAction<UserCreated>((context, state){
      Navigator.pushReplacementNamed(context, Constants.signinRoute);

      GlobalWidgets(context).showSnackBar(content: 'User created successfully. Please sign in', backgroundColor: Colors.green);
    });
  }


  //handle sign in
  static AuthStateChangeAction<SignedIn> _handleUserSignIn(BuildContext context){

    return AuthStateChangeAction<SignedIn>((context, state) async {

      final user = state.user;

      if (user != null) {
        Navigator.pushReplacementNamed(context, Constants.homeRoute);
        GlobalWidgets(context).showSnackBar(content: 'You have successfully signed in', backgroundColor: Colors.amberAccent );
      }

    });

  }


  // handle sign out
  static Future<void> signOut(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushNamedAndRemoveUntil(context, Constants.signinRoute, (Route<dynamic> route) => false,);
    GlobalWidgets(context).showSnackBar(content: 'You have successfully signed out', backgroundColor: Colors.amberAccent);
  }


}

