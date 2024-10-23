import 'package:attendence_app/Constants.dart';
import 'package:attendence_app/Screens/NewUserScreen.dart';
import 'package:attendence_app/models/User.dart';
import 'package:attendence_app/utilities/authScreens.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import '../widgets/search_text_field.dart';
import '../widgets/search_list_view.dart';
import '../widgets/default_list_view.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<bool> _selections = List.generate(1, (_) => false);
  bool _searchBoolean = false;



  List<int> _searchIndexList = [];

  List<User> _users = []; // List to hold the fetched users
  bool _isLoading = true; // Loading state

  @override
  void initState() {
    super.initState();
    fetchUsers(); // Call fetchUsers in initState
  }

  Future<void> fetchUsers() async {
    try {
      // Reference to the users collection
      CollectionReference usersCollection = firestore.collection(Constants.userCollections);

      // Get the collection snapshot
      QuerySnapshot querySnapshot = await usersCollection.get();

      // Map the documents to User objects
      List<User> userList = querySnapshot.docs.map((doc) {
        return User.fromMap(doc.data() as Map<String, dynamic>); // Convert each document to a User object
      }).toList();

      // Sort the list by createdAt date in descending order
      User.sortByCreatedAtDesc(userList);

      // Update state
      setState(() {
        _users = userList; // Update the users list
        _isLoading = false; // Set loading to false
      });
    } catch (error) {
      print("Error fetching users: $error");
      setState(() {
        _isLoading = false; // Set loading to false even if there's an error
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: !_searchBoolean
            ? const Text('Attendance App Home Page')
            : SearchTextField(onChanged: (s) {
          setState(() {
            _searchIndexList = [];
            for (int i = 0; i < _users.length; i++) {
              if (_users[i].name.contains(s)) {
                _searchIndexList.add(i);
              }
            }
          });
        }),
        actions: !_searchBoolean
            ? [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.amberAccent),
            onPressed: () {
              setState(() {
                _searchBoolean = true;
                _searchIndexList = [];
              });
            },
          ),
          IconButton(onPressed: ()async {
            await AuthScreens.signOut(context); // Call the sign-out method
          }, icon: const Icon(Icons.logout, color: Colors.amberAccent,))
        ]
            : [
          IconButton(
            icon: const Icon(Icons.clear, color: Colors.amberAccent),
            onPressed: () {
              setState(() {
                _searchBoolean = false;
              });
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.amberAccent,
        foregroundColor: Colors.black,
        child: const Icon(Icons.person_add_alt_1),
        onPressed: () {
          _navigateAndDisplayInput(context);
        },
      ),
      body: _isLoading? const Center(child: CircularProgressIndicator())
          :!_searchBoolean
          ? DefaultListView(
        students: _users,
        selections: _selections,
        onToggle: (index) {
          setState(() {
            _selections[index] = !_selections[index];
            var box2 = Hive.box('box2');
            box2.put("toggle", _selections[index] ? 1 : 0);
          });
        },
      )
          : SearchListView(searchIndexList: _searchIndexList, students: _users),
    );
  }

  Future<void> _navigateAndDisplayInput(BuildContext context) async {
    await Navigator.push(context,
      MaterialPageRoute(builder: (context) => const AddUsersScreen()),
    );

    if (!mounted) {
      return;
    }

    setState(() {
      fetchUsers();
    });
  }
}
