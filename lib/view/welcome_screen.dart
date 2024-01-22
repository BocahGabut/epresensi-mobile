import 'dart:async';

import 'package:e_absensi/utils/global.color.dart';
import 'package:e_absensi/view/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double imageHeightPercent = 0.45;
    double imageHeight = screenHeight * imageHeightPercent;

    return Scaffold(
      backgroundColor: GlobalColor.mainColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: imageHeight,
              child: Image.asset('assets/splash-screen.png'),
            ),
            const SizedBox(height: 35.0),
            const Text(
              'Hi, Welcome to',
              style: TextStyle(
                  fontSize: 28,
                  color: Colors.white,
                  fontWeight: FontWeight.w600),
            ),
            const Text(
              'Our Mobile ePresensi',
              style: TextStyle(
                  fontSize: 28,
                  color: Colors.white,
                  fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 40.0),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20.0),
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 15.0)),
                onPressed: () {
                  _setButtonPressed(context);
                },
                child: const Text('Let`s Get Started'),
              ),
            )
          ],
        ),
      ),
    );
  }

  Future<void> _setButtonPressed(context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('welcomeScreen', false);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }
}
