import 'package:flutter/material.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'home_screen.dart';

void main() {
  tz.initializeTimeZones();
  runApp(const LocationTapperApp());
}

class LocationTapperApp extends StatelessWidget {
  const LocationTapperApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Location Tapper',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}
