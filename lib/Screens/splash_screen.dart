import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../APIs/api.dart';
import '../main.dart';
import 'home_screen.dart';
import 'login_screen.dart';

class splash_screen extends StatefulWidget
{
  const splash_screen({super.key});

  @override
  State<splash_screen> createState() => _splash_screenState();
}

class _splash_screenState extends State<splash_screen>
{

  @override
  void initState()
  {
    super.initState();

    Future.delayed(const Duration(seconds: 2),(){
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
          systemNavigationBarColor: Colors.white,
          statusBarColor: Colors.white
      ));

      if (API.auth.currentUser!=null)
      {
        Navigator.pushReplacement(
            context, MaterialPageRoute(
            builder: (_)=> const home_screen())
        );
      }
      else
      {
        Navigator.pushReplacement(
            context, MaterialPageRoute(
            builder: (_)=> const login_screen())
        );
      }
    });
  }


  @override
  Widget build(BuildContext context)
  {
    mq = MediaQuery.of(context).size;

    return
      Scaffold(
        body: Stack(
          children: [
            Positioned(
                top: mq.height*.35,
                right: mq.width*.25,
                width: mq.width*.5,
                child: Image.asset("Assets/Images/icon.png")
            )
          ],
        ),
      );

  }
}
