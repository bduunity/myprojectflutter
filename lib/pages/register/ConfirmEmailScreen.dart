import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:myprojectflutter/pages/activities/HomeScreen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class ConfirmEmailScreen extends StatefulWidget {
  const ConfirmEmailScreen({Key? key, required this.email_txt, required this.password_txt}) : super(key: key);
  final String email_txt, password_txt;
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
                  final emailConfirm = _emailConfirmController.text;
                  if (emailConfirm.isEmpty) {
                    Fluttertoast.showToast(
                      msg: "Please fill all the fields!",
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.BOTTOM,
                      timeInSecForIosWeb: 1,
                      backgroundColor: Colors.red,
                      textColor: Colors.white,
                    );
                    return;
                  } else{
                    IO.Socket socket = IO.io('http://192.168.1.139:5000', <String, dynamic>{
                      'transports': ['websocket'],
                    });
                    socket.emit('email_confirm', jsonEncode({'email_code': emailConfirm, 'email': email}));

                    socket.on('email_confirm_response', (message) async {
                      try {
                        Fluttertoast.showToast(
                          msg: message['message'],
                          toastLength: Toast.LENGTH_SHORT,
                          gravity: ToastGravity.BOTTOM,
                          timeInSecForIosWeb: 1,
                          backgroundColor: Colors.red,
                          textColor: Colors.white,
                        );
                        setState(() {
                          _isLoading = false;
                        });

                        if(message['message'] == "Confirm your Email!"){
                          SharedPreferences prefs = await SharedPreferences.getInstance();
                          prefs.setString('email', email);
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => ConfirmEmailScreen(email_txt: email, password_txt: password)),
                          );
                        }
                      } catch (error) {
                        print('Error parsing JSON: $error');
                      }
                    });
                  }
                  Navigator.push(
                      context, MaterialPageRoute(builder: (_) => const HomeScreen()));
                },
                child: const Text(
                  'Confirm',
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
