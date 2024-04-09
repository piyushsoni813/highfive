import 'package:flutter/material.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:highfive/screens/api.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
    return Container(
      color: Colors.transparent,
      child: Center(
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
                    style: GoogleFonts.rubik(
                      textStyle: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.black54,
                      ),
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
                          color: Colors.black54,
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
      ),
    );
  }
}

class ComplaintCard extends StatefulWidget {
  final int id;
  final String title;
  final String type;
  final String date;
  final String image;
  final String details;
  final String status;
  final Function() deleteSelf;
  const ComplaintCard(
      {super.key,
      required this.id,
      required this.title,
      required this.type,
      required this.date,
      required this.details,
      required this.image,
      required this.status,
      required this.deleteSelf});

  @override
  State<ComplaintCard> createState() => _ComplaintCardState();
}

class _ComplaintCardState extends State<ComplaintCard> {
  late String csrftoken;
  late String cookie;

  @override
  void initState() {
    SharedPreferences.getInstance().then((data) {
      String? value = data.getString('MyCookie');
      cookie = value.toString();
      csrftoken =
          cookie.substring(cookie.indexOf('csrf') + 10, cookie.indexOf(';'));
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 1, bottom: 1),
      height: 90,
      child: Row(
        children: [
          Expanded(
              flex: 5,
              child: InkWell(
                onTap: () {
                  showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return Dialog(
                          child: Container(
                            decoration: const BoxDecoration(
                              color: Colors.white,
                            ),
                            padding: const EdgeInsets.fromLTRB(10, 20, 10, 20),
                            alignment: Alignment.center,
                            height: 600,
                            child: Column(
                              children: [
                                Expanded(
                                  flex: 1,
                                  child: Text(
                                    widget.title,
                                    style: GoogleFonts.rubik(
                                        textStyle: const TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.w600)),
                                  ),
                                ),
                                Container(
                                  decoration: const BoxDecoration(boxShadow: [
                                    BoxShadow(color: Colors.grey, blurRadius: 6)
                                  ]),
                                  height: MediaQuery.of(context).size.width / 4,
                                  width: MediaQuery.of(context).size.width / 4,
                                  child: FittedBox(
                                      fit: BoxFit.cover,
                                      clipBehavior: Clip.hardEdge,
                                      child: (widget.image.isNotEmpty)
                                          ? Image.network(host + widget.image)
                                          : Image.asset(
                                              "assets/images/complaint_image.jpg")),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: Container(
                                    alignment: Alignment.center,
                                    child: Text(
                                      '${widget.type}: ${widget.date}',
                                      style: GoogleFonts.rubik(
                                          textStyle: const TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w400)),
                                    ),
                                  ),
                                ),
                                Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                        border: Border.all(
                                            width: 1, color: Colors.black87),
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                    child: Text(
                                      widget.details,
                                      maxLines: 10,
                                      textAlign: TextAlign.justify,
                                      overflow: TextOverflow.fade,
                                      style: const TextStyle(
                                          fontSize: 15, color: Colors.black87),
                                    )),
                                Expanded(
                                  flex: 5,
                                  child: Container(
                                    alignment: Alignment.center,
                                    child: Text(
                                      widget.status,
                                      style: GoogleFonts.rubik(
                                          textStyle: const TextStyle(
                                              fontSize: 25,
                                              fontWeight: FontWeight.w600),
                                          color: (widget.status == 'Pending')
                                              ? Colors.blue
                                              : Colors.green),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        );
                      });
                },
                child: Container(
                  color: Colors.white,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 30, top: 20),
                        child: Text(
                          widget.title,
                          style: GoogleFonts.rubik(
                              textStyle: const TextStyle(fontSize: 16)),
                        ),
                      ),
                      Row(
                        children: [
                          Expanded(child: Container()),
                          Padding(
                            padding: const EdgeInsets.only(
                                right: 30, top: 20, bottom: 15),
                            child: Text('${widget.type}: ${widget.date}',
                                style: GoogleFonts.rubik(
                                    textStyle: const TextStyle(fontSize: 12))),
                          )
                        ],
                      )
                    ],
                  ),
                ),
              )),
          Expanded(
              flex: 1,
              child: Container(
                height: 90,
                color: Colors.red,
                child: InkWell(
                  onTap: widget.deleteSelf,
                  child: const Icon(
                    Icons.delete,
                    color: Colors.white,
                  ),
                ),
              ))
        ],
      ),
    );
  }
}
