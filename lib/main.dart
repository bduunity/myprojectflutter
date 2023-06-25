import 'package:flutter/material.dart';
import 'package:myprojectflutter/pages/activities/HomeScreen.dart';
import 'package:myprojectflutter/pages/register/LoginScreen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Future<bool> checkFirstStart() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool? firstStartValue = prefs.getBool('firstStart');
    firstStartValue ??= false;
    if(firstStartValue) {
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: checkFirstStart(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final bool firstStartValue = snapshot.data!;
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Flutter Sample Activity',
            theme: ThemeData(
              // useMaterial3: true,
              colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.blue),
            ),
            home: firstStartValue ? const HomeScreen() : const LoginScreenHelper(),
          );
        } else {
          // Handle loading state if needed
          return CircularProgressIndicator();
        }
      },
    );
  }

}

