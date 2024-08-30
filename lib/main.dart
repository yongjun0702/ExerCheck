import 'package:check_bike/screen/home_screen.dart';
import 'package:check_bike/widget/tab_widget.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

late Size ratio;


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
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
            home: RootTab()
    );
  }
}
