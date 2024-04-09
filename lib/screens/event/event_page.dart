import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:highfive/screens/api.dart';
import 'package:highfive/screens/event/local_widgets/event_widgets.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EventPage extends StatefulWidget {
  const EventPage({super.key});

  @override
  State<EventPage> createState() => _EventPageState();
}

class _EventPageState extends State<EventPage> {
  String? rawtoken;

  Future<List<Post>> _getData() async {
    var response = await get(Uri.parse(apiAllEvents), headers: {
      'Content-Type': "application/json",
      'Cookie': rawtoken ?? "",
    });
    if (response.statusCode == 200) {
      List data = jsonDecode(response.body)!;
      List<Post> posts = [];
      for (var each in data) {
        Post post =
            Post(each["title"], "$host${each["post"]}", each["description"]);
        posts.add(post);
      }
      return posts;
    } else {
      List<Post> empty = [];
      return empty;
    }
  }

  @override
  void initState() {
    SharedPreferences.getInstance().then((data) {
      String? value = data.getString('MyCookie');
      if (mounted) {
        setState(() {
          rawtoken = value.toString();
        });
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return (rawtoken != null)
        ? FutureBuilder(
            future: _getData(),
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              if (snapshot.hasData) {
                return ListView.builder(
                  itemCount: snapshot.data.length,
                  itemBuilder: (BuildContext context, int index) {
                    return Event(
                      title: snapshot.data[index].title,
                      detail: snapshot.data[index].detail,
                      posturl: snapshot.data[index].posturl,
                    );
                  },
                );
              } else {
                return const Center(
                  child: CircularProgressIndicator(color: Colors.lightBlue),
                );
              }
            },
          )
        : const Center(child: CircularProgressIndicator(color: Colors.blue));
  }
}

class Post {
  final String title;
  final String posturl;
  final String detail;

  Post(this.title, this.posturl, this.detail);
}
