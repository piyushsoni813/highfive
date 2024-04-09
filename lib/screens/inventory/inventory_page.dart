import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart';
import 'package:highfive/screens/api.dart';
import 'package:highfive/screens/inventory/local_widget/local_widget.dart';

class InventoryPage extends StatefulWidget {
  final List<String> domains = const ["Cult", "Sports", "Tech"];

  const InventoryPage({super.key});

  @override
  State<InventoryPage> createState() => _InventoryPageState();
}

class _InventoryPageState extends State<InventoryPage> {
  final categoryKey = GlobalKey<_MyDropDownState>();
  List<List<String>> categories = [[], [], []];
  String? selectedDomain;
  String uri = 'test';
  String? errorMessage;

  void changeIndex(String domain) {
    selectedDomain = domain;
    categoryKey.currentState!.selectedValue = null;
    setState(() {});
  }

  void changeURI(String category) {
    setState(() {
      uri = category;
    });
  }

  Future<List<Inventory>> fetchInventory() async {
    final response = await get(Uri.parse(apiInventoryItems + uri));
    List<Inventory> inventory = [];
    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);

      for (var each in data) {
        Inventory item = Inventory(
            name: each['name'],
            location: each['location'],
            quantity: each['quantity'].toString(),
            photo: each['photo']);
        inventory.add(item);
      }
    } else if (response.statusCode == 203) {
      errorMessage = 'No category is chosen!';
    } else if (response.statusCode == 204) {
      errorMessage = 'No item in this category!';
    }
    return inventory;
  }

  Future<bool> fetchCategories() async {
    final response = await get(Uri.parse(apiInventoryCategory));
    var data = jsonDecode(response.body);
    if (response.statusCode == 200) {
      if (response.body.isNotEmpty) {
        for (var each in data) {
          categories[widget.domains.indexOf(each['domain'])]
              .add(each['heading']);
        }
        return true;
      }
      return true;
    }
    throw Exception("Error agya bhai firse");
  }

  bool isLoaded = false;

  @override
  void initState() {
    fetchCategories().then((value) {
      if (mounted) {
        setState(() {
          isLoaded = value;
        });
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return isLoaded
        ? Column(
            children: [
              Container(
                decoration: const BoxDecoration(
                    image: DecorationImage(
                        image: AssetImage("assets/images/inventory_bg.jpeg"),
                        fit: BoxFit.cover)),
                padding: const EdgeInsets.fromLTRB(0, 0, 0, 5),
                height: MediaQuery.of(context).size.height / 5,
                width: MediaQuery.of(context).size.width,
                child: Column(
                  children: [
                    Container(
                      alignment: Alignment.center,
                      width: MediaQuery.of(context).size.width,
                      padding: const EdgeInsets.all(10),
                      child: Text(
                        "Hostel Inventory",
                        style: GoogleFonts.barlow(
                            textStyle: const TextStyle(
                                fontSize: 25,
                                fontWeight: FontWeight.bold,
                                color: Colors.white)),
                      ),
                    ),
                    Expanded(
                        child: MyDropDown(
                      items: widget.domains,
                      hint: "Select Domain",
                      changed: changeIndex,
                    )),
                    Expanded(
                        child: MyDropDown(
                      key: categoryKey,
                      items: selectedDomain == null
                          ? []
                          : categories[widget.domains.indexOf(selectedDomain!)],
                      hint: "Select Category",
                      changed: changeURI,
                    )),
                  ],
                ),
              ),
              Expanded(
                  child: FutureBuilder(
                future: fetchInventory(),
                builder: (BuildContext context, AsyncSnapshot snapshot) {
                  if (snapshot.hasData && snapshot.data.length > 0) {
                    return ListView.builder(
                      itemCount: snapshot.data.length,
                      itemBuilder: (context, index) {
                        return Padding(
                            padding: const EdgeInsets.only(top: 5, bottom: 5),
                            child: InventoryCard(
                              name: snapshot.data[index].name,
                              location: snapshot.data[index].location,
                              quantity: snapshot.data[index].quantity,
                              imageurl: host + snapshot.data[index].photo,
                            ));
                      },
                    );
                  } else {
                    return Center(
                      child: Text(
                        errorMessage ??= 'Unknown Error Occured',
                        style: GoogleFonts.robotoSlab(
                            textStyle: const TextStyle(
                                color: Colors.black38,
                                fontSize: 20,
                                fontWeight: FontWeight.w600)),
                      ),
                    );
                  }
                },
              ))
            ],
          )
        : const CircularProgressIndicator();
  }
}

class Inventory {
  final String name;
  final String location;
  final String quantity;
  final String photo;

  const Inventory(
      {required this.name,
      required this.location,
      required this.quantity,
      required this.photo});
}

class MyDropDown extends StatefulWidget {
  final List<String> items;
  final String hint;
  final Function(String) changed;

  const MyDropDown(
      {super.key,
      required this.items,
      required this.hint,
      required this.changed});

  @override
  State<MyDropDown> createState() => _MyDropDownState();
}

class _MyDropDownState extends State<MyDropDown> {
  String? selectedValue;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: DropdownButtonHideUnderline(
        child: DropdownButton2(
          isExpanded: true,
          hint: Row(
            children: [
              const SizedBox(
                width: 4,
              ),
              Expanded(
                child: Text(
                  widget.hint,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          items: widget.items
              .map((item) => DropdownMenuItem<String>(
                    value: item,
                    child: Text(
                      item,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ))
              .toList(),
          value: selectedValue,
          onChanged: (value) {
            setState(() {
              selectedValue = value as String;
            });
            widget.changed(value as String);
          },
          buttonStyleData: ButtonStyleData(
            height: 35,
            width: MediaQuery.of(context).size.width / 1.5,
            padding: const EdgeInsets.only(left: 14, right: 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(35),
              border: Border.all(color: Colors.black54, width: 1),
              color: Colors.white,
            ),
            elevation: 1,
          ),
          iconStyleData: const IconStyleData(
            icon: Icon(
              Icons.arrow_forward_ios_outlined,
            ),
            iconSize: 14,
            iconEnabledColor: Colors.black54,
            iconDisabledColor: Colors.grey,
          ),
          dropdownStyleData: DropdownStyleData(
              maxHeight: 200,
              width: 200,
              padding: null,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                border: Border.all(width: 1, color: Colors.black54),
                color: Colors.white,
              ),
              elevation: 8,
              offset: const Offset(0, 0),
              scrollbarTheme: ScrollbarThemeData(
                thumbColor: MaterialStateProperty.all(Colors.black54),
                radius: const Radius.circular(40),
                thickness: MaterialStateProperty.all(6),
                thumbVisibility: MaterialStateProperty.all(true),
              )),
          menuItemStyleData: const MenuItemStyleData(
            height: 40,
            padding: EdgeInsets.only(left: 14, right: 14),
          ),
        ),
      ),
    );
  }
}
