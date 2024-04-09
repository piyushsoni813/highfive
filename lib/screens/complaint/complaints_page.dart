import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:highfive/screens/complaint/complaint_raise.dart';
import 'package:highfive/screens/complaint/local_widgets/complaint_widgets.dart';
import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart';
import 'package:highfive/screens/api.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class ComplaintPage extends StatefulWidget {
  const ComplaintPage({super.key});

  @override
  State<ComplaintPage> createState() => _ComplaintPageState();
}

class _ComplaintPageState extends State<ComplaintPage> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 2,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
                color: Colors.white,
                height: 60,
                child: TabBar(
                    indicatorColor: Colors.blue,
                    labelColor: Colors.black,
                    unselectedLabelColor: Colors.grey.shade700,
                    indicatorSize: TabBarIndicatorSize.label,
                    tabs: [
                      Tab(
                        child: Text(
                          "My Complaints",
                          style: GoogleFonts.roboto(
                              textStyle: const TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.w600)),
                        ),
                      ),
                      Tab(
                        child: Text(
                          "Raise Complaint",
                          style: GoogleFonts.roboto(
                              textStyle: const TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.w600)),
                        ),
                      )
                    ])),
            const Expanded(
              child: TabBarView(
                children: [MyComplaint(), ComplaintRaise()],
              ),
            )
          ],
        ));
  }
}

class MyComplaint extends StatefulWidget {
  const MyComplaint({super.key});

  @override
  State<MyComplaint> createState() => _MyComplaintState();
}

class _MyComplaintState extends State<MyComplaint> {
  String? rawtoken;

  late String csrftoken;
  late String cookie;

  List<Complaint>? allComplains;

  Future<List<Complaint>> _deleteData(int id) async {
    var response = await delete(
      Uri.parse(apiDeleteComplaint),
      headers: <String, String>{
        HttpHeaders.contentTypeHeader: 'application/json; charset=UTF-8',
        HttpHeaders.cookieHeader: cookie,
        'Referer': 'https://hostel5.online',
        'X-CSRFToken': csrftoken
      },
      body: jsonEncode(<String, int>{'id': id}),
    );
    List<Complaint> complains = [];
    if (response.statusCode == 200) {
      List data = jsonDecode(response.body)!;
      for (var each in data) {
        Complaint complaint = Complaint.fromJson(each);
        complains.add(complaint);
      }
    }
    return complains;
  }

  Future<List<Complaint>> _getData() async {
    var response = await get(
      Uri.parse(apiAllComplaints),
      headers: <String, String>{
        HttpHeaders.contentTypeHeader: 'application/json; charset=UTF-8',
        HttpHeaders.cookieHeader: cookie,
        'X-CSRFToken': csrftoken
      },
    );
    List<Complaint> complains = [];
    if (response.statusCode == 200) {
      List data = jsonDecode(response.body)!;
      for (var each in data) {
        Complaint complaint = Complaint.fromJson(each);
        complains.add(complaint);
      }
    }
    return complains;
  }

  @override
  void initState() {
    SharedPreferences.getInstance().then((data) {
      String? value = data.getString('MyCookie');
      cookie = value.toString();
      csrftoken =
          cookie.substring(cookie.indexOf('csrf') + 10, cookie.indexOf(';'));
      _getData().then((value) {
        if (mounted) {
          setState(() {
            if (value.isEmpty) {
              allComplains = <Complaint>[];
            } else {
              allComplains = value;
            }
          });
        }
      });
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return (allComplains != null)
        ? ((allComplains!.isNotEmpty)
            ? ListView.builder(
                itemCount: allComplains!.length,
                itemBuilder: (BuildContext context, int index) {
                  return ComplaintCard(
                      id: allComplains![index].id,
                      title: allComplains![index].title,
                      type: allComplains![index].type,
                      date: allComplains![index].date,
                      details: allComplains![index].details,
                      image: allComplains![index].image,
                      status: allComplains![index].status,
                      deleteSelf: () {
                        _deleteData(allComplains![index].id).then((value) {
                          setState(() {
                            allComplains = value;
                          });
                        });
                      });
                },
              )
            : FittedBox(
                fit: BoxFit.none,
                child: Text(
                  "You Have No Complains",
                  style: GoogleFonts.notoSans(
                      fontSize: 20, fontWeight: FontWeight.w700),
                )))
        : LoadingAnimationWidget.hexagonDots(color: Colors.blue, size: 60);
  }
}

class Complaint {
  final int id;
  final String title;
  final String type;
  final String date;
  final String details;
  final String image;
  final String status;

  Complaint(this.id, this.title, this.type, this.date, this.details, this.image,
      this.status);

  factory Complaint.fromJson(Map<String, dynamic> json) {
    return Complaint(json['id'], json['title'], json['type'], json['date'],
        json['details'], json['image'] ?? "", json['status']);
  }
}
