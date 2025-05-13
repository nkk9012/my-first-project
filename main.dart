import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'settings.dart';
import 'loginR.dart';
import 'settings.dart';
import 'profile.dart';
import 'register_screen.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'alarm.dart';
import 'parents.dart';
import 'me.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase 초기화
  await Firebase.initializeApp();
  tz.initializeTimeZones(); // 시간대 초기화
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      locale: const Locale('ko', 'KR'), // 한국어 언어 설정
      title: '내 앱',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const Settings(), // 첫 화면
    );
  }
}
