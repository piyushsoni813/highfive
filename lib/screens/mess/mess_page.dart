import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pinput/pinput.dart';
import 'dart:io';
import 'dart:convert';
import 'package:highfive/screens/api.dart';
import 'package:http/http.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:highfive/screens/mess/mess_graphs.dart';

class Meal {
  final DateTime date;
  String? breakfast;
  String? lunch;
  String? snacks;
  String? dinner;

  Meal(
      {required this.date,
      this.breakfast,
      this.lunch,
      this.snacks,
      this.dinner});

  factory Meal.fromJson(Map<String, dynamic> json) {
    int year = int.parse(json['date'].toString().substring(0, 4));
    int month = int.parse(json['date'].toString().substring(5, 7));
    int day = int.parse(json['date'].toString().substring(8, 10));
    return Meal(
        date: DateTime(year, month, day),
        breakfast: json['breakfast'],
        lunch: json['lunch'],
        snacks: json['snacks'],
        dinner: json['dinner']);
  }
}

late String csrftoken;
late String cookie;

class MessPage extends StatefulWidget {
  const MessPage({super.key});

  @override
  State<MessPage> createState() => _MessPageState();
}

class _MessPageState extends State<MessPage> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 2,
        child: Column(
          children: [
            Container(
                color: Colors.blue.shade100,
                height: 60,
                child: TabBar(
                    indicatorColor: Colors.blue,
                    labelColor: Colors.black,
                    unselectedLabelColor: Colors.grey.shade700,
                    indicatorSize: TabBarIndicatorSize.label,
                    tabs: [
                      Tab(
                        child: Text(
                          "Meals",
                          style: GoogleFonts.lato(
                              textStyle: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          )),
                        ),
                      ),
                      Tab(
                        child: Text(
                          "My history",
                          style: GoogleFonts.lato(
                              textStyle: const TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.w600)),
                        ),
                      )
                    ])),
            const Expanded(
              child: TabBarView(
                children: [TakeMealPage(), MyHistoryPage()],
              ),
            )
          ],
        ));
  }
}

class TakeMealPage extends StatefulWidget {
  const TakeMealPage({super.key});

  @override
  State<TakeMealPage> createState() => _TakeMealPageState();
}

class _TakeMealPageState extends State<TakeMealPage> {
  final pinController = TextEditingController();
  final focusNode = FocusNode();
  final formKey = GlobalKey<FormState>();
  String? mealError;
  bool isEdit = false;
  String? mealType;
  bool? isVerified;
  bool plateTaken = false;
  int machineCount = 0;
  String? weight;
  String? machineID;

  // final dio = Dio();

  late String csrftoken;
  late String cookie;

  Future<Response> messState() {
    return get(Uri.parse(apiMess), headers: <String, String>{
      HttpHeaders.contentTypeHeader: 'application/json; charset=UTF-8',
      HttpHeaders.cookieHeader: cookie,
      'X-CSRFToken': csrftoken
    });
  }

  Future<Response> pinSubmit({required String id, required String pin}) {
    return post(
      Uri.parse(apiCheckPin),
      headers: <String, String>{
        HttpHeaders.contentTypeHeader: 'application/json; charset=UTF-8',
        HttpHeaders.cookieHeader: cookie,
        'Referer': 'https://hostel5.online',
        'X-CSRFToken': csrftoken
      },
      body: jsonEncode(<String, String>{'id': id, 'pin': pin}),
    );
  }

  void getID(String? id) {
    setState(() {
      machineID = id;
    });
  }

  @override
  void initState() {
    SharedPreferences.getInstance().then((data) {
      String? value = data.getString('MyCookie');
      cookie = value.toString();
      csrftoken =
          cookie.substring(cookie.indexOf('csrf') + 10, cookie.indexOf(';'));
      messState().then((value) {
        if (kDebugMode) {
          print(value.statusCode);
        }
        if (value.statusCode == 200) {
          var state = jsonDecode(value.body);
          if (mounted) {
            setState(() {
              isVerified = state['isVerified'];
              plateTaken = state['plateTaken'];
              mealType = state['mealType'];
              weight = state['weight'];
              machineCount = state['count'];
            });
          }
        }
      });
    });

    super.initState();
  }

  @override
  void dispose() {
    pinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const focusedBorderColor = Color.fromRGBO(23, 171, 144, 1);
    const fillColor = Color.fromRGBO(243, 246, 249, 0);
    const borderColor = Color.fromRGBO(89, 89, 89, 0.4);

    final defaultPinTheme = PinTheme(
      width: 40,
      height: 40,
      textStyle: const TextStyle(
        fontSize: 20,
        color: Color.fromRGBO(30, 60, 87, 1),
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: borderColor),
      ),
    );
    return (isVerified != null)
        ? ((isVerified!)
            ? SingleChildScrollView(
                child: Column(
                  children: [
                    Container(
                      color: Colors.white,
                      width: MediaQuery.of(context).size.width,
                      child: Column(
                        children: [
                          const SizedBox(
                            height: 20,
                          ),
                          (mealType != null)
                              ? (weight != null)
                                  ? Container(
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(5),
                                          border: Border.all(
                                              color: Colors.grey.shade800)),
                                      width: MediaQuery.of(context).size.width /
                                          1.1,
                                      height: 100,
                                      child: FittedBox(
                                          fit: BoxFit.none,
                                          child: Text(
                                            "Already Weighed: $weight grams",
                                            style: GoogleFonts.roboto(
                                                textStyle: const TextStyle(
                                                    fontSize: 20)),
                                          )))
                                  : Container(
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        border: Border.all(
                                            width: 0.5,
                                            color: Colors.grey.shade500),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      margin: const EdgeInsets.all(20),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          const SizedBox(
                                            height: 10,
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            children: [
                                              Text(
                                                !plateTaken
                                                    ? 'Take Your ${mealType ?? 'Meal!'}'
                                                    : 'Weigh Your ${mealType ?? 'Meal'}!',
                                                style:
                                                    GoogleFonts.inter(
                                                        textStyle:
                                                            const TextStyle(
                                                                fontSize: 20,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600)),
                                              ),
                                              IconButton(
                                                onPressed: () {
                                                  showDialog(
                                                    context: context,
                                                    builder: (BuildContext
                                                            context) =>
                                                        AlertDialog(
                                                            shape: const RoundedRectangleBorder(
                                                                borderRadius: BorderRadius
                                                                    .all(Radius
                                                                        .circular(
                                                                            15))),
                                                            content: Text(
                                                              "Enter the PIN shown on the machine.",
                                                              style: GoogleFonts
                                                                  .roboto(
                                                                      fontSize:
                                                                          15),
                                                            ),
                                                            actions: [
                                                          TextButton(
                                                            onPressed: () {
                                                              Navigator.pop(
                                                                  context);
                                                            },
                                                            child: const Text(
                                                              "Close",
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .blue),
                                                            ),
                                                          )
                                                        ]),
                                                  );
                                                },
                                                icon: Icon(
                                                  Icons.help_outline_rounded,
                                                  color: Colors.blue.shade600,
                                                  size: 20,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(
                                            height: 15,
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              MyDropDown(
                                                  elements: List<
                                                          String>.generate(
                                                      machineCount,
                                                      (index) => plateTaken
                                                          ? ('W${(index + 1).toString()}')
                                                          : ('L${(index + 1).toString()}')),
                                                  hint: 'ID',
                                                  changed: getID),
                                              const SizedBox(
                                                width: 20,
                                              ),
                                              Pinput(
                                                enabled: (machineID != null),
                                                controller: pinController,
                                                focusNode: focusNode,
                                                defaultPinTheme:
                                                    defaultPinTheme,
                                                onCompleted: (pin) {
                                                  pinSubmit(
                                                    id: machineID!,
                                                    pin: pin,
                                                  ).then((value) {
                                                    if (value.statusCode ==
                                                        401) {
                                                      setState(() {
                                                        mealError =
                                                            'Incorrect Pin!';
                                                      });
                                                    } else if (value
                                                            .statusCode ==
                                                        201) {
                                                      var state = jsonDecode(
                                                          value.body);

                                                      setState(() {
                                                        pinController.text = '';
                                                        machineID = null;
                                                        isVerified =
                                                            state['isVerified'];
                                                        plateTaken =
                                                            state['plateTaken'];
                                                        mealType =
                                                            state['mealType'];
                                                        weight =
                                                            state['weight'];
                                                        machineCount =
                                                            state['count'];
                                                      });
                                                    }
                                                  });
                                                },
                                                onChanged: (value) {
                                                  debugPrint(
                                                      'onChanged: $value');
                                                  setState(() {
                                                    mealError = null;
                                                  });
                                                },
                                                cursor: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.end,
                                                  children: [
                                                    Container(
                                                      margin:
                                                          const EdgeInsets.only(
                                                              bottom: 8),
                                                      width: 22,
                                                      height: 1,
                                                      color:
                                                          const Color.fromRGBO(
                                                              23, 171, 144, 1),
                                                    ),
                                                  ],
                                                ),
                                                focusedPinTheme:
                                                    defaultPinTheme.copyWith(
                                                  decoration: defaultPinTheme
                                                      .decoration!
                                                      .copyWith(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            7),
                                                    border: Border.all(
                                                        color:
                                                            focusedBorderColor,
                                                        width: 2),
                                                  ),
                                                ),
                                                submittedPinTheme:
                                                    defaultPinTheme.copyWith(
                                                  decoration: defaultPinTheme
                                                      .decoration!
                                                      .copyWith(
                                                    color: fillColor,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                    border: Border.all(
                                                        color:
                                                            focusedBorderColor),
                                                  ),
                                                ),
                                                disabledPinTheme:
                                                    defaultPinTheme.copyWith(
                                                  decoration: defaultPinTheme
                                                      .decoration!
                                                      .copyWith(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            7),
                                                    border: Border.all(
                                                        color: Colors.grey,
                                                        width: 1),
                                                  ),
                                                ),
                                                errorPinTheme: defaultPinTheme
                                                    .copyBorderWith(
                                                  border: Border.all(
                                                      color: Colors.redAccent),
                                                ),
                                              ),
                                            ],
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(15.0),
                                            child: Text(
                                              mealError ?? '',
                                              style: GoogleFonts.notoSans(
                                                  textStyle: const TextStyle(
                                                      fontSize: 15,
                                                      color: Colors.red,
                                                      fontWeight:
                                                          FontWeight.w500)),
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                              : Text(
                                  'No Meals Available Now!',
                                  style: GoogleFonts.notoSans(
                                      textStyle: const TextStyle(
                                          fontSize: 15,
                                          color: Colors.red,
                                          fontWeight: FontWeight.w500)),
                                ),
                        ],
                      ),
                    ),
                    const Divider(),
                    const SizedBox(height: 800, child: TotalGraph())
                  ],
                ),
              )
            : Center(
                child: Text(
                  "You have not linked your ID card",
                  style: GoogleFonts.lato(
                      fontSize: 20, fontWeight: FontWeight.w600),
                ),
              ))
        : const Center(
            child: CircularProgressIndicator(
              color: Colors.lightBlue,
            ),
          );
  }
}

class MyHistoryPage extends StatefulWidget {
  const MyHistoryPage({super.key});

  @override
  State<MyHistoryPage> createState() => _MyHistoryPageState();
}

class _MyHistoryPageState extends State<MyHistoryPage> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  List<Meal>? monthMeals;
  bool pageChanged = false;
  Meal meal = Meal(date: DateTime.now());

  Future<List<Meal>> getPosts(DateTime date) async {
    final response = await get(
      Uri.parse(apiMessMonthHistory),
      headers: <String, String>{
        HttpHeaders.contentTypeHeader: 'application/json; charset=UTF-8',
        HttpHeaders.cookieHeader: cookie,
        'X-CSRFToken': csrftoken,
        'date': date.toString()
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Something went wrong. Try again later');
    }

    final json = jsonDecode(response.body) as List<dynamic>;
    final meals = json.map(
      (each) => Meal.fromJson(
        Map<String, dynamic>.from(each as Map<String, dynamic>),
      ),
    );

    return meals.toList();
  }

  void getMeal(DateTime day) {
    if (monthMeals != null) {
      meal = monthMeals!.firstWhere((element) => element.date == day,
          orElse: () => Meal(date: day));
    }
  }

  void imageBottomSheet(BuildContext context) {
    showModalBottomSheet(
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
        context: context,
        builder: (BuildContext context) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo),
                title: const Text("Gallery"),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera),
                title: const Text("Camera"),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
            ],
          );
        });
  }

  @override
  void initState() {
    monthMeals = [];
    SharedPreferences.getInstance().then((data) {
      String? value = data.getString('MyCookie');
      cookie = value.toString();
      csrftoken =
          cookie.substring(cookie.indexOf('csrf') + 10, cookie.indexOf(';'));
      getPosts(DateTime.now()).then((value) {
        DateTime today = DateTime.now();
        int year = today.year;
        int month = today.month;
        int day = today.day;
        monthMeals = value;
        getMeal(DateTime(year, month, day));
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const SizedBox(
            height: 20,
          ),
          TableCalendar(
            firstDay: DateTime(2023),
            lastDay: DateTime(2024, DateTime.now().month),
            focusedDay: _focusedDay,
            calendarFormat: _calendarFormat,
            selectedDayPredicate: (day) {
              return isSameDay(_selectedDay, day);
            },
            onDaySelected: (selectedDay, focusedDay) {
              if (pageChanged) {
                getPosts(selectedDay).then((value) {
                  monthMeals = value;

                  pageChanged = false;
                });
              }
              setState(() {
                getMeal(DateTime(
                    selectedDay.year, selectedDay.month, selectedDay.day));
              });
              if (!isSameDay(_selectedDay, selectedDay)) {
                // Call `setState()` when updating the selected day
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
              }
            },
            onFormatChanged: (format) {
              if (_calendarFormat != format) {
                // Call `setState()` when updating calendar format
                setState(() {
                  _calendarFormat = format;
                });
              }
            },
            onPageChanged: (focusedDay) {
              pageChanged = true;
            },
            headerStyle: HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
              titleTextStyle: GoogleFonts.hind(
                  textStyle: TextStyle(
                      fontSize: 23,
                      color: Colors.grey.shade800,
                      fontWeight: FontWeight.w600)),
              leftChevronIcon: Icon(
                Icons.arrow_back_ios,
                color: Colors.grey.shade600,
                size: 20,
              ),
              rightChevronIcon: Icon(
                Icons.arrow_forward_ios_rounded,
                color: Colors.grey.shade600,
                size: 20,
              ),
            ),
            rowHeight: 45,
            daysOfWeekStyle: const DaysOfWeekStyle(
                weekdayStyle: TextStyle(color: Colors.red)),
            calendarStyle: const CalendarStyle(
                cellMargin: EdgeInsets.all(7),
                weekendTextStyle: TextStyle(color: Colors.red, fontSize: 15),
                defaultTextStyle: TextStyle(fontSize: 15)),
            availableGestures: AvailableGestures.all,
          ),
          const SizedBox(
            height: 20,
          ),
          const Divider(
            color: Colors.black,
          ),
          Row(
            children: [
              const SizedBox(
                width: 100,
              ),
              Text('Breakfast:',
                  style: GoogleFonts.hind(
                      textStyle: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold))),
              const SizedBox(
                width: 50,
              ),
              Text(meal.breakfast ?? 'Not taken',
                  style: GoogleFonts.hind(
                      textStyle: TextStyle(
                          fontSize: 20,
                          color: Colors.grey.shade800,
                          fontWeight: FontWeight.w600))),
            ],
          ),
          const Divider(
            color: Colors.black,
          ),
          Row(
            children: [
              const SizedBox(
                width: 100,
              ),
              Text('Lunch:',
                  style: GoogleFonts.hind(
                      textStyle: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold))),
              const SizedBox(
                width: 50,
              ),
              Text(meal.lunch ?? 'Not taken',
                  style: GoogleFonts.hind(
                      textStyle: TextStyle(
                          fontSize: 20,
                          color: Colors.grey.shade800,
                          fontWeight: FontWeight.w600))),
            ],
          ),
          const Divider(
            color: Colors.black,
          ),
          Row(
            children: [
              const SizedBox(
                width: 100,
              ),
              Text('Snacks:',
                  style: GoogleFonts.hind(
                      textStyle: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold))),
              const SizedBox(
                width: 50,
              ),
              Text(meal.snacks ?? 'Not taken',
                  style: GoogleFonts.hind(
                      textStyle: TextStyle(
                          fontSize: 20,
                          color: Colors.grey.shade800,
                          fontWeight: FontWeight.w600))),
            ],
          ),
          const Divider(
            color: Colors.black,
          ),
          Row(
            children: [
              const SizedBox(
                width: 100,
              ),
              Text('Dinner:',
                  style: GoogleFonts.hind(
                      textStyle: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold))),
              const SizedBox(
                width: 50,
              ),
              Text(meal.dinner ?? 'Not taken',
                  style: GoogleFonts.hind(
                      textStyle: TextStyle(
                          fontSize: 20,
                          color: Colors.grey.shade800,
                          fontWeight: FontWeight.w600))),
            ],
          ),
          const Divider(
            color: Colors.black,
          ),
        ],
      ),
    );
  }
}

class MyDropDown extends StatefulWidget {
  final List<String> elements;
  final String hint;
  final Function(String) changed;

  const MyDropDown(
      {super.key,
      required this.elements,
      required this.hint,
      required this.changed});

  @override
  State<MyDropDown> createState() => _MyDropDownState();
}

class _MyDropDownState extends State<MyDropDown> {
  String? selectedValue;
  List<String> items = [];

  @override
  Widget build(BuildContext context) {
    if (!listEquals(items, widget.elements)) {
      setState(() {
        items = widget.elements;
        selectedValue = null;
      });
    }
    return Container(
      color: Colors.white,
      child: Center(
        child: DropdownButtonHideUnderline(
          child: DropdownButton2(
            isExpanded: true,
            hint: const Row(
              children: [
                Expanded(
                  child: Text(
                    'ID',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            items: items
                .map((item) => DropdownMenuItem<String>(
                      value: item,
                      child: Text(
                        item,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
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
              height: 40,
              width: 70,
              padding: const EdgeInsets.only(left: 10, right: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                    color: (selectedValue == null)
                        ? Colors.red
                        : const Color.fromRGBO(23, 171, 144, 1),
                    width: 1),
                color: Colors.white,
              ),
              elevation: 0,
            ),
            iconStyleData: const IconStyleData(
              icon: Icon(
                Icons.arrow_drop_down_rounded,
              ),
              iconSize: 20,
              iconEnabledColor: Colors.black87,
              iconDisabledColor: Colors.black45,
            ),
            dropdownStyleData: DropdownStyleData(
                maxHeight: 200,
                width: 60,
                padding: null,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(width: 1, color: Colors.black54),
                  color: Colors.white,
                ),
                elevation: 5,
                offset: const Offset(0, 0),
                scrollbarTheme: ScrollbarThemeData(
                  thumbColor: MaterialStateProperty.all(Colors.black54),
                  radius: const Radius.circular(40),
                  thickness: MaterialStateProperty.all(6),
                  thumbVisibility: MaterialStateProperty.all(true),
                )),
            menuItemStyleData: const MenuItemStyleData(
              height: 40,
              padding: EdgeInsets.only(left: 13, right: 13),
            ),
          ),
        ),
      ),
    );
  }
}
