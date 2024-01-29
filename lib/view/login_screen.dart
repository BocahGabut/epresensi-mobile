import 'package:e_absensi/service/api_service.dart';
import 'package:e_absensi/utils/global.color.dart';
import 'package:e_absensi/view/webview_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:fluttertoast/fluttertoast.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GlobalColor.mainColor,
      body: SafeArea(
        child: Center(
            child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Hello Again',
                style: GoogleFonts.bebasNeue(fontSize: 42, color: Colors.white),
              ),
              const SizedBox(height: 10),
              const Text(
                'Welcome back, you`ve been missed!',
                style: TextStyle(color: Colors.white, fontSize: 18),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),

              //username text field
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25.0),
                child: Container(
                  decoration: BoxDecoration(
                      color: Colors.grey[200],
                      border: Border.all(color: Colors.white),
                      borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 20.0),
                    child: TextFormField(
                      controller: _usernameController,
                      keyboardType: TextInputType.text,
                      decoration: const InputDecoration(
                          border: InputBorder.none, hintText: 'Username'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your username';
                        }
                        return null;
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 15),

              //password text field
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25.0),
                child: Container(
                  decoration: BoxDecoration(
                      color: Colors.grey[200],
                      border: Border.all(color: Colors.white),
                      borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 20.0),
                    child: TextFormField(
                      controller: _passwordController,
                      keyboardType: TextInputType.text,
                      obscureText: true,
                      decoration: const InputDecoration(
                          border: InputBorder.none, hintText: 'Password'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your password';
                        }
                        return null;
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 15),

              //button submit
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20.0),
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 15.0)),
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      _login(context);
                    }
                  },
                  child: const Text(
                    'Login',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                ),
              ),
              const SizedBox(height: 15),

              //forgot password
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Lupa Password',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14.4,
                        color: Colors.white),
                  )
                ],
              )
            ],
          ),
        )),
      ),
    );
  }

  Future<void> _login(context) async {
    final String username = _usernameController.text;
    final String password = _passwordController.text;
    const FlutterSecureStorage secureStorage = FlutterSecureStorage();

    final bool loginSuccess = await ApiService.login(username, password);

    if (loginSuccess) {
      final String? accessToken = await secureStorage.read(key: 'access_token');

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => WebViewApp(
              accessToken: accessToken ??
                  ""), // Gunakan operator ?? untuk menangani nilai null
        ),
      );
    } else {
      Fluttertoast.showToast(
          msg: "Login gagal, Silahkan coba lagi!!",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.TOP,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0
      );
    }
  }
}
