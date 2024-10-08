import 'package:check_bike/widget/tab_widget.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'firebase_options.dart';

late Size ratio;

final FlutterLocalNotificationsPlugin _local = FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await initializeDateFormatting();
  tz.initializeTimeZones();

  runApp(const MyApp());
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    ratio = Size(MediaQuery.sizeOf(context).width / 412, MediaQuery.sizeOf(context).height / 892);
    return MaterialApp(
            theme: ThemeData(
              fontFamily: "Pretendard",
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
            ),

            debugShowCheckedModeBanner: false,
      home: RootTab(),
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(boldText: false, textScaler: TextScaler.linear(1.0)),
        child: child!,
      ),
    );
  }
}
