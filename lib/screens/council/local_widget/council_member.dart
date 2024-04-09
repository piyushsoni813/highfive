import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:highfive/screens/council/local_widget/call_button.dart';
import 'package:highfive/screens/api.dart';

class CouncilMember extends StatelessWidget {
  final dynamic json;

  const CouncilMember({required this.json, super.key});

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          CircleAvatar(
            backgroundImage: NetworkImage(host + json["image"].toString()),
            radius: MediaQuery.of(context).size.width / 6,
          ),
          Padding(
            padding: const EdgeInsets.all(5.0),
            child: Text(json["por"].toString(),
                textAlign: TextAlign.center,
                style: GoogleFonts.roboto(
                  textStyle: const TextStyle(
                      fontSize: 20,
                      color: Colors.white,
                      fontWeight: FontWeight.bold),
                )),
          ),
          Padding(
            padding: const EdgeInsets.all(5.0),
            child: Text(json["name"].toString(),
                textAlign: TextAlign.center,
                style: GoogleFonts.hind(
                  textStyle: const TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.normal),
                )),
          ),
          CallButton(phonenumber: json["mobile"].toString())
        ],
      ),
    );
  }
}
