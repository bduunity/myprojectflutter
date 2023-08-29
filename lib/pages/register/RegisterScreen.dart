import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:myprojectflutter/config.dart';
import 'package:myprojectflutter/pages/register/ConfirmEmailScreen.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'dart:convert';

class RegisterScreenHelper extends StatefulWidget {
  const RegisterScreenHelper({Key? key}) : super(key: key);

  @override
  State<RegisterScreenHelper> createState() => _RegisterScreenHelperState();
}

class _RegisterScreenHelperState extends State<RegisterScreenHelper> {

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  bool _isLoading = false;

  bool isValidEmail(String email) {
    final RegExp regex = RegExp(
        r"^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+"
    );

    return regex.hasMatch(email);
  }


  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
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
    IO.Socket socket = IO.io(Configs.server_ip, <String, dynamic>{
      'transports': ['websocket'],
    });

    socket.onConnect((_) {
      print('Connected to the server');
      // socket.emit('my event', jsonEncode({'data': 'Welcome!'}));
    });

    socket.on('message', (message) {
      try {
        print(message['message']);
        Fluttertoast.showToast(
          msg: message['message'],
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
      } catch (error) {
        print('Error parsing JSON: $error');
      }
    });


    return  Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 4,
        title: const Text("User Registration"),
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
                    controller: _emailController,
                    decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Email',
                        hintText: 'Enter valid email id as abc@gmail.com'),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                      left: 15.0, right: 15.0, top: 15, bottom: 15),
                  child: TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Password',
                        hintText: 'Enter secure password'),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                      left: 15.0, right: 15.0, top: 15, bottom: 40),
                  child: TextField(
                    controller: _confirmPasswordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Confirm Password',
                        hintText: 'Confirm secure password'),
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
                      final email = _emailController.text;

                      if (!isValidEmail(email)){
                        Fluttertoast.showToast(
                          msg: "Email incorrect!",
                          toastLength: Toast.LENGTH_SHORT,
                          gravity: ToastGravity.BOTTOM,
                          timeInSecForIosWeb: 1,
                          backgroundColor: Colors.red,
                          textColor: Colors.white,
                        );
                        return;
                      }
                      final password = _passwordController.text;
                      final confirmPassword = _confirmPasswordController.text;

                      if(password.length < 6) {
                        Fluttertoast.showToast(
                          msg: "Password is less than 6 characters",
                          toastLength: Toast.LENGTH_SHORT,
                          gravity: ToastGravity.BOTTOM,
                          timeInSecForIosWeb: 1,
                          backgroundColor: Colors.red,
                          textColor: Colors.white,
                        );
                        return;
                      }

                      if (email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
                        Fluttertoast.showToast(
                          msg: "Please fill all the fields!",
                          toastLength: Toast.LENGTH_SHORT,
                          gravity: ToastGravity.BOTTOM,
                          timeInSecForIosWeb: 1,
                          backgroundColor: Colors.red,
                          textColor: Colors.white,
                        );
                        return;
                      }

                      if (password != confirmPassword) {
                        Fluttertoast.showToast(
                          msg: "Passwords not equal!",
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
                        socket.emit('register', jsonEncode({'email': email, 'password': password}));
                        socket.on('register_response', (message) async {
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
                    },
                    child: const Text(
                      'Register',
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
