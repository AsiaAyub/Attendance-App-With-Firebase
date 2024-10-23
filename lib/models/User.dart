import 'package:attendence_app/Constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  String uid;
  String name;
  int phone_number;
  DateTime checking;
  DateTime createdAt;
  String imageUrl;

  User(this.uid, this.name, this.phone_number, this.checking, this.createdAt, this.imageUrl);

  // Override the toString method
  @override
  String toString() {
    return 'User (Id: $uid, name: $name, phone_number: $phone_number, checking: $checking, createdAt: $createdAt, '
        'imageUrl: $imageUrl)';
  }

  // Method to create a User from Firestore data
  factory User.fromMap(Map<String, dynamic> data) {
    return User(
      data[Constants.uid] ?? '',
      data[Constants.name] ?? '', // Default to empty string if name is null
      int.tryParse(data[Constants.phone]) ?? 0, // Default to 0 if phone is null
      (data[Constants.registeredDate] as Timestamp).toDate(),
        (data[Constants.createdAt] as Timestamp).toDate(),// Convert Firestore Timestamp to DateTime
      data[Constants.imageUrl] ?? ''
    );
  }


  // Function to sort a list of users by createdAt in descending order
  static void sortByCreatedAtDesc(List<User> users) {
    users.sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }
}
