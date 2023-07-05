import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:myprojectflutter/pages/activities/HomeScreen.dart';
import 'package:myprojectflutter/pages/register/RegisterScreen.dart';

class ConfirmEmailScreen extends StatefulWidget {
  const ConfirmEmailScreen({Key? key, required this.email_txt}) : super(key: key);
  final String email_txt;
  @override
  State<ConfirmEmailScreen> createState() => _ConfirmEmailScreenState();
}

class _ConfirmEmailScreenState extends State<ConfirmEmailScreen> {
  late final String email;
  final TextEditingController _emailConfirmController = TextEditingController();

  bool _isLoading = false;

  @override
  void dispose() {
    _emailConfirmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Login Page"),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(top: 60.0),
              child: Center(
                child: SizedBox(
                    width: 200,
                    height: 150,
                    /*decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(50.0)),*/
                    child: Image.asset('assets/images/bigLogo.png')),
              ),
            ),
            Padding(
              //padding: const EdgeInsets.only(left:15.0,right: 15.0,top:0,bottom: 0),
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
              child: TextField(
                controller: _emailConfirmController,
                decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    labelText: 'Code sent to ${widget.email_txt}',
                    hintText: 'Confirmation Code'),
              ),
            ),
            SizedBox(
              height: 50,
              width: 250,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                      context, MaterialPageRoute(builder: (_) => const HomeScreen()));
                },
                child: const Text(
                  'Login',
                  style: TextStyle(color: Colors.white, fontSize: 25),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
