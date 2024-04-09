import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:io';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:highfive/screens/api.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class TotalGraph extends StatefulWidget {
  const TotalGraph({super.key});

  @override
  State<TotalGraph> createState() => _TotalGraphState();
}

class _TotalGraphState extends State<TotalGraph> {
  late String csrftoken;
  late String cookie;

  bool leftEnabled = false;
  bool rightEnabled = false;

  List<MonthData>? monthlyData;

  String mealTotalType = 'All';
  String mealAverageType = 'All';
  DateTime currentDate = DateTime.now();

  Future<DateTime?> getTimeline() async {
    final response = await get(
      Uri.parse(apiStatMonthInit),
      headers: <String, String>{
        HttpHeaders.contentTypeHeader: 'application/json; charset=UTF-8',
        HttpHeaders.cookieHeader: cookie,
        'X-CSRFToken': csrftoken,
      },
    );

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      int year = int.parse(data[0].toString().substring(0, 4));
      int month = int.parse(data[0].toString().substring(5, 7));
      return DateTime(year, month);
    } else {
      return null;
    }
  }

  Future<List<MonthData>> getStats(DateTime date) async {
    final response = await get(
      Uri.parse('$apiStats?month=${date.month}&year=${date.year}'),
      headers: <String, String>{
        HttpHeaders.contentTypeHeader: 'application/json; charset=UTF-8',
        HttpHeaders.cookieHeader: cookie,
        'X-CSRFToken': csrftoken,
        'date': date.toString()
      },
    );
    List<MonthData> stats = [];
    if ([200, 201, 202, 203].contains(response.statusCode)) {
      List data = jsonDecode(response.body)!;
      for (var each in data) {
        MonthData data = MonthData(
          date: DateTime(
              int.parse(each['date'].substring(0, 4)),
              int.parse(each['date'].substring(5, 7)),
              int.parse(each['date'].substring(8, 10))),
          breakfastSum: each['breakfast_sum'],
          lunchSum: each['lunch_sum'],
          snacksSum: each['snacks_sum'],
          dinnerSum: each['dinner_sum'],
          breakfastCount: each['breakfast_count'],
          lunchCount: each['lunch_count'],
          snacksCount: each['snacks_count'],
          dinnerCount: each['dinner_count'],
        );
        stats.add(data);
      }

      if (!mounted) return stats;

      switch (response.statusCode) {
        case 200:
          setState(() {
            leftEnabled = true;
            rightEnabled = true;
          });
          break;
        case 201:
          setState(() {
            leftEnabled = false;
            rightEnabled = false;
          });
          break;
        case 202:
          setState(() {
            leftEnabled = true;
            rightEnabled = false;
          });
          break;
        case 203:
          setState(() {
            leftEnabled = false;
            rightEnabled = true;
          });
          break;
        default:
      }
    }

    return stats;
  }

  void changeTotalType(String type) {
    setState(() {
      mealTotalType = type;
    });
  }

  void changeAverageType(String type) {
    setState(() {
      mealAverageType = type;
    });
  }

  void upMonth() {
    setState(() {
      currentDate =
          DateTime(currentDate.year, currentDate.month + 1, currentDate.day);
      monthlyData = null;
    });
    getStats(currentDate).then((value) {
      setState(() {
        monthlyData = value;
      });
    });
  }

  void downMonth() {
    setState(() {
      currentDate =
          DateTime(currentDate.year, currentDate.month - 1, currentDate.day);
      monthlyData = null;
    });
    getStats(currentDate).then((value) {
      setState(() {
        monthlyData = value;
      });
    });
  }

  @override
  void initState() {
    SharedPreferences.getInstance().then((data) {
      String? value = data.getString('MyCookie');
      cookie = value.toString();
      csrftoken =
          cookie.substring(cookie.indexOf('csrf') + 10, cookie.indexOf(';'));
      getTimeline().then((value) {
        getStats(value ?? currentDate).then((value) {
          if (mounted) {
            setState(() {
              monthlyData = value;
            });
          }
        });
      });
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: Center(
            child: Column(
          children: [
            SizedBox(
              height: 50,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  SizedBox(
                    child: IconButton(
                        disabledColor: Colors.white,
                        splashRadius: 30,
                        icon: Ink.image(
                            image: AssetImage((leftEnabled)
                                ? "assets/icons/left_arrow.png"
                                : "assets/icons/left_grey.png")),
                        iconSize: 30,
                        onPressed: leftEnabled ? downMonth : null),
                  ),
                  Text(
                    DateFormat.yMMMM().format(currentDate),
                    style: GoogleFonts.roboto(
                        fontSize: 20, fontWeight: FontWeight.w600),
                  ),
                  SizedBox(
                    child: IconButton(
                        splashRadius: 30,
                        icon: Ink.image(
                            image: AssetImage((rightEnabled)
                                ? "assets/icons/right_arrow.png"
                                : "assets/icons/right_grey.png")),
                        iconSize: 30,
                        onPressed: rightEnabled ? upMonth : null),
                  ),
                ],
              ),
            ),
            const Divider(),
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(30, 10, 10, 10),
                  child: Text(
                    "Total Waste",
                    style: GoogleFonts.rubik(
                        fontSize: 20,
                        color: Colors.black,
                        fontWeight: FontWeight.w500),
                  ),
                ),
                Expanded(
                  child: CustomDropDown(
                      items: const <String>[
                        'All',
                        'Breakfast',
                        'Lunch',
                        'Snacks',
                        'Dinner'
                      ],
                      hint: 'All',
                      changed: (value) {
                        changeTotalType(value);
                      }),
                )
              ],
            ),
            (monthlyData != null)
                ? SizedBox(
                    height: 300,
                    child: SfCartesianChart(
                        // Initialize category axis
                        primaryXAxis: const CategoryAxis(),
                        isTransposed: true,
                        series: <BarSeries<MonthData, int>>[
                          BarSeries<MonthData, int>(
                              dataSource: monthlyData!,
                              xValueMapper: (MonthData sales, _) {
                                return sales.date.day;
                              },
                              yValueMapper: (MonthData sales, _) {
                                switch (mealTotalType) {
                                  case 'All':
                                    return (sales.breakfastSum +
                                        sales.lunchSum +
                                        sales.snacksSum +
                                        sales.dinnerSum);
                                  case 'Breakfast':
                                    return sales.breakfastSum;
                                  case 'Lunch':
                                    return sales.lunchSum;
                                  case 'Snacks':
                                    return sales.snacksSum;
                                  case 'Dinner':
                                    return sales.dinnerSum;
                                  default:
                                    return 0;
                                }
                              },
                              spacing: 0.1,
                              width: monthlyData!.length * 0.02,
                              xAxisName: 'Date',
                              borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(20)))
                        ]),
                  )
                : Container(
                    alignment: Alignment.center,
                    height: 300,
                    color: Colors.white,
                    child: const CircularProgressIndicator()),
            const Divider(),
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(30, 10, 10, 10),
                  child: Text(
                    "Average Waste",
                    style: GoogleFonts.rubik(
                        fontSize: 20,
                        color: Colors.black,
                        fontWeight: FontWeight.w500),
                  ),
                ),
                Expanded(
                  child: CustomDropDown(
                      items: const <String>[
                        'All',
                        'Breakfast',
                        'Lunch',
                        'Snacks',
                        'Dinner'
                      ],
                      hint: 'All',
                      changed: (value) {
                        changeAverageType(value);
                      }),
                )
              ],
            ),
            (monthlyData != null)
                ? SizedBox(
                    height: 300,
                    child: SfCartesianChart(
                        // Initialize category axis
                        primaryXAxis: const CategoryAxis(),
                        isTransposed: true,
                        enableAxisAnimation: true,
                        series: <BarSeries<MonthData, int>>[
                          BarSeries<MonthData, int>(
                              dataSource: monthlyData!,
                              xValueMapper: (MonthData sales, _) {
                                return sales.date.day;
                              },
                              yValueMapper: (MonthData sales, _) {
                                switch (mealAverageType) {
                                  case 'All':
                                    return (sales.breakfastSum +
                                            sales.lunchSum +
                                            sales.snacksSum +
                                            sales.dinnerSum) /
                                        (sales.breakfastCount +
                                            sales.lunchCount +
                                            sales.snacksCount +
                                            sales.dinnerCount);
                                  case 'Breakfast':
                                    return sales.breakfastSum /
                                        sales.breakfastCount;
                                  case 'Lunch':
                                    return sales.lunchSum / sales.lunchCount;
                                  case 'Snacks':
                                    return sales.snacksSum / sales.snacksCount;
                                  case 'Dinner':
                                    return sales.dinnerSum / sales.dinnerCount;
                                  default:
                                    return 0;
                                }
                              },
                              spacing: 0.1,
                              width: monthlyData!.length * 0.02,
                              xAxisName: 'Date',
                              borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(20)))
                        ]),
                  )
                : Container(
                    alignment: Alignment.center,
                    height: 300,
                    color: Colors.white,
                    child: const CircularProgressIndicator()),
            const Divider(),
          ],
        )));
  }
}

class MonthData {
  final DateTime date;
  final int breakfastSum;
  final int lunchSum;
  final int snacksSum;
  final int dinnerSum;

  final int breakfastCount;
  final int lunchCount;
  final int snacksCount;
  final int dinnerCount;

  MonthData(
      {required this.date,
      required this.breakfastSum,
      required this.lunchSum,
      required this.snacksSum,
      required this.dinnerSum,
      required this.breakfastCount,
      required this.lunchCount,
      required this.snacksCount,
      required this.dinnerCount});
}

class CustomDropDown extends StatefulWidget {
  final List<String> items;
  final String hint;
  final Function(String) changed;

  const CustomDropDown(
      {super.key,
      required this.items,
      required this.hint,
      required this.changed});

  @override
  State<CustomDropDown> createState() => _CustomDropDownState();
}

class _CustomDropDownState extends State<CustomDropDown> {
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
                        color: Colors.black,
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
              width: MediaQuery.of(context).size.width / 3,
              padding: const EdgeInsets.only(left: 14, right: 14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(35),
                border: Border.all(color: Colors.black87, width: 1),
                color: Colors.white,
              ),
              elevation: 1,
            ),
            iconStyleData: const IconStyleData(
              icon: Icon(
                Icons.arrow_forward_ios_outlined,
              ),
              iconSize: 14,
              iconEnabledColor: Colors.black87,
              iconDisabledColor: Colors.grey,
            ),
            dropdownStyleData: DropdownStyleData(
                maxHeight: 200,
                width: 200,
                padding: null,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(width: 1, color: Colors.black87),
                  color: Colors.white,
                ),
                elevation: 8,
                offset: const Offset(0, 0),
                scrollbarTheme: ScrollbarThemeData(
                  thumbColor: MaterialStateProperty.all(Colors.black87),
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
