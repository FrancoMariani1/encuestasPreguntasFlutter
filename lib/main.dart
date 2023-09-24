import 'package:flutter/material.dart';
import 'package:trabajo_final/ui/screens/survey_screen.dart';
import 'database/database.dart';

void main() async {
  final DatabaseHelper dbHelper = DatabaseHelper();
  await dbHelper.connect();
  runApp(MyApp(dbHelper: dbHelper));
}

class MyApp extends StatelessWidget {
  final DatabaseHelper dbHelper;

  MyApp({required this.dbHelper});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: SurveyApp(dbHelper: dbHelper),
    );
  }
}
