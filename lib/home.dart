import 'package:flutter/material.dart';
import 'package:highfive/screens/complaint/complaints_page.dart';
import 'package:highfive/screens/event/event_page.dart';
import 'package:highfive/screens/inventory/inventory_page.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:highfive/screens/drawer.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:highfive/screens/mess/mess_page.dart';
import 'package:provider/provider.dart';
import 'package:highfive/user.dart';
import 'package:highfive/screens/api.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = <Widget>[
    const EventPage(),
    const MessPage(),
    const InventoryPage(),
    const ComplaintPage(),
  ];

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User>(context);
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
                onPressed: () {
                  Scaffold.of(context).openDrawer();
                },
                icon: const Icon(
                  Icons.menu_rounded,
                  color: Colors.white,
                  size: 30,
                ));
          },
        ),
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: Text(
          "HighFive",
          style: GoogleFonts.lobster(
              textStyle: const TextStyle(
                  color: Colors.white,
                  fontSize: 40,
                  fontWeight: FontWeight.w700,
                  shadows: [
                Shadow(
                    blurRadius: 5,
                    offset: Offset(5, 5),
                    color: Colors.lightBlue)
              ])),
        ),
        backgroundColor: Colors.lightBlue.shade700,
        toolbarHeight: 80,
      ),
      body: Center(
        child: _pages.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: GNav(
        backgroundColor: Colors.lightBlue.shade100,
        color: Colors.white,
        gap: 8,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        activeColor: Colors.lightBlue.shade700,
        tabBackgroundColor: Colors.lightBlue.withOpacity(0.3),
        selectedIndex: _selectedIndex,
        onTabChange: (int index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        tabs: const [
          GButton(
            icon: Icons.home_filled,
            text: "Home",
          ),
          GButton(
            icon: Icons.food_bank_rounded,
            text: "Mess",
          ),
          GButton(
            icon: Icons.store_rounded,
            text: "Inventory",
          ),
          GButton(
            icon: Icons.crisis_alert_rounded,
            text: "Complaints",
          ),
        ],
      ),
      drawer: MyDrawer(
        name: user.name,
        email: '${user.roll}@iitb.ac.in',
        imagePath: (user.image != null) ? host + user.image! : null,
      ),
    );
  }
}
