import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:highfive/home.dart';
import 'package:highfive/screens/authentication/login_page.dart';
import 'package:provider/provider.dart';
import 'package:highfive/user.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:highfive/screens/api.dart';
import 'package:http/http.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:upgrader/upgrader.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    if (kDebugMode) {
      print('App Restarted');
    }
    return ChangeNotifierProvider<User>(
      create: (_) => User(
          name_: 'Test User',
          roll_: 'XXXXXXXXX',
          room_: 'XXX',
          isCompleted_: false,
          isVerfied_: false,
          isAdmin_: false),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primaryColor: const Color.fromARGB(217, 222, 22, 8),
        ),
        title: "User Profile",
        home: UpgradeAlert(
          upgrader: Upgrader(
            willDisplayUpgrade: (
                {required display, installedVersion, versionInfo}) {
              if (Platform.isAndroid || Platform.isIOS) {
                final appId = Platform.isAndroid
                    ? 'com.hostel5iitb.highfive'
                    : 'YOUR_IOS_APP_ID';
                final url = Uri.parse(
                  Platform.isAndroid
                      ? "market://details?id=$appId"
                      : "https://apps.apple.com/app/id$appId",
                );
                launchUrl(
                  url,
                  mode: LaunchMode.externalApplication,
                );
                return ;
              } else {
                return ;
              }
            },
            // canDismissDialog: false,
            // showIgnore: false,
            // showReleaseNotes: false,
            // showLater: false,
          ),
          child: const Initialiser(),
        ),
      ),
    );
  }
}

class Initialiser extends StatefulWidget {
  const Initialiser({super.key});

  @override
  State<Initialiser> createState() => _InitialiserState();
}

class _InitialiserState extends State<Initialiser> {
  bool? userPresent;
  bool networkConnected = true;
  String? cookie;

  Future<Response?> isLogged(String cookie) async {
    var csrftoken =
        cookie.substring(cookie.indexOf('csrf') + 10, cookie.indexOf(';'));

    try {
      return await post(Uri.parse(apiCheckUser), headers: {
        HttpHeaders.contentTypeHeader: 'application/json; charset=UTF-8',
        HttpHeaders.cookieHeader: cookie,
        'Referer': host,
        'X-CSRFToken': csrftoken
      }).timeout(const Duration(seconds: 10));
    } on TimeoutException {
      return null;
    } on ClientException {
      return null;
    }
  }

  @override
  void initState() {
    SharedPreferences.getInstance().then((data) {
      String? value = data.getString('MyCookie');
      if (value == null) {
        setState(() {
          userPresent = false;
        });
      } else {
        if (kDebugMode) {
          print(value);
        }
        if (kDebugMode) {
          print('islogged calling');
        }
        isLogged(value.toString()).then((value) {
          if (value != null) {
            setState(() {
              if (value.statusCode == 200) {
                Provider.of<User>(context, listen: false)
                    .updateUser(value.body);

                userPresent = true;
              } else {
                userPresent = false;
              }
            });
          } else {
            setState(() {
              networkConnected = false;
            });
          }
        });
      }
      cookie = value;
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (networkConnected) {
      if (userPresent != null) {
        return userPresent! ? const HomePage() : const LoginPage();
      } else {
        return Scaffold(
          backgroundColor: Colors.lightBlue[700],
          body: Stack(
            children: [
              Center(
                child: Container(
                  child: LoadingAnimationWidget.fourRotatingDots(
                      color: Colors.white, size: 50),
                ),
              ),
              Align(
                alignment: const Alignment(0, 0.8),
                child: Text(
                  "Hostel 5 Council 2023-24",
                  style: GoogleFonts.merriweather(
                      fontSize: 18, color: Colors.white),
                ),
              ),
            ],
          ),
        );
      }
    } else {
      return Scaffold(
        backgroundColor: Colors.lightBlue[700],
        body: Stack(
          children: [
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset(
                    "assets/icons/404.png",
                    scale: 3,
                  ),
                  Text(
                    "Server not found!",
                    style: GoogleFonts.spaceMono(
                        textStyle: const TextStyle(
                            fontSize: 35,
                            color: Colors.white,
                            fontWeight: FontWeight.bold)),
                  ),
                  SizedBox(
                    width: 200,
                    height: 50,
                    child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            elevation: 10,
                            shape: const StadiumBorder(),
                            backgroundColor: Colors.cyan,
                            shadowColor: Colors.black26),
                        onPressed: () {
                          setState(() {
                            networkConnected = true;
                            userPresent = null;
                            isLogged(cookie.toString()).then((value) {
                              if (value != null) {
                                setState(() {
                                  if (value.statusCode == 200) {
                                    Provider.of<User>(context, listen: false)
                                        .updateUser(value.body);
                                    userPresent = true;
                                  } else {
                                    userPresent = false;
                                  }
                                });
                              } else {
                                setState(() {
                                  networkConnected = false;
                                });
                              }
                            });
                          });
                        },
                        child: const Text(
                          "Try Again",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.bold),
                        )),
                  ),
                ],
              ),
            ),
            Center(
              heightFactor: 0.2,
              child: Text(
                "Hostel 5 Council 2023-24",
                style:
                    GoogleFonts.merriweather(fontSize: 15, color: Colors.grey),
              ),
            ),
          ],
        ),
      );
    }
  }
}
