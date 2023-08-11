import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:myprojectflutter/pages/add_device/ListDevice.dart';
import 'package:myprojectflutter/pages/register/ConfirmEmailScreen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'dart:convert';

class AddDevice extends StatefulWidget {
  const AddDevice({Key? key}) : super(key: key);

  @override
  State<AddDevice> createState() => _AddDeviceState();
}

class _AddDeviceState extends State<AddDevice> {

  final TextEditingController _chCodeController = TextEditingController();

  bool _isLoading = false;

  bool isValidEmail(String code) {
    final RegExp regex = RegExp(
        r"^[0-9]+$"
    );

    return regex.hasMatch(code);
  }


  @override
  void dispose() {
    _chCodeController.dispose();
    super.dispose();
  }

  Future<bool> checkInternetConnectivity() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile ||
        connectivityResult == ConnectivityResult.wifi) {
      return true;
    } else {
      return false;
    }
  }


  @override
  Widget build(BuildContext context) {

    IO.Socket socket = IO.io('http://192.168.1.139:5000', <String, dynamic>{
      'transports': ['websocket'],
    });

    socket.onConnect((_) {
      print('Connected to the server');
      // socket.emit('my event', jsonEncode({'data': 'Welcome!'}));
    });

    return  Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 4,
        title: const Text("Add Device"),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
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
                  padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                  child: TextField(
                    controller: _chCodeController,
                    decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Code',
                        hintText: 'Enter chils code'),
                  ),
                ),
                SizedBox(
                  height: 50,
                  width: 250,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.blue,
                    ),
                    onPressed: () async {
                      final code = _chCodeController.text;

                      if (!isValidEmail(code)){
                        Fluttertoast.showToast(
                          msg: "Only numbers!",
                          toastLength: Toast.LENGTH_SHORT,
                          gravity: ToastGravity.BOTTOM,
                          timeInSecForIosWeb: 1,
                          backgroundColor: Colors.red,
                          textColor: Colors.white,
                        );
                        return;
                      }

                      if (code.isEmpty) {
                        Fluttertoast.showToast(
                          msg: "Please fill the field!",
                          toastLength: Toast.LENGTH_SHORT,
                          gravity: ToastGravity.BOTTOM,
                          timeInSecForIosWeb: 1,
                          backgroundColor: Colors.red,
                          textColor: Colors.white,
                        );
                        return;
                      }

                      setState(() {
                        _isLoading = true;
                      });

                      if ((await checkInternetConnectivity()) == false){
                        Fluttertoast.showToast(
                          msg: "NO INTERNET CONNECTION!",
                          toastLength: Toast.LENGTH_SHORT,
                          gravity: ToastGravity.BOTTOM,
                          timeInSecForIosWeb: 1,
                          backgroundColor: Colors.red,
                          textColor: Colors.white,
                        );


                        setState(() {
                          _isLoading = false;
                        });
                      } else{
                        SharedPreferences prefs = await SharedPreferences.getInstance();
                        String? email = prefs.getString('email');
                        socket.emit('add_child', jsonEncode({'code': code, 'email': email}));
                        socket.on('add_child_response', (message) async {
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

                            if(message['status']){
                              Navigator.pop(context);                            }
                          } catch (error) {
                            print('Error parsing JSON: $error');
                          }
                        });
                      }
                    },
                    child: const Text(
                      'ADD',
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}
