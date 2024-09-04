import 'package:check_bike/config/color.dart';
import 'package:check_bike/main.dart';
import 'package:check_bike/screen/stats_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CalendarScreen extends StatefulWidget {
  @override
  _CalendarScreenState createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  Map<DateTime, bool> _exerciseData = {};
  late DateTime _selectedDay;
  late DateTime _focusedDay;
  late DateFormat daysFormat;
  DateTime _firstDay = DateTime.utc(DateTime
      .now()
      .year, DateTime
      .now()
      .month - 2, 1);
  DateTime _lastDay = DateTime.now();
  String _selectedRange = '3개월';

  final Map<String, Duration> _dateRanges = {
    '1개월': Duration(days: 30),
    '3개월': Duration(days: 90),
    '6개월': Duration(days: 180),
    '1년': Duration(days: 365),
  };

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now();
    _focusedDay = DateTime.now();
    daysFormat = DateFormat.EEEE('ko'); // 요일 한글표현
  }

  // 실시간 데이터 스트림
  Stream<Map<DateTime, bool>> _exerciseDataStream() {
    return FirebaseFirestore.instance.collection('exercises').snapshots().map(
          (snapshot) {
        final data = <DateTime, bool>{};
        for (var doc in snapshot.docs) {
          final exerciseData = doc.data();
          final isGoalAchieved = exerciseData['is_goal_achieved'] as bool?;
          final startTimeString = exerciseData['start_time'] as String?;

          if (isGoalAchieved != null && startTimeString != null) {
            try {
              final startTime =
              DateFormat('yyyy년 M월 d일 H시 m분').parse(startTimeString);
              data[DateTime(startTime.year, startTime.month, startTime.day)] =
                  isGoalAchieved;
            } catch (e) {
              print("Error parsing date: $e");
            }
          }
        }
        return data;
      },
    );
  }

  void _updateCalendarRange(String selectedRange) {
    setState(() {
      _selectedRange = selectedRange;
      final now = DateTime.now();
      _firstDay = DateTime(now.year, now.month, now.day).subtract(
          _dateRanges[selectedRange]!);
      _lastDay = DateTime(now.year, now.month, now.day);
      _focusedDay = _lastDay;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CheckBikeColor.background,
      body: StreamBuilder<Map<DateTime, bool>>(
        stream: _exerciseDataStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error loading data'));
          }

          if (snapshot.hasData) {
            _exerciseData = snapshot.data!;
          }

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: ratio.height * 110),
                  Row(
                    children: [
                      Text(
                        "캘린더 범위 선택",
                        style: TextStyle(
                            fontSize: ratio.height * 20,
                            fontWeight: FontWeight.bold),
                      ),
                      SizedBox(width: ratio.width * 15),
                      DropdownButton<String>(
                        value: _selectedRange,
                        items: _dateRanges.keys.map((String key) {
                          return DropdownMenuItem<String>(
                            value: key,
                            child: Text(key),
                          );
                        }).toList(),
                        onChanged: (newValue) {
                          if (newValue != null) {
                            _updateCalendarRange(newValue);
                          }
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: ratio.height * 15),
                  Container(
                    width: double.infinity,
                    height: ratio.height * 480,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.3),
                          blurRadius: 8.0,
                          spreadRadius: 0.0,
                          offset: const Offset(0, 2),
                        )
                      ],
                    ),
                    child: TableCalendar(
                      locale: 'ko_KR',
                      firstDay: _firstDay,
                      lastDay: _lastDay,
                      focusedDay: _focusedDay,
                      rowHeight: ratio.height * 60,
                      calendarStyle: CalendarStyle(
                        cellMargin: EdgeInsets.symmetric(vertical: 18),
                        outsideDaysVisible: false,
                      ),
                      calendarBuilders: CalendarBuilders(
                        defaultBuilder: (context, day, focusedDay) {
                          final isGoalAchieved = _exerciseData[
                          DateTime(day.year, day.month, day.day)];
                          return Container(
                            margin: EdgeInsets.symmetric(vertical: 10),
                            child: Column(
                              children: [
                                Center(
                                  child: Text(
                                    '${day.day}',
                                    style:
                                    TextStyle(color: CheckBikeColor.grey3),
                                  ),
                                ),
                                Container(
                                    child: Center(
                                        child: isGoalAchieved != null
                                            ? isGoalAchieved == true
                                            ? Icon(Icons.check_circle,
                                            size: 20, color: Colors.green)
                                            : Icon(Icons.cancel,
                                            size: 20, color: Colors.red)
                                            : null)),
                              ],
                            ),
                          );
                        },
                        todayBuilder: (context, day, focusedDay) {
                          final isGoalAchieved = _exerciseData[
                          DateTime(day.year, day.month, day.day)];
                          return Container(
                            margin: EdgeInsets.only(top: 10),
                            decoration: BoxDecoration(
                                border:
                                Border.all(color: CheckBikeColor.mainBlue)),
                            child: Column(
                              children: [
                                Center(
                                  child: Text(
                                    '${day.day}',
                                    style:
                                    TextStyle(color: CheckBikeColor.grey3),
                                  ),
                                ),
                                Container(
                                    child: Center(
                                        child: isGoalAchieved != null
                                            ? isGoalAchieved == true
                                            ? Icon(Icons.check_circle,
                                            size: 20, color: Colors.green)
                                            : Icon(Icons.cancel,
                                            size: 20, color: Colors.red)
                                            : null)),
                              ],
                            ),
                          );
                        },
                        selectedBuilder: (context, day, focusedDay) {
                          return Container(
                            margin: EdgeInsets.symmetric(vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.transparent,
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                '${day.day}',
                                style: TextStyle(color: CheckBikeColor.grey3),
                              ),
                            ),
                          );
                        },
                        disabledBuilder: (context, day, focusedDay) {
                          final isGoalAchieved = _exerciseData[
                          DateTime(day.year, day.month, day.day)];
                          return Container(
                            margin: EdgeInsets.only(top: 10),
                            child: Column(
                              children: [
                                Center(
                                  child: Text(
                                    '${day.day}',
                                    style:
                                    TextStyle(color: CheckBikeColor.grey2),
                                  ),
                                ),
                                Container(
                                    child: Center(
                                        child: isGoalAchieved != null
                                            ? isGoalAchieved == true
                                            ? Icon(Icons.check_circle,
                                            size: 20, color: Colors.green)
                                            : Icon(Icons.cancel,
                                            size: 20, color: Colors.red)
                                            : null)),
                              ],
                            ),
                          );
                        },
                      ),
                      headerStyle: HeaderStyle(
                        titleTextFormatter: (date, locale) =>
                            DateFormat('yyyy년 M월').format(date),
                        formatButtonVisible: false,
                        titleCentered: true,
                      ),
                      daysOfWeekStyle: DaysOfWeekStyle(
                        dowTextFormatter: (date, locale) =>
                        DateFormat.E(locale).format(date)[0],
                        weekendStyle: TextStyle(
                            color: Colors.red, fontWeight: FontWeight.bold),
                        weekdayStyle: TextStyle(
                            color: Colors.black, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  SizedBox(height: ratio.height * 20),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => StatsScreen(),
                        ),
                      );
                    },
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.3),
                            blurRadius: 8.0,
                            spreadRadius: 0.0,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 20, horizontal: 20),
                        child: Row(
                          children: [
                            Text(
                              "기록 자세히 보기",
                              style: TextStyle(
                                fontSize: ratio.height * 20,
                                fontWeight: FontWeight.bold,
                                color: CheckBikeColor.mainBlue,
                              ),
                            ),
                            Spacer(),
                            Image.asset("assets/img/navigation.png"),
                          ],
                        ),

                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}