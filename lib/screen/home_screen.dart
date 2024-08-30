import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:check_bike/config/color.dart';
import 'package:check_bike/main.dart';
import 'package:check_bike/screen/stats_screen.dart';
import 'package:check_bike/screen/timer_screen.dart';
import 'package:check_bike/widget/card_widget.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _exerciseCount = 0; // 운동 횟수
  Duration _totalDuration = Duration.zero; // 총 운동 시간
  int _consecutiveDays = 0; // 연속 운동일 수
  bool _isExerciseOngoing = false; // 운동 진행 중 여부
  int _achievedGoalsCount = 0; // 목표 달성 횟수

  @override
  void initState() {
    super.initState();
    _checkOngoingExercise();
    FirebaseFirestore.instance
        .collection('exercises')
        .snapshots()
        .listen((snapshot) {
      _processSnapshot(snapshot);
    });
  }

  // 진행 중인 운동이 있는지 확인하는 메서드
  Future<void> _checkOngoingExercise() async {
    final prefs = await SharedPreferences.getInstance();
    final savedStartTime = prefs.getString('saved_start_time');
    setState(() {
      _isExerciseOngoing = savedStartTime != null;
    });
  }

  // Firestore에서 가져온 데이터를 처리하는 메서드
  void _processSnapshot(QuerySnapshot snapshot) {
    int count = 0;
    int achievedGoals = 0;
    Duration totalDuration = Duration.zero;
    Set<DateTime> exerciseDates = {};
    bool isOngoing = false;

    for (var doc in snapshot.docs) {
      var data = doc.data() as Map<String, dynamic>;
      String durationString =
          data['duration'] ?? '0초';
      Duration duration = _parseDuration(durationString);

      count++;
      totalDuration += duration;

      String startTimeString = data['start_time'] ?? '';
      DateTime startTime;

      try {
        startTime = DateFormat('yyyy년 M월 d일 H시 m분').parse(startTimeString);
      } catch (e) {
        startTime = DateTime.now();
        print('Error parsing date: $startTimeString');
      }

      exerciseDates.add(DateTime(startTime.year, startTime.month, startTime.day));

      if (data['end_time'] == null) {
        isOngoing = true;
      }

      if (data['is_goal_achieved'] == true) {
        achievedGoals++;
      }
    }

    List<DateTime> sortedDates = exerciseDates.toList()..sort();

    int consecutiveDays = 1;

    for (int i = sortedDates.length - 2; i >= 0; i--) {
      DateTime currentDate = sortedDates[i];
      DateTime nextDate = sortedDates[i + 1];

      if (currentDate.add(Duration(days: 1)).isAtSameMomentAs(nextDate)) {
        consecutiveDays++;
      } else {
        break;
      }
    }

    setState(() {
      _exerciseCount = count;
      _totalDuration = totalDuration;
      _isExerciseOngoing = isOngoing;
      _achievedGoalsCount = achievedGoals;
      _consecutiveDays = consecutiveDays;
    });
  }

  // 문자열을 Duration으로 변환하는 메서드
  Duration _parseDuration(String durationString) {
    final hoursRegex = RegExp(r'(\d+)시간');
    final minutesRegex = RegExp(r'(\d+)분');
    final secondsRegex = RegExp(r'(\d+)초');

    final hours = hoursRegex.firstMatch(durationString)?.group(1) ?? '0';
    final minutes = minutesRegex.firstMatch(durationString)?.group(1) ?? '0';
    final seconds = secondsRegex.firstMatch(durationString)?.group(1) ?? '0';

    return Duration(
      hours: int.parse(hours),
      minutes: int.parse(minutes),
      seconds: int.parse(seconds),
    );
  }

  void _navigateToTimerPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TimerPage(),
      ),
    ).then((_) => _checkOngoingExercise());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CheckBikeColor.background,
      appBar: AppBar(
        scrolledUnderElevation: 0,
        backgroundColor: CheckBikeColor.background,
        title: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Text(
            "ExerCheck",
            style: TextStyle(
              color: CheckBikeColor.darkgrey,
              fontSize: 25 * ratio.height,
              fontWeight: FontWeight.bold,
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
        centerTitle: false,
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: GestureDetector(
              onTap: () {
                // 설정 페이지로 이동
              },
              child: Image.asset(
                "assets/img/settings.png",
                color: CheckBikeColor.darkgrey,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Container(
          color: CheckBikeColor.background,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  child: Center(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(height: ratio.height * 35),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Container(
                              height: ratio.height * 100,
                              child: DefaultTextStyle(
                                style: TextStyle(
                                  fontFamily: "Pretendard",
                                  fontSize: ratio.height * 35,
                                  color: CheckBikeColor.mainBlue,
                                  fontWeight: FontWeight.bold
                                ),
                                child: AnimatedTextKit(
                                  repeatForever: true,
                                  pause: Duration(milliseconds: 500),
                                  animatedTexts: [
                                    ColorizeAnimatedText(
                                      '오늘도 운동을\n시작해볼까요?',
                                      textStyle: TextStyle(
                                          fontSize: ratio.height * 35
                                      ),
                                      colors: [CheckBikeColor.mainBlue, CheckBikeColor.subBlue2, CheckBikeColor.mainBlue],
                                      speed: Duration(milliseconds: 200),
                                    ),
                                  ],
                                  onTap: () {
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: ratio.height * 45),
                        GestureDetector(
                          onTap: () {
                            _navigateToTimerPage();
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
                                    _isExerciseOngoing ? "운동 종료" : "운동 시작",
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
                        SizedBox(height: ratio.height * 70),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "내 운동 현황은?",
                        style: TextStyle(
                          fontSize: ratio.height * 20,
                          fontWeight: FontWeight.bold,
                          color: CheckBikeColor.darkgrey,
                        ),
                      ),
                      SizedBox(height: ratio.height * 10),
                      Container(
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
                            )
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 20, horizontal: 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text.rich(
                                TextSpan(
                                  children: [
                                    WidgetSpan(
                                      child: Icon(Icons.info_outlined,
                                          color: CheckBikeColor.mainBlue,
                                          size: 20),
                                    ),
                                    TextSpan(
                                        text: ' 운동 횟수\n',
                                        style: TextStyle(
                                            fontSize: ratio.height * 16,
                                            fontWeight: FontWeight.bold,
                                            color: CheckBikeColor.grey3)),
                                    WidgetSpan(
                                      child: SizedBox(
                                        height: ratio.height * 40,
                                      ),
                                    ),
                                    TextSpan(
                                        text: '운동을 총',
                                        style: TextStyle(
                                            fontSize: ratio.height * 23,
                                            fontWeight: FontWeight.bold,
                                            color: CheckBikeColor.grey3)),
                                    TextSpan(
                                        text: ' ${_exerciseCount}번',
                                        style: TextStyle(
                                            fontSize: ratio.height * 23,
                                            fontWeight: FontWeight.bold,
                                            color: CheckBikeColor.mainBlue)),
                                    TextSpan(
                                        text: '\n목표를',
                                        style: TextStyle(
                                            fontSize: ratio.height * 23,
                                            fontWeight: FontWeight.bold,
                                            color: CheckBikeColor.grey3)),
                                    TextSpan(
                                        text: ' ${_achievedGoalsCount}번',
                                        style: TextStyle(
                                            fontSize: ratio.height * 23,
                                            fontWeight: FontWeight.bold,
                                            color: CheckBikeColor.mainBlue)),
                                    TextSpan(
                                        text: ' 달성했어요\n',
                                        style: TextStyle(
                                            fontSize: ratio.height * 23,
                                            fontWeight: FontWeight.bold,
                                            color: CheckBikeColor.grey3)),
                                  ],
                                ),
                              ),
                              _isExerciseOngoing
                                  ? Text(
                                      '현재 운동이 진행 중입니다!',
                                      style: TextStyle(
                                        fontSize: ratio.height * 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.red,
                                      ),
                                    )
                                  : Text(
                                      '운동을 아직 시작하지 않았어요!',
                                      style: TextStyle(
                                        fontSize: ratio.height * 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.green,
                                      ),
                                    ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: ratio.height * 15),
                      BuildCard(
                        title: '총 운동 시간',
                        value: _formatDuration(_totalDuration),
                        content: '동안 했어요',
                      ),
                      SizedBox(height: ratio.height * 15),
                      BuildCard(
                        title: '연속 일수',
                        value: '$_consecutiveDays일',
                        content: '연속 운동중이에요',
                      ),
                      SizedBox(height: ratio.height * 15),
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
                      SizedBox(height: ratio.height * 20)
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      if (minutes > 0) {
        return "${hours}시간 ${minutes}분 ${seconds}초";
      } else {
        return "${hours}시간 ${seconds}초";
      }
    } else if (minutes > 0) {
      return "${minutes}분 ${seconds}초";
    } else {
      return "${seconds}초";
    }
  }
}
