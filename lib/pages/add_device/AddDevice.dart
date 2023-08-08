import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class AddDevice extends StatefulWidget {
  const AddDevice({super.key});

  @override
  State<AddDevice> createState() => _AddDeviceState();
}
class _AddDeviceState extends State<AddDevice> {
  List<String> flattenedList = [];
  late IO.Socket socket;

  @override
  void initState() {
    super.initState();

    socket = IO.io('http://192.168.1.139:5000', <String, dynamic>{
      'transports': ['websocket'],
    });
    socket.onConnect(_handleOnConnect);
    socket.on('get_child_list_result', _handleChildListResult);
  }

  _handleOnConnect(_) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? email = prefs.getString('email');

    if (email != null) {
      socket.emit('get_child_list', jsonEncode({'email': email}));
    }
  }

  _handleChildListResult(dynamic message) {
    if (message['status']) {
      try {
        List<dynamic> childList = message['message'];
        List<String> newFlattenedList = childList.expand((element) => element).cast<String>().toList();

        setState(() {
          flattenedList = newFlattenedList;
        });
      } catch (error) {
        print('Error parsing JSON: $error');
      }
    }
  }

  @override
  void dispose() {
    socket.dispose();  // Close the socket connection
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("My Devices"),
      ),
      body: ListView.builder(
          itemCount: flattenedList.length,
          itemBuilder: (context, index) {
            return ListTile(
              title: Text(flattenedList[index]),
            );
          }
      ),
      floatingActionButton: FloatingActionButton.extended(
        label: Text('Add Child'),
        icon: Icon(Icons.add_reaction),
        onPressed: () {},
      ),
    );
  }
}
