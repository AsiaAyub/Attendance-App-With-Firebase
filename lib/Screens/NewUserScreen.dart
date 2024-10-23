import 'dart:io';
import 'package:attendence_app/Constants.dart';
import 'package:attendence_app/utilities/global_widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart'; // For file extension handling

final FirebaseFirestore firestore = FirebaseFirestore.instance;

// screen for adding new users
class AddUsersScreen extends StatefulWidget {
  const AddUsersScreen({super.key});

  @override
  State<AddUsersScreen> createState() => _AddUsersScreenState();
}

class _AddUsersScreenState extends State<AddUsersScreen> {
  final FirebaseStorage storage = FirebaseStorage.instance;

  // initialise all text controller for text-fields
  TextEditingController nameController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController dateController = TextEditingController();

  late Future<String?> imageUrl;

  // State variable for loading
  bool _isLoading = false;

  Future<String?> uploadImage(File imageFile, String userId) async {
    String fileExtension = extension(imageFile.path);
    String uniqueFileName = '$userId$fileExtension';

    File file = File(imageFile.path);
    try {
      // Create a reference to the location you want to upload to
      Reference ref = storage.ref().child('images/$uniqueFileName');

      UploadTask uploadTask = ref.putFile(imageFile);

      // Wait for the upload to complete
      await uploadTask.whenComplete(() => null);

      // Get the download URL
      String downloadUrl = await ref.getDownloadURL();
      // Store the URL in Firestore (or Realtime Database)
      await firestore.collection('users').doc(userId).set({
        'imageUrl': downloadUrl,
      }, SetOptions(merge: true));
      return downloadUrl; // Return the URL
    } catch (e) {
      print('Error uploading image: $e');
    }
    return null;
  }

  Future<void> addUser(String name, String phone, DateTime date) async {
    CollectionReference users = firestore.collection(Constants.userCollections);

    try {
      DocumentReference docRef = await users.add({
        Constants.name: name,
        Constants.phone: phone,
        Constants.registeredDate: date,
        Constants.createdAt: DateTime.now(),
      });
      print("User Added with ID: ${docRef.id}"); // access the auto-generated ID

      if (_selectedImage != null) {
        String? imageUrl = await uploadImage(_selectedImage!, docRef.id);
      }
    } catch (error) {
      print("Failed to add user: $error");
      rethrow; // Modified: Propagate the error up if needed
    }
  }

  @override
  void initState() {
    nameController.text = ""; //set the initial value of text field
    phoneController.text = "";
    dateController.text = "";
    super.initState();
  }

  // Add this variable to store the image picked by the user
  File? _selectedImage;

  // Function to handle image picking
  Future<void> _pickImage(BuildContext context) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.camera);

    if (image != null) {
      setState(() {
        _selectedImage = File(image.path); // Store the selected image
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No image selected')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New User Information'),
      ),
      body: SingleChildScrollView(
        child: Container(
          height: 550,
          padding: const EdgeInsets.all(20),
          margin: const EdgeInsets.fromLTRB(25, 30, 25, 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20.0),
            color: Colors.black87,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Padding(
                padding: EdgeInsets.all(17),
                child: Text(
                  'Add New User',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),

              // Circular image with '+' icon for uploading an image
              Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundImage: _selectedImage != null
                          ? FileImage(_selectedImage!) // If an image is selected, show it
                          : const AssetImage('assets/images/profilepic.jpg')
                      as ImageProvider, // Show a default image if none is selected
                      backgroundColor: Colors.grey[300],
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: InkWell(
                        onTap: () => _pickImage(context), // Trigger image picking
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.amberAccent,
                            border: Border.all(
                              color: Colors.white,
                              width: 2,
                            ),
                          ),
                          child: const Icon(
                            Icons.add,
                            size: 20,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
                child: TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.amberAccent),
                    ),
                    labelText: 'name',
                    labelStyle: TextStyle(color: Colors.amberAccent),
                    hintText: 'Enter user Name',
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                child: TextField(
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  controller: phoneController,
                  decoration: const InputDecoration(
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.amberAccent),
                    ),
                    labelText: 'phone Number',
                    labelStyle: TextStyle(color: Colors.amberAccent),
                    hintText: 'Enter User Phone Number',

                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                child: TextField(
                  controller: dateController,
                  decoration: const InputDecoration(
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.amberAccent),
                    ),
                    labelText: 'checking Date',
                    labelStyle: TextStyle(color: Colors.amberAccent),
                  ),
                  readOnly: true, //set it true, so that user will not able to edit text
                  onTap: () async {
                    // take the date from the calendar
                    DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime.now(),
                    );

                    DateTime finalDateTime = DateTime.now();

                    if (pickedDate != null) {
                      // Step 2: Select Time
                      TimeOfDay? pickedTime = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.now(),
                      );

                      if (pickedTime != null) {
                        // Step 3: Combine the picked date and time into a single DateTime object
                        finalDateTime = DateTime(
                          pickedDate.year,
                          pickedDate.month,
                          pickedDate.day,
                          pickedTime.hour,
                          pickedTime.minute,
                          0,
                        );
                      }
                    }

                    String formattedDate = DateFormat('yyyy-MM-dd HH:mm:ss')
                        .format(finalDateTime);
                    setState(() {
                      dateController.text =
                          formattedDate; //set output date to TextField value.
                    });
                  },
                ),
              ),
              const SizedBox(
                height: 20,
              ),

              // Button to add user
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amberAccent,
                    foregroundColor: Colors.black,
                    disabledBackgroundColor: Colors.white38,
                    disabledForegroundColor: Colors.black,
                  ),
                  onPressed: _isLoading // Disable button if loading
                      ? null
                      : () async {
                    //set the initial value of text field
                    String name = nameController.text;
                    String phone = phoneController.text;

                    // Validate the input
                    if (name.isNotEmpty &&
                        phone.isNotEmpty &&
                        dateController.text.isNotEmpty) {
                      setState(() {
                        _isLoading = true; // Start loading
                      });

                      DateTime date = DateTime.parse(dateController.text);
                      await addUser(name, phone, date); // Call your addUser function



                      // Clear the input after adding
                      nameController.clear();
                      phoneController.clear();
                      dateController.clear();

                      // Close the screen.
                      Navigator.pop(context);
                      GlobalWidgets(context).showSnackBar(
                        content: 'You have successfully added a user',
                        backgroundColor: Colors.amberAccent,
                      );
                    } else {
                      // Modified: Show error if fields are empty
                      GlobalWidgets(context).showSnackBar(
                        content: 'Please fill in all fields',
                        backgroundColor: Colors.red,
                      );
                    }

                    setState(() {
                      _isLoading = false; // Stop loading
                    });
                  },
                  child: _isLoading // Show loading indicator
                      ? const Text('Adding Please wait ...')
                      : const Text('Add to Users'),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
