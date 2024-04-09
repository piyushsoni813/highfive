import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:highfive/home.dart';
import 'package:highfive/screens/api.dart';
import 'package:http/http.dart';
import 'package:provider/provider.dart';
import 'package:highfive/user.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  RegExp passValid = RegExp(r"(?=.*\d)(?=.*[a-z])(?=.*[A-Z])(?=.*\W)");

  bool _isPasswordVisible = true;
  bool _showHelp = false;
  bool _isButtonEnabled = true;
  String? _loginError;
  String? _passError;
  String? _rollError;

  final _formKey = GlobalKey<FormState>();

  Future<Response> studentLogin(String username, String password) {
    return post(
      Uri.parse(apiLogin),
      headers: <String, String>{
        HttpHeaders.contentTypeHeader: 'application/json; charset=UTF-8',
        'Referer': 'https://hostel5.online',
      },
      body: jsonEncode(
          <String, String>{'rollNumber': username, 'password': password}),
    );
  }

  bool validatePassword(String pass) {
    String password = pass.trim();
    if (passValid.hasMatch(password)) {
      return true;
    } else {
      return false;
    }
  }

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User>(context);
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.black26,
      body: Stack(children: [
        Container(
          decoration: const BoxDecoration(
              image: DecorationImage(
                  image: AssetImage("assets/images/bg.jpg"),
                  fit: BoxFit.cover)),
        ),
        Center(
          child: Form(
            key: _formKey,
            child: Container(
              margin: const EdgeInsets.only(top: 150),
              color: Colors.transparent,
              child: Container(
                height: MediaQuery.of(context).size.height / 1.5,
                width: MediaQuery.of(context).size.width / 1.1,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    color: Colors.white),
                child: Column(children: [
                  Expanded(
                    flex: 2,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Sign In",
                          style: GoogleFonts.roboto(
                              textStyle: const TextStyle(
                                  color: Colors.black87,
                                  fontSize: 40,
                                  fontWeight: FontWeight.bold)),
                        ),
                        Text(
                          "Welcome back!",
                          style: GoogleFonts.roboto(
                              textStyle: const TextStyle(
                                  color: Colors.black54,
                                  fontSize: 20,
                                  fontWeight: FontWeight.normal)),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: SizedBox(
                      height: 50,
                      width: MediaQuery.of(context).size.width / 1.5,
                      child: TextFormField(
                        controller: usernameController,
                        validator: (value) {
                          if (value == null ||
                              value.length < 6 ||
                              value.length > 10 ||
                              value.isEmpty) {
                            return 'Invalid Roll Number (field is case sensitive)';
                          }
                          return null;
                        },
                        onChanged: (value) {
                          setState(() {
                            _loginError = null;
                          });
                        },
                        style: TextStyle(
                            color: Colors.lightBlue[700],
                            fontWeight: FontWeight.bold),
                        decoration: InputDecoration(
                            errorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(50),
                                borderSide: const BorderSide(
                                    width: 2, color: Colors.red)),
                            fillColor: Colors.lightBlue[100],
                            filled: true,
                            errorText: _rollError,
                            errorStyle: const TextStyle(
                                color: Colors.redAccent,
                                fontWeight: FontWeight.w600),
                            hintText: "Roll Number",
                            hintStyle: TextStyle(
                                color: Colors.lightBlue[700],
                                fontWeight: FontWeight.w600),
                            prefixIcon: Icon(
                              Icons.email_outlined,
                              color: Colors.lightBlue[700],
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(50),
                              borderSide: BorderSide.none,
                            )),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  Expanded(
                    flex: 1,
                    child: SizedBox(
                      height: 50,
                      width: MediaQuery.of(context).size.width / 1.5,
                      child: TextFormField(
                        controller: passwordController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Invalid Password';
                          }
                          return null;
                        },
                        onChanged: (value) {
                          setState(() {
                            _loginError = null;
                          });
                        },
                        style: TextStyle(
                            color: Colors.lightBlue[700],
                            fontWeight: FontWeight.bold),
                        obscureText: _isPasswordVisible,
                        obscuringCharacter: '*',
                        decoration: InputDecoration(
                            fillColor: Colors.lightBlue[100],
                            filled: true,
                            hintText: "Password",
                            errorText: _passError,
                            hintStyle: TextStyle(
                                color: Colors.lightBlue[700],
                                fontWeight: FontWeight.w600),
                            suffixIcon: IconButton(
                              color: Colors.lightBlue[700],
                              icon: _isPasswordVisible
                                  ? const Icon(Icons.visibility_off_outlined)
                                  : const Icon(Icons.visibility_outlined),
                              onPressed: () {
                                setState(() {
                                  _isPasswordVisible = !_isPasswordVisible;
                                });
                              },
                            ),
                            prefixIcon: Icon(
                              Icons.lock_outline_rounded,
                              color: Colors.lightBlue[700],
                            ),
                            errorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(50),
                                borderSide: const BorderSide(
                                    width: 2, color: Colors.red)),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(50),
                              borderSide: BorderSide.none,
                            )),
                      ),
                    ),
                  ),
                  Text(
                    _loginError ??= '',
                    style: const TextStyle(
                        color: Colors.redAccent, fontWeight: FontWeight.w600),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SizedBox(
                      height: 40,
                      width: MediaQuery.of(context).size.width / 1.5,
                      child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              elevation: 10,
                              shape: const StadiumBorder(),
                              backgroundColor: _isButtonEnabled
                                  ? Colors.lightBlue
                                  : Colors.grey.shade100,
                              shadowColor: Colors.black26),
                          onPressed: () {
                            if (_isButtonEnabled) {
                              setState(() {
                                _loginError = null;
                              });
                              if (_formKey.currentState!.validate()) {
                                studentLogin(usernameController.text,
                                        passwordController.text)
                                    .then((value) {
                                  setState(() {
                                    if (value.statusCode == 202) {
                                      String? rawCookie =
                                          value.headers['set-cookie'];
                                      if (rawCookie != null) {
                                        saveKey('MyCookie', cookies(rawCookie))
                                            .then((_) {
                                          user.updateUser(value.body);
                                          Navigator.pushReplacement(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    const HomePage()),
                                          );
                                        });
                                      }
                                    } else if (value.statusCode == 208) {
                                      _loginError = 'Invalid Credentials! ';
                                      _isButtonEnabled = true;
                                    } else if (value.statusCode == 404) {
                                      _loginError =
                                          'Not Registered! (Roll No. is case sensitive)';
                                      _isButtonEnabled = true;
                                    } else {
                                      _loginError = 'Unknown Error!';
                                      _isButtonEnabled = true;
                                    }
                                  });
                                });
                                setState(() {
                                  _isButtonEnabled = false;
                                });
                              }
                            }
                          },
                          child: const Text(
                            'Login',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.bold),
                          )),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        InkWell(
                            onTap: () {
                              setState(() {
                                _showHelp = !_showHelp;
                              });
                            },
                            child: Text(
                              "Forgot credentials?",
                              style: TextStyle(color: Colors.lightBlue[500]),
                            )),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
                            child: Text(
                              _showHelp
                                  ? "raise a credential reset request from your registered LDAP ID"
                                  : " ",
                              maxLines: 2,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                  color: Colors.green, fontSize: 15),
                            ),
                          ),
                        )
                      ],
                    ),
                  )
                ]),
              ),
            ),
          ),
        )
      ]),
    );
  }
}

String cookies(String rawcookie) {
  String csrftoken = rawcookie.substring(rawcookie.indexOf('csrftoken'),
      rawcookie.indexOf(';', rawcookie.indexOf('csrftoken')));
  String sessionid = rawcookie.substring(rawcookie.indexOf('sessionid'),
      rawcookie.indexOf(';', rawcookie.indexOf('sessionid')));
  return "$csrftoken; $sessionid";
}

Future<void> saveKey(String key, String value) async {
  var pref = await SharedPreferences.getInstance();
  pref.setString(key, value);
  if (kDebugMode) {
    print(pref.getString(key).toString());
  }
}
