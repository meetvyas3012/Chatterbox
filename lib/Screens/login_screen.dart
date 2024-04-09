import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../APIs/api.dart';
import '../Helpers/dialogs.dart';
import '../main.dart';
import 'home_screen.dart';

class login_screen extends StatefulWidget
{
  const login_screen({super.key});

  @override
  State<login_screen> createState() {
    return _login_screen_state();
  }
}

class _login_screen_state extends State<login_screen>
{
  bool _is_animate=false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    Future.delayed(const Duration(milliseconds: 500),(){
      setState(() {
        _is_animate=true;
      });
    });
  }

  _on_click_google_button()
  {
    Dialogs.show_progress_bar(context);

    _sign_in_with_google().then((user) async {

      Navigator.pop(context);

      if (user!=null)
      {
        if ((await API.user_exists()))
        {
          Navigator.pushReplacement(context,
              MaterialPageRoute(
                  builder: (_) =>
                  const home_screen()
              )
          );
        }
        else
        {
          await API.create_user().then(
                  (value) =>
                  Navigator.pushReplacement(context,
                      MaterialPageRoute(
                          builder: (_) =>
                          const home_screen()
                      )
                  )
          );
        }
      }
    });
  }

  Future<UserCredential?> _sign_in_with_google() async
  {
    try{
      await InternetAddress.lookup('google.com');
      final GoogleSignInAccount? user=await GoogleSignIn().signIn();
      final GoogleSignInAuthentication? auth= await user?.authentication;
      final credential=GoogleAuthProvider.credential(
          accessToken: auth?.accessToken,
          idToken: auth?.idToken
      );
      return await API.auth.signInWithCredential(credential);
    }
    catch(e){
      Dialogs.show_snackbar(context, "Something went wrong!!");
      return null;
    }
  }

  @override
  Widget build(BuildContext context)
  {
    return
      Scaffold(
        appBar: AppBar(
          title: const Text("Welcome to Chat"),
        ),
        body: Stack(
          children: [
            AnimatedPositioned(
                top: mq.height*.15,
                right: _is_animate?mq.width*.25:-mq.width*.5,
                width: mq.width*.5,
                duration: const Duration(seconds: 1),
                child: Image.asset("Assets/Images/icon.png")
            ),
            Positioned(
                bottom: mq.height*.15,
                left: mq.width*.05,
                width: mq.width*.9,
                height: mq.width*.15,
                child: ElevatedButton.icon(
                  onPressed: _on_click_google_button,
                  icon: Image.asset("Assets/Images/google.png"),
                  label: RichText(
                      text: const TextSpan(
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 20
                          ),
                          children: [
                            TextSpan(text: "Login with "),
                            TextSpan(
                                text: "Google",
                                style: TextStyle(fontWeight: FontWeight.w500)
                            )
                          ]
                      )
                  ),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 223, 255, 187),
                      shape: const StadiumBorder(),
                      elevation: 1
                  ),
                )
            )
          ],
        ),
      );
  }
}