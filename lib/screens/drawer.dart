import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:highfive/screens/api.dart';
import 'package:highfive/screens/authentication/login_page.dart';
import 'package:highfive/screens/pdf_viewer.dart';
import 'package:highfive/screens/council/council_page.dart';
import 'package:highfive/screens/profile/profile_view.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cached_network_image/cached_network_image.dart';

class MyDrawer extends StatefulWidget {
  final String name;
  final String email;
  final String? imagePath;

  const MyDrawer(
      {super.key, required this.name, required this.email, this.imagePath});

  @override
  State<MyDrawer> createState() => _MyDrawerState();
}

class _MyDrawerState extends State<MyDrawer> {
  late String csrftoken;
  late String cookie;

  Future<Response> _signOut() async {
    var response = await get(Uri.parse(apiLogout), headers: {
      'Content-Type': "application/json",
      'Cookie': cookie,
      'X-CSRFToken': csrftoken
    });

    return response;
  }

  @override
  void initState() {
    SharedPreferences.getInstance().then((data) {
      String? value = data.getString('MyCookie');
      setState(() {
        cookie = value.toString();
        csrftoken =
            cookie.substring(cookie.indexOf('csrf') + 10, cookie.indexOf(';'));
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
        child: SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          buildHeader(context),
          buildMenuItems(context),
        ],
      ),
    ));
  }

  Widget buildHeader(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.pop(context);
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ProfileView(),
            ));
      },
      child: Stack(
        alignment: Alignment.center,
        children: [
          CachedNetworkImage(
              imageUrl: apiDrawercover,
              placeholder: (context, url) => Image.asset(
                    "assets/images/placeholder.jpg",
                    fit: BoxFit.fitWidth,
                  )),
          Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.width / 4,
                  width: MediaQuery.of(context).size.width / 4,
                  child: ClipOval(
                    child: FittedBox(
                        fit: BoxFit.cover,
                        clipBehavior: Clip.hardEdge,
                        child: (widget.imagePath != null)
                            ? Image.network(
                                widget.imagePath!,
                                errorBuilder: (context, error, stackTrace) {
                                  return Image.asset('assets/icons/man.png');
                                },
                              )
                            : Image.asset("assets/icons/man.png")),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  widget.name,
                  style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
                Text(
                  widget.email,
                  style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.normal,
                      color: Colors.white),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget buildMenuItems(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      child: Wrap(
        runSpacing: 16,
        children: [
          ListTile(
            leading: Image.asset(
              "assets/icons/menu.png",
              scale: 1.0,
              height: 30.0,
              width: 30.0,
            ),
            title: const Text(
              'Mess Menu',
              style: TextStyle(fontSize: 15),
            ),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        MyPDFViewer(name: "Mess Menu", pdfPath: apiMenuPDF),
                  ));
            },
          ),
          ListTile(
            leading: Image.asset(
              "assets/icons/standing.png",
              scale: 1.0,
              height: 30.0,
              width: 30.0,
            ),
            title: const Text(
              'GC Performances',
              style: TextStyle(fontSize: 15),
            ),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Scaffold(
                        backgroundColor: Colors.blue,
                        extendBodyBehindAppBar: true,
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
                        body: const Center(
                            child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "COMING SOON...",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 30,
                                  fontWeight: FontWeight.w600),
                            ),
                            Text(
                              "STAY TUNED",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 25,
                                  fontWeight: FontWeight.w500),
                            ),
                          ],
                        ))),
                  ));
            },
          ),
          ListTile(
            leading: Image.asset(
              "assets/icons/constitution.png",
              scale: 1.0,
              height: 30.0,
              width: 30.0,
            ),
            title: const Text(
              'Hostel Constitution',
              style: TextStyle(fontSize: 15),
            ),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Scaffold(
                        backgroundColor: Colors.blue,
                        extendBodyBehindAppBar: true,
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
                        body: const Center(
                            child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "UNDER FORMULATION...",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 30,
                                  fontWeight: FontWeight.w600),
                            ),
                          ],
                        ))),
                  ));
            },
          ),
          ListTile(
            leading: Image.asset(
              "assets/icons/room.png",
              scale: 1.0,
              height: 30.0,
              width: 30.0,
            ),
            title: const Text(
              'Room Allocation',
              style: TextStyle(fontSize: 15),
            ),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MyPDFViewer(
                        name: "Room Allocation", pdfPath: apiRoomAllocationPDF),
                  ));
            },
          ),
          const Divider(color: Colors.black54),
          ListTile(
            leading: Image.asset(
              "assets/icons/council.png",
              scale: 1.0,
              height: 30.0,
              width: 30.0,
            ),
            title: const Text(
              'Hostel Council',
              style: TextStyle(fontSize: 15),
            ),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CouncilPage(),
                  ));
            },
          ),
          ListTile(
            leading: Image.asset(
              "assets/icons/logout.png",
              scale: 1.0,
              height: 30.0,
              width: 30.0,
            ),
            title: const Text(
              'Sign Out',
              style: TextStyle(fontSize: 15),
            ),
            onTap: () {
              Navigator.pop(context);
              _signOut().then((value) {});
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const LoginPage(),
                  ));
            },
          ),
          const SizedBox(height: 130),
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Developed with ",
                    style: GoogleFonts.inter(
                        fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                  Image.asset(
                    "assets/icons/heart.png",
                    width: 20,
                    height: 20,
                  ),
                  Text(
                    " for Hostel 5",
                    style: GoogleFonts.inter(
                        fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              Text("by Dheeraj Shakya",
                  style: GoogleFonts.inter(fontSize: 15)),
            ],
          ),
        ],
      ),
    );
  }
}
