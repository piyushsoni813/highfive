import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:highfive/screens/api.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:highfive/screens/authentication/login_page.dart';

class PasswordChange extends StatefulWidget {
  const PasswordChange({super.key});

  @override
  State<PasswordChange> createState() => _PasswordChangeState();
}

class _PasswordChangeState extends State<PasswordChange> {
  TextEditingController currentPassController = TextEditingController();
  TextEditingController pass1Controller = TextEditingController();
  TextEditingController pass2Controller = TextEditingController();

  bool _isPasswordVisible = true;
  final bool _isButtonEnabled = true;

  bool _currPassError = false;
  bool _pass1Error = false;
  bool _pass2Error = false;

  String? _credentialError;

  String? csrftoken;
  String? cookie;

  Future<Response> changePassword(
      {required String currentPassword, required String newPassword}) {
    return post(
      Uri.parse(apiChangePassword),
      headers: <String, String>{
        'Referer': 'https://hostel5.online',
        'X-CSRFToken': csrftoken!,
        'Host': 'hostel5.online',
        'Content-Type': "application/json",
        HttpHeaders.cookieHeader: cookie!
      },
      body: jsonEncode(<String, String>{
        'curr_pass': currentPassword,
        'new_pass': newPassword
      }),
    );
  }

  @override
  void dispose() {
    pass1Controller.dispose();
    pass2Controller.dispose();
    super.dispose();
  }

  @override
  void initState() {
    SharedPreferences.getInstance().then((data) {
      String? value = data.getString('MyCookie');
      setState(() {
        cookie = value.toString();
        csrftoken = cookie!
            .substring(cookie!.indexOf('csrf') + 10, cookie!.indexOf(';'));
      });
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // final user = Provider.of<User>(context);
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
        Positioned(
          top: 30,
          left: 20,
          child: IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(
                Icons.cancel_rounded,
                color: Colors.white,
                size: 35,
              )),
        ),
        Center(
          child: Container(
            margin: const EdgeInsets.only(top: 150),
            color: Colors.transparent,
            child: Container(
              height: MediaQuery.of(context).size.height / 1.5,
              width: MediaQuery.of(context).size.width / 1.1,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30), color: Colors.white),
              child: cookie != null
                  ? Column(children: [
                      Expanded(
                        flex: 2,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Change Password",
                              style: GoogleFonts.roboto(
                                  textStyle: const TextStyle(
                                      color: Colors.black87,
                                      fontSize: 30,
                                      fontWeight: FontWeight.bold)),
                            ),
                            Text(
                              "Provide required fields!",
                              style: GoogleFonts.roboto(
                                  textStyle: const TextStyle(
                                      color: Colors.black54,
                                      fontSize: 18,
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
                            controller: currentPassController,
                            onChanged: (value) {
                              setState(() {
                                _credentialError = null;
                                _currPassError = false;
                                _pass1Error = false;
                                _pass2Error = false;
                              });
                            },
                            style: TextStyle(
                                color: Colors.lightBlue[700],
                                fontWeight: FontWeight.bold),
                            decoration: InputDecoration(
                                enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(50),
                                    borderSide: BorderSide(
                                        width: 2,
                                        color: _currPassError == false
                                            ? Colors.transparent
                                            : Colors.red)),
                                focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(50),
                                    borderSide: BorderSide(
                                        width: 2,
                                        color: _currPassError == false
                                            ? Colors.transparent
                                            : Colors.red)),
                                fillColor: Colors.lightBlue[100],
                                filled: true,
                                errorStyle: const TextStyle(
                                    color: Colors.redAccent,
                                    fontWeight: FontWeight.w600),
                                hintText: "Current Password",
                                hintStyle: TextStyle(
                                    color: Colors.lightBlue[700],
                                    fontWeight: FontWeight.w600),
                                prefixIcon: Icon(
                                  Icons.lock_open_outlined,
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
                            controller: pass1Controller,
                            onChanged: (value) {
                              setState(() {
                                _credentialError = null;
                                _currPassError = false;
                                _pass1Error = false;
                                _pass2Error = false;
                              });
                            },
                            style: TextStyle(
                                color: Colors.lightBlue[700],
                                fontWeight: FontWeight.bold),
                            obscureText: true,
                            obscuringCharacter: '*',
                            decoration: InputDecoration(
                                fillColor: Colors.lightBlue[100],
                                filled: true,
                                hintText: "New Password",
                                hintStyle: TextStyle(
                                    color: Colors.lightBlue[700],
                                    fontWeight: FontWeight.w600),
                                prefixIcon: Icon(
                                  Icons.lock_outline_rounded,
                                  color: Colors.lightBlue[700],
                                ),
                                enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(50),
                                    borderSide: BorderSide(
                                        width: 2,
                                        color: _pass1Error == false
                                            ? Colors.transparent
                                            : Colors.red)),
                                focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(50),
                                    borderSide: BorderSide(
                                        width: 2,
                                        color: _pass1Error == false
                                            ? Colors.transparent
                                            : Colors.red)),
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
                            controller: pass2Controller,
                            onChanged: (value) {
                              setState(() {
                                _credentialError = null;
                                _currPassError = false;
                                _pass1Error = false;
                                _pass2Error = false;
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
                                hintText: "Confirm New Password",
                                hintStyle: TextStyle(
                                    color: Colors.lightBlue[700],
                                    fontWeight: FontWeight.w600),
                                suffixIcon: IconButton(
                                  color: Colors.lightBlue[700],
                                  icon: _isPasswordVisible
                                      ? const Icon(
                                          Icons.visibility_off_outlined)
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
                                enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(50),
                                    borderSide: BorderSide(
                                        width: 2,
                                        color: _pass2Error == false
                                            ? Colors.transparent
                                            : Colors.red)),
                                focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(50),
                                    borderSide: BorderSide(
                                        width: 2,
                                        color: _pass2Error == false
                                            ? Colors.transparent
                                            : Colors.red)),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(50),
                                  borderSide: BorderSide.none,
                                )),
                          ),
                        ),
                      ),
                      Text(
                        _credentialError ??= '',
                        style: const TextStyle(
                            color: Colors.redAccent,
                            fontWeight: FontWeight.w600),
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
                                setState(() {
                                  if (currentPassController.text.isEmpty) {
                                    _currPassError = true;
                                    _credentialError =
                                        'Provide the required fields';
                                  }
                                  if (pass1Controller.text.isEmpty) {
                                    _pass1Error = true;
                                    _credentialError =
                                        'Provide the required fields';
                                  }
                                  if (pass2Controller.text.isEmpty) {
                                    _pass2Error = true;
                                    _credentialError =
                                        'Provide the required fields';
                                  }
                                });
                                if (currentPassController.text.isNotEmpty &&
                                    pass1Controller.text.isNotEmpty &&
                                    pass2Controller.text.isNotEmpty) {
                                  if (pass1Controller.text !=
                                      pass2Controller.text) {
                                    setState(() {
                                      _pass1Error = true;
                                      _pass2Error = true;
                                      _credentialError =
                                          'Password doesn\'t match';
                                    });
                                  } else if (pass1Controller.text.length < 8) {
                                    setState(() {
                                      _pass1Error = true;
                                      _pass2Error = true;
                                      _credentialError =
                                          'Password should be 10 characters long';
                                    });
                                  } else {
                                    changePassword(
                                            currentPassword:
                                                currentPassController.text,
                                            newPassword: pass1Controller.text)
                                        .then((value) {
                                      if (value.statusCode == 200) {
                                        Navigator.of(context).pop(context);
                                        Navigator.of(context).pop(context);
                                        Navigator.pushReplacement(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  const LoginPage(),
                                            ));
                                        showDialog(
                                            context: context,
                                            builder: (context) {
                                              Future.delayed(
                                                  const Duration(seconds: 5),
                                                  () {
                                                Navigator.of(context).pop(true);
                                              });
                                              return const AlertDialog(
                                                title: Text('Title'),
                                              );
                                            });
                                      } else {
                                        setState(() {
                                          _credentialError = 'Invalid Password';
                                        });
                                      }
                                    });
                                  }
                                }
                              },
                              child: const Text(
                                'Change Password',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold),
                              )),
                        ),
                      ),
                      const SizedBox(
                        height: 50,
                      )
                    ])
                  : const Center(
                      child: CircularProgressIndicator(),
                    ),
            ),
          ),
        )
      ]),
    );
  }
}
