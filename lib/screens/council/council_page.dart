import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:highfive/screens/council/local_widget/council_member.dart';
import 'package:http/http.dart';
import 'package:highfive/screens/api.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Council {
  final dynamic data;
  Council({required this.data});
}

class CouncilPage extends StatefulWidget {
  const CouncilPage({super.key});

  @override
  State<CouncilPage> createState() => _CouncilPageState();
}

class _CouncilPageState extends State<CouncilPage> {
  dynamic jsonData;
  String? rawtoken;

  Future<dynamic> _getCouncil() async {
    var response = await get(
        Uri.parse(
          "$host/server/council",
        ),
        headers: {
          'Content-Type': "application/json",
          'Cookie': rawtoken ?? "",
        });
    return jsonDecode(response.body);
  }

  @override
  void initState() {
    SharedPreferences.getInstance().then((data) {
      String? value = data.getString('MyCookie');
      if (mounted) {
        rawtoken = value.toString();
        _getCouncil().then((value) {
          if (mounted) {
            setState(() {
              jsonData = value;
            });
          }
        });
      }
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return rawtoken != null
        ? Scaffold(
            extendBodyBehindAppBar: true,
            backgroundColor: Colors.blue,
            appBar: AppBar(
              shadowColor: Colors.transparent,
              backgroundColor: Colors.transparent,
              leading: IconButton(
                  splashRadius: 20,
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.arrow_back_ios_rounded)),
            ),
            body: (jsonData != null)
                ? Stack(
                    children: [
                      Container(
                        decoration: const BoxDecoration(
                            image: DecorationImage(
                                image:
                                    AssetImage("assets/images/council_bg.jpg"),
                                fit: BoxFit.cover)),
                      ),
                      SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const SizedBox(
                              height: 30,
                            ),
                            RichText(
                                text: TextSpan(
                                    text: 'Hostel',
                                    style: GoogleFonts.lato(
                                        textStyle: const TextStyle(
                                            fontSize: 25,
                                            fontWeight: FontWeight.w600)),
                                    children: [
                                  TextSpan(
                                      text: ' 5 ',
                                      style: GoogleFonts.lato(
                                          textStyle: const TextStyle(
                                              fontSize: 40,
                                              fontWeight: FontWeight.w900))),
                                  TextSpan(
                                      text: 'Council',
                                      style: GoogleFonts.lato(
                                          textStyle: const TextStyle(
                                              fontSize: 25,
                                              fontWeight: FontWeight.bold)))
                                ])),
                            const SizedBox(
                              height: 30,
                            ),
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    CouncilMember(
                                      json: jsonData['gsec'],
                                    ),
                                  ]),
                            ),
                            const SizedBox(
                              height: 30,
                            ),
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.center,
                              child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    CouncilMember(
                                      json: jsonData['wardnom'],
                                    ),
                                    CouncilMember(
                                      json: jsonData['eventnom'],
                                    ),
                                  ]),
                            ),
                            const Divider(color: Colors.white),
                            const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text(
                                "  Maintenance Council",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 30,
                                    fontWeight: FontWeight.w600),
                              ),
                            ),
                            SizedBox(
                              height: 220,
                              width: 220,
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                alignment: Alignment.center,
                                child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      CouncilMember(
                                        json: jsonData['maintco'],
                                      ),
                                    ]),
                              ),
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            Wrap(
                              alignment: WrapAlignment.center,
                              runSpacing: 20,
                              children: List.generate(
                                  jsonData['maintsecies'].length ?? 0, (index) {
                                return SizedBox(
                                  height: 190,
                                  width: 190,
                                  child: CouncilMember(
                                    json: jsonData['maintsecies'][index],
                                  ),
                                );
                              }),
                            ),
                            const Divider(color: Colors.white),
                            const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text(
                                "Mess Council",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 30,
                                    fontWeight: FontWeight.w600),
                              ),
                            ),
                            SizedBox(
                              height: 220,
                              width: 220,
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                alignment: Alignment.center,
                                child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      CouncilMember(
                                        json: jsonData['messco'],
                                      ),
                                    ]),
                              ),
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            Wrap(
                              alignment: WrapAlignment.center,
                              runSpacing: 20,
                              children: List.generate(
                                  jsonData['messsecies'].length ?? 0, (index) {
                                return SizedBox(
                                  height: 190,
                                  width: 190,
                                  child: CouncilMember(
                                    json: jsonData['messsecies'][index],
                                  ),
                                );
                              }),
                            ),
                            const Divider(
                              color: Colors.white,
                            ),
                            const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text(
                                "Sports Council",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 30,
                                    fontWeight: FontWeight.w600),
                              ),
                            ),
                            SizedBox(
                              height: 220,
                              width: 220,
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                alignment: Alignment.center,
                                child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      CouncilMember(
                                        json: jsonData['sportsco'],
                                      ),
                                    ]),
                              ),
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            Wrap(
                              alignment: WrapAlignment.center,
                              runSpacing: 20,
                              children: List.generate(
                                  jsonData['sportssecies'].length ?? 0,
                                  (index) {
                                return SizedBox(
                                  height: 190,
                                  width: 190,
                                  child: CouncilMember(
                                    json: jsonData['sportssecies'][index],
                                  ),
                                );
                              }),
                            ),
                            const Divider(
                              color: Colors.white,
                            ),
                            const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text(
                                "Cultural Council",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 30,
                                    fontWeight: FontWeight.w600),
                              ),
                            ),
                            SizedBox(
                              height: 220,
                              width: 220,
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                alignment: Alignment.center,
                                child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      CouncilMember(
                                        json: jsonData['cultco'],
                                      ),
                                    ]),
                              ),
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            Wrap(
                              alignment: WrapAlignment.center,
                              runSpacing: 20,
                              children: List.generate(
                                  jsonData['cultsecies'].length, (index) {
                                return SizedBox(
                                  height: 190,
                                  width: 190,
                                  child: CouncilMember(
                                    json: jsonData['cultsecies'][index],
                                  ),
                                );
                              }),
                            ),
                            const Divider(
                              color: Colors.white,
                            ),
                            const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text(
                                "Technical Council",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 30,
                                    fontWeight: FontWeight.w600),
                              ),
                            ),
                            SizedBox(
                              height: 220,
                              width: 220,
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                alignment: Alignment.center,
                                child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      CouncilMember(
                                        json: jsonData['techco'],
                                      ),
                                    ]),
                              ),
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            Wrap(
                              alignment: WrapAlignment.center,
                              runSpacing: 20,
                              children: List.generate(
                                  jsonData['techsecies'].length, (index) {
                                return SizedBox(
                                  height: 190,
                                  width: 190,
                                  child: CouncilMember(
                                    json: jsonData['techsecies'][index],
                                  ),
                                );
                              }),
                            ),
                            const Divider(
                              color: Colors.white,
                            ),
                            const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text(
                                "Web Council",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 30,
                                    fontWeight: FontWeight.w600),
                              ),
                            ),
                            SizedBox(
                              height: 220,
                              width: 220,
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                alignment: Alignment.center,
                                child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      CouncilMember(
                                        json: jsonData['sysad'],
                                      ),
                                    ]),
                              ),
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            Wrap(
                              alignment: WrapAlignment.center,
                              runSpacing: 20,
                              children: List.generate(
                                  jsonData['websecies'].length, (index) {
                                return SizedBox(
                                  height: 190,
                                  width: 190,
                                  child: CouncilMember(
                                    json: jsonData['websecies'][index],
                                  ),
                                );
                              }),
                            ),
                          ],
                        ),
                      ),
                    ],
                  )
                : const Center(
                    child: CircularProgressIndicator(
                    color: Colors.white,
                  )),
          )
        : const Center(
            child: CircularProgressIndicator(),
          );
  }
}
