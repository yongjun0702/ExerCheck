import 'dart:async';
import 'package:check_bike/main.dart';
import 'package:check_bike/widget/custom_button_widget.dart';
import 'package:check_bike/widget/custom_dialog_widget.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:check_bike/config/color.dart';

class TimerPage extends StatefulWidget {
  final DateTime? startTime;

  const TimerPage({this.startTime, Key? key}) : super(key: key);

  @override
  State<TimerPage> createState() => _TimerPageState();
}

class _TimerPageState extends State<TimerPage> {
  DateTime? _startTime;
  DateTime? _endTime;
  Timer? _timer;
  Duration _elapsedTime = Duration.zero;
  bool _isRunning = false;
  bool _isLoading = false; // 로딩 상태 변수
  int _goalMinutes = 10;
  bool _goalSet = false;
  double _progress = 0.0;
  String? _exerciseId;

  final FlutterLocalNotificationsPlugin _local = FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    _initializeTimer();
  }

  Future<void> _initializeTimer() async {
    final prefs = await SharedPreferences.getInstance();
    final savedStartTime = prefs.getString('saved_start_time');
    final savedElapsedTime = prefs.getInt('saved_elapsed_time');
    final savedGoalMinutes = prefs.getInt('saved_goal_minutes');
    final savedExerciseId = prefs.getString('saved_exercise_id');

    if (savedGoalMinutes != null) {
      _goalMinutes = savedGoalMinutes;
      _goalSet = true;
    }

    if (savedStartTime != null) {
      _startTime = DateTime.parse(savedStartTime);
      if (savedElapsedTime != null) {
        _elapsedTime = Duration(milliseconds: savedElapsedTime);
      }
      _exerciseId = savedExerciseId;
      _isRunning = true;
      _startTimer();
    } else if (widget.startTime != null) {
      _startTime = widget.startTime!;
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _startTimer() async {
    if (_startTime == null) {
      _startTime = DateTime.now();
    }

    if (_exerciseId == null) {
      _exerciseId =
          (await FirebaseFirestore.instance.collection('exercises').add({
        'start_time': _formatDateTime(_startTime!),
      }))
              .id;
      final prefs = await SharedPreferences.getInstance();
      prefs.setString('saved_exercise_id', _exerciseId!);
      _isRunning = true;
    }

    final prefs = await SharedPreferences.getInstance();
    prefs.setString('saved_start_time', _startTime!.toIso8601String());
    prefs.setInt('saved_goal_minutes', _goalMinutes);

    _elapsedTime = Duration.zero;

    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          final now = DateTime.now();
          _elapsedTime = now.difference(_startTime!);
          _progress = _elapsedTime.inSeconds / (_goalMinutes * 60);
          if (_progress >= 1.0) {
            _progress = 1.0;
          _sendNotification();
          }
        });
        _saveElapsedTime();
      } else {
        _timer?.cancel();
      }
    });
  }

  Future<void> _stopExercise() async {
    _timer?.cancel();
    _isRunning = false;
    _endTime = DateTime.now();
    _elapsedTime = _endTime!.difference(_startTime!);

    String formattedEndTime = _formatDateTime(_endTime!);
    String formattedDuration = _formatDuration(_elapsedTime);

    bool isGoalAchieved = _elapsedTime >= Duration(minutes: _goalMinutes);

    await FirebaseFirestore.instance
        .collection('exercises')
        .doc(_exerciseId)
        .update({
      'end_time': formattedEndTime,
      'duration': formattedDuration,
      'is_goal_achieved': isGoalAchieved,
    });

    final prefs = await SharedPreferences.getInstance();
    prefs.remove('saved_start_time');
    prefs.remove('saved_elapsed_time');
    prefs.remove('saved_goal_minutes');
    prefs.remove('saved_exercise_id');
    CustomDialog(
        context: context,
        title: "운동 종료",
        dialogContent: "운동이 종료되었습니다.",
        buttonText: "확인",
        buttonCount: 1,
        func: () {
          Navigator.pop(context);
          Navigator.pop(context);
        });
  }

  Future<void> _saveElapsedTime() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setInt('saved_elapsed_time', _elapsedTime.inMilliseconds);
  }

  Future<void> _handleStartExercise() async {
    setState(() {
      _isLoading = true; // 로딩 시작
    });

    await Future.delayed(Duration(seconds: 1)); // 1초 동안 로딩 표시

    // 로딩이 끝나면 운동 시작
    await _startTimer();

    setState(() {
      _isLoading = false; // 로딩 끝
    });
  }

  Future<void> _sendNotification() async {
    if (_isBackground()) {
      NotificationDetails details = const NotificationDetails(
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
        android: AndroidNotificationDetails(
          "show_test",
          "show_test",
          importance: Importance.max,
          priority: Priority.high,
        ),
      );
      await _local.show(
        0,
        "오늘도 목표를 달성했어요!",
        "목표를 달성해도 계속 진행할게요.",
        details,
        payload: "tyger://",
      );
    }
  }



  bool _isBackground() {
    return WidgetsBinding.instance.lifecycleState == AppLifecycleState.paused;
  }

  String _formatDateTime(DateTime dateTime) {
    return DateFormat('yyyy년 M월 d일 H시 m분').format(dateTime);
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return "${hours}시간 ${twoDigits(minutes)}분 ${twoDigits(seconds)}초";
    } else if (minutes > 0) {
      return "${minutes}분 ${twoDigits(seconds)}초";
    } else {
      return "${seconds}초";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CheckBikeColor.background,
      appBar: AppBar(
        title: Text("운동 타이머", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: CheckBikeColor.background,
        scrolledUnderElevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28.0, vertical: 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: ratio.height * 20),
            _isRunning
                ? Text(
                    "운동 기록이\n시작되었습니다!",
                    style: TextStyle(
                        fontSize: ratio.height * 30,
                        fontWeight: FontWeight.bold),
                  )
                : Text(
                    "목표를 설정하고\n운동을 시작해보세요!",
                    style: TextStyle(
                        fontSize: ratio.height * 30,
                        fontWeight: FontWeight.bold),
                  ),
            SizedBox(height: ratio.height * 20),
            DropdownButton<int>(
              value: _goalSet ? _goalMinutes : null,
              items: [10, 20, 30, 40, 50, 60].map((int value) {
                return DropdownMenuItem<int>(
                  value: value,
                  child: Text("$value분"),
                );
              }).toList(),
              onChanged: _isRunning
                  ? null
                  : (int? newValue) {
                      setState(() {
                        _goalMinutes = newValue!;
                        _goalSet = true;
                      });
                    },
              hint: Text("목표 설정"),
            ),
            SizedBox(height: ratio.height * 70),
            Padding(
              padding: const EdgeInsets.fromLTRB(28, 0, 28, 28),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        _isLoading
                            ? Container(
                          width: ratio.width * 45,
                          height: ratio.height * 45,
                          child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  CheckBikeColor.mainBlue),
                              strokeWidth: 5),
                        )
                            : Text(
                          _formatDuration(_elapsedTime),
                          style: TextStyle(
                              fontSize: ratio.height * 30,
                              color: CheckBikeColor.mainBlue,
                              fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: ratio.height * 30),
                        Container(
                          width: ratio.width * 270,
                          height: ratio.height * 270,
                          child: CircularProgressIndicator(
                            value: _progress,
                            backgroundColor: Colors.grey[300],
                            color: CheckBikeColor.mainBlue,
                            strokeWidth: 25,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: ratio.height * 90),
                    CustomButton(
                      width: 150,
                      height: 48,
                      text: _isRunning ? "운동 종료" : "운동 시작",
                      func: _goalSet
                          ? (_isRunning
                              ? _stopExercise
                              : _handleStartExercise) // 로딩과 운동 시작 처리
                          : null,
                      buttonCount: 1,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
