import 'dart:async';

import 'package:flutter/material.dart';
import 'package:gocar_driver_app/global/global.dart';
import 'package:gocar_driver_app/screen/homeScreens/home_screen.dart';

import 'authScreens/login_screen.dart';

class SplashScreen extends StatefulWidget  {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  startTimer() {
    Timer(const Duration(seconds: 3), () async {

      if(await firebaseAuth.currentUser != null){
        currentFirebaseUser = firebaseAuth.currentUser;
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (c) => HomeScreen()));

      } else {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (c) => const LoginScreen()));
      }

    });
  }

  @override
  void initState(){
    super.initState();
    startTimer();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Container(
        color: Colors.black,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset("assets/icons/logo1.png"),
              const SizedBox(height: 10),
              const Text(
                "DriverIt Apps",
                style: TextStyle(
                  fontSize: 24,
                  color: Colors.white,
                  fontWeight: FontWeight.bold
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
