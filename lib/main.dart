import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'Screens/splash_screen.dart';
import 'firebase_options.dart';

late Size mq;

void main()
{

  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);


  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown]).then(
          (value) async {
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
        runApp(const MyApp());
      });
}

class MyApp extends StatelessWidget
{
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {

    return
      MaterialApp(
        title: "Multi chat app",
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
            appBarTheme: const AppBarTheme(
                centerTitle: true,
                elevation: 1,
                iconTheme: IconThemeData(color: Colors.black),
                titleTextStyle: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.normal,
                    fontSize: 20
                ),
                backgroundColor: Colors.white
            )
        ),
        home: const splash_screen(),
      );
  }
}

