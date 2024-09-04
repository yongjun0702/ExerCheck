import 'package:check_bike/config/color.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ExerciseWidget extends StatelessWidget {
  List<DateTime> getRecent7Days() {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday % 7));
    return List.generate(7, (index) {
      return startOfWeek.add(Duration(days: index));
    });
  }

  String getWeekday(DateTime date) {
    // Korean weekday names
    final weekdayNames = ['일', '월', '화', '수', '목', '금', '토'];
    return weekdayNames[date.weekday % 7];
  }

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

  @override
  Widget build(BuildContext context) {
    final deviceWidth = MediaQuery.of(context).size.width;
    final itemWidth = deviceWidth / 7;
    final today = DateTime.now();

    return StreamBuilder<Map<DateTime, bool>>(
      stream: _exerciseDataStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error loading data'));
        }

        if (!snapshot.hasData) {
          return Center(child: Text('No data available'));
        }

        final exerciseData = snapshot.data!;
        final recent7Days = getRecent7Days();

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: recent7Days.map((date) {
              final isGoalAchieved = exerciseData[DateTime(date.year, date.month, date.day)] ?? false;
              final isToday = date.year == today.year && date.month == today.month && date.day == today.day;
              return Container(
                margin: EdgeInsets.symmetric(vertical: 20),
                width: itemWidth,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        width: itemWidth * 0.6,
                        height: itemWidth * 0.6,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isGoalAchieved ? CheckBikeColor.mainBlue : Colors.transparent,
                          border: Border.all(color: CheckBikeColor.mainBlue),
                        ),
                        child: isGoalAchieved
                            ? Center(child: Icon(Icons.check, color: Colors.white))
                            : null,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      getWeekday(date),
                      style: TextStyle(
                        fontSize: isToday ? 18 : 15,
                        color: isToday ? CheckBikeColor.mainBlue : CheckBikeColor.subBlue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }
}
