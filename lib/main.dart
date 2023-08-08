import 'package:flutter/material.dart';
import 'package:myprojectflutter/pages/activities/HomeScreen.dart';
import 'package:myprojectflutter/pages/add_device/ListDevice.dart';
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
    print("hello");
    return FutureBuilder<bool>(
      future: checkFirstStart(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final bool firstStartValue = snapshot.data!;
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Flutter Sample Activity',
            theme: ThemeData(
              useMaterial3: true,
                colorSchemeSeed: Colors.blue[700]
            ),
            home: firstStartValue ? const AddDevice() : const LoginScreenHelper(),
          );
        } else {
          // Handle loading state if needed
          return CircularProgressIndicator();
        }
      },
    );
  }

}

