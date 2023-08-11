import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:myprojectflutter/pages/add_device/AddDevice.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class ListDevice extends StatefulWidget {
  const ListDevice({super.key});

  @override
  State<ListDevice> createState() => _ListDeviceState();
}
class _ListDeviceState extends State<ListDevice> {
  NavigationDestinationLabelBehavior labelBehavior = NavigationDestinationLabelBehavior.alwaysShow;
  int currentPageIndex = 0;
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


  @override
  void dispose() {
    socket.dispose();  // Close the socket connection
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 4,
        shadowColor: Theme.of(context).shadowColor,
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
        label: const Text('Add Child'),
        icon: const Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddDevice()),
          );
        },
      ),
      bottomNavigationBar: NavigationBar(
        labelBehavior: labelBehavior,
        selectedIndex: currentPageIndex,
        onDestinationSelected: (int index) {
          setState(() {
            currentPageIndex = index;
          });
        },
        destinations: const <Widget>[
          NavigationDestination(
            selectedIcon: Icon(Icons.home_filled),
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.account_tree_rounded),
            icon: Icon(Icons.account_tree_outlined),
            label: 'Features',
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.location_on),
            icon: Icon(Icons.location_on_outlined),
            label: 'Location',
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.account_circle),
            icon: Icon(Icons.account_circle_outlined),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
