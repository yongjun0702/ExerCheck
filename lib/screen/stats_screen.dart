import 'package:check_bike/config/color.dart';
import 'package:check_bike/main.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({Key? key}) : super(key: key);

  @override
  _StatsScreenState createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  String _sortOrder = '최신순'; // 초기 정렬 순서

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CheckBikeColor.background,
      appBar: AppBar(
        title: Text("운동 기록 목록", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: CheckBikeColor.background,
        scrolledUnderElevation: 0,
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: DropdownButton<String>(
              value: _sortOrder,
              items: ['최신순', '오래된순'].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value,
                      style: TextStyle(color: CheckBikeColor.grey3)),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _sortOrder = newValue!;
                });
              },
            ),
          ),
          SizedBox(width: ratio.width * 10),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('exercises').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('오류 발생: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('기록이 없습니다.'));
          }

          final records = snapshot.data!.docs;

          final sortedRecords = records..sort((a, b) {
            final dateA = DateFormat("yyyy년 MM월 dd일 HH시 mm분").parse(a['end_time']);
            final dateB = DateFormat("yyyy년 MM월 dd일 HH시 mm분").parse(b['end_time']);
            return _sortOrder == '최신순' ? dateB.compareTo(dateA) : dateA.compareTo(dateB);
          });

          return Padding(
            padding: const EdgeInsets.only(top: 30),
            child: ListView.builder(
              itemCount: sortedRecords.length,
              itemBuilder: (context, index) {
                final record = sortedRecords[index].data() as Map<String, dynamic>;
                final startTime = record['start_time'] as String;
                final endTime = record['end_time'] as String?;
                final duration = record['duration'] as String;
                final isGoalAchieved = record['is_goal_achieved'] as bool? ?? false;

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
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
                        )
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("운동 기록 ${index + 1}",
                              style: TextStyle(
                                fontSize: ratio.height * 18,
                                fontWeight: FontWeight.bold,
                                color: CheckBikeColor.grey3,
                              )),
                          Text("시작 시간: $startTime",
                              style: TextStyle(
                                fontSize: ratio.height * 15,
                                color: CheckBikeColor.grey3,
                              )),
                          Text("종료 시간: $endTime",
                              style: TextStyle(
                                fontSize: ratio.height * 15,
                                color: CheckBikeColor.grey3,
                              )),
                          Divider(),
                          Text("운동 시간: $duration",
                              style: TextStyle(
                                fontSize: ratio.height * 18,
                                fontWeight: FontWeight.bold,
                                color: CheckBikeColor.mainBlue,
                              )),
                          SizedBox(height: ratio.height * 10),
                          Row(
                            children: [
                              Icon(
                                isGoalAchieved ? Icons.check_circle : Icons.cancel,
                                color: isGoalAchieved ? Colors.green : Colors.red,
                              ),
                              SizedBox(width: ratio.width * 10),
                              Text(
                                isGoalAchieved ? "달성 성공" : "달성 실패",
                                style: TextStyle(
                                  fontSize: 16,
                                  color: isGoalAchieved ? Colors.green : Colors.red,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
